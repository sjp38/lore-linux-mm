Date: Tue, 9 Oct 2007 22:20:25 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <Pine.LNX.4.64.0710100424050.24074@blonde.wat.veritas.com>
Message-ID: <alpine.LFD.0.999.0710092202000.3838@woody.linux-foundation.org>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <200710091931.51564.nickpiggin@yahoo.com.au>
 <alpine.LFD.0.999.0710091917410.3838@woody.linux-foundation.org>
 <200710092015.07741.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0710100424050.24074@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 10 Oct 2007, Hugh Dickins wrote:

> On Tue, 9 Oct 2007, Nick Piggin wrote:
> > by it ;) To prove my point: the *first* approach I posted to fix this
> > problem was exactly a patch to special-case the zero_page refcounting
> > which was removed with my PageReserved patch. Neither Hugh nor yourself
> > liked it one bit!
> 
> True (speaking for me; I forget whether Linus ever got to see it).

The problem is, those first "remove ref-counting" patches were ugly 
*regardless* of ZERO_PAGE.

We (yes, largely I) fixed up the mess since. The whole vm_normal_page() 
and the magic PFN_REMAP thing got rid of a lot of the problems.

And I bet that we could do something very similar wrt the zero page too.

Basically, the ZERO page could act pretty much exactly like a PFN_REMAP 
page: the VM would not touch it. No rmap, no page refcounting, no nothing.

This following patch is not meant to be even half-way correct (it's not 
even _remotely_ tested), but is just meant to be a rough "grep for 
ZERO_PAGE in the VM, and see what happens if you don't ref-count it".

Would something like the below work? I dunno. But I suspect it would. I 
doubt anybody has the energy to actually try to actually follow through on 
it, which is why I'm not pushing on it any more, and why I'll accept 
Nick's patch to just remove ZERO_PAGE, but I really *am* very unhappy 
about this.

The "page refcounting cleanups" in the VM back when were really painful. 
And dammit, I felt like I was the one who had to clean them up after you 
guys. Which makes me really testy on this subject.

And yes, I also admit that the vm_normal_page() and the PFN_REMAP thing 
ended up really improving the VM, and we're pretty much certainly better 
off now than we were before - but I also think that ZERO_PAGE etc could 
easily be handled with the same model. After all, if we can make 
"mmap(/dev/mem)" work with COW and everything, I'd argue that ZERO_PAGE 
really is just a very very small special case of that!

Totally half-assed untested patch to follow, not meant for anything but a 
"I think this kind of approach should have worked too" comment.

So I'm not pushing the patch below, I'm just fighting for people realizing 
that

 - the kernel has *always* (since pretty much day 1) done that ZERO_PAGE 
   thing. This means that I would not be at all surprised if some 
   application basically depends on it. I've written test-programs that 
   depends on it - maybe people have written other code that basically has 
   been written for and tested with a kernel that has basically always 
   made read-only zero pages extra cheap.

   So while it may be true that removing ZERO_PAGE won't affect anybody, I 
   don't think it's a given, and I also don't think it's sane calling 
   people "crazy" for depending on something that has always been true 
   under Linux for the last 15+ years. There are few behaviors that have 
   been around for that long.

 - make sure the commit message is accurate as to need for this (ie not 
   claim that the ZERO_PAGE itself was the problem, and give some actual 
   performance numbers on what is going on)

that's all.

		Linus

---
 mm/memory.c  |   17 ++++++++---------
 mm/migrate.c |    2 +-
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index f82b359..0a8cc88 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -386,6 +386,7 @@ static inline int is_cow_mapping(unsigned int flags)
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
 	unsigned long pfn = pte_pfn(pte);
+	struct page *page;
 
 	if (unlikely(vma->vm_flags & VM_PFNMAP)) {
 		unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
@@ -413,7 +414,11 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_
 	 * The PAGE_ZERO() pages and various VDSO mappings can
 	 * cause them to exist.
 	 */
-	return pfn_to_page(pfn);
+	page = pfn_to_page(pfn);
+	if (PageReserved(page))
+		page = NULL;
+
+	return page;
 }
 
 /*
@@ -968,7 +973,7 @@ no_page_table:
 	if (flags & FOLL_ANON) {
 		page = ZERO_PAGE(address);
 		if (flags & FOLL_GET)
-			get_page(page);
+			page = alloc_page(GFP_KERNEL | GFP_ZERO);
 		BUG_ON(flags & FOLL_WRITE);
 	}
 	return page;
@@ -1131,9 +1136,6 @@ static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
 			pte++;
 			break;
 		}
-		page_cache_get(page);
-		page_add_file_rmap(page);
-		inc_mm_counter(mm, file_rss);
 		set_pte_at(mm, addr, pte, zero_pte);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
@@ -1717,7 +1719,7 @@ gotten:
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	if (old_page == ZERO_PAGE(address)) {
+	if (!old_page) {
 		new_page = alloc_zeroed_user_highpage_movable(vma, address);
 		if (!new_page)
 			goto oom;
@@ -2274,15 +2276,12 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
 		page = ZERO_PAGE(address);
-		page_cache_get(page);
 		entry = mk_pte(page, vma->vm_page_prot);
 
 		ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
 		if (!pte_none(*page_table))
 			goto release;
-		inc_mm_counter(mm, file_rss);
-		page_add_file_rmap(page);
 	}
 
 	set_pte_at(mm, address, page_table, entry);
diff --git a/mm/migrate.c b/mm/migrate.c
index e2fdbce..8d2e110 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -827,7 +827,7 @@ static int do_move_pages(struct mm_struct *mm, struct page_to_node *pm,
 			goto set_status;
 
 		if (PageReserved(page))		/* Check for zero page */
-			goto put_and_set;
+			goto set_status;
 
 		pp->page = page;
 		err = page_to_nid(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

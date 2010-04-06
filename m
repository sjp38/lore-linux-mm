Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E32E6B01EF
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 22:29:47 -0400 (EDT)
Date: Mon, 5 Apr 2010 19:23:44 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
References: <patchbomb.1270168887@v2.random> <20100405120906.0abe8e58.akpm@linux-foundation.org> <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>



On Mon, 5 Apr 2010, Linus Torvalds wrote:
> 
> So I thought it was a more interesting load than it was. The 
> virtualization "TLB miss is expensive" load I can't find it in myself to 
> care about. "Get a better CPU" is my answer to that one,

[ Btw, I do realize that "better CPU" in this case may be "future CPU". I 
  just think that this is where better TLB's and using ASID's etc is 
  likely to be a much bigger deal than adding VM complexity. Kind of the 
  same way I think HIGHMEM was ultimately a failure, and the 4G:4G split 
  was an atrocity that should have been killed ]

Anyway. Since the prefaulting wasn't the point, I'm killing the patch. But 
since I actually tested it, and then I made it work, here's something that 
I will hereby throw away, but maybe somebody else would like to play with. 
It still gets the memcg accounting wrong, but it actually does seem to 
boot for me.

And it just might make page faults cheaper. We avoid the whole "drop the 
ptl and re-take it" for the optimistic case, for example. So maybe it is 
worth looking at, even though the 6% thing wasn't here.

		Linus

---
 include/linux/gfp.h |    4 ++
 mm/memory.c         |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c      |    9 +++++
 3 files changed, 95 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4c6d413..1b94d09 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -84,6 +84,8 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
+#define GFP_USER_ORDER	(GFP_NOWAIT | __GFP_HARDWALL | __GFP_NOWARN | __GFP_NORETRY | \
+			 __GFP_HIGHMEM | __GFP_MOVABLE | __GFP_ZERO)
 #define GFP_IOFS	(__GFP_IO | __GFP_FS)
 
 #ifdef CONFIG_NUMA
@@ -306,10 +308,12 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 }
 extern struct page *alloc_page_vma(gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr);
+extern struct page *alloc_page_user_order(struct vm_area_struct *, unsigned long, int);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
 #define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
+#define alloc_page_user_order(vma, addr, order) alloc_pages(GFP_USER_ORDER, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 
diff --git a/mm/memory.c b/mm/memory.c
index 1d2ea39..b2d5025 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2742,6 +2742,83 @@ out_release:
 }
 
 /*
+ * See if we can optimistically fill eight pages at a time
+ */
+static spinlock_t *optimistic_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd)
+{
+	int i;
+	spinlock_t *ptl;
+	struct page *bigpage;
+
+	/* Don't even bother if it's not writable */
+	if (!(vma->vm_flags & VM_WRITE))
+		return NULL;
+
+	/*
+	 * The optimistic path doesn't want to drop the
+	 * page table map, so it can't allocate anon_vma's
+	 * etc.
+	 */
+	if (!vma->anon_vma)
+		return NULL;
+
+	/* Are we ok wrt the vma boundaries? */
+	if ((address & (PAGE_MASK << 3)) < vma->vm_start)
+		return NULL;
+	if ((address | ~(PAGE_MASK << 3)) > vma->vm_end)
+		return NULL;
+
+	/*
+	 * Round to a nice even 8-byte page boundary, and
+	 * optimistically (with no locking), check whether
+	 * it's all empty. Skip if we have it partly filled
+	 * in.
+	 *
+	 * 8 page table entries tends to be about a cacheline.
+	 */
+	page_table -= (address >> PAGE_SHIFT) & 7;
+	for (i = 0; i < 8; i++)
+		if (!pte_none(page_table[i]))
+			return NULL;
+
+	/* Allocate the eight pages in one go, no warning or retrying */
+	bigpage = alloc_page_user_order(vma, addr, 3);
+	if (!bigpage)
+		return NULL;
+
+	split_page(bigpage, 3);
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	address &= PAGE_MASK << 3;
+	for (i = 0; i < 8; i++) {
+		struct page *page = bigpage + i;
+
+		if (pte_none(page_table[i])) {
+			pte_t pte;
+
+			__SetPageUptodate(page);
+
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
+			page_add_new_anon_rmap(page, vma, address);
+
+			pte = mk_pte(page, vma->vm_page_prot);
+			pte = pte_mkwrite(pte_mkdirty(pte));
+			set_pte_at(mm, address, page_table+i, pte);
+		} else {
+			__free_page(page);
+		}
+		address += PAGE_SIZE;
+	}
+
+	/* The caller will unlock */
+	return ptl;
+}
+
+
+/*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
@@ -2754,6 +2831,10 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	pte_t entry;
 
+	ptl = optimistic_fault(mm, vma, address, page_table, pmd);
+	if (ptl)
+		goto update;
+
 	if (!(flags & FAULT_FLAG_WRITE)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
 						vma->vm_page_prot));
@@ -2790,6 +2871,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 setpte:
 	set_pte_at(mm, address, page_table, entry);
 
+update:
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, page_table);
 unlock:
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 08f40a2..55a92bd 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1707,6 +1707,15 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 	return __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
 }
 
+struct page *
+alloc_page_user_order(struct vm_area_struct *vma, unsigned long addr, int order)
+{
+	struct zonelist *zl = policy_zonelist(gfp, pol);
+	struct mempolicy *pol = get_vma_policy(current, vma, addr);
+
+	return __alloc_pages_nodemask(GFP_USER_ORDER, order, zl, pol);
+}
+
 /**
  * 	alloc_pages_current - Allocate pages.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

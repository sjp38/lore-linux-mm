Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBFEE6B01EE
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:14:03 -0400 (EDT)
Date: Mon, 5 Apr 2010 18:08:51 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [RFD] Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1004051747030.21411@i5.linux-foundation.org>
References: <patchbomb.1270168887@v2.random> <20100405120906.0abe8e58.akpm@linux-foundation.org> <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>



On Mon, 5 Apr 2010, Linus Torvalds wrote:
> 
> In particular, when you quote 6% improvement for a kernel compile, your 
> own numbers make [me] seriously wonder how many percentage points you'd get 
> from just faulting in 8 pages at a time when you have lots of memory free, 
> and use a single 3-order allocation to get those eight pages?

THIS PATCH IS TOTALLY UNTESTED!

It's very very unlikely to work, but it compiles for me at least in one 
particular configuration. So it must be perfect. Ship it.

It basically tries to just fill in anonymous memory PTE entries roughly 
one cacheline at a time, avoiding extra page-faults and extra memory 
allocations.

It's probably buggy as hell, I don't dare try to actually boot the crap I 
write. It literally started out as a pseudo-code patch that I then ended 
up expanding until it compiled and then fixed up some corner cases in. 

IOW, it's not really a serious patch, although when I look at it, it 
doesn't really look all that horrible.

Now, I'm pretty sure that allocating the page with a single order-3 
allocation, and then treating it as 8 individual order-0 pages is broken 
and probably makes various things unhappy. That "make_single_page()" 
monstrosity may or may not be sufficient.

In other words, what I'm trying to say is: treat this patch as a request 
for discussion, rather than something that necessarily _works_. 

			Linus

---
 include/linux/gfp.h |    3 ++
 mm/memory.c         |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c      |    9 ++++++
 3 files changed, 81 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4c6d413..2b8f42b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -84,6 +84,7 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
+#define GFP_USER_ORDER	(GFP_HIGHUSER_MOVABLE | __GFP_ZERO | __GFP_NOWARN | __GFP_NORETRY)
 #define GFP_IOFS	(__GFP_IO | __GFP_FS)
 
 #ifdef CONFIG_NUMA
@@ -306,10 +307,12 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
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
index 1d2ea39..7ad97cb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2741,6 +2741,71 @@ out_release:
 	return ret;
 }
 
+static inline void make_single_page(struct page *page)
+{
+	set_page_count(page, 1);
+	set_page_private(page, 0);
+}
+
+/*
+ * See if we can optimistically fill eight pages at a time
+ */
+static int optimistic_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd)
+{
+	int i;
+	spinlock_t *ptl;
+	struct page *bigpage;
+
+	/* Don't even bother if it's not writable */
+	if (!(vma->vm_flags & VM_WRITE))
+		return 0;
+
+	/* Are we ok wrt the vma boundaries? */
+	if ((address & (PAGE_MASK << 3)) < vma->vm_start)
+		return 0;
+	if ((address | ~(PAGE_MASK << 3)) > vma->vm_end)
+		return 0;
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
+			return 0;
+
+	/* Allocate the eight pages in one go, no warning or retrying */
+	bigpage = alloc_page_user_order(vma, addr, 3);
+	if (!bigpage)
+		return 0;
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	for (i = 0; i < 8; i++) {
+		struct page *page = bigpage + i;
+
+		make_single_page(page);
+		if (pte_none(page_table[i])) {
+			pte_t pte = mk_pte(page, vma->vm_page_prot);
+			pte = pte_mkwrite(pte_mkdirty(pte));
+			set_pte_at(mm, address, page_table+i, pte);
+		} else {
+			__free_page(page);
+		}
+	}
+
+	/* The caller will unlock */
+	return 1;
+}
+
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
@@ -2754,6 +2819,9 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	pte_t entry;
 
+	if (optimistic_fault(mm, vma, address, page_table, pmd))
+		goto update;
+
 	if (!(flags & FAULT_FLAG_WRITE)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
 						vma->vm_page_prot));
@@ -2790,6 +2858,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
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

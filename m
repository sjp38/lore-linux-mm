Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 113196B01F4
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 22:50:39 -0400 (EDT)
Date: Wed, 25 Aug 2010 10:54:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] HWPOISON, hugetlb: fix unpoison for hugepage
Message-ID: <20100825025432.GA15129@localhost>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1282694127-14609-8-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282694127-14609-8-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 07:55:26AM +0800, Naoya Horiguchi wrote:
> Currently unpoisoning hugepages doesn't work because it's not enough
> to just clear PG_HWPoison bits and we need to link the hugepage
> to be unpoisoned back to the free hugepage list.
> To do this, we get and put hwpoisoned hugepage whose refcount is 0.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
> ---
>  mm/memory-failure.c |   16 +++++++++++++---
>  1 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git v2.6.36-rc2/mm/memory-failure.c v2.6.36-rc2/mm/memory-failure.c
> index 60178d2..ab36690 100644
> --- v2.6.36-rc2/mm/memory-failure.c
> +++ v2.6.36-rc2/mm/memory-failure.c
> @@ -1154,9 +1154,19 @@ int unpoison_memory(unsigned long pfn)
>  	nr_pages = 1 << compound_order(page);
>  
>  	if (!get_page_unless_zero(page)) {
> -		if (TestClearPageHWPoison(p))
> +		/* The page to be unpoisoned was free one when hwpoisoned */
> +		if (TestClearPageHWPoison(page))
>  			atomic_long_sub(nr_pages, &mce_bad_pages);
>  		pr_debug("MCE: Software-unpoisoned free page %#lx\n", pfn);
> +		if (PageHuge(page)) {
> +			/*
> +			 * To unpoison free hugepage, we get and put it
> +			 * to move it back to the free list.
> +			 */
> +			get_page(page);
> +			clear_page_hwpoison_huge_page(page);
> +			put_page(page);
> +		}
>  		return 0;
>  	}

It's racy in free huge page detection.

alloc_huge_page() does not increase page refcount inside hugetlb_lock,
the alloc_huge_page()=>alloc_buddy_huge_page() path even drops the
lock temporarily! Then we never know reliably if a huge page is really
free.

Here is a scratched fix. It is totally untested. Just want to notice
you that with this patch, the huge page unpoisoning should go easier.

Thanks,
Fengguang

---
 include/linux/hugetlb.h |    4 +-
 mm/hugetlb.c            |   51 +++++++++++++++++---------------------
 mm/memory-failure.c     |   24 ++++++-----------
 3 files changed, 34 insertions(+), 45 deletions(-)

--- linux-next.orig/mm/hugetlb.c	2010-08-25 10:16:15.000000000 +0800
+++ linux-next/mm/hugetlb.c	2010-08-25 10:47:17.000000000 +0800
@@ -502,6 +502,7 @@ static struct page *dequeue_huge_page_vm
 			page = list_entry(h->hugepage_freelists[nid].next,
 					  struct page, lru);
 			list_del(&page->lru);
+			set_page_refcounted(page);
 			h->free_huge_pages--;
 			h->free_huge_pages_node[nid]--;
 
@@ -822,12 +823,6 @@ static struct page *alloc_buddy_huge_pag
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
-		/*
-		 * This page is now managed by the hugetlb allocator and has
-		 * no users -- drop the buddy allocator's reference.
-		 */
-		put_page_testzero(page);
-		VM_BUG_ON(page_count(page));
 		nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
 		/*
@@ -877,8 +872,6 @@ retry:
 			 * satisfy the entire reservation so we free what
 			 * we've allocated so far.
 			 */
-			spin_lock(&hugetlb_lock);
-			needed = 0;
 			goto free;
 		}
 
@@ -904,33 +897,28 @@ retry:
 	 * process from stealing the pages as they are added to the pool but
 	 * before they are reserved.
 	 */
-	needed += allocated;
 	h->resv_huge_pages += delta;
 	ret = 0;
-free:
+
 	/* Free the needed pages to the hugetlb pool */
 	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
-		if ((--needed) < 0)
-			break;
 		list_del(&page->lru);
+		/*
+		 * This page is now managed by the hugetlb allocator and has
+		 * no users -- drop the buddy allocator's reference.
+		 */
+		put_page_testzero(page);
+		VM_BUG_ON(page_count(page));
 		enqueue_huge_page(h, page);
 	}
-
+	spin_unlock(&hugetlb_lock);
+free:
 	/* Free unnecessary surplus pages to the buddy allocator */
 	if (!list_empty(&surplus_list)) {
-		spin_unlock(&hugetlb_lock);
 		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
 			list_del(&page->lru);
-			/*
-			 * The page has a reference count of zero already, so
-			 * call free_huge_page directly instead of using
-			 * put_page.  This must be done with hugetlb_lock
-			 * unlocked which is safe because free_huge_page takes
-			 * hugetlb_lock before deciding how to free the page.
-			 */
-			free_huge_page(page);
+			put_page(page);
 		}
-		spin_lock(&hugetlb_lock);
 	}
 
 	return ret;
@@ -1058,7 +1046,6 @@ static struct page *alloc_huge_page(stru
 		}
 	}
 
-	set_page_refcounted(page);
 	set_page_private(page, (unsigned long) mapping);
 
 	vma_commit_reservation(h, vma, addr);
@@ -2875,18 +2862,26 @@ void hugetlb_unreserve_pages(struct inod
 	hugetlb_acct_memory(h, -(chg - freed));
 }
 
+#ifdef CONFIG_MEMORY_FAILURE
 /*
  * This function is called from memory failure code.
  * Assume the caller holds page lock of the head page.
  */
-void __isolate_hwpoisoned_huge_page(struct page *hpage)
+int dequeue_hwpoisoned_huge_page(struct page *hpage)
 {
 	struct hstate *h = page_hstate(hpage);
 	int nid = page_to_nid(hpage);
+	int ret = -EBUSY;
 
 	spin_lock(&hugetlb_lock);
-	list_del(&hpage->lru);
-	h->free_huge_pages--;
-	h->free_huge_pages_node[nid]--;
+	if (!page_count(hpage)) {
+		list_del(&hpage->lru);
+		set_page_refcounted(hpage);
+		h->free_huge_pages--;
+		h->free_huge_pages_node[nid]--;
+		ret = 0;
+	}
 	spin_unlock(&hugetlb_lock);
+	return ret;
 }
+#endif
--- linux-next.orig/include/linux/hugetlb.h	2010-08-25 10:43:18.000000000 +0800
+++ linux-next/include/linux/hugetlb.h	2010-08-25 10:48:43.000000000 +0800
@@ -43,7 +43,7 @@ int hugetlb_reserve_pages(struct inode *
 						struct vm_area_struct *vma,
 						int acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
-void __isolate_hwpoisoned_huge_page(struct page *page);
+int dequeue_hwpoisoned_huge_page(struct page *page);
 
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
@@ -101,7 +101,7 @@ static inline void hugetlb_report_meminf
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
 #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
 #define huge_pte_offset(mm, address)	0
-#define __isolate_hwpoisoned_huge_page(page)	0
+#define dequeue_hwpoisoned_huge_page(page)	0
 
 #define hugetlb_change_protection(vma, address, end, newprot)
 
--- linux-next.orig/mm/memory-failure.c	2010-08-25 10:25:03.000000000 +0800
+++ linux-next/mm/memory-failure.c	2010-08-25 10:42:51.000000000 +0800
@@ -698,21 +698,6 @@ static int me_swapcache_clean(struct pag
  */
 static int me_huge_page(struct page *p, unsigned long pfn)
 {
-	struct page *hpage = compound_head(p);
-	/*
-	 * We can safely recover from error on free or reserved (i.e.
-	 * not in-use) hugepage by dequeuing it from freelist.
-	 * To check whether a hugepage is in-use or not, we can't use
-	 * page->lru because it can be used in other hugepage operations,
-	 * such as __unmap_hugepage_range() and gather_surplus_pages().
-	 * So instead we use page_mapping() and PageAnon().
-	 * We assume that this function is called with page lock held,
-	 * so there is no race between isolation and mapping/unmapping.
-	 */
-	if (!(page_mapping(hpage) || PageAnon(hpage))) {
-		__isolate_hwpoisoned_huge_page(hpage);
-		return RECOVERED;
-	}
 	return DELAYED;
 }
 
@@ -993,6 +978,11 @@ int __memory_failure(unsigned long pfn, 
 		if (is_free_buddy_page(p)) {
 			action_result(pfn, "free buddy", DELAYED);
 			return 0;
+		} else if (PageHuge(hpage)) {
+			res = dequeue_hwpoisoned_huge_page(hpage);
+			action_result(pfn, "free huge",
+				      res ? DELAYED : RECOVERED);
+			return res;
 		} else {
 			action_result(pfn, "high order kernel", IGNORED);
 			return -EBUSY;
@@ -1221,6 +1211,10 @@ static int get_any_page(struct page *p, 
 			/* Set hwpoison bit while page is still isolated */
 			SetPageHWPoison(p);
 			ret = 0;
+		} else if (PageHuge(p)) {
+			ret = dequeue_hwpoisoned_huge_page(compound_head(p));
+			if (!ret)
+				SetPageHWPoison(p);
 		} else {
 			pr_debug("get_any_page: %#lx: unknown zero refcount page type %lx\n",
 				pfn, p->flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

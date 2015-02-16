Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4451C6B006C
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 10:57:48 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id k14so20368777wgh.3
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 07:57:47 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id o4si22854005wij.23.2015.02.16.07.57.44
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 07:57:45 -0800 (PST)
Date: Mon, 16 Feb 2015 17:57:19 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 14/24] thp: implement new split_huge_page()
Message-ID: <20150216155719.GA6003@node.dhcp.inet.fi>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1423757918-197669-15-git-send-email-kirill.shutemov@linux.intel.com>
 <54DCDDEE.5030501@oracle.com>
 <54DCFDF8.4000207@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54DCFDF8.4000207@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 12, 2015 at 02:24:40PM -0500, Sasha Levin wrote:
> On 02/12/2015 12:07 PM, Sasha Levin wrote:
> > On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
> >> > +void __get_page_tail(struct page *page);
> >> >  static inline void get_page(struct page *page)
> >> >  {
> >> > -	struct page *page_head = compound_head(page);
> >> > -	VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page);
> >> > -	atomic_inc(&page_head->_count);
> >> > +	if (unlikely(PageTail(page)))
> >> > +		return __get_page_tail(page);
> >> > +
> >> > +	/*
> >> > +	 * Getting a normal page or the head of a compound page
> >> > +	 * requires to already have an elevated page->_count.
> >> > +	 */
> >> > +	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
> > This BUG_ON seems to get hit:
> 
> Plus a few more different traces:

Sasha, could you check if the patch below makes any better?

diff --git a/mm/gup.c b/mm/gup.c
index 22585ef667d9..10d98d39bc03 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -211,12 +211,19 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (flags & FOLL_SPLIT) {
 		int ret;
 		page = pmd_page(*pmd);
-		get_page(page);
-		spin_unlock(ptl);
-		lock_page(page);
-		ret = split_huge_page(page);
-		unlock_page(page);
-		put_page(page);
+		if (is_huge_zero_page(page)) {
+			spin_unlock(ptl);
+			ret = 0;
+			split_huge_pmd(vma, pmd, address);
+		} else {
+			get_page(page);
+			spin_unlock(ptl);
+			lock_page(page);
+			ret = split_huge_page(page);
+			unlock_page(page);
+			put_page(page);
+		}
+
 		return ret ? ERR_PTR(ret) :
 			follow_page_pte(vma, address, pmd, flags);
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2667938a3d2c..4d69baa41a6c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1821,7 +1821,7 @@ static int __split_huge_page_refcount(struct anon_vma *anon_vma,
 	int tail_mapcount = 0;
 
 	freeze_page(anon_vma, page);
-	BUG_ON(compound_mapcount(page));
+	VM_BUG_ON_PAGE(compound_mapcount(page), page);
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
diff --git a/mm/memory.c b/mm/memory.c
index f81bcd539ca0..5153fd0d8e5c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2231,7 +2231,7 @@ unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (mmun_end > mmun_start)
 		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-	if (old_page) {
+	if (old_page && !PageTransCompound(old_page)) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
diff --git a/mm/mlock.c b/mm/mlock.c
index 40c6ab590cde..6afef15f80ab 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -502,39 +502,26 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
 				&page_mask);
 
-		if (page && !IS_ERR(page)) {
-			if (PageTransHuge(page)) {
-				lock_page(page);
-				/*
-				 * Any THP page found by follow_page_mask() may
-				 * have gotten split before reaching
-				 * munlock_vma_page(), so we need to recompute
-				 * the page_mask here.
-				 */
-				page_mask = munlock_vma_page(page);
-				unlock_page(page);
-				put_page(page); /* follow_page_mask() */
-			} else {
-				/*
-				 * Non-huge pages are handled in batches via
-				 * pagevec. The pin from follow_page_mask()
-				 * prevents them from collapsing by THP.
-				 */
-				pagevec_add(&pvec, page);
-				zone = page_zone(page);
-				zoneid = page_zone_id(page);
+		if (page && !IS_ERR(page) && !PageTransCompound(page)) {
+			/*
+			 * Non-huge pages are handled in batches via
+			 * pagevec. The pin from follow_page_mask()
+			 * prevents them from collapsing by THP.
+			 */
+			pagevec_add(&pvec, page);
+			zone = page_zone(page);
+			zoneid = page_zone_id(page);
 
-				/*
-				 * Try to fill the rest of pagevec using fast
-				 * pte walk. This will also update start to
-				 * the next page to process. Then munlock the
-				 * pagevec.
-				 */
-				start = __munlock_pagevec_fill(&pvec, vma,
-						zoneid, start, end);
-				__munlock_pagevec(&pvec, zone);
-				goto next;
-			}
+			/*
+			 * Try to fill the rest of pagevec using fast
+			 * pte walk. This will also update start to
+			 * the next page to process. Then munlock the
+			 * pagevec.
+			 */
+			start = __munlock_pagevec_fill(&pvec, vma,
+					zoneid, start, end);
+			__munlock_pagevec(&pvec, zone);
+			goto next;
 		}
 		/* It's a bug to munlock in the middle of a THP page */
 		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

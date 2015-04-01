Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A9A176B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 09:18:11 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so53118755wgb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 06:18:11 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id q9si3925449wiz.40.2015.04.01.06.18.09
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 06:18:10 -0700 (PDT)
Date: Wed, 1 Apr 2015 16:17:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound
 page
Message-ID: <20150401131753.GD17153@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
 <87lhicbbf8.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lhicbbf8.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 01, 2015 at 12:08:35PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > Current split_huge_page() combines two operations: splitting PMDs into
> > tables of PTEs and splitting underlying compound page. This patch
> > changes split_huge_pmd() implementation to split the given PMD without
> > splitting other PMDs this page mapped with or underlying compound page.
> >
> > In order to do this we have to get rid of tail page refcounting, which
> > uses _mapcount of tail pages. Tail page refcounting is needed to be able
> > to split THP page at any point: we always know which of tail pages is
> > pinned (i.e. by get_user_pages()) and can distribute page count
> > correctly.
> >
> > We can avoid this by allowing split_huge_page() to fail if the compound
> > page is pinned. This patch removes all infrastructure for tail page
> > refcounting and make split_huge_page() to always return -EBUSY. All
> > split_huge_page() users already know how to handle its fail. Proper
> > implementation will be added later.
> >
> > Without tail page refcounting, implementation of split_huge_pmd() is
> > pretty straight-forward.
> >
> 
> With this we now have pte mapping part of a compound page(). Now the
> gneric gup implementation does
> 
> gup_pte_range()
> 	ptem = ptep = pte_offset_map(&pmd, addr);
> 	do {
> 
> ....
> ...
> 		if (!page_cache_get_speculative(page))
> 			goto pte_unmap;
> .....
>         }
> 
> That page_cache_get_speculative will fail in our case because it does
> if (unlikely(!get_page_unless_zero(page))) on a tail page. ??

Nice catch, thanks.

But the problem is not exclusive to my patchset. In current kernel some
drivers (sound, for instance) map compound pages with PTEs.

We can try to get page_cache_get_speculative() work on PTE-mapped tail
pages. Untested patch is below.

BTW, it would be nice to rename the function since it's now used not only
for page cache.

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7c3790764795..b2b6e886ed9b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -142,8 +142,10 @@ void release_pages(struct page **pages, int nr, bool cold);
  */
 static inline int page_cache_get_speculative(struct page *page)
 {
+	struct page *head_page;
 	VM_BUG_ON(in_interrupt());
-
+retry:
+	head_page = compound_head_fast(page);
 #ifdef CONFIG_TINY_RCU
 # ifdef CONFIG_PREEMPT_COUNT
 	VM_BUG_ON(!in_atomic());
@@ -157,11 +159,11 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * disabling preempt, and hence no need for the "speculative get" that
 	 * SMP requires.
 	 */
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	atomic_inc(&page->_count);
+	VM_BUG_ON_PAGE(page_count(head_page) == 0, head_page);
+	atomic_inc(&head_page->_count);
 
 #else
-	if (unlikely(!get_page_unless_zero(page))) {
+	if (unlikely(!get_page_unless_zero(head_page))) {
 		/*
 		 * Either the page has been freed, or will be freed.
 		 * In either case, retry here and the caller should
@@ -170,7 +172,21 @@ static inline int page_cache_get_speculative(struct page *page)
 		return 0;
 	}
 #endif
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	/* compound_head_fast() seen PageTail(page) == true */
+	if (unlikely(head_page != page)) {
+		/*
+		 * compound_head_fast() could fetch dangling page->first_page
+		 * pointer to an old compound page, so recheck that it is still
+		 * a tail page before returning.
+		 */
+		smp_rmb();
+		if (unlikely(!PageTail(page))) {
+			put_page(head_page);
+			goto retry;
+		}
+		/* Do not touch THP tail pages! */
+		VM_BUG_ON_PAGE(compound_tail_refcounted(head_page), head_page);
+	}
 
 	return 1;
 }
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

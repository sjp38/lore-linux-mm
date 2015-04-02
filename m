Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id EAC806B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 11:39:52 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so110229647wib.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 08:39:52 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id p6si10053504wic.104.2015.04.02.08.39.51
        for <linux-mm@kvack.org>;
        Thu, 02 Apr 2015 08:39:51 -0700 (PDT)
Date: Thu, 2 Apr 2015 18:39:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound
 page
Message-ID: <20150402153936.GA25345@node.dhcp.inet.fi>
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

IIUC, something as simple as patch below should work fine with migration
entries.

The reason I'm talking about migration enties is that with new refcounting
split_huge_page() breaks this generic fast GUP invariant:

 *  *) THP splits will broadcast an IPI, this can be achieved by overriding
 *      pmdp_splitting_flush.

We don't necessary trigger IPI during split. The page can be mapped only
with ptes by split time. That's fine for migration entries since we
re-check pte value after taking the pin. But it seems we don't have
anything in place for compound_lock case.

Hm. If I will not find any way to get it work with compound_lock, I would
need to implement new split_huge_page() on migration entries without
intermediate step with compound_lock.

Any comments?

diff --git a/mm/gup.c b/mm/gup.c
index d58af0785d24..b45edb8e6455 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1047,7 +1047,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		 * for an example see gup_get_pte in arch/x86/mm/gup.c
 		 */
 		pte_t pte = READ_ONCE(*ptep);
-		struct page *page;
+		struct page *head, *page;
 
 		/*
 		 * Similar to the PMD case below, NUMA hinting must take slow
@@ -1059,15 +1059,17 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
+		head = compound_head(page);
 
-		if (!page_cache_get_speculative(page))
+		if (!page_cache_get_speculative(head))
 			goto pte_unmap;
 
 		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
-			put_page(page);
+			put_page(head);
 			goto pte_unmap;
 		}
 
+		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
 		(*nr)++;
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

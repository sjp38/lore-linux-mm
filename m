Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id B8ABC6B025F
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 13:51:27 -0400 (EDT)
Received: by lahh2 with SMTP id h2so169193561lah.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 10:51:26 -0700 (PDT)
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com. [209.85.215.41])
        by mx.google.com with ESMTPS id s71si6973342lfd.169.2015.09.28.10.51.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 10:51:25 -0700 (PDT)
Received: by laer8 with SMTP id r8so40121891lae.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 10:51:25 -0700 (PDT)
Date: Mon, 28 Sep 2015 20:51:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/16] page-flags: introduce page flags policies wrt
 compound pages
Message-ID: <20150928175123.GA6590@node>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1443106264-78075-4-git-send-email-kirill.shutemov@linux.intel.com>
 <56053E1D.7050001@yandex-team.ru>
 <20150925191307.GA25711@node.dhcp.inet.fi>
 <5609102B.5020704@yandex-team.ru>
 <20150928110305.GA4721@node>
 <560928FC.2090407@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560928FC.2090407@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Mel Gorman <mgorman@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 28, 2015 at 02:48:12PM +0300, Konstantin Khlebnikov wrote:
> On 28.09.2015 14:03, Kirill A. Shutemov wrote:
> >On Mon, Sep 28, 2015 at 01:02:19PM +0300, Konstantin Khlebnikov wrote:
> >>On 25.09.2015 22:13, Kirill A. Shutemov wrote:
> >>>On Fri, Sep 25, 2015 at 03:29:17PM +0300, Konstantin Khlebnikov wrote:
> >>>>On 24.09.2015 17:50, Kirill A. Shutemov wrote:
> >>>>>This patch adds a third argument to macros which create function
> >>>>>definitions for page flags.  This argument defines how page-flags helpers
> >>>>>behave on compound functions.
> >>>>>
> >>>>>For now we define four policies:
> >>>>>
> >>>>>- PF_ANY: the helper function operates on the page it gets, regardless
> >>>>>   if it's non-compound, head or tail.
> >>>>>
> >>>>>- PF_HEAD: the helper function operates on the head page of the compound
> >>>>>   page if it gets tail page.
> >>>>>
> >>>>>- PF_NO_TAIL: only head and non-compond pages are acceptable for this
> >>>>>   helper function.
> >>>>>
> >>>>>- PF_NO_COMPOUND: only non-compound pages are acceptable for this helper
> >>>>>   function.
> >>>>>
> >>>>>For now we use policy PF_ANY for all helpers, which matches current
> >>>>>behaviour.
> >>>>>
> >>>>>We do not enforce the policy for TESTPAGEFLAG, because we have flags
> >>>>>checked for random pages all over the kernel.  Noticeable exception to
> >>>>>this is PageTransHuge() which triggers VM_BUG_ON() for tail page.
> >>>>>
> >>>>>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >>>>>---
> >>>>>  include/linux/page-flags.h | 154 ++++++++++++++++++++++++++-------------------
> >>>>>  1 file changed, 90 insertions(+), 64 deletions(-)
> >>>>>
> >>>>>diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> >>>>>index 713d3f2c2468..1b3babe5ff69 100644
> >>>>>--- a/include/linux/page-flags.h
> >>>>>+++ b/include/linux/page-flags.h
> >>>>>@@ -154,49 +154,68 @@ static inline int PageCompound(struct page *page)
> >>>>>  	return test_bit(PG_head, &page->flags) || PageTail(page);
> >>>>>  }
> >>>>>
> >>>>>+/* Page flags policies wrt compound pages */
> >>>>>+#define PF_ANY(page, enforce)	page
> >>>>>+#define PF_HEAD(page, enforce)	compound_head(page)
> >>>>>+#define PF_NO_TAIL(page, enforce) ({					\
> >>>>>+		if (enforce)						\
> >>>>>+			VM_BUG_ON_PAGE(PageTail(page), page);		\
> >>>>>+		else							\
> >>>>>+			page = compound_head(page);			\
> >>>>>+		page;})
> >>>>>+#define PF_NO_COMPOUND(page, enforce) ({					\
> >>>>>+		if (enforce)						\
> >>>>>+			VM_BUG_ON_PAGE(PageCompound(page), page);	\
> >>>>
> >>>>Linux next-20150925 crashes here (at least in lkvm)
> >>>>if CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
> >>>
> >>>Hm. I don't see the crash in qemu. Could you share your config?
> >>
> >>see in attachment
> >
> >Still don't see it. Have you tried patch from my previous mail?
> >
> 
> Just checked: patch fixes oops.
> 
> 
> This part of 7e18adb4f80bea90d30b62158694d97c31f71d37
> (mm: meminit: initialise remaining struct pages in parallel with kswapd)
> is unclear:
> 
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +static void init_reserved_page(unsigned long pfn)
> +{
> +       pg_data_t *pgdat;
> +       int nid, zid;
> +
> +       if (!early_page_uninitialised(pfn))
> +               return;
> +
> +       nid = early_pfn_to_nid(pfn);
> +       pgdat = NODE_DATA(nid);
> +
> +       for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +               struct zone *zone = &pgdat->node_zones[zid];
> +
> +               if (pfn >= zone->zone_start_pfn && pfn < zone_end_pfn(zone))
> +                       break;
> +       }
> +       __init_single_pfn(pfn, zid, nid);
> +}
> +#else
> +static inline void init_reserved_page(unsigned long pfn)
> +{
> +}
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> +
>  /*
>   * Initialised pages do not have PageReserved set. This function is
>   * called for each range allocated by the bootmem allocator and
>   * marks the pages PageReserved. The remaining valid pages are later
>   * sent to the buddy page allocator.
>   */
> -void reserve_bootmem_region(unsigned long start, unsigned long end)
> +void __meminit reserve_bootmem_region(unsigned long start, unsigned long
> end)
>  {
>         unsigned long start_pfn = PFN_DOWN(start);
>         unsigned long end_pfn = PFN_UP(end);
> 
> -       for (; start_pfn < end_pfn; start_pfn++)
> -               if (pfn_valid(start_pfn))
> -                       SetPageReserved(pfn_to_page(start_pfn));
> +       for (; start_pfn < end_pfn; start_pfn++) {
> +               if (pfn_valid(start_pfn)) {
> +                       struct page *page = pfn_to_page(start_pfn);
> +
> +                       init_reserved_page(start_pfn);
> +                       SetPageReserved(page);
> +               }
> +       }
>  }
> 
> We leave struct page uninitialized but call SetPageReserved for it.

__init_single_pfn() initializes the page.

I guess the problem is false-negative reply from
early_page_uninitialised(). No idea why it could happen.

Mel?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

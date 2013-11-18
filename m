Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B3F066B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 13:52:03 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj1so2154132pad.14
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:52:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id kn3si10327239pbc.274.2013.11.18.10.52.01
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 10:52:02 -0800 (PST)
Date: Mon, 18 Nov 2013 13:51:54 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1384800714-y653r3ch-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131115225553.B0E9DFFB@viggo.jf.intel.com>
References: <20131115225550.737E5C33@viggo.jf.intel.com>
 <20131115225553.B0E9DFFB@viggo.jf.intel.com>
Subject: Re: [v3][PATCH 2/2] mm: thp: give transparent hugepage code aseparate
 copy_page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Mel Gorman <mgorman@suse.de>

On Fri, Nov 15, 2013 at 02:55:53PM -0800, Dave Hansen wrote:
> 
> Changes from v2:
>  * 
> Changes from v1:
>  * removed explicit might_sleep() in favor of the one that we
>    get from the cond_resched();
> 
> --
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Right now, the migration code in migrate_page_copy() uses
> copy_huge_page() for hugetlbfs and thp pages:
> 
>        if (PageHuge(page) || PageTransHuge(page))
>                 copy_huge_page(newpage, page);
> 
> So, yay for code reuse.  But:
> 
> void copy_huge_page(struct page *dst, struct page *src)
> {
>         struct hstate *h = page_hstate(src);
> 
> and a non-hugetlbfs page has no page_hstate().  This works 99% of
> the time because page_hstate() determines the hstate from the
> page order alone.  Since the page order of a THP page matches the
> default hugetlbfs page order, it works.
> 
> But, if you change the default huge page size on the boot
> command-line (say default_hugepagesz=1G), then we might not even
> *have* a 2MB hstate so page_hstate() returns null and
> copy_huge_page() oopses pretty fast since copy_huge_page()
> dereferences the hstate:
> 
> void copy_huge_page(struct page *dst, struct page *src)
> {
>         struct hstate *h = page_hstate(src);
>         if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> ...
> 
> Mel noticed that the migration code is really the only user of
> these functions.  This moves all the copy code over to migrate.c
> and makes copy_huge_page() work for THP by checking for it
> explicitly.
> 
> I believe the bug was introduced in b32967ff101:
> Author: Mel Gorman <mgorman@suse.de>
> Date:   Mon Nov 19 12:35:47 2012 +0000
> mm: numa: Add THP migration for the NUMA working set scanning fault case.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Looks good to me with a few comments below. Thanks.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> 
>  linux.git-davehans/include/linux/hugetlb.h |    4 --
>  linux.git-davehans/mm/hugetlb.c            |   34 --------------------
>  linux.git-davehans/mm/migrate.c            |   48 +++++++++++++++++++++++++++++
>  3 files changed, 48 insertions(+), 38 deletions(-)
> 
> diff -puN mm/migrate.c~copy-huge-separate-from-copy-transhuge mm/migrate.c
> --- linux.git/mm/migrate.c~copy-huge-separate-from-copy-transhuge	2013-11-15 14:44:55.256970259 -0800
> +++ linux.git-davehans/mm/migrate.c	2013-11-15 14:45:17.457963844 -0800
> @@ -442,6 +442,54 @@ int migrate_huge_page_move_mapping(struc
>  }
>  
>  /*
> + * Gigantic pages are so large that the we do not guarantee

s/the // ?

> + * that page++ pointer arithmetic will work across the
> + * entire page.  We need something more specialized.
> + */
> +static void __copy_gigantic_page(struct page *dst, struct page *src,
> +				int nr_pages)
> +{
> +	int i;
> +	struct page *dst_base = dst;
> +	struct page *src_base = src;
> +
> +	for (i = 0; i < nr_pages; ) {
> +		cond_resched();

I think that this cond_resched() seems to be called too often.
One cond_resched() per MAX_ORDER_NR_PAGES pages copy looks better
than per single page copy. So I'll post a separate patch for this
which is appled on top of your patches.

> +		copy_highpage(dst, src);
> +
> +		i++;
> +		dst = mem_map_next(dst, dst_base, i);
> +		src = mem_map_next(src, src_base, i);
> +	}
> +}
> +
> +static void copy_huge_page(struct page *dst, struct page *src)
> +{
> +	int i;
> +	int nr_pages;
> +
> +	if (PageHuge(src)) {
> +		/* hugetlbfs page */
> +		struct hstate *h = page_hstate(src);
> +		nr_pages = pages_per_huge_page(h);
> +
> +		if (unlikely(nr_pages > MAX_ORDER_NR_PAGES)) {
> +			__copy_gigantic_page(dst, src, nr_pages);
> +			return;
> +		}
> +	} else {
> +		/* thp page */
> +		BUG_ON(!PageTransHuge(src));
> +		nr_pages = hpage_nr_pages(src);
> +	}
> +
> +	for (i = 0; i < nr_pages; i++ ) {

Coding style violation?

  ERROR: space prohibited before that close parenthesis ')'
  #177: FILE: mm/migrate.c:486:                            
  +       for (i = 0; i < nr_pages; i++ ) {                

Thanks,
Naoya Horiguchi

> +		cond_resched();
> +		copy_highpage(dst + i, src + i);
> +	}
> +}
> +
> +/*
>   * Copy the page to its new location
>   */
>  void migrate_page_copy(struct page *newpage, struct page *page)
> diff -puN mm/hugetlb.c~copy-huge-separate-from-copy-transhuge mm/hugetlb.c
> --- linux.git/mm/hugetlb.c~copy-huge-separate-from-copy-transhuge	2013-11-15 14:44:55.261970484 -0800
> +++ linux.git-davehans/mm/hugetlb.c	2013-11-15 14:44:55.389976227 -0800
> @@ -476,40 +476,6 @@ static int vma_has_reserves(struct vm_ar
>  	return 0;
>  }
>  
> -static void copy_gigantic_page(struct page *dst, struct page *src)
> -{
> -	int i;
> -	struct hstate *h = page_hstate(src);
> -	struct page *dst_base = dst;
> -	struct page *src_base = src;
> -
> -	for (i = 0; i < pages_per_huge_page(h); ) {
> -		cond_resched();
> -		copy_highpage(dst, src);
> -
> -		i++;
> -		dst = mem_map_next(dst, dst_base, i);
> -		src = mem_map_next(src, src_base, i);
> -	}
> -}
> -
> -void copy_huge_page(struct page *dst, struct page *src)
> -{
> -	int i;
> -	struct hstate *h = page_hstate(src);
> -
> -	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> -		copy_gigantic_page(dst, src);
> -		return;
> -	}
> -
> -	might_sleep();
> -	for (i = 0; i < pages_per_huge_page(h); i++) {
> -		cond_resched();
> -		copy_highpage(dst + i, src + i);
> -	}
> -}
> -
>  static void enqueue_huge_page(struct hstate *h, struct page *page)
>  {
>  	int nid = page_to_nid(page);
> diff -puN include/linux/hugetlb.h~copy-huge-separate-from-copy-transhuge include/linux/hugetlb.h
> --- linux.git/include/linux/hugetlb.h~copy-huge-separate-from-copy-transhuge	2013-11-15 14:44:55.263970574 -0800
> +++ linux.git-davehans/include/linux/hugetlb.h	2013-11-15 14:44:55.325973356 -0800
> @@ -69,7 +69,6 @@ int dequeue_hwpoisoned_huge_page(struct
>  bool isolate_huge_page(struct page *page, struct list_head *list);
>  void putback_active_hugepage(struct page *page);
>  bool is_hugepage_active(struct page *page);
> -void copy_huge_page(struct page *dst, struct page *src);
>  
>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
>  pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
> @@ -140,9 +139,6 @@ static inline int dequeue_hwpoisoned_hug
>  #define isolate_huge_page(p, l) false
>  #define putback_active_hugepage(p)	do {} while (0)
>  #define is_hugepage_active(x)	false
> -static inline void copy_huge_page(struct page *dst, struct page *src)
> -{
> -}
>  
>  static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  		unsigned long address, unsigned long end, pgprot_t newprot)
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

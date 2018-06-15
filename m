Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31C886B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 14:11:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f13-v6so6672694wrs.0
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 11:11:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63-v6sor728933wmi.13.2018.06.15.11.11.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 11:11:15 -0700 (PDT)
Date: Fri, 15 Jun 2018 20:11:13 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: skip invalid pages block at a time in
 zero_resv_unresv
Message-ID: <20180615181113.GA27558@techadventures.net>
References: <20180615155733.1175-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180615155733.1175-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, osalvador@suse.de, willy@infradead.org, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

On Fri, Jun 15, 2018 at 11:57:33AM -0400, Pavel Tatashin wrote:
> The role of zero_resv_unavail() is to make sure that every struct page that
> is allocated but is not backed by memory that is accessible by kernel is
> zeroed and not in some uninitialized state.
> 
> Since struct pages are allocated in blocks (2M pages in x86 case), we can
> skip pageblock_nr_pages at a time, when the first one is found to be
> invalid.
> 
> This optimization may help since now on x86 every hole in e820 maps
> is marked as reserved in memblock, and thus will go through this function.
> 
> This function is called before sched_clock() is initialized, so I used my
> x86 early boot clock patches to measure the performance improvement.
> 
> With 1T hole on i7-8700 currently we would take 0.606918s of boot time, but
> with this optimization 0.001103s.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  mm/page_alloc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1521100f1e63..94f1b3201735 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6404,8 +6404,11 @@ void __paginginit zero_resv_unavail(void)
>  	pgcnt = 0;
>  	for_each_resv_unavail_range(i, &start, &end) {
>  		for (pfn = PFN_DOWN(start); pfn < PFN_UP(end); pfn++) {
> -			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> +			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))) {
> +				pfn = ALIGN_DOWN(pfn, pageblock_nr_pages)
> +					+ pageblock_nr_pages - 1;
>  				continue;
> +			}
>  			mm_zero_struct_page(pfn_to_page(pfn));
>  			pgcnt++;
>  		}

Hi Pavel,

Thanks for the patch.
This looks good to me.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> -- 
> 2.17.1
> 

Best Regards
Oscar Salvador

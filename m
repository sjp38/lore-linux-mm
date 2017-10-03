Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52C236B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 09:09:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f84so19467915pfj.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 06:09:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t21si9770547pfk.89.2017.10.03.06.09.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 06:09:00 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:08:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 06/12] mm: zero struct pages during initialization
Message-ID: <20171003130857.vohli6lnqj4tdmhl@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-7-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920201714.19817-7-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Wed 20-09-17 16:17:08, Pavel Tatashin wrote:
> Add struct page zeroing as a part of initialization of other fields in
> __init_single_page().
> 
> This single thread performance collected on: Intel(R) Xeon(R) CPU E7-8895
> v3 @ 2.60GHz with 1T of memory (268400646 pages in 8 nodes):
> 
>                         BASE            FIX
> sparse_init     11.244671836s   0.007199623s
> zone_sizes_init  4.879775891s   8.355182299s
>                   --------------------------
> Total           16.124447727s   8.362381922s

Hmm, this is confusing. This assumes that sparse_init doesn't zero pages
anymore, right? So these number depend on the last patch in the series?

> sparse_init is where memory for struct pages is zeroed, and the zeroing
> part is moved later in this patch into __init_single_page(), which is
> called from zone_sizes_init().
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mm.h | 9 +++++++++
>  mm/page_alloc.c    | 1 +
>  2 files changed, 10 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f8c10d336e42..50b74d628243 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -94,6 +94,15 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #define mm_forbids_zeropage(X)	(0)
>  #endif
>  
> +/*
> + * On some architectures it is expensive to call memset() for small sizes.
> + * Those architectures should provide their own implementation of "struct page"
> + * zeroing by defining this macro in <asm/pgtable.h>.
> + */
> +#ifndef mm_zero_struct_page
> +#define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
> +#endif
> +
>  /*
>   * Default maximum number of active map areas, this limits the number of vmas
>   * per mm struct. Users can overwrite this number by sysctl but there is a
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a8dbd405ed94..4b630ee91430 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1170,6 +1170,7 @@ static void free_one_page(struct zone *zone,
>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
>  				unsigned long zone, int nid)
>  {
> +	mm_zero_struct_page(page);
>  	set_page_links(page, zone, nid, pfn);
>  	init_page_count(page);
>  	page_mapcount_reset(page);
> -- 
> 2.14.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 188ED6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 08:28:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q203so5473104wmb.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 05:28:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si5695154wrc.519.2017.10.03.05.28.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 05:28:24 -0700 (PDT)
Date: Tue, 3 Oct 2017 14:28:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 02/12] sparc64/mm: setting fields in deferred pages
Message-ID: <20171003122823.mdzkhxs4xza7sb2w@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-3-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920201714.19817-3-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Wed 20-09-17 16:17:04, Pavel Tatashin wrote:
> Without deferred struct page feature (CONFIG_DEFERRED_STRUCT_PAGE_INIT),
> flags and other fields in "struct page"es are never changed prior to first
> initializing struct pages by going through __init_single_page().
> 
> With deferred struct page feature enabled there is a case where we set some
> fields prior to initializing:
> 
> mem_init() {
>      register_page_bootmem_info();
>      free_all_bootmem();
>      ...
> }
> 
> When register_page_bootmem_info() is called only non-deferred struct pages
> are initialized. But, this function goes through some reserved pages which
> might be part of the deferred, and thus are not yet initialized.
> 
> mem_init
> register_page_bootmem_info
> register_page_bootmem_info_node
>  get_page_bootmem
>   .. setting fields here ..
>   such as: page->freelist = (void *)type;
> 
> free_all_bootmem()
> free_low_memory_core_early()
>  for_each_reserved_mem_region()
>   reserve_bootmem_region()
>    init_reserved_page() <- Only if this is deferred reserved page
>     __init_single_pfn()
>      __init_single_page()
>       memset(0) <-- Loose the set fields here
> 
> We end-up with similar issue as in the previous patch, where currently we
> do not observe problem as memory is zeroed. But, if flag asserts are
> changed we can start hitting issues.
> 
> Also, because in this patch series we will stop zeroing struct page memory
> during allocation, we must make sure that struct pages are properly
> initialized prior to using them.
> 
> The deferred-reserved pages are initialized in free_all_bootmem().
> Therefore, the fix is to switch the above calls.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> Acked-by: David S. Miller <davem@davemloft.net>

As you separated x86 and sparc patches doing essentially the same I
assume David is going to take this patch?

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/sparc/mm/init_64.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 6034569e2c0d..310c6754bcaa 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -2548,9 +2548,15 @@ void __init mem_init(void)
>  {
>  	high_memory = __va(last_valid_pfn << PAGE_SHIFT);
>  
> -	register_page_bootmem_info();
>  	free_all_bootmem();
>  
> +	/* Must be done after boot memory is put on freelist, because here we
> +	 * might set fields in deferred struct pages that have not yet been
> +	 * initialized, and free_all_bootmem() initializes all the reserved
> +	 * deferred pages for us.
> +	 */
> +	register_page_bootmem_info();
> +
>  	/*
>  	 * Set up the zero page, mark it reserved, so that page count
>  	 * is not manipulated when freeing the page from user ptes.
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

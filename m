Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 985246B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 08:27:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c42so479924wrc.13
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 05:27:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x10si10596790wrc.475.2017.10.03.05.27.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 05:27:02 -0700 (PDT)
Date: Tue, 3 Oct 2017 14:26:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 01/12] x86/mm: setting fields in deferred pages
Message-ID: <20171003122658.cv64pxnuavopjid6@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920201714.19817-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Wed 20-09-17 16:17:03, Pavel Tatashin wrote:
> Without deferred struct page feature (CONFIG_DEFERRED_STRUCT_PAGE_INIT),
> flags and other fields in "struct page"es are never changed prior to first
> initializing struct pages by going through __init_single_page().
> 
> With deferred struct page feature enabled, however, we set fields in
> register_page_bootmem_info that are subsequently clobbered right after in
> free_all_bootmem:
> 
>         mem_init() {
>                 register_page_bootmem_info();
>                 free_all_bootmem();
>                 ...
>         }
> 
> When register_page_bootmem_info() is called only non-deferred struct pages
> are initialized. But, this function goes through some reserved pages which
> might be part of the deferred, and thus are not yet initialized.
> 
>   mem_init
>    register_page_bootmem_info
>     register_page_bootmem_info_node
>      get_page_bootmem
>       .. setting fields here ..
>       such as: page->freelist = (void *)type;
> 
>   free_all_bootmem()
>    free_low_memory_core_early()
>     for_each_reserved_mem_region()
>      reserve_bootmem_region()
>       init_reserved_page() <- Only if this is deferred reserved page
>        __init_single_pfn()
>         __init_single_page()
>             memset(0) <-- Loose the set fields here
> 
> We end-up with issue where, currently we do not observe problem as memory
> is explicitly zeroed. But, if flag asserts are changed we can start hitting
> issues.
> 
> Also, because in this patch series we will stop zeroing struct page memory
> during allocation, we must make sure that struct pages are properly
> initialized prior to using them.
> 
> The deferred-reserved pages are initialized in free_all_bootmem().
> Therefore, the fix is to switch the above calls.

Thanks for extending the changelog. This is more informative now.
 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>

I hope I haven't missed anything but it looks good to me.

Acked-by: Michal Hocko <mhocko@suse.com>

one nit below
> ---
>  arch/x86/mm/init_64.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 5ea1c3c2636e..30fe22558720 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1182,12 +1182,17 @@ void __init mem_init(void)
>  
>  	/* clear_bss() already clear the empty_zero_page */
>  
> -	register_page_bootmem_info();
> -
>  	/* this will put all memory onto the freelists */
>  	free_all_bootmem();
>  	after_bootmem = 1;
>  
> +	/* Must be done after boot memory is put on freelist, because here we

standard code style is to do
	/*
	 * text starts here

> +	 * might set fields in deferred struct pages that have not yet been
> +	 * initialized, and free_all_bootmem() initializes all the reserved
> +	 * deferred pages for us.
> +	 */
> +	register_page_bootmem_info();
> +
>  	/* Register memory areas for /proc/kcore */
>  	kclist_add(&kcore_vsyscall, (void *)VSYSCALL_ADDR,
>  			 PAGE_SIZE, KCORE_OTHER);
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 881856B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 05:02:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r7so4223158wrb.0
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 02:02:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si444429wmi.139.2017.08.11.02.02.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 02:02:17 -0700 (PDT)
Date: Fri, 11 Aug 2017 11:02:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 02/15] x86/mm: setting fields in deferred pages
Message-ID: <20170811090214.GD30811@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-3-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502138329-123460-3-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

[CC Mel - the full series is here
http://lkml.kernel.org/r/1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com]

On Mon 07-08-17 16:38:36, Pavel Tatashin wrote:
> Without deferred struct page feature (CONFIG_DEFERRED_STRUCT_PAGE_INIT),
> flags and other fields in "struct page"es are never changed prior to first
> initializing struct pages by going through __init_single_page().
> 
> With deferred struct page feature enabled there is a case where we set some
> fields prior to initializing:
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

I have to confess that this part of the early struct page initialization
is not my strongest point and I have to always re-read the code from the
scratch but I really do not undestand what you are trying to achieve
here.

AFAIU register_page_bootmem_info_node is only about struct pages backing
pgdat, usemap and memmap. Those should be in reserved memblocks and we
do not initialize those at later times, they are not relevant to the
deferred initialization as your changelog suggests so the ordering with
get_page_bootmem shouldn't matter. Or am I missing something here?
 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> ---
>  arch/x86/mm/init_64.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 136422d7d539..1e863baec847 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1165,12 +1165,17 @@ void __init mem_init(void)
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
> 2.14.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

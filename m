Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0D78E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:54:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so7428908edr.7
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 01:54:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o22-v6si5072004ejd.133.2019.01.21.01.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 01:53:59 -0800 (PST)
Date: Mon, 21 Jan 2019 10:53:52 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hotplug: invalid PFNs from pfn_to_online_page()
Message-ID: <20190121095352.GM4087@dhcp22.suse.cz>
References: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
 <20190118021650.93222-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190118021650.93222-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, catalin.marinas@arm.com, vbabka@suse.cz, linux-mm@kvack.org

On Thu 17-01-19 21:16:50, Qian Cai wrote:
> On an arm64 ThunderX2 server, the first kmemleak scan would crash [1]
> with CONFIG_DEBUG_VM_PGFLAGS=y due to page_to_nid() found a pfn that is
> not directly mapped (MEMBLOCK_NOMAP). Hence, the page->flags is
> uninitialized.
> 
> This is due to the commit 9f1eb38e0e11 ("mm, kmemleak: little
> optimization while scanning") starts to use pfn_to_online_page() instead
> of pfn_valid(). However, in the CONFIG_MEMORY_HOTPLUG=y case,
> pfn_to_online_page() does not call memblock_is_map_memory() while
> pfn_valid() does.

How come there is an online section which has an pfn_valid==F? We do
allocate the full section worth of struct pages so there is a valid
struct page. Is there any hole inside this section?

Isn't this a problem that the particular struct page hasn't been
intialized properly?

> [1]
> [  102.195320] Unable to handle kernel NULL pointer dereference at virtual address 0000000000000006
> [  102.204113] Mem abort info:
> [  102.206921]   ESR = 0x96000005
> [  102.209997]   Exception class = DABT (current EL), IL = 32 bits
> [  102.215926]   SET = 0, FnV = 0
> [  102.218993]   EA = 0, S1PTW = 0
> [  102.222150] Data abort info:
> [  102.225047]   ISV = 0, ISS = 0x00000005
> [  102.228887]   CM = 0, WnR = 0
> [  102.231866] user pgtable: 64k pages, 48-bit VAs, pgdp = (____ptrval____)
> [  102.238572] [0000000000000006] pgd=0000000000000000, pud=0000000000000000
> [  102.245448] Internal error: Oops: 96000005 [#1] SMP
> [  102.264062] CPU: 60 PID: 1408 Comm: kmemleak Not tainted 5.0.0-rc2+ #8
> [  102.280403] pstate: 60400009 (nZCv daif +PAN -UAO)
> [  102.280409] pc : page_mapping+0x24/0x144
> [  102.280415] lr : __dump_page+0x34/0x3dc
> [  102.292923] sp : ffff00003a5cfd10
> [  102.296229] x29: ffff00003a5cfd10 x28: 000000000000802f
> [  102.301533] x27: 0000000000000000 x26: 0000000000277d00
> [  102.306835] x25: ffff000010791f56 x24: ffff7fe000000000
> [  102.312138] x23: ffff000010772f8b x22: ffff00001125f670
> [  102.317442] x21: ffff000011311000 x20: ffff000010772f8b
> [  102.322747] x19: fffffffffffffffe x18: 0000000000000000
> [  102.328049] x17: 0000000000000000 x16: 0000000000000000
> [  102.333352] x15: 0000000000000000 x14: ffff802698b19600
> [  102.338654] x13: ffff802698b1a200 x12: ffff802698b16f00
> [  102.343956] x11: ffff802698b1a400 x10: 0000000000001400
> [  102.349260] x9 : 0000000000000001 x8 : ffff00001121a000
> [  102.354563] x7 : 0000000000000000 x6 : ffff0000102c53b8
> [  102.359868] x5 : 0000000000000000 x4 : 0000000000000003
> [  102.365173] x3 : 0000000000000100 x2 : 0000000000000000
> [  102.370476] x1 : ffff000010772f8b x0 : ffffffffffffffff
> [  102.375782] Process kmemleak (pid: 1408, stack limit = 0x(____ptrval____))
> [  102.382648] Call trace:
> [  102.385091]  page_mapping+0x24/0x144
> [  102.388659]  __dump_page+0x34/0x3dc
> [  102.392140]  dump_page+0x28/0x4c
> [  102.395363]  kmemleak_scan+0x4ac/0x680
> [  102.399106]  kmemleak_scan_thread+0xb4/0xdc
> [  102.403285]  kthread+0x12c/0x13c
> [  102.406509]  ret_from_fork+0x10/0x18
> [  102.410080] Code: d503201f f9400660 36000040 d1000413 (f9400661)
> [  102.416357] ---[ end trace 4d4bd7f573490c8e ]---
> [  102.420966] Kernel panic - not syncing: Fatal exception
> [  102.426293] SMP: stopping secondary CPUs
> [  102.431830] Kernel Offset: disabled
> [  102.435311] CPU features: 0x002,20000c38
> [  102.439223] Memory Limit: none
> [  102.442384] ---[ end Kernel panic - not syncing: Fatal exception ]---
> 
> Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to
> have holes")

Did you mean 
Fixes: 9f1eb38e0e11 ("mm, kmemleak: little  optimization while scanning")

> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  include/linux/memory_hotplug.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 07da5c6c5ba0..b8b36e6ac43b 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -26,7 +26,7 @@ struct vmem_altmap;
>  	struct page *___page = NULL;			\
>  	unsigned long ___nr = pfn_to_section_nr(pfn);	\
>  							\
> -	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr))\
> +	if (online_section_nr(___nr) && pfn_valid(pfn))	\
>  		___page = pfn_to_page(pfn);		\

Why have you removed the bound check? Is this safe?
Regarding the fix, I am not really sure TBH. If the secion is online
then we assume all struct pages to be initialized. If anything this
should be limited to werid arches which might have holes so
pfn_valid_within().

>  	___page;					\
>  })
> -- 
> 2.17.2 (Apple Git-113)

-- 
Michal Hocko
SUSE Labs

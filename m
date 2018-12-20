Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A595A8E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:22:04 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so1648996edt.23
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:22:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si3505940edv.312.2018.12.20.01.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 01:22:03 -0800 (PST)
Date: Thu, 20 Dec 2018 10:22:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_owner: fix for deferred struct page init
Message-ID: <20181220092202.GD14234@dhcp22.suse.cz>
References: <cbfacb4b-dbfd-f68f-3d1e-05e137feca18@lca.pw>
 <20181220060303.38686-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220060303.38686-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-12-18 01:03:03, Qian Cai wrote:
> When booting a system with "page_owner=on",
> 
> start_kernel
>   page_ext_init
>     invoke_init_callbacks
>       init_section_page_ext
>         init_page_owner
>           init_early_allocated_pages
>             init_zones_in_node
>               init_pages_in_zone
>                 lookup_page_ext
>                   page_to_nid
> 
> The issue here is that page_to_nid() will not work since some page
> flags have no node information until later in page_alloc_init_late() due
> to DEFERRED_STRUCT_PAGE_INIT. Hence, it could trigger an out-of-bounds
> access with an invalid nid.
> 
> [    8.666047] UBSAN: Undefined behaviour in ./include/linux/mm.h:1104:50
> [    8.672603] index 7 is out of range for type 'zone [5]'
> 
> Also, kernel will panic since flags were poisoned earlier with,
> 
> CONFIG_DEBUG_VM_PGFLAGS=y
> CONFIG_NODE_NOT_IN_PAGE_FLAGS=n
> 
> start_kernel
>   setup_arch
>     pagetable_init
>       paging_init
>         sparse_init
>           sparse_init_nid
>             memblock_alloc_try_nid_raw
> 
> Although later it tries to set page flags for pages in reserved bootmem
> regions,
> 
> mm_init
>   mem_init
>     memblock_free_all
>       free_low_memory_core_early
>         reserve_bootmem_region
> 
> there could still have some freed pages from the page allocator but yet
> to be initialized due to DEFERRED_STRUCT_PAGE_INIT. It have already been
> dealt with a bit in page_ext_init().

Is there any reason why we cannot postpone page_ext initialization to
after all the memory is initialized?
-- 
Michal Hocko
SUSE Labs

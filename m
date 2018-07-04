Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 739606B000D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 08:43:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z13-v6so2590wrq.3
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 05:43:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y204-v6si2764613wmc.152.2018.07.04.05.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 05:43:44 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64ChXj5020829
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 08:43:43 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k0uupev3e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:43:43 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 13:43:41 +0100
Date: Wed, 4 Jul 2018 15:43:35 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
 <20180704075410.GF22503@dhcp22.suse.cz>
 <89f48f7a-6cbf-ac9a-cacc-cd3ca79f8c66@suse.cz>
 <20180704123627.GM22503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704123627.GM22503@dhcp22.suse.cz>
Message-Id: <20180704124335.GE4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 04, 2018 at 02:36:27PM +0200, Michal Hocko wrote:
> [CC Andrew - email thread starts
> http://lkml.kernel.org/r/1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com]
> 
> OK, so here we go with the full patch.
> 
> From 0e8432b875d98a7a0d3f757fce2caa8d16a8de15 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 4 Jul 2018 14:31:46 +0200
> Subject: [PATCH] memblock: do not complain about top-down allocations for
>  !MEMORY_HOTREMOVE
> 
> Mike Rapoport is converting architectures from bootmem to noboodmem
> allocator. While doing so for m68k Geert has noticed that he gets
> a scary looking warning
> WARNING: CPU: 0 PID: 0 at mm/memblock.c:230
> memblock_find_in_range_node+0x11c/0x1be
> memblock: bottom-up allocation failed, memory hotunplug may be affected
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper Not tainted
> 4.18.0-rc3-atari-01343-gf2fb5f2e09a97a3c-dirty #7
> Stack from 003c3e20:
>         003c3e20 0039cf44 00023800 00433000 ffffffff 00001000 00240000 000238aa
>         00378734 000000e6 004285ac 00000009 00000000 003c3e58 003787c0 003c3e74
>         003c3ea4 004285ac 00378734 000000e6 003787c0 00000000 00000000 00000001
>         00000000 00000010 00000000 00428490 003e3856 ffffffff ffffffff 003c3ed0
>         00044620 003c3ee0 00417a10 00240000 00000010 00000000 00000000 00000001
>         00000000 00000001 00240000 00000000 00000000 00000000 00001000 003e3856
> Call Trace: [<00023800>] __warn+0xa8/0xc2
>  [<00001000>] kernel_pg_dir+0x0/0x1000
>  [<00240000>] netdev_lower_get_next+0x2/0x22
>  [<000238aa>] warn_slowpath_fmt+0x2e/0x36
>  [<004285ac>] memblock_find_in_range_node+0x11c/0x1be
>  [<004285ac>] memblock_find_in_range_node+0x11c/0x1be
>  [<00428490>] memblock_find_in_range_node+0x0/0x1be
>  [<00044620>] vprintk_func+0x66/0x6e
>  [<00417a10>] memblock_virt_alloc_internal+0xd0/0x156
>  [<00240000>] netdev_lower_get_next+0x2/0x22
>  [<00240000>] netdev_lower_get_next+0x2/0x22
>  [<00001000>] kernel_pg_dir+0x0/0x1000
>  [<00417b8c>] memblock_virt_alloc_try_nid_nopanic+0x58/0x7a
>  [<00240000>] netdev_lower_get_next+0x2/0x22
>  [<00001000>] kernel_pg_dir+0x0/0x1000
>  [<00001000>] kernel_pg_dir+0x0/0x1000
>  [<00010000>] EXPTBL+0x234/0x400
>  [<00010000>] EXPTBL+0x234/0x400
>  [<002f3644>] alloc_node_mem_map+0x4a/0x66
>  [<00240000>] netdev_lower_get_next+0x2/0x22
>  [<004155ca>] free_area_init_node+0xe2/0x29e
>  [<00010000>] EXPTBL+0x234/0x400
>  [<00411392>] paging_init+0x430/0x462
>  [<00001000>] kernel_pg_dir+0x0/0x1000
>  [<000427cc>] printk+0x0/0x1a
>  [<00010000>] EXPTBL+0x234/0x400
>  [<0041084c>] setup_arch+0x1b8/0x22c
>  [<0040e020>] start_kernel+0x4a/0x40a
>  [<0040d344>] _sinittext+0x344/0x9e8
> 
> The warning is basically saying that a top-down allocation can break
> memory hotremove because memblock allocation is not movable. But m68k
> doesn't even support MEMORY_HOTREMOVE is there is no point to warn
> about it.
> 
> Make the warning conditional only to configurations that care.
> 
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memblock.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 03d48d8835ba..2acec4033389 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -227,7 +227,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>  		 * so we use WARN_ONCE() here to see the stack trace if
>  		 * fail happens.
>  		 */
> -		WARN_ONCE(1, "memblock: bottom-up allocation failed, memory hotunplug may be affected\n");
> +		WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> +					"memblock: bottom-up allocation failed, memory hotremove may be affected\n");

nit: isn't the warning indented too much?

>  	}
> 
>  	return __memblock_find_range_top_down(start, end, size, align, nid,
> -- 
> 2.18.0
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

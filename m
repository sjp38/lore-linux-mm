Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 767EC6B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 19:33:45 -0400 (EDT)
Received: by yhr47 with SMTP id 47so9460688yhr.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2012 16:33:44 -0700 (PDT)
Date: Thu, 2 Aug 2012 08:33:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: WARNING: at mm/page_alloc.c:4514 free_area_init_node+0x4f/0x37b()
Message-ID: <20120801233335.GA4673@barrios>
References: <20120801173837.GI8082@aftab.osrc.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120801173837.GI8082@aftab.osrc.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: Minchan Kim <minchan@kernel.org>, Tejun Heo <tj@kernel.org>, Ralf Baechle <ralf@linux-mips.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello Borislav,

On Wed, Aug 01, 2012 at 07:38:37PM +0200, Borislav Petkov wrote:
> Hi,
> 
> I'm hitting the WARN_ON in $Subject with latest linus:
> v3.5-8833-g2d534926205d on a 4-node AMD system. As it looks from
> dmesg, it is happening on node 0, 1 and 2 but not on 3. Probably the
> pgdat->nr_zones thing but I'll have to add more dbg code to be sure.

As I look the code quickly, free_area_init_node initializes node_id and
node_start_pfn doublely. They were initialized by setup_node_data.

Could you test below patch? It's not a totally right way to fix it but
I want to confirm why it happens.

(I'm on vacation now so please understand that it hard to reach me)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 889532b..009ac28 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4511,7 +4511,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
        pg_data_t *pgdat = NODE_DATA(nid);
 
        /* pg_data_t should be reset to zero when it's allocated */
-       WARN_ON(pgdat->nr_zones || pgdat->node_start_pfn || pgdat->classzone_idx);
+       WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
 
        pgdat->node_id = nid;
        pgdat->node_start_pfn = node_start_pfn;

> 
> Config is attached.
> 
> dmesg:
> 
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00010000-0x00087fff]
> [    0.000000]   node   0: [mem 0x00100000-0xc7ebffff]
> [    0.000000]   node   0: [mem 0x100000000-0x437ffffff]
> [    0.000000]   node   1: [mem 0x438000000-0x837ffffff]
> [    0.000000]   node   2: [mem 0x838000000-0xc37ffffff]
> [    0.000000]   node   3: [mem 0xc38000000-0x1037ffffff]
> [    0.000000] On node 0 totalpages: 4193848
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 6 pages reserved
> [    0.000000]   DMA zone: 3890 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 16320 pages used for memmap
> [    0.000000]   DMA32 zone: 798464 pages, LIFO batch:31
> [    0.000000]   Normal zone: 52736 pages used for memmap
> [    0.000000]   Normal zone: 3322368 pages, LIFO batch:31
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: at mm/page_alloc.c:4514 free_area_init_node+0x4f/0x37b()
> [    0.000000] Hardware name: Dinar
> [    0.000000] Modules linked in:
> [    0.000000] Pid: 0, comm: swapper Not tainted 3.5.0+ #9
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff810320bd>] warn_slowpath_common+0x85/0x9d
> [    0.000000]  [<ffffffff810320ef>] warn_slowpath_null+0x1a/0x1c
> [    0.000000]  [<ffffffff81470bc0>] free_area_init_node+0x4f/0x37b
> [    0.000000]  [<ffffffff81af5962>] ? find_min_pfn_for_node+0x57/0x84
> [    0.000000]  [<ffffffff81af61a2>] free_area_init_nodes+0x55d/0x5ac
> [    0.000000]  [<ffffffff81aed7ca>] zone_sizes_init+0x3b/0x3d
> [    0.000000]  [<ffffffff81aedadc>] paging_init+0x20/0x22
> [    0.000000]  [<ffffffff81ae030d>] setup_arch+0x6f3/0x7c2
> [    0.000000]  [<ffffffff81add806>] start_kernel+0x8f/0x2eb
> [    0.000000]  [<ffffffff81add280>] x86_64_start_reservations+0x84/0x89
> [    0.000000]  [<ffffffff81add377>] x86_64_start_kernel+0xf2/0xf9
> [    0.000000] ---[ end trace d76bed13a5793ee3 ]---
> [    0.000000] On node 1 totalpages: 4194304
> [    0.000000]   Normal zone: 65536 pages used for memmap
> [    0.000000]   Normal zone: 4128768 pages, LIFO batch:31
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: at mm/page_alloc.c:4514 free_area_init_node+0x4f/0x37b()
> [    0.000000] Hardware name: Dinar
> [    0.000000] Modules linked in:
> [    0.000000] Pid: 0, comm: swapper Tainted: G        W    3.5.0+ #9
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff810320bd>] warn_slowpath_common+0x85/0x9d
> [    0.000000]  [<ffffffff810320ef>] warn_slowpath_null+0x1a/0x1c
> [    0.000000]  [<ffffffff81470bc0>] free_area_init_node+0x4f/0x37b
> [    0.000000]  [<ffffffff81af5962>] ? find_min_pfn_for_node+0x57/0x84
> [    0.000000]  [<ffffffff81af61a2>] free_area_init_nodes+0x55d/0x5ac
> [    0.000000]  [<ffffffff81aed7ca>] zone_sizes_init+0x3b/0x3d
> [    0.000000]  [<ffffffff81aedadc>] paging_init+0x20/0x22
> [    0.000000]  [<ffffffff81ae030d>] setup_arch+0x6f3/0x7c2
> [    0.000000]  [<ffffffff81add806>] start_kernel+0x8f/0x2eb
> [    0.000000]  [<ffffffff81add280>] x86_64_start_reservations+0x84/0x89
> [    0.000000]  [<ffffffff81add377>] x86_64_start_kernel+0xf2/0xf9
> [    0.000000] ---[ end trace d76bed13a5793ee4 ]---
> [    0.000000] On node 2 totalpages: 4194304
> [    0.000000]   Normal zone: 65536 pages used for memmap
> [    0.000000]   Normal zone: 4128768 pages, LIFO batch:31
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: at mm/page_alloc.c:4514 free_area_init_node+0x4f/0x37b()
> [    0.000000] Hardware name: Dinar
> [    0.000000] Modules linked in:
> [    0.000000] Pid: 0, comm: swapper Tainted: G        W    3.5.0+ #9
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff810320bd>] warn_slowpath_common+0x85/0x9d
> [    0.000000]  [<ffffffff810320ef>] warn_slowpath_null+0x1a/0x1c
> [    0.000000]  [<ffffffff81470bc0>] free_area_init_node+0x4f/0x37b
> [    0.000000]  [<ffffffff81af5962>] ? find_min_pfn_for_node+0x57/0x84
> [    0.000000]  [<ffffffff81af61a2>] free_area_init_nodes+0x55d/0x5ac
> [    0.000000]  [<ffffffff81aed7ca>] zone_sizes_init+0x3b/0x3d
> [    0.000000]  [<ffffffff81aedadc>] paging_init+0x20/0x22
> [    0.000000]  [<ffffffff81ae030d>] setup_arch+0x6f3/0x7c2
> [    0.000000]  [<ffffffff81add806>] start_kernel+0x8f/0x2eb
> [    0.000000]  [<ffffffff81add280>] x86_64_start_reservations+0x84/0x89
> [    0.000000]  [<ffffffff81add377>] x86_64_start_kernel+0xf2/0xf9
> [    0.000000] ---[ end trace d76bed13a5793ee5 ]---
> [    0.000000] On node 3 totalpages: 4194304
> [    0.000000]   Normal zone: 65536 pages used for memmap
> [    0.000000]   Normal zone: 4128768 pages, LIFO batch:31
> 
> -- 
> Regards/Gruss,
> Boris.
> 
> Advanced Micro Devices GmbH
> Einsteinring 24, 85609 Dornach
> GM: Alberto Bozzo
> Reg: Dornach, Landkreis Muenchen
> HRB Nr. 43632 WEEE Registernr: 129 19551


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

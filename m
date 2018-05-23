Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 831B26B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:19:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f21-v6so1989397wmh.5
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:19:16 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id s5-v6si16428038wrc.318.2018.05.23.02.19.14
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 02:19:14 -0700 (PDT)
Date: Wed, 23 May 2018 11:19:14 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC] trace when adding memory to an offline nod
Message-ID: <20180523091914.GA31306@techadventures.net>
References: <20180523080108.GA30350@techadventures.net>
 <20180523083756.GJ20441@dhcp22.suse.cz>
 <20180523084342.GK20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523084342.GK20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, dan.j.williams@intel.com

On Wed, May 23, 2018 at 10:43:42AM +0200, Michal Hocko wrote:
> On Wed 23-05-18 10:37:56, Michal Hocko wrote:
> > On Wed 23-05-18 10:01:08, Oscar Salvador wrote:
> > > Hi guys,
> > > 
> > > while testing memhotplug, I spotted the following trace:
> > > 
> > > =====
> > > linux kernel: WARNING: CPU: 0 PID: 64 at ./include/linux/gfp.h:467 vmemmap_alloc_block+0x4e/0xc9
> > 
> > This warning is too loud and not really helpful. We are doing
> > 		gfp_t gfp_mask = GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
> > 
> > 		page = alloc_pages_node(node, gfp_mask, order);
> > 
> > so we do not really insist on the allocation succeeding on the requested
> > node (it is more a hint which node is the best one but we can fallback
> > to any other node). Moreover we do explicitly do not care about
> > allocation warnings by __GFP_NOWARN. So maybe we want to soften the
> > warning like this?
> > 
> The patch with the full changelog
> 
> From 13a168ec3b84561abc201bd116ad53af343928c0 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 23 May 2018 10:38:06 +0200
> Subject: [PATCH] mm: do not warn on offline nodes unless the specific node is
>  explicitly requested
> 
> Oscar has noticed that we splat
> linux kernel: WARNING: CPU: 0 PID: 64 at ./include/linux/gfp.h:467 vmemmap_alloc_block+0x4e/0xc9
> [...]
> linux kernel: CPU: 0 PID: 64 Comm: kworker/u4:1 Tainted: G        W   E     4.17.0-rc5-next-20180517-1-default+ #66
> linux kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
> linux kernel: Workqueue: kacpi_hotplug acpi_hotplug_work_fn
> linux kernel: RIP: 0010:vmemmap_alloc_block+0x4e/0xc9
> linux kernel: Code: fb ff 8d 69 01 75 07 65 8b 1d 9d cb 93 7e 81 fb ff 03 00 00 76 02 0f 0b 48 63 c3 48 0f a3 05 c8 b1 b4 00 0f 92 c0 84 c0 75 02 <0f> 0b 31 c9 89 da 89 ee bf c0 06 40 01 e8 0f d1 ad ff 48 85 c0 74
> linux kernel: RSP: 0018:ffffc90000d03bf0 EFLAGS: 00010246
> linux kernel: RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000000000008
> linux kernel: RDX: 0000000000000000 RSI: 0000000000000001 RDI: 00000000000001ff
> linux kernel: RBP: 0000000000000009 R08: 0000000000000001 R09: ffffc90000d03ae8
> linux kernel: R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0006000000
> linux kernel: R13: ffffea0005e00000 R14: ffffea0006000000 R15: 0000000000000001
> linux kernel: FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
> linux kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> linux kernel: CR2: 00007fa92a698018 CR3: 00000001184ce000 CR4: 00000000000006f0
> linux kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> linux kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> linux kernel: Call Trace:
> linux kernel:  vmemmap_populate+0xf2/0x2ae
> linux kernel:  sparse_mem_map_populate+0x28/0x35
> linux kernel:  sparse_add_one_section+0x4c/0x187
> linux kernel:  __add_pages+0xe7/0x1a0
> linux kernel:  add_pages+0x16/0x70
> linux kernel:  add_memory_resource+0xa3/0x1d0
> linux kernel:  add_memory+0xe4/0x110
> linux kernel:  acpi_memory_device_add+0x134/0x2e0
> linux kernel:  acpi_bus_attach+0xd9/0x190
> linux kernel:  acpi_bus_scan+0x37/0x70
> linux kernel:  acpi_device_hotplug+0x389/0x4e0
> linux kernel:  acpi_hotplug_work_fn+0x1a/0x30
> linux kernel:  process_one_work+0x146/0x340
> linux kernel:  worker_thread+0x47/0x3e0
> linux kernel:  kthread+0xf5/0x130
> linux kernel:  ? max_active_store+0x60/0x60
> linux kernel:  ? kthread_bind+0x10/0x10
> linux kernel:  ret_from_fork+0x35/0x40
> linux kernel: ---[ end trace 2e2241f4e2f2f018 ]---
> ====
> 
> when adding memory to a node that is currently offline.
> 
> The VM_WARN_ON is just too loud without a good reason. In this
> particular case we are doing
> 	alloc_pages_node(node, GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOWARN, order)
> 
> so we do not insist on allocating from the given node (it is more a
> hint) so we can fall back to any other populated node and moreover we
> explicitly ask to not warn for the allocation failure.
> 
> Soften the warning only to cases when somebody asks for the given node
> explicitly by __GFP_THISNODE.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/gfp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 036846fc00a6..7f860ea29ec6 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -464,7 +464,7 @@ static inline struct page *
>  __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
>  {
>  	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> -	VM_WARN_ON(!node_online(nid));
> +	VM_WARN_ON((gfp_mask & __GFP_THISNODE) && !node_online(nid));
>  
>  	return __alloc_pages(gfp_mask, order, nid);
>  }
> -- 
> 2.17.0
> -- 

For what is worth it:

Tested-by: Oscar Salvador <osalvador@techadventures.net>

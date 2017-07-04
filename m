Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 969C96B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 06:24:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z1so45077152wrz.10
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 03:24:24 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id w28si13510116wra.157.2017.07.04.03.24.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 03:24:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 9554D99433
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 10:24:22 +0000 (UTC)
Date: Tue, 4 Jul 2017 11:24:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH stable-only] mm: fix classzone_idx underflow in
 shrink_zones()
Message-ID: <20170704102421.hi2syscvkqb5ohzq@techsingularity.net>
References: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: stable <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 04, 2017 at 10:45:43AM +0200, Vlastimil Babka wrote:
> Hi,
> 
> I realize this is against the standard stable policy, but I see no other
> way, because the mainline accidental fix is part of 34+ patch reclaim
> rework, that would be absurd to try to backport into stable. The fix is
> a one-liner though.
> 

That 34+ rework would be excessive to say the least as it's quite a
fundamental set of changes to catch a corner case.

> ----8<----
> From a1a1e459276298ac98827520e07923aa1219dbe1 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 22 Jun 2017 16:23:13 +0200
> Subject: [PATCH] mm: fix classzone_idx underflow in shrink_zones()
> 
> We've got reported a BUG in do_try_to_free_pages():
> 
> BUG: unable to handle kernel paging request at ffff8ffffff28990
> IP: [<ffffffff8119abe0>] do_try_to_free_pages+0x140/0x490
> PGD 0
> Oops: 0000 [#1] SMP
> megaraid_sas sg scsi_mod efivarfs autofs4
> Supported: No, Unsupported modules are loaded
> Workqueue: kacpi_hotplug acpi_hotplug_work_fn
> task: ffff88ffd0d4c540 ti: ffff88ffd0e48000 task.ti: ffff88ffd0e48000
> RIP: 0010:[<ffffffff8119abe0>]  [<ffffffff8119abe0>] do_try_to_free_pages+0x140/0x490
> RSP: 0018:ffff88ffd0e4ba60  EFLAGS: 00010206
> RAX: 000006fffffff900 RBX: 00000000ffffffff RCX: ffff88fffff29000
> RDX: 000000ffffffff00 RSI: 0000000000000003 RDI: 00000000024200c8
> RBP: 0000000001320122 R08: 0000000000000000 R09: ffff88ffd0e4bbac
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff88ffd0e4bae0
> R13: 0000000000000e00 R14: ffff88fffff2a500 R15: ffff88fffff2b300
> FS:  0000000000000000(0000) GS:ffff88ffe6440000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffff8ffffff28990 CR3: 0000000001c0a000 CR4: 00000000003406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Stack:
>  00000002db570a80 024200c80000001e ffff88fffff2b300 0000000000000000
>  ffff88fffffd5700 ffff88ffd0d4c540 ffff88ffd0d4c540 ffffffff0000000c
>  0000000000000000 0000000000000040 00000000024200c8 ffff88ffd0e4bae0
> Call Trace:
>  [<ffffffff8119afea>] try_to_free_pages+0xba/0x170
>  [<ffffffff8118cf2f>] __alloc_pages_nodemask+0x53f/0xb20
>  [<ffffffff811d39ff>] alloc_pages_current+0x7f/0x100
>  [<ffffffff811e2232>] migrate_pages+0x202/0x710
>  [<ffffffff815dadaa>] __offline_pages.constprop.23+0x4ba/0x790
>  [<ffffffff81463263>] memory_subsys_offline+0x43/0x70
>  [<ffffffff8144cbed>] device_offline+0x7d/0xa0
>  [<ffffffff81392fa2>] acpi_bus_offline+0xa5/0xef
>  [<ffffffff81394a77>] acpi_device_hotplug+0x21b/0x41f
>  [<ffffffff8138dab7>] acpi_hotplug_work_fn+0x1a/0x23
>  [<ffffffff81093cee>] process_one_work+0x14e/0x410
>  [<ffffffff81094546>] worker_thread+0x116/0x490
>  [<ffffffff810999ed>] kthread+0xbd/0xe0
>  [<ffffffff815e4e7f>] ret_from_fork+0x3f/0x70
> 
> This translates to the loop in shrink_zone():
> 
> classzone_idx = requested_highidx;
> while (!populated_zone(zone->zone_pgdat->node_zones +
> 					classzone_idx))
> 	classzone_idx--;
> 
> where no zone is populated, so classzone_idx becomes -1 (in RBX).
> 

Well.... one zone must have been populated or we wouldn't be here in the
first place but you clear that up later.

> Added debugging output reveals that we enter the function with
> sc->gfp_mask == GFP_NOFS|__GFP_NOFAIL|__GFP_HARDWALL|__GFP_MOVABLE
> requested_highidx = gfp_zone(sc->gfp_mask) == 2 (ZONE_NORMAL)
> 
> Inside the for loop, however:
> gfp_zone(sc->gfp_mask) == 3 (ZONE_MOVABLE)
> 
> This means we have gone through this branch:
> 
> if (buffer_heads_over_limit)
>     sc->gfp_mask |= __GFP_HIGHMEM;
> 
> This changes the gfp_zone() result, but requested_highidx remains unchanged.
> On nodes where the only populated zone is movable, the inner while loop will
> check only lower zones, which are not populated, and underflow classzone_idx.
> 

And this here is the key. It's a lowmem request when the only populated
zone is ZONE_MOVABLE without the __GFP_HIGHMEM flag being in the
original request.

It's somewhat of a corner case that on systems without highmem that the
movable zone is not used for lowmem requests that are __GFP_MOVABLE. However,
taking the approach of "fixing" that has it's own consequences for the
stability of memory hot-remove in general if it turns out that any of those
lowmem __GFP_MOVABLE requests are in fact not movable (can happen if it
turns out the page is permanently pinned if it's holdiing superblock data
pinned by the mount). In the general case, this is ok but for full memory
node removal, a "fix" in that direction will regress memory node hot-remove
and potentially stop it ever working once a filesystem was mounted.

There is a slight corner-case that a lowmem request may consider
the node to be prematurely balanced by this change in the event that
buffer_heads_over_limit is true. This may result in a second, potentially
redundant, direct reclaim request but the effect will be transient.
I expect that to be extremely rare and only apply in the case where the
ratio of ZONE_MOVABLE to ZONE_NORMAL is abnormally high (potentially due
to excessive use of movable_node).

Given the consequences of alternative fixes (backporting a massive
series that fundamentally alters reclaim and introducing a change that
potentiully breaks memory node removable), I consider this the safest
fix for this particular problem so;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

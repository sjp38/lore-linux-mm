Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5096B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 05:01:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so44916518wrc.7
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 02:01:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i23si13648832wrb.180.2017.07.04.02.01.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 02:01:42 -0700 (PDT)
Date: Tue, 4 Jul 2017 11:01:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable-only] mm: fix classzone_idx underflow in
 shrink_zones()
Message-ID: <20170704090139.GD14722@dhcp22.suse.cz>
References: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf25f1a5-5276-90ea-1eac-f2a2aceffaef@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: stable <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue 04-07-17 10:45:43, Vlastimil Babka wrote:
> Hi,
> 
> I realize this is against the standard stable policy, but I see no other
> way, because the mainline accidental fix is part of 34+ patch reclaim
> rework, that would be absurd to try to backport into stable. The fix is
> a one-liner though.
> 
> The bug affects at least 4.4.y, and likely also older stable trees that
> backported commit 7bf52fb891b6, which itself was a fix for 3.19 commit
> 6b4f7799c6a5. You could revert the 7bf52fb891b6 backport, but then 32bit
> with highmem might suffer from OOM or thrashing.
> 
> More details in the changelog itself.
> 
> ----8<----
> >From a1a1e459276298ac98827520e07923aa1219dbe1 Mon Sep 17 00:00:00 2001
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
> To sum up, the bug occurs in configurations with ZONE_MOVABLE (such as when
> booted with the movable_node parameter) and only in situations when
> buffer_heads_over_limit is true, and there's an allocation with __GFP_MOVABLE
> and without __GFP_HIGHMEM performing direct reclaim.
> 
> This patch makes sure that classzone_idx starts with the correct zone.
> 
> Mainline has been affected in versions 4.6 and 4.7, but the culprit commit has
> been also included in stable trees.
> In mainline, this has been fixed accidentally as part of 34-patch series (plus
> follow-up fixes) "Move LRU page reclaim from zones to nodes", which makes the
> mainline commit unsuitable for stable backport, unfortunately.
> 
> Fixes: 7bf52fb891b6 ("mm: vmscan: reclaim highmem zone if buffer_heads is over limit")
> Obsoleted-by: b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a per-node basis")
> Debugged-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: <stable@vger.kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2539,7 +2539,7 @@ static bool shrink_zones(struct zonelist
>  		if (!populated_zone(zone))
>  			continue;
>  
> -		classzone_idx = requested_highidx;
> +		classzone_idx = gfp_zone(sc->gfp_mask);
>  		while (!populated_zone(zone->zone_pgdat->node_zones +
>  							classzone_idx))
>  			classzone_idx--;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

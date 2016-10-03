Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4156B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 09:00:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f193so58890508wmg.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 06:00:02 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id q197si18644564wmb.145.2016.10.03.06.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 06:00:00 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id b201so80106086wmb.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 06:00:00 -0700 (PDT)
Date: Mon, 3 Oct 2016 14:59:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Crashes in refresh_zone_stat_thresholds when some nodes have no
 memory
Message-ID: <20161003125959.GD26768@dhcp22.suse.cz>
References: <20160804064410.GA20509@fergus.ozlabs.ibm.com>
 <20161003124716.GD26759@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003124716.GD26759@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Balbir Singh <bsingharora@gmail.com>, Nicholas Piggin <npiggin@gmail.com>

On Mon 03-10-16 14:47:16, Michal Hocko wrote:
> [Sorry I have only now noticed this email]
> 
> On Thu 04-08-16 16:44:10, Paul Mackerras wrote:
[...]
> > [    1.717648] Call Trace:
> > [    1.717687] [c000000ff0707b80] [c000000000270d08] refresh_zone_stat_thresholds+0xb8/0x240 (unreliable)
> > [    1.717818] [c000000ff0707bd0] [c000000000a1e4d4] init_per_zone_wmark_min+0x94/0xb0
> > [    1.717932] [c000000ff0707c30] [c00000000000b90c] do_one_initcall+0x6c/0x1d0
> > [    1.718036] [c000000ff0707cf0] [c000000000d04244] kernel_init_freeable+0x294/0x384
> > [    1.718150] [c000000ff0707dc0] [c00000000000c1a8] kernel_init+0x28/0x160
> > [    1.718249] [c000000ff0707e30] [c000000000009968] ret_from_kernel_thread+0x5c/0x74
> > [    1.718358] Instruction dump:
> > [    1.718408] 3fc20003 3bde4e34 3b800000 60420000 3860ffff 3fbb0001 4800001c 60420000 
> > [    1.718575] 3d220003 3929f8e0 7d49502a e93d9c00 <7f8a49ae> 38a30001 38800800 7ca507b4 
> > 
> > It turns out that we can get a pgdat in the online pgdat list where
> > pgdat->per_cpu_nodestats is NULL.  On my machine the pgdats for nodes
> > 1 and 17 are like this.  All the memory is in nodes 0 and 16.
> 
> How is this possible? setup_per_cpu_pageset does
> 
> 	for_each_online_pgdat(pgdat)
> 		pgdat->per_cpu_nodestats =
> 			alloc_percpu(struct per_cpu_nodestat);
> 
> so each online node should have the per_cpu_nodestat allocated.
> refresh_zone_stat_thresholds then does for_each_online_pgdat and
> for_each_populated_zone also shouldn't give any offline pgdat. Is it
> possible that this is yet another manifest of 6aa303defb74 ("mm, vmscan:
> only allocate and reclaim from zones with pages managed by the buddy
> allocator")? I guess the following should be sufficient?
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 73aab319969d..c170932a0101 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -185,6 +185,9 @@ void refresh_zone_stat_thresholds(void)
>  		struct pglist_data *pgdat = zone->zone_pgdat;
>  		unsigned long max_drift, tolerate_drift;
>  
> +		if (!managed_zone(zone))
> +			continue;
> +
>  		threshold = calculate_normal_threshold(zone);
>  
>  		for_each_online_cpu(cpu) {

Hmm, now that I am thinking about this some more I fail to understand
the crash. Even if a zone was poppulated but not managed it shouldn't
point to an offline node. So this smells like some race when a node is
brought up. What does addr2line tells about the instruction which
failed?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

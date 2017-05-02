Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34B306B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 03:54:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 65so834935wmi.2
        for <linux-mm@kvack.org>; Tue, 02 May 2017 00:54:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k203si43669wma.165.2017.05.02.00.54.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 00:54:34 -0700 (PDT)
Date: Tue, 2 May 2017 09:54:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: scan pages until it founds eligible pages
Message-ID: <20170502075432.GC14593@dhcp22.suse.cz>
References: <1493700038-27091-1-git-send-email-minchan@kernel.org>
 <20170502051452.GA27264@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170502051452.GA27264@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 02-05-17 14:14:52, Minchan Kim wrote:
> Oops, forgot to add lkml and linux-mm.
> Sorry for that.
> Send it again.
> 
> >From 8ddf1c8aa15baf085bc6e8c62ce705459d57ea4c Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 2 May 2017 12:34:05 +0900
> Subject: [PATCH] vmscan: scan pages until it founds eligible pages
> 
> On Tue, May 02, 2017 at 01:40:38PM +0900, Minchan Kim wrote:
> There are premature OOM happening. Although there are a ton of free
> swap and anonymous LRU list of elgible zones, OOM happened.
> 
> With investigation, skipping page of isolate_lru_pages makes reclaim
> void because it returns zero nr_taken easily so LRU shrinking is
> effectively nothing and just increases priority aggressively.
> Finally, OOM happens.

I am not really sure I understand the problem you are facing. Could you
be more specific please? What is your configuration etc...

> balloon invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=0, oom_score_adj=0
[...]
> Node 0 active_anon:1698864kB inactive_anon:261256kB active_file:208kB inactive_file:184kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:532kB dirty:108kB writeback:0kB shmem:172kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
> DMA free:7316kB min:32kB low:44kB high:56kB active_anon:8064kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:464kB slab_unreclaimable:40kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 992 992 1952
> DMA32 free:9088kB min:2048kB low:3064kB high:4080kB active_anon:952176kB inactive_anon:0kB active_file:36kB inactive_file:0kB unevictable:0kB writepending:88kB present:1032192kB managed:1019388kB mlocked:0kB slab_reclaimable:13532kB slab_unreclaimable:16460kB kernel_stack:3552kB pagetables:6672kB bounce:0kB free_pcp:56kB local_pcp:24kB free_cma:0kB
> lowmem_reserve[]: 0 0 0 959

Hmm DMA32 has sufficient free memory to allow this order-0 request.
Inactive anon lru is basically empty. Why do not we rotate a really
large active anon list? Isn't this the primary problem?

I haven't really looked at the patch deeply yet. It looks quite scary at
first sight though. I would really like to understand what exactly is
going on here before we move to a patch to fix it.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

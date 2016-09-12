Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E60B6B0260
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:16:38 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k12so93352683lfb.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 05:16:38 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id w6si14999758wmw.38.2016.09.12.05.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 05:16:37 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a6so13337459wmc.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 05:16:36 -0700 (PDT)
Date: Mon, 12 Sep 2016 14:16:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] scripts: Include postprocessing script for memory
 allocation tracing
Message-ID: <20160912121635.GL14524@dhcp22.suse.cz>
References: <20160911222411.GA2854@janani-Inspiron-3521>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160911222411.GA2854@janani-Inspiron-3521>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, rostedt@goodmis.org

Hi,
I am sorry I didn't follow up on the previous submission. I find this
_really_ helpful. It is great that you could build on top of existing
tracepoints but one thing is not entirely clear to me. Without a begin
marker in __alloc_pages_nodemask we cannot really tell how long the
whole allocation took, which would be extremely useful. Or do you use
any graph tracer tricks to deduce that? There is a note in your
changelog but I cannot seem to find that in the changelog. And FWIW I
would be open to adding a tracepoint like that. It would make our life
so much easier...

On Sun 11-09-16 18:24:12, Janani Ravichandran wrote:
[...]
> allocation_postprocess.py is a script which reads from trace_pipe. It
> does the following to filter out info from tracepoints that may not
> be important:
> 
> 1. Displays mm_vmscan_direct_reclaim_begin and
> mm_vmscan_direct_reclaim_end only when try_to_free_pages has
> exceeded the threshold.
> 2. Displays mm_compaction_begin and mm_compaction_end only when
> compact_zone has exceeded the threshold.
> 3. Displays mm_compaction_try_to_compat_pages only when
> try_to_compact_pages has exceeded the threshold.
> 4. Displays mm_shrink_slab_start and mm_shrink_slab_end only when
> the time elapsed between them exceeds the threshold.
> 5. Displays mm_vmscan_lru_shrink_inactive only when shrink_inactive_list
> has exceeded the threshold.
> 
> When CTRL+C is pressed, the script shows the times taken by the
> shrinkers. However, currently it is not possible to differentiate among
> the
> superblock shrinkers.
> 
> Sample output:
> ^Ci915_gem_shrinker_scan : total time = 8.731000 ms, max latency =
> 0.278000 ms
> ext4_es_scan : total time = 0.970000 ms, max latency = 0.129000 ms
> scan_shadow_nodes : total time = 1.150000 ms, max latency = 0.175000 ms
> super_cache_scan : total time = 8.455000 ms, max latency = 0.466000 ms
> deferred_split_scan : total time = 25.767000 ms, max latency = 25.485000
> ms

Would it be possible to group those per the context? I mean a single
allocation/per-process drop down values rather than mixing all those
values together? For example if I see that a process is talling due to
direct reclaim I would love to see what is the worst case allocation
stall and what is the most probable source of that stall. Mixing kswapd
traces would be misleading here.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

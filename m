Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA64C6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 11:01:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k15so3252361wrc.1
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 08:01:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o90si1056057edb.193.2017.11.02.08.01.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 08:01:22 -0700 (PDT)
Date: Thu, 2 Nov 2017 16:01:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: swapper/0: page allocation failure: order:0,
 mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Message-ID: <20171102150120.fb5qgrvmebbup64g@dhcp22.suse.cz>
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
 <20171019035641.GB23773@intel.com>
 <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
 <20171020064305.GA13688@intel.com>
 <20171020091239.cfwapdkx5g7afyp7@dhcp22.suse.cz>
 <CABXGCsMZ0hFFJyPU2cu+JDLHZ+5eO5i=8FOv71biwpY5neyofA@mail.gmail.com>
 <20171024200639.2pyxkw2cucwxrtlb@dhcp22.suse.cz>
 <CABXGCsPukABMx40dGz7NSjKsWVsz_USFFeHdEY-ZMdgRLCfuwQ@mail.gmail.com>
 <CABXGCsMVsn44xHH6SZxb6jrKv4S_GQFSqHNddAyDKOqNEpP6Ow@mail.gmail.com>
 <a6eab5f2-7ce5-d4fc-5524-0f6b3449742d@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6eab5f2-7ce5-d4fc-5524-0f6b3449742d@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, "Du, Changbin" <changbin.du@intel.com>, linux-mm@kvack.org

On Thu 02-11-17 22:15:06, Tetsuo Handa wrote:
> I was waiting for Michal's comment, but it seems that he is too busy now.
> Thus, I post non-authoritative comment here. (I'm not a tracepoints user.)

yes, that is the case. Thanks for looking into this Tetsuo.

> Two stalls were found in dmesg but only PID = 2798 part was recorded in the trace logs.
> 
>   [ 6109.502115] chrome: page allocation stalls for 10321ms, order:0, mode:0x14000d2(GFP_TEMPORARY|__GFP_HIGHMEM), nodemask=(null)
>   [ 6109.502179] chrome cpuset=/ mems_allowed=0
>   [ 6109.502570] CPU: 0 PID: 2798 Comm: chrome Not tainted 4.13.9-300.fc27.x86_64+debug #1
> 

I have only glanced through the trace data.

> So, trying to analyze this one. 
> 
> Since 10 seconds of blank was found between mm_shrink_slab_start and
> mm_shrink_slab_end, this alone can cause stall warning messages.
> 
>   # tracer: nop
>   #
>   #                              _-----=> irqs-off
>   #                             / _----=> need-resched
>   #                            | / _---=> hardirq/softirq
>   #                            || / _--=> preempt-depth
>   #                            ||| /     delay
>   #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
>   #              | |       |   ||||       |         |
>             chrome-2798  [000] .N.1  6099.188540: mm_shrink_slab_start: super_cache_scan+0x0/0x1b0 ffff8eefa4651830: nid: 0 objects to shrink 5895 gfp_flags GFP_TEMPORARY|__GFP_HIGHMEM pgs_scanned 90 lru_pgs 6992959 cache items 5049 delta 0 total_scan 2524
>             chrome-2798  [000] ...1  6109.494205: mm_shrink_slab_end: super_cache_scan+0x0/0x1b0 ffff8eefa4651830: nid: 0 unused scan count 5895 new scan count 941785 total_scan 476 last shrinker return val 1959

Yeah, the direct reclaim has started
chrome-2798  [000] ...1  6099.187991: mm_vmscan_direct_reclaim_begin: order=0 may_writepage=1 gfp_flags=GFP_TEMPORARY|__GFP_HIGHMEM classzone_idx=2
and finished
chrome-2798  [000] ...1  6109.509445: mm_vmscan_direct_reclaim_end: nr_reclaimed=51

the only notable hole in logging was the one pointed by Tetsuo. There is
a lot of activity on that CPU during that time wrt. reclaim
$ grep -v '\-2798' trace.txt | grep '\[000\]' | awk '{val=$4+0; if (val > 6099 && val < 6109) print}' | wc -l
744

And there were more processes involved
$ grep -v '\-2798' trace.txt | grep '\[000\]' | awk '{val=$4+0; if (val > 6099 && val < 6109) print $1}' | sort | uniq -c
     74 <...>-10654
     43 <...>-13862
     82 <...>-17624
      2 <...>-27318
      1 <...>-3518
     37 <...>-5331
    180 <...>-6602
     38 chrome-3482
     40 Chrome_IOThread-2773
      3 DedicatedWorker-19604
      1 gmain-10668
    139 qemu-system-x86-13763
    104 TaskSchedulerBa-6011

So I agree that it looks like your system seems to be overloaded.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

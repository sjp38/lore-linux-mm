Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE4346B0260
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:15:22 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t10so5980034pgo.20
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:15:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a3si2302310pld.455.2017.11.02.06.15.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 06:15:21 -0700 (PDT)
Subject: Re: swapper/0: page allocation failure: order:0,
 mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
 <20171019035641.GB23773@intel.com>
 <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
 <20171020064305.GA13688@intel.com>
 <20171020091239.cfwapdkx5g7afyp7@dhcp22.suse.cz>
 <CABXGCsMZ0hFFJyPU2cu+JDLHZ+5eO5i=8FOv71biwpY5neyofA@mail.gmail.com>
 <20171024200639.2pyxkw2cucwxrtlb@dhcp22.suse.cz>
 <CABXGCsPukABMx40dGz7NSjKsWVsz_USFFeHdEY-ZMdgRLCfuwQ@mail.gmail.com>
 <CABXGCsMVsn44xHH6SZxb6jrKv4S_GQFSqHNddAyDKOqNEpP6Ow@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <a6eab5f2-7ce5-d4fc-5524-0f6b3449742d@I-love.SAKURA.ne.jp>
Date: Thu, 2 Nov 2017 22:15:06 +0900
MIME-Version: 1.0
In-Reply-To: <CABXGCsMVsn44xHH6SZxb6jrKv4S_GQFSqHNddAyDKOqNEpP6Ow@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: "Du, Changbin" <changbin.du@intel.com>, linux-mm@kvack.org

I was waiting for Michal's comment, but it seems that he is too busy now.
Thus, I post non-authoritative comment here. (I'm not a tracepoints user.)

On 2017/10/30 6:48, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> On 26 October 2017 at 22:49, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2
> <mikhail.v.gavrilov@gmail.com> wrote:
>> On 25 October 2017 at 01:06, Michal Hocko <mhocko@kernel.org> wrote:
>>>> [ 3551.169126] chrome: page allocation stalls for 11542ms, order:0,
>>>> mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
>>>
>>> this is a sleeping allocation which means that it is allowed to perform
>>> the direct reclaim and that took a lot of time here. This is really
>>> unusual and worth debugging some more.
>>>
>>> [...]
>>>> [ 3551.169590] Mem-Info:
>>>> [ 3551.169595] active_anon:6904352 inactive_anon:520427 isolated_anon:0
>>>>                 active_file:55480 inactive_file:38890 isolated_file:0
>>>>                 unevictable:1836 dirty:556 writeback:0 unstable:0
>>>>                 slab_reclaimable:67559 slab_unreclaimable:95967
>>>>                 mapped:353547 shmem:480723 pagetables:89161 bounce:0
>>>>                 free:49404 free_pcp:1474 free_cma:0
>>>
>>> This tells us that there is quite some page cache (file LRUs) to reclaim
>>> so I am wondering what could have caused such a delay. In order to debug
>>> this some more we would need an additional debugging information. I
>>> usually enable vmscan tracepoints to watch for events during the
>>> reclaim.
>>>
>>
>> I able got the needed tracepoints logs.
>> If I understanded correctly vmscan tracepoints are possible enable by
>> option 1 in the file /sys/kernel/debug/tracing/events/vmscan/enable
>> All archives attached to this email.
>>

Two stalls were found in dmesg but only PID = 2798 part was recorded in the trace logs.

  [ 6109.502115] chrome: page allocation stalls for 10321ms, order:0, mode:0x14000d2(GFP_TEMPORARY|__GFP_HIGHMEM), nodemask=(null)
  [ 6109.502179] chrome cpuset=/ mems_allowed=0
  [ 6109.502570] CPU: 0 PID: 2798 Comm: chrome Not tainted 4.13.9-300.fc27.x86_64+debug #1

So, trying to analyze this one. 

Since 10 seconds of blank was found between mm_shrink_slab_start and
mm_shrink_slab_end, this alone can cause stall warning messages.

  # tracer: nop
  #
  #                              _-----=> irqs-off
  #                             / _----=> need-resched
  #                            | / _---=> hardirq/softirq
  #                            || / _--=> preempt-depth
  #                            ||| /     delay
  #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
  #              | |       |   ||||       |         |
            chrome-2798  [000] .N.1  6099.188540: mm_shrink_slab_start: super_cache_scan+0x0/0x1b0 ffff8eefa4651830: nid: 0 objects to shrink 5895 gfp_flags GFP_TEMPORARY|__GFP_HIGHMEM pgs_scanned 90 lru_pgs 6992959 cache items 5049 delta 0 total_scan 2524
            chrome-2798  [000] ...1  6109.494205: mm_shrink_slab_end: super_cache_scan+0x0/0x1b0 ffff8eefa4651830: nid: 0 unused scan count 5895 new scan count 941785 total_scan 476 last shrinker return val 1959

Since need-resched flag was set as of mm_shrink_slab_start and was not set
as of mm_shrink_slab_end, and last shrinker return val is larger than 0,
PID = 2798 has called cond_resched() inside "while" loop in do_shrink_slab().

During this blank, CPU 0 recorded many mm_vmscan_writepage: lines
with flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC. What is strange is that
there was 4.7 seconds of blank inside of 10 seconds of blank.

             <...>-13862 [000] .N.1  6102.008806: mm_vmscan_direct_reclaim_end: nr_reclaimed=42
   qemu-system-x86-13763 [000] ...1  6106.732115: mm_shrink_slab_end: super_cache_scan+0x0/0x1b0 ffff8eefa4651830: nid: 0 unused scan count 7 new scan count 1079551 total_scan 0 last shrinker return val 0

I wonder what CPU 0 was doing for this blank period.

> 
> I was able to catch this issue again.
> Is there anything interesting in the trace logs?

Nothing interesting was recorded. What is interesting is that nothing
about PID = 6542 was recorded in the trace logs. It stalled for more
than 10 seconds without ever hitting vmscan tracepoints!?

  [ 8445.912332] CFileWriterThre: page allocation stalls for 12123ms, order:4, mode:0x140c4c0(GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_COMP|__GFP_ZERO), nodemask=(null)
  [ 8445.912355] CFileWriterThre cpuset=/ mems_allowed=0
  [ 8445.912501] CPU: 3 PID: 6542 Comm: CFileWriterThre Not tainted 4.13.9-300.fc27.x86_64+debug #1

I can't tell whether enabling more tracepoints gives us some clue. But
your system might be merely overloaded. Your system is hosting a lot of
processes including QEMU and Chrome on 8 CPUs + 32GB RAM + 64GB swap and
nearly a half of swap is in use, isn't it?

Anyway, this allocation stall warning mechanism is about to be removed
( http://lkml.kernel.org/r/1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

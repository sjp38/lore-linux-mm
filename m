Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5C36B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 16:41:43 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so255030wgh.14
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 13:41:42 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id g1si3736653wib.94.2014.08.13.13.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 13:41:41 -0700 (PDT)
Date: Wed, 13 Aug 2014 16:41:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/4] mm: memcontrol: reduce reclaim invocations for
 higher order requests
Message-ID: <20140813204134.GA20932@cmpxchg.org>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-2-git-send-email-hannes@cmpxchg.org>
 <20140807130822.GB12730@dhcp22.suse.cz>
 <20140807153141.GD14734@cmpxchg.org>
 <20140808123258.GK4004@dhcp22.suse.cz>
 <20140808132635.GJ14734@cmpxchg.org>
 <20140813145904.GC2775@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140813145904.GC2775@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Aug 13, 2014 at 04:59:04PM +0200, Michal Hocko wrote:
> On Fri 08-08-14 09:26:35, Johannes Weiner wrote:
> > On Fri, Aug 08, 2014 at 02:32:58PM +0200, Michal Hocko wrote:
> > > On Thu 07-08-14 11:31:41, Johannes Weiner wrote:
> [...]
> > > > THP latencies are actually the same when comparing high limit nr_pages
> > > > reclaim with the current hard limit SWAP_CLUSTER_MAX reclaim,
> > > 
> > > Are you sure about this? I fail to see how they can be same as THP
> > > allocations/charges are __GFP_NORETRY so there is only one reclaim
> > > round for the hard limit reclaim followed by the charge failure if
> > > it is not successful.
> > 
> > I use this test program that faults in anon pages, reports average and
> > max for every 512-page chunk (THP size), then reports the aggregate at
> > the end:
> > 
> > memory.max:
> > 
> > avg=18729us max=450625us
> > 
> > real    0m14.335s
> > user    0m0.157s
> > sys     0m6.307s
> > 
> > memory.high:
> > 
> > avg=18676us max=457499us
> > 
> > real    0m14.375s
> > user    0m0.046s
> > sys     0m4.294s
> 
> I was playing with something like that as well. mmap 800MB anon mapping
> in 256MB memcg (kvm guest had 1G RAM and 2G swap so the global reclaim
> doesn't trigger and the host 2G free memory), start faulting in from
> THP aligned address and measured each fault. Then I was recording
> mm_vmscan_lru_shrink_inactive and mm_vmscan_memcg_reclaim_{begin,end}
> tracepoints to see how the reclaim went.
> 
> I was testing two setups
> 1) fault in every 4k page
> 2) fault in only 2M aligned addresses.
>
> The first simulates the case where successful THP allocation saves
> follow up 511 fallback charges and so the excessive reclaim might
> pay off.
> The second one simulates potential time wasting when memory is used
> extremely sparsely and any latencies would be unwelcome.
> 
> (new refers to nr_reclaim target, old to SWAP_CLUSTER_MAX, thponly
> faults only 2M aligned addresses, 4k pages are faulted otherwise)
> 
> vmstat says:
> out.256m.new-thponly.vmstat.after:pswpin 44
> out.256m.new-thponly.vmstat.after:pswpout 154681
> out.256m.new-thponly.vmstat.after:thp_fault_alloc 399
> out.256m.new-thponly.vmstat.after:thp_fault_fallback 0
> out.256m.new-thponly.vmstat.after:thp_split 302
> 
> out.256m.old-thponly.vmstat.after:pswpin 28
> out.256m.old-thponly.vmstat.after:pswpout 31271
> out.256m.old-thponly.vmstat.after:thp_fault_alloc 149
> out.256m.old-thponly.vmstat.after:thp_fault_fallback 250
> out.256m.old-thponly.vmstat.after:thp_split 61
> 
> out.256m.new.vmstat.after:pswpin 48
> out.256m.new.vmstat.after:pswpout 169530
> out.256m.new.vmstat.after:thp_fault_alloc 399
> out.256m.new.vmstat.after:thp_fault_fallback 0
> out.256m.new.vmstat.after:thp_split 331
> 
> out.256m.old.vmstat.after:pswpin 47
> out.256m.old.vmstat.after:pswpout 156514
> out.256m.old.vmstat.after:thp_fault_alloc 127
> out.256m.old.vmstat.after:thp_fault_fallback 272
> out.256m.old.vmstat.after:thp_split 127
> 
> As expected new managed to fault in all requests as THP without a single
> fallback allocation while with the old reclaim we got to the limit and
> then most of the THP charges failed and fallen back to single page
> charge.

In a more realistic workload, global reclaim and compaction have to
invest a decent amount of work to create the 2MB page in the first
place.  You would be wasting this work on the off-chance that only a
small part of the THP is actually used.  Once that 2MB page is already
assembled, I don't think the burden on memcg is high enough to justify
wasting that work speculatively.

If we really have a latency issue here, I think the right solution is
to attempt the charge first - because it's much less work - and only
if it succeeds allocate and commit an actual 2MB physical page.

But I have yet to be convinced that there is a practical issue here.
Who uses only 4k out of every 2MB area and enables THP?  The 'thponly'
scenario is absurd.

> Note the increased swapout activity for new. It is almost 5x more for
> thponly and +8% with per-page faults. This looks like a fallout from the
> over-reclaim in smaller priorities.
>
> - trace.new
>     229 0
>       3 12
> - trace.old
>     294 0
>       2 1
>      25 10
>       1 11
>       3 12
>       8 2
>       8 3
>      20 4
>      33 5
>      21 6
>      43 7
>    1286 8
>    1279 9
> 
> And here as well, we have to reclaim much more because we do much more
> charges so the load benefits a bit from the high reclaim target.
>
> mm_vmscan_memcg_reclaim_end tracepoint tells us also how many pages were
> reclaimed during each run and the cummulative numbers are:
> - trace.new-thponly: 139029
> - trace.old-thponly: 11344
> - trace.new: 139687
> - trace.old: 139887

Here the number of reclaimed pages is actually lower in new, so I'm
guessing the increase in swapouts above is variation between runs, as
there doesn't seem to be a significant amount of cache in that group.

> time -v says:
> out.256m.new-thponly.time:      System time (seconds): 1.50
> out.256m.new-thponly.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:13.56
> out.256m.old-thponly.time:      System time (seconds): 0.45
> out.256m.old-thponly.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:03.76
> 
> out.256m.new.time:      System time (seconds): 1.45
> out.256m.new.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:15.12
> out.256m.old.time:      System time (seconds): 2.08
> out.256m.old.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:15.26
> 
> I guess this is expected as well. Sparse access doesn't amortize the
> costly reclaim for each charged THP. On the other hand it can help a bit
> if the whole mmap is populated.
>
> If we compare fault latencies then we get the following:
> - the worst latency [ms]:
> out.256m.new-thponly 1991
> out.256m.old-thponly 1838
> out.256m.new 6197
> out.256m.old 5538
> 
> - top 5 worst latencies (sum in [ms]):
> out.256m.new-thponly 5694
> out.256m.old-thponly 3168
> out.256m.new 9498
> out.256m.old 8291
> 
> - top 10
> out.256m.new-thponly 7139
> out.256m.old-thponly 3193
> out.256m.new 11786
> out.256m.old 9347
> 
> - top 100
> out.256m.new-thponly 13035
> out.256m.old-thponly 3434
> out.256m.new 14634
> out.256m.old 12881
> 
> I think this shows up that my concern about excessive reclaim and stalls
> is real and it is worse when the memory is used sparsely. It is true it
> might help when the whole THP section is used and so the additional cost
> is amortized but the more sparsely each THP section is used the higher
> overhead you are adding without userspace actually asking for it.

THP is expected to have some overhead in terms of initial fault cost
and space efficiency, don't use it when you get little to no benefit
from it.  It can be argued that my patch moves that breakeven point a
little bit, but the THP-positive end of the spectrum is much better
off: THP coverage goes from 37% to 100%, while reclaim efficiency is
significantly improved and system time significantly reduced.

You demonstrated a THP-workload that really benefits from my change,
and another workload that shouldn't be using THP in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

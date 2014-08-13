Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 343496B0038
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 10:59:09 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id mc6so9373773lab.34
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 07:59:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13si3297771lbv.9.2014.08.13.07.59.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 07:59:07 -0700 (PDT)
Date: Wed, 13 Aug 2014 16:59:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/4] mm: memcontrol: reduce reclaim invocations for
 higher order requests
Message-ID: <20140813145904.GC2775@dhcp22.suse.cz>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-2-git-send-email-hannes@cmpxchg.org>
 <20140807130822.GB12730@dhcp22.suse.cz>
 <20140807153141.GD14734@cmpxchg.org>
 <20140808123258.GK4004@dhcp22.suse.cz>
 <20140808132635.GJ14734@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140808132635.GJ14734@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 08-08-14 09:26:35, Johannes Weiner wrote:
> On Fri, Aug 08, 2014 at 02:32:58PM +0200, Michal Hocko wrote:
> > On Thu 07-08-14 11:31:41, Johannes Weiner wrote:
[...]
> > > THP latencies are actually the same when comparing high limit nr_pages
> > > reclaim with the current hard limit SWAP_CLUSTER_MAX reclaim,
> > 
> > Are you sure about this? I fail to see how they can be same as THP
> > allocations/charges are __GFP_NORETRY so there is only one reclaim
> > round for the hard limit reclaim followed by the charge failure if
> > it is not successful.
> 
> I use this test program that faults in anon pages, reports average and
> max for every 512-page chunk (THP size), then reports the aggregate at
> the end:
> 
> memory.max:
> 
> avg=18729us max=450625us
> 
> real    0m14.335s
> user    0m0.157s
> sys     0m6.307s
> 
> memory.high:
> 
> avg=18676us max=457499us
> 
> real    0m14.375s
> user    0m0.046s
> sys     0m4.294s

I was playing with something like that as well. mmap 800MB anon mapping
in 256MB memcg (kvm guest had 1G RAM and 2G swap so the global reclaim
doesn't trigger and the host 2G free memory), start faulting in from
THP aligned address and measured each fault. Then I was recording
mm_vmscan_lru_shrink_inactive and mm_vmscan_memcg_reclaim_{begin,end}
tracepoints to see how the reclaim went.

I was testing two setups
1) fault in every 4k page
2) fault in only 2M aligned addresses.

The first simulates the case where successful THP allocation saves
follow up 511 fallback charges and so the excessive reclaim might
pay off.
The second one simulates potential time wasting when memory is used
extremely sparsely and any latencies would be unwelcome.

(new refers to nr_reclaim target, old to SWAP_CLUSTER_MAX, thponly
faults only 2M aligned addresses, 4k pages are faulted otherwise)

vmstat says:
out.256m.new-thponly.vmstat.after:pswpin 44
out.256m.new-thponly.vmstat.after:pswpout 154681
out.256m.new-thponly.vmstat.after:thp_fault_alloc 399
out.256m.new-thponly.vmstat.after:thp_fault_fallback 0
out.256m.new-thponly.vmstat.after:thp_split 302

out.256m.old-thponly.vmstat.after:pswpin 28
out.256m.old-thponly.vmstat.after:pswpout 31271
out.256m.old-thponly.vmstat.after:thp_fault_alloc 149
out.256m.old-thponly.vmstat.after:thp_fault_fallback 250
out.256m.old-thponly.vmstat.after:thp_split 61

out.256m.new.vmstat.after:pswpin 48
out.256m.new.vmstat.after:pswpout 169530
out.256m.new.vmstat.after:thp_fault_alloc 399
out.256m.new.vmstat.after:thp_fault_fallback 0
out.256m.new.vmstat.after:thp_split 331

out.256m.old.vmstat.after:pswpin 47
out.256m.old.vmstat.after:pswpout 156514
out.256m.old.vmstat.after:thp_fault_alloc 127
out.256m.old.vmstat.after:thp_fault_fallback 272
out.256m.old.vmstat.after:thp_split 127

As expected new managed to fault in all requests as THP without a single
fallback allocation while with the old reclaim we got to the limit and
then most of the THP charges failed and fallen back to single page
charge.

Note the increased swapout activity for new. It is almost 5x more for
thponly and +8% with per-page faults. This looks like a fallout from the
over-reclaim in smaller priorities.

Tracepoints will tell us the priority at which we ended up the reclaim
round:
- trace.new-thponly
  Count Priority
      1 3
      2 5
    159 6
     24 7
- trace.old-thponly
    230 10
      1 11
      1 12
      1 3
     39 9

Again expected that the priority is falling down for the new much more.

- trace.new
    229 0
      3 12
- trace.old
    294 0
      2 1
     25 10
      1 11
      3 12
      8 2
      8 3
     20 4
     33 5
     21 6
     43 7
   1286 8
   1279 9

And here as well, we have to reclaim much more because we do much more
charges so the load benefits a bit from the high reclaim target.

mm_vmscan_memcg_reclaim_end tracepoint tells us also how many pages were
reclaimed during each run and the cummulative numbers are:
- trace.new-thponly: 139029
- trace.old-thponly: 11344
- trace.new: 139687
- trace.old: 139887

time -v says:
out.256m.new-thponly.time:      System time (seconds): 1.50
out.256m.new-thponly.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:13.56
out.256m.old-thponly.time:      System time (seconds): 0.45
out.256m.old-thponly.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:03.76

out.256m.new.time:      System time (seconds): 1.45
out.256m.new.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:15.12
out.256m.old.time:      System time (seconds): 2.08
out.256m.old.time:      Elapsed (wall clock) time (h:mm:ss or m:ss): 0:15.26

I guess this is expected as well. Sparse access doesn't amortize the
costly reclaim for each charged THP. On the other hand it can help a bit
if the whole mmap is populated.

If we compare fault latencies then we get the following:
- the worst latency [ms]:
out.256m.new-thponly 1991
out.256m.old-thponly 1838
out.256m.new 6197
out.256m.old 5538

- top 5 worst latencies (sum in [ms]):
out.256m.new-thponly 5694
out.256m.old-thponly 3168
out.256m.new 9498
out.256m.old 8291

- top 10
out.256m.new-thponly 7139
out.256m.old-thponly 3193
out.256m.new 11786
out.256m.old 9347

- top 100
out.256m.new-thponly 13035
out.256m.old-thponly 3434
out.256m.new 14634
out.256m.old 12881

I think this shows up that my concern about excessive reclaim and stalls
is real and it is worse when the memory is used sparsely. It is true it
might help when the whole THP section is used and so the additional cost
is amortized but the more sparsely each THP section is used the higher
overhead you are adding without userspace actually asking for it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

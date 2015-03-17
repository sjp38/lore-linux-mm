Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAE46B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 18:08:45 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so21662742pad.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:08:45 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id er5si31807075pad.227.2015.03.17.15.08.43
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 15:08:44 -0700 (PDT)
Date: Wed, 18 Mar 2015 09:08:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150317220840.GC28621@dastard>
References: <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
 <20150309191943.GF26657@destitution>
 <CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
 <20150312131045.GE3406@suse.de>
 <CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
 <20150312184925.GH3406@suse.de>
 <20150317070655.GB10105@dastard>
 <CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
 <20150317205104.GA28621@dastard>
 <CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Mar 17, 2015 at 02:30:57PM -0700, Linus Torvalds wrote:
> On Tue, Mar 17, 2015 at 1:51 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > On the -o ag_stride=-1 -o bhash=101073 config, the 60s perf stat I
> > was using during steady state shows:
> >
> >      471,752      migrate:mm_migrate_pages ( +-  7.38% )
> >
> > The migrate pages rate is even higher than in 4.0-rc1 (~360,000)
> > and 3.19 (~55,000), so that looks like even more of a problem than
> > before.
> 
> Hmm. How stable are those numbers boot-to-boot?

I've run the test several times but only profiles once so far.
runtimes were 7m45, 7m50, 7m44s, 8m2s, and the profiles came from
the 8m2s run.

reboot, run again:

$ sudo perf stat -a -r 6 -e migrate:mm_migrate_pages sleep 10

 Performance counter stats for 'system wide' (6 runs):

           572,839      migrate:mm_migrate_pages    ( +-  3.15% )

      10.001664694 seconds time elapsed             ( +-  0.00% )
$

And just to confirm, a minute later, still in phase 3:

	590,974      migrate:mm_migrate_pages       ( +-  2.86% )

Reboot, run again:

	575,344      migrate:mm_migrate_pages       ( +-  0.70% )

So there is boot-to-boot variation, but it doesn't look like it
gets any better....

> That kind of extreme spread makes me suspicious. It's also interesting
> that if the numbers really go up even more (and by that big amount),
> then why does there seem to be almost no correlation with performance
> (which apparently went up since rc1, despite migrate_pages getting
> even _worse_).
> 
> > And the profile looks like:
> >
> > -   43.73%     0.05%  [kernel]            [k] native_flush_tlb_others
> 
> Ok, that's down from rc1 (67%), but still hugely up from 3.19 (13.7%).
> And flush_tlb_page() does seem to be called about ten times more
> (flush_tlb_mm_range used to be 1.4% of the callers, now it's invisible
> at 0.13%)
> 
> Damn. From a performance number standpoint, it looked like we zoomed
> in on the right thing. But now it's migrating even more pages than
> before. Odd.

Throttling problem, like Mel originally suspected?

> > And the vmstats are:
> >
> > 3.19:
> >
> > numa_hit 5163221
> > numa_local 5153127
> 
> > 4.0-rc1:
> >
> > numa_hit 36952043
> > numa_local 36927384
> >
> > 4.0-rc4:
> >
> > numa_hit 23447345
> > numa_local 23438564
> >
> > Page migrations are still up by a factor of ~20 on 3.19.
> 
> The thing is, those "numa_hit" things come from the zone_statistics()
> call in buffered_rmqueue(), which in turn is simple from the memory
> allocator. That has *nothing* to do with virtual memory, and
> everything to do with actual physical memory allocations.  So the load
> is simply allocating a lot more pages, presumably for those stupid
> migration events.
> 
> But then it doesn't correlate with performance anyway..
>
> Can you do a simple stupid test? Apply that commit 53da3bc2ba9e ("mm:
> fix up numa read-only thread grouping logic") to 3.19, so that it uses
> the same "pte_dirty()" logic as 4.0-rc4. That *should* make the 3.19
> and 4.0-rc4 numbers comparable.

patched 3.19 numbers on this test are slightly worse than stock
3.19, but nowhere near as bad as 4.0-rc4:

	241,718      migrate:mm_migrate_pages		( +-  5.17% )

So that pte_write->pte_dirty change makes this go from ~55k to 240k,
and runtime go from 4m54s to 5m20s. vmstats:

numa_hit 9162476
numa_miss 0
numa_foreign 0
numa_interleave 10685
numa_local 9153740
numa_other 8736
numa_pte_updates 49582103
numa_huge_pte_updates 0
numa_hint_faults 48075098
numa_hint_faults_local 12974704
numa_pages_migrated 5748256
pgmigrate_success 5748256
pgmigrate_fail 0

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

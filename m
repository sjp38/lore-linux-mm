Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 32FDD6B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 16:51:21 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so20135722pdb.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 13:51:20 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id q3si12170676pdr.138.2015.03.17.13.51.18
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 13:51:19 -0700 (PDT)
Date: Wed, 18 Mar 2015 07:51:05 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150317205104.GA28621@dastard>
References: <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
 <20150309112936.GD26657@destitution>
 <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
 <20150309191943.GF26657@destitution>
 <CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
 <20150312131045.GE3406@suse.de>
 <CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
 <20150312184925.GH3406@suse.de>
 <20150317070655.GB10105@dastard>
 <CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Mar 17, 2015 at 09:53:57AM -0700, Linus Torvalds wrote:
> On Tue, Mar 17, 2015 at 12:06 AM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > TO close the loop here, now I'm back home and can run tests:
> >
> > config                            3.19      4.0-rc1     4.0-rc4
> > defaults                         8m08s        9m34s       9m14s
> > -o ag_stride=-1                  4m04s        4m38s       4m11s
> > -o bhash=101073                  6m04s       17m43s       7m35s
> > -o ag_stride=-1,bhash=101073     4m54s        9m58s       7m50s
> >
> > It's better but there are still significant regressions, especially
> > for the large memory footprint cases. I haven't had a chance to look
> > at any stats or profiles yet, so I don't know yet whether this is
> > still page fault related or some other problem....
> 
> Ok. I'd love to see some data on what changed between 3.19 and rc4 in
> the profiles, just to see whether it's "more page faults due to extra
> COW", or whether it's due to "more TLB flushes because of the
> pte_write() vs pte_dirty()" differences. I'm *guessing*  lot of the
> remaining issues are due to extra page fault overhead because I'd
> expect write/dirty to be fairly 1:1, but there could be differences
> due to shared memory use and/or just writebacks of dirty pages that
> become clean.
> 
> I guess you can also see in vmstat.mm_migrate_pages whether it's
> because of excessive migration (because of bad grouping) or not. So
> not just profiles data.

On the -o ag_stride=-1 -o bhash=101073 config, the 60s perf stat I
was using during steady state shows:

     471,752      migrate:mm_migrate_pages ( +-  7.38% )

The migrate pages rate is even higher than in 4.0-rc1 (~360,000)
and 3.19 (~55,000), so that looks like even more of a problem than
before.

And the profile looks like:

-   43.73%     0.05%  [kernel]            [k] native_flush_tlb_others
   - native_flush_tlb_others
      - 99.87% flush_tlb_page
           ptep_clear_flush
           try_to_unmap_one
           rmap_walk
           try_to_unmap
           migrate_pages
           migrate_misplaced_page
         - handle_mm_fault
            - 99.84% __do_page_fault
                 trace_do_page_fault
                 do_async_page_fault
               + async_page_fault

(grrrr - running perf with call stack profiling for long enough
oom-kills xfs_repair)

And the vmstats are:

3.19:

numa_hit 5163221
numa_miss 121274
numa_foreign 121274
numa_interleave 12116
numa_local 5153127
numa_other 131368
numa_pte_updates 36482466
numa_huge_pte_updates 0
numa_hint_faults 34816515
numa_hint_faults_local 9197961
numa_pages_migrated 1228114
pgmigrate_success 1228114
pgmigrate_fail 0

4.0-rc1:

numa_hit 36952043
numa_miss 92471
numa_foreign 92471
numa_interleave 10964
numa_local 36927384
numa_other 117130
numa_pte_updates 84010995
numa_huge_pte_updates 0
numa_hint_faults 81697505
numa_hint_faults_local 21765799
numa_pages_migrated 32916316
pgmigrate_success 32916316
pgmigrate_fail 0

4.0-rc4:

numa_hit 23447345
numa_miss 47471
numa_foreign 47471
numa_interleave 10877
numa_local 23438564
numa_other 56252
numa_pte_updates 60901329
numa_huge_pte_updates 0
numa_hint_faults 58777092
numa_hint_faults_local 16478674
numa_pages_migrated 20075156
pgmigrate_success 20075156
pgmigrate_fail 0

Page migrations are still up by a factor of ~20 on 3.19.


> At the same time, I feel fairly happy about the situation - we at
> least understand what is going on, and the "3x worse performance" case
> is at least gone.  Even if that last case still looks horrible.
> 
> So it's still a bad performance regression, but at the same time I
> think your test setup (big 500 TB filesystem, but then a fake-numa
> thing with just 4GB per node) is specialized and unrealistic enough
> that I don't feel it's all that relevant from a *real-world*
> standpoint,

I don't buy it.

The regression is triggered by the search algorithm that
xfs_repair uses, and it's fairly common. It just uses a large hash
table which has at least a 50% miss rate (every I/O misses on the
initial lookup). The page faults are triggered by searching all
these pointer chasing misses.

IOWs the filesystem size under test is irrelevant - the amount of
metadata in the FS determines the xfs_repair memory footprint. The
fs size only determines concurrency, but this particular test case
(ag_stride=-1) turns off the concurrency.  Hence we'll see the same
problem with a 1TB filesystem with 50 million inodes in it, and
there's *lots* of those around.

Also, to address the "fake-numa" setup - the problem is node-local
allocation policy, not the size of the nodes.  The repair threads
wander all over the machine, even when there are only 8 threads
running (ag_stride=-1):

$ ps wauxH |grep  xfs_repair |wc -l
8
$

top - 07:31:08 up 24 min,  2 users,  load average: 1.75, 0.62, 0.69
Tasks: 240 total,   1 running, 239 sleeping,   0 stopped,   0 zombie
%Cpu0  :  3.2 us, 13.4 sy,  0.0 ni, 63.6 id, 19.8 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu1  :  0.0 us,  0.0 sy,  0.0 ni, 99.7 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu2  :  1.4 us,  8.5 sy,  0.0 ni, 74.7 id, 15.4 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu3  :  1.0 us,  1.7 sy,  0.0 ni, 83.2 id, 14.1 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu4  :  0.0 us,  0.7 sy,  0.0 ni, 98.7 id,  0.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu5  :  4.0 us, 21.7 sy,  0.0 ni, 56.5 id, 17.8 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu6  :  1.0 us,  2.3 sy,  0.0 ni, 92.4 id,  4.3 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu7  :  2.0 us, 13.5 sy,  0.0 ni, 80.7 id,  3.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu8  : 18.8 us,  2.7 sy,  0.0 ni, 78.5 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu9  :  1.4 us, 10.2 sy,  0.0 ni, 87.4 id,  1.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu10 :  2.4 us, 13.2 sy,  0.0 ni, 84.5 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu11 :  1.0 us,  6.1 sy,  0.0 ni, 88.6 id,  4.4 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu12 :  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu13 :  0.7 us,  5.4 sy,  0.0 ni, 79.3 id, 14.6 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu14 :  0.3 us,  0.7 sy,  0.0 ni, 93.3 id,  5.7 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu15 :  2.7 us,  9.3 sy,  0.0 ni, 87.7 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st

So, 8 threads doing work, 16 cpu cores, and only one fully idle
processor core in the machine over a 5s sample period.  Hence it
seems to me that process memory is getting sprayed over all nodes
because of the way the scheduler processes move around, not because
of the small memory size of the numa nodes.

> and so I wouldn't be uncomfortable saying "ok, the page
> table handling cleanup caused some issues, but we know about them and
> how to fix them longer-term".  So I don't consider this a 4.0
> showstopper or a "we need to revert for now" issue.

I don't consider it necessary of a revert, either, but I don't want
it swept under the table because of "workload not relevant"
arguments.

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

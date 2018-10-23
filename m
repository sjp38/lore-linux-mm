Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B08536B000A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 04:39:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e5-v6so609711eda.4
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 01:39:01 -0700 (PDT)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id f4-v6si467329ejt.329.2018.10.23.01.38.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Oct 2018 01:38:59 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id 9E87DB8782
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:38:59 +0100 (IST)
Date: Tue, 23 Oct 2018 09:38:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181023083826.GA23537@techsingularity.net>
References: <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
 <20181016074606.GH6931@suse.de>
 <alpine.DEB.2.21.1810221355050.120157@chino.kir.corp.google.com>
 <20181023075745.GA28684@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181023075745.GA28684@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue, Oct 23, 2018 at 08:57:45AM +0100, Mel Gorman wrote:
> Note that I accept it's trivial to fragment memory in a harmful way.
> I've prototyped a test case yesterday that uses fio in the following way
> to fragment memory
> 
> o fio of many small files (64K)
> o create initial pages using writes that disable fallocate and create
>   inodes on first open. This is massively inefficient from an IO
>   perspective but it mixes slab and page cache allocations so all
>   NUMA nodes get fragmented.
> o Size the page cache so that it's 150% the size of memory so it forces
>   reclaim activity and new fio activity to further mix slab and page
>   cache allocations
> o After initial write, run parallel readers to keep slab active and run
>   this for the same length of time the initial writes took so fio has
>   called stat() on the existing files and begun the read phase. This
>   forces the slab and page cache pages to remain "live" and difficult
>   to reclaim/compact.
> o Finally, start a workload that allocates THP after the warmup phase
>   but while fio is still runnning to measure allocation success rate
>   and latencies
> 

The tests completed shortly after I wrote this mail so I can put some
figures to the intuitions expressed in this mail. I'm truncating the
reports for clarity but can upload the full data if necessary.

The target system is a 2-socket using E5-2670 v3 (Haswell). Base kernel
is 4.19. The baseline is an unpatched kernel. relaxthisnode-v1r1 is
patch 1 of Michal's series and does not include the second cleanup.
noretry-v1r1 is David's alternative

global-dhp__workload_usemem-stress-numa-compact
(no filesystem as this is the trivial case of allocating anonymous
 memory on a freshly booted system. Figures are elapsed time)

                                   4.19.0                 4.19.0                 4.19.0
                                  vanilla     relaxthisnode-v1r1           noretry-v1r1
Amean     System-1       14.16 (   0.00%)       12.35 *  12.75%*       15.96 * -12.70%*
Amean     System-3       15.14 (   0.00%)        9.83 *  35.08%*       11.00 *  27.34%*
Amean     System-4        9.88 (   0.00%)        9.85 (   0.25%)        9.80 (   0.75%)
Amean     Elapsd-1       29.23 (   0.00%)       26.16 *  10.50%*       33.81 * -15.70%*
Amean     Elapsd-3       25.67 (   0.00%)        7.28 *  71.63%*        8.49 *  66.93%*
Amean     Elapsd-4        5.49 (   0.00%)        5.53 (  -0.76%)        5.46 (   0.49%)

The figures in () are the percentage gain/loss. If it's around *'s then
the automation has guessed at the results are outside the noise.

System CPU usage is reduced by both as reported but Micha's gives a
10.5% gain and David's is a 15.7% loss. Boith appear to be outside the
noise. While not included here, the vanilla kernel swaps heavily with a 56%
reclaim efficiency (pages scanned vs pages reclaimed) and neither of the
proposed patches swaps and it's all from direct reclaim activity. Michal's
patch does not enter reclaim, David's enters reclaim but it's very light.

global-dhp__workload_thpfioscale-xfs
(Uses fio to fragment memory and keep slab and page cache active while
 there is an attempt to allocate THP in parallel. No special madvise
 flags or tuning is applied. A dedicated test partition is used for
 fio and XFS was the target filesystem that is recreated on every test)
thpfioscale Fault Latencies
                                       4.19.0                 4.19.0                 4.19.0
                                      vanilla     relaxthisnode-v1r1           noretry-v1r1
Amean     fault-base-5     1471.95 (   0.00%)     1515.64 (  -2.97%)     1491.05 (  -1.30%)
Amean     fault-huge-5        0.00 (   0.00%)      534.51 * -99.00%*        0.00 (   0.00%)

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0                 4.19.0
                                 vanilla     relaxthisnode-v1r1           noretry-v1r1
Percentage huge-5        0.00 (   0.00%)        1.18 ( 100.00%)        0.00 (   0.00%)

Both patches incur a slight hit to fault latency (measured in microseconds)
but it's well within the noise. While not included here, the variance is
massive (min 1052 microseconds, max 282348 microseconds in the vanilla
kernel. Both patches reduce the worst-case scenarios. All kernels show
terrible allocation success rates. Michal's had a 1.18% success rate but
that's probably luck.

global-dhp__workload_thpfioscale-madvhugepage-xfs
(Same as the last test but the THP allocation program uses
 MADV_HUGEPAGE)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0                 4.19.0
                                      vanilla     relaxthisnode-v1r1           noretry-v1r1
Amean     fault-base-5     6772.84 (   0.00%)    10256.30 * -51.43%*     1574.45 *  76.75%*
Amean     fault-huge-5     2644.19 (   0.00%)     5314.17 *-100.98%*     3517.89 ( -33.04%)

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0                 4.19.0
                                 vanilla     relaxthisnode-v1r1           noretry-v1r1
Percentage huge-5       45.48 (   0.00%)       95.09 ( 109.08%)        2.81 ( -93.81%

The first point of interest is that even with the vanilla kernel, the
allocation fault latency is much higher than average reflecting that
additional work is being done.

Next point of interest -- David's patch has much lower latency on
average when allocating *base* pages showing and the vmstats (not
included) show that compaction activity is reduced but not eliminated.

To balance this, Michal's patch has an 95% allocation success rate for THP
versus 45% on the default kernel at the cost of higher fault latency. This
is almost certainly a reflection that THPs are being allocated on remote
nodes. This can be considered good or bad depending on whether THP is
more important than locality. Note with David's patch that the allocation
success rate drops to 2.81% showing that it's much less efficient at THP.

This demonstrates a very clear trade-off between allocation latency and
allocation success rate for THP. Which one is better is workload
dependent.

global-dhp__workload_thpfioscale-defrag-xfs
(Same as global-dhp__workload_thpfioscale-xfs except that defrag is set
 to always)
thpfioscale Fault Latencies
                                       4.19.0                 4.19.0                 4.19.0
                                      vanilla     relaxthisnode-v1r1           noretry-v1r1
Amean     fault-base-5     2678.60 (   0.00%)     4442.14 * -65.84%*     1640.15 *  38.77%*
Amean     fault-huge-5     1324.61 (   0.00%)     1460.08 ( -10.23%)     2358.23 ( -78.03%)

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0                 4.19.0
                                 vanilla     relaxthisnode-v1r1           noretry-v1r1
Percentage huge-5        0.90 (   0.00%)        0.40 ( -55.56%)        0.22 ( -75.93%)

The allocation latency is again higher in this case as greater effort is
made to allocate the huge page. Michal's takes a hit as it's still
trying to allocate the THP while David's gives up early. In all cases
the allocation success rate is terrible.

So it should be reasonably clear that no approach is a universal win.
Michal's wins at the trivial case which is what the original problem
was and why it was pushed at all. David's in general has lower latency
in general because it gives up quickly but the allocation success rate
when MADV_HUGEPAGE specifically asks for huge pages is terrible. This
may make it a non-starter for the virtualisation case that wants huge
pages on the basis that if an application asks for huge pages, it
presumably is willing to pay the cost to get them.

-- 
Mel Gorman
SUSE Labs

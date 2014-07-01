Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 396176B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 17:25:45 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so10219107wgh.7
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 14:25:44 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ez14si16949790wid.92.2014.07.01.14.25.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 14:25:44 -0700 (PDT)
Date: Tue, 1 Jul 2014 17:25:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] Improve sequential read throughput v4r8
Message-ID: <20140701212538.GD1369@cmpxchg.org>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
 <20140701171611.GB1369@cmpxchg.org>
 <20140701183915.GW10819@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701183915.GW10819@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, Jul 01, 2014 at 07:39:15PM +0100, Mel Gorman wrote:
> On Tue, Jul 01, 2014 at 01:16:11PM -0400, Johannes Weiner wrote:
> > On Mon, Jun 30, 2014 at 05:47:59PM +0100, Mel Gorman wrote:
> > > Changelog since V3
> > > o Push down kwapd changes to cover the balance gap
> > > o Drop drop page distribution patch
> > > 
> > > Changelog since V2
> > > o Simply fair zone policy cost reduction
> > > o Drop CFQ patch
> > > 
> > > Changelog since v1
> > > o Rebase to v3.16-rc2
> > > o Move CFQ patch to end of series where it can be rejected easier if necessary
> > > o Introduce page-reclaim related patch related to kswapd/fairzone interactions
> > > o Rework fast zone policy patch
> > > 
> > > IO performance since 3.0 has been a mixed bag. In many respects we are
> > > better and in some we are worse and one of those places is sequential
> > > read throughput. This is visible in a number of benchmarks but I looked
> > > at tiobench the closest. This is using ext3 on a mid-range desktop and
> > > the series applied.
> > > 
> > >                                       3.16.0-rc2                 3.0.0            3.16.0-rc2
> > >                                          vanilla               vanilla         fairzone-v4r5
> > > Min    SeqRead-MB/sec-1         120.92 (  0.00%)      133.65 ( 10.53%)      140.68 ( 16.34%)
> > > Min    SeqRead-MB/sec-2         100.25 (  0.00%)      121.74 ( 21.44%)      118.13 ( 17.84%)
> > > Min    SeqRead-MB/sec-4          96.27 (  0.00%)      113.48 ( 17.88%)      109.84 ( 14.10%)
> > > Min    SeqRead-MB/sec-8          83.55 (  0.00%)       97.87 ( 17.14%)       89.62 (  7.27%)
> > > Min    SeqRead-MB/sec-16         66.77 (  0.00%)       82.59 ( 23.69%)       70.49 (  5.57%)
> > > 
> > > Overall system CPU usage is reduced
> > > 
> > >           3.16.0-rc2       3.0.0  3.16.0-rc2
> > >              vanilla     vanilla fairzone-v4
> > > User          390.13      251.45      396.13
> > > System        404.41      295.13      389.61
> > > Elapsed      5412.45     5072.42     5163.49
> > > 
> > > This series does not fully restore throughput performance to 3.0 levels
> > > but it brings it close for lower thread counts. Higher thread counts are
> > > known to be worse than 3.0 due to CFQ changes but there is no appetite
> > > for changing the defaults there.
> > 
> > I ran tiobench locally and here are the results:
> > 
> > tiobench MB/sec
> >                                         3.16-rc1              3.16-rc1
> >                                                            seqreadv4r8
> > Mean   SeqRead-MB/sec-1         129.66 (  0.00%)      156.16 ( 20.44%)
> > Mean   SeqRead-MB/sec-2         115.74 (  0.00%)      138.50 ( 19.66%)
> > Mean   SeqRead-MB/sec-4         110.21 (  0.00%)      127.08 ( 15.31%)
> > Mean   SeqRead-MB/sec-8         101.70 (  0.00%)      108.47 (  6.65%)
> > Mean   SeqRead-MB/sec-16         86.45 (  0.00%)       91.57 (  5.92%)
> > Mean   RandRead-MB/sec-1          1.14 (  0.00%)        1.11 ( -2.35%)
> > Mean   RandRead-MB/sec-2          1.30 (  0.00%)        1.25 ( -3.85%)
> > Mean   RandRead-MB/sec-4          1.50 (  0.00%)        1.46 ( -2.23%)
> > Mean   RandRead-MB/sec-8          1.72 (  0.00%)        1.60 ( -6.96%)
> > Mean   RandRead-MB/sec-16         1.72 (  0.00%)        1.69 ( -2.13%)
> > 
> > Seqread throughput is up, randread takes a small hit.  But allocation
> > latency is badly screwed at higher concurrency levels:
> > 
> 
> So the results are roughly similar. You don't state which filesystem it is
> but FWIW if it's the ext3 filesystem using the ext4 driver then throughput
> at higher levels is also affected by filesystem fragmentation. The problem
> was outside the scope of the series.

It's an ext4 filesystem.

> > tiobench Maximum Latency
> >                                             3.16-rc1              3.16-rc1
> >                                                                seqreadv4r8
> > Mean   SeqRead-MaxLatency-1          77.23 (  0.00%)       57.69 ( 25.30%)
> > Mean   SeqRead-MaxLatency-2         228.80 (  0.00%)      218.50 (  4.50%)
> > Mean   SeqRead-MaxLatency-4         329.58 (  0.00%)      325.93 (  1.11%)
> > Mean   SeqRead-MaxLatency-8         485.13 (  0.00%)      475.35 (  2.02%)
> > Mean   SeqRead-MaxLatency-16        599.10 (  0.00%)      637.89 ( -6.47%)
> > Mean   RandRead-MaxLatency-1         66.98 (  0.00%)       18.21 ( 72.81%)
> > Mean   RandRead-MaxLatency-2        132.88 (  0.00%)      119.61 (  9.98%)
> > Mean   RandRead-MaxLatency-4        222.95 (  0.00%)      213.82 (  4.10%)
> > Mean   RandRead-MaxLatency-8        982.99 (  0.00%)     1009.71 ( -2.72%)
> > Mean   RandRead-MaxLatency-16       515.24 (  0.00%)     1883.82 (-265.62%)
> > Mean   SeqWrite-MaxLatency-1        239.78 (  0.00%)      233.61 (  2.57%)
> > Mean   SeqWrite-MaxLatency-2        517.85 (  0.00%)      413.39 ( 20.17%)
> > Mean   SeqWrite-MaxLatency-4        249.10 (  0.00%)      416.33 (-67.14%)
> > Mean   SeqWrite-MaxLatency-8        629.31 (  0.00%)      851.62 (-35.33%)
> > Mean   SeqWrite-MaxLatency-16       987.05 (  0.00%)     1080.92 ( -9.51%)
> > Mean   RandWrite-MaxLatency-1         0.01 (  0.00%)        0.01 (  0.00%)
> > Mean   RandWrite-MaxLatency-2         0.02 (  0.00%)        0.02 (  0.00%)
> > Mean   RandWrite-MaxLatency-4         0.02 (  0.00%)        0.02 (  0.00%)
> > Mean   RandWrite-MaxLatency-8         1.83 (  0.00%)        1.96 ( -6.73%)
> > Mean   RandWrite-MaxLatency-16        1.52 (  0.00%)        1.33 ( 12.72%)
> > 
> > Zone fairness is completely gone.  The overall allocation distribution
> > on this system goes from 40%/60% to 10%/90%, and during the workload
> > the DMA32 zone is not used *at all*:
> > 
> 
> The zone fairness gets effectively disabled when the streaming is using all
> of physical memory and reclaiming behind anyway as kswapd. The allocator is
> using the preferred zone while reclaim scans behind it. If you run tiobench
> with a size that fits within memory then the IO results themselves are
> valid but it should show that the zone allocation is still spread fairly.
> 
> This is from a tiobench configuration that fits within memory.
> 
>                             3.16.0-rc2  3.16.0-rc2
>                                vanilla fairzone-v4
> DMA32 allocs                  10809658    10904632
> Normal allocs                 18401594    18342985
> 
> In this case there was no reclaim activity.
> 
> >                               3.16-rc1    3.16-rc1
> >                                        seqreadv4r8
> > Zone normal velocity         11358.492   17996.733
> > Zone dma32 velocity           8213.852       0.000
> > 
> 
> Showing that when the IO workload is twice memory that it stays confined
> within one zone. Considering that this is a streaming workload for the
> most part and we're discarding behind it was of less concern considering
> that interleaving results in the wrong reclaim decisions being made.

How can we tell a streaming workload from a thrashing one?  The VM can
only recognize multiple accesses within an LRU cycle, and you just cut
the LRU cycle in half.

Workingset adaptiveness is back in the toilet with your changes, you
can verify that easily by trying to cache one file slightly bigger
than memory through sequential reads, then another file of the same
size.  The second file never gets cached because it's thrashing in the
Normal zone while the unused file-1 gunk in DMA32 never gets the boot.

This is a correctness issue, which means that the other side of the
20% improvement in tiobench is a regression that scales with runtime
of file-2 access.

> > Both negative effects stem from kswapd suddenly ignoring the classzone
> > index while the page allocator respects it: the page allocator will
> > keep the low wmark + lowmem reserves in DMA32 free, but kswapd won't
> > reclaim in there until it drops down to the high watermark.  The low
> > watermark + lowmem reserve is usually bigger than the high watermark,
> > so you effectively disable kswapd service in DMA32 for user requests.
> > The zone is then no longer used until it fills with enough kernel
> > pages to trigger kswapd, or the workload goes into direct reclaim.
> > 
> 
> Yes. If the classzone index was preserved or the balance gap then the same
> regression exists. The interleaving from the allocator and ordering of kswapd
> activity on the lower zones reclaimed pages before they were finished with.

Is "readahead pages getting trashed before they are used" the main
explanation for this particular regression?

> > The classzone change is a non-sensical change IMO, and there is no
> > useful description of it to be found in the changelog.  But for the
> > given tests it appears to be the only change in the entire series to
> > make a measurable difference; reverting it gets me back to baseline:
> > 
> > tiobench MB/sec
> >                                         3.16-rc1              3.16-rc1              3.16-rc1
> >                                                            seqreadv4r8  seqreadv4r8classzone
> > Mean   SeqRead-MB/sec-1         129.66 (  0.00%)      156.16 ( 20.44%)      129.72 (  0.05%)
> > Mean   SeqRead-MB/sec-2         115.74 (  0.00%)      138.50 ( 19.66%)      115.61 ( -0.11%)
> > Mean   SeqRead-MB/sec-4         110.21 (  0.00%)      127.08 ( 15.31%)      110.15 ( -0.06%)
> > Mean   SeqRead-MB/sec-8         101.70 (  0.00%)      108.47 (  6.65%)      102.15 (  0.44%)
> > Mean   SeqRead-MB/sec-16         86.45 (  0.00%)       91.57 (  5.92%)       86.63 (  0.20%)
> > 
> 
> That is consistent with my own tests. The single patch that remained was
> the logical change.
> 
> >             3.16-rc1    3.16-rc1    3.16-rc1
> >                      seqreadv4r8seqreadv4r8classzone
> > User          272.45      277.17      272.23
> > System        197.89      186.30      193.73
> > Elapsed      4589.17     4356.23     4584.57
> > 
> >                               3.16-rc1    3.16-rc1    3.16-rc1
> >                                        seqreadv4r8seqreadv4r8classzone
> > Zone normal velocity         11358.492   17996.733   12695.547
> > Zone dma32 velocity           8213.852       0.000    6891.421
> > 
> > Please stop making multiple logical changes in a single patch/testing
> > unit. 
> 
> In this case you would end up with two patches
> 
> Removal of balance gap -- no major difference measured
> Removal of classzone_idx -- removes the lowmem reserve
> 
> The first patch on its own would have no useful documentation attached
> which is why it was not split out.

The balance gap is a self-contained concept that was introduced for a
specific reason, which I'm sure has nothing to do with lowmem
reserves.  If that reason doesn't exist anymore, removing it can be a
separate change that documents when and how the gap became obsolete.

Sure, there is only one motivation why you are actually removing both
things, which can be mentioned in the cover letter, but they are still
different logical changes in the reclaim/placement model.

> > This will make it easier to verify them, and hopefully make it
> > also more obvious if individual changes are underdocumented.  As it
> > stands, it's hard to impossible to verify the implementation when the
> > intentions are not fully documented.  Performance results can only do
> > so much.  They are meant to corroborate the model, not replace it.
> > 
> 
> The fair zone policy itself is partially working against the lowmem
> reserve idea. The point of the lowmem reserve was to preserve the lower
> zones when an upper zone can be used and the fair zone policy breaks
> that.

The allocator always filled all zones minus their lowmem reserves
before initiating reclaim, the fair policy just makes sure they fill
up at the same rate, but it still respects the chunks reserved for
non-user allocations, the lowmem reserves.

It's arguable whether there was an intentional best-effort mechanism
that preferred higher zones, in addition to the lowmem reserves, but
the upsides are not clear to me (nobody complained about lowmem
allocation problems after the change) and it doesn't integrate into
our multi-zone LRU aging model, so I got rid of it.

So no, I don't see conflicting concepts here.

> The fair zone policy ignores that and it was never reconciled. The
> dirty page distribution does a different interleaving again and was never
> reconciled with the fair zone policy or lowmem reserves.

A write will pick the zone that meets the watermark (low+reserve) and
has available fair quota - they should be roughly in sync - and hasn't
exhausted its zone dirty limit.  If there is no eligible zone, reclaim
is preferred over breaching the dirty limit (rather have clean cache
reclaimed than the reclaimer running into dirty cache), so we enter
the slowpath.  The only reason why the slowpath ultimately ignores the
dirty limit (after waking kswapd) is because the flushers are not NUMA
aware, but this is explicitely documented.  But kswapd is awake at
that point, so any setbacks in fairness should be temporary.

> kswapd itself was
> not using the classzone_idx it actually woken for although in this case
> it may not matter. The end result is that the model is fairly inconsistent
> which makes comparison against it a difficult exercise at best. About all
> that was left was that from a performance perspective that the fair zone
> allocation policy is not doing the right thing for streaming workloads.

But your changes are not doing the right thing for in-core workloads
and working set changes where predictable aging matters, plus they
take away whatever consistency we have in the placement model.  It's
not a good trade-off.

> > And again, if you change the way zone fairness works, please always
> > include the zone velocity numbers or allocation numbers to show that
> > your throughput improvements don't just come from completely wrecking
> > fairness - or in this case from disabling an entire zone.
> 
> The fair zone policy is preserved until such time as the workload is
> continually streaming data in and reclaiming out. The original fair zone
> allocation policy patch (81c0a2bb515fd4daae8cab64352877480792b515) did not
> describe what workload it measurably benefitted. It noted that pages can
> get activated and live longer than they should which is completely true
> but did not document why that mattered for streaming workloads or notice
> that performance for those workloads got completely shot.

It's also still not clear what's causing the regression.  Your first
theory was allocator overhead, but it couldn't get profiled, and
reducing the overhead and pointless zonelist walks significantly
didn't make a real difference in the end result.  The second theory of
lower zones being scanned excessively when they are balanced turned
out to not even match the code.  Lastly, the balance gap was suspected
as the reason for unfavorable lower zone reclaim, but removing it
didn't help, either.

These explanations make no sense.  If pages of a streaming writer have
enough time in memory to not thrash with a single zone, the fair
policy should make even MORE time in memory available to them and not
thrash them.  The fair policy is a necessity for multi-zone aging to
make any sense and having predictable reclaim and activation behavior.
That's why it's obviously not meant to benefit streaming workloads,
but it shouldn't harm them, either.  Certainly not 20%.  If streaming
pages thrash, something is up, the solution isn't to just disable the
second zone or otherwise work around the issue.

> There is a concern that the pages on the lower zone potentially get preserved
> forever. However, the interleaving from the fair zone policy would reach
> the low watermark again and pages up to the high watermark would still
> get rotated and reclaimed so it did not seem like it would be an issue.

There is no interleaving because the page allocator recognizes the
lowmem reserve and doesn't reach the now much lower kswapd trigger
point.  The zone is full from a page allocator point of view, and
balanced from a kswapd point of view.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

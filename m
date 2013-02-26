Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id D54CA6B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 10:13:42 -0500 (EST)
Date: Tue, 26 Feb 2013 10:13:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] add extra free kbytes tunable
Message-ID: <20130226151315.GG24384@cmpxchg.org>
References: <alpine.DEB.2.02.1302111734090.13090@dflat>
 <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com>
 <511EB5CB.2060602@redhat.com>
 <alpine.DEB.2.02.1302171546120.10836@dflat>
 <20130219152936.f079c971.akpm@linux-foundation.org>
 <alpine.DEB.2.02.1302192100100.23162@dflat>
 <20130222175634.GA4824@cmpxchg.org>
 <20130226104731.GB22498@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130226104731.GB22498@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: dormando <dormando@rydia.net>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "hughd@google.com" <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>

On Tue, Feb 26, 2013 at 10:47:31AM +0000, Mel Gorman wrote:
> On Fri, Feb 22, 2013 at 12:56:34PM -0500, Johannes Weiner wrote:
> > > > <SNIP>
> > > >
> > > > : We have a server workload wherein machines with 100G+ of "free" memory
> > > > : (used by page cache), scattered but frequent random io reads from 12+
> > > > : SSD's, and 5gbps+ of internet traffic, will frequently hit direct reclaim
> > > > : in a few different ways.
> > > > :
> > > > : 1) It'll run into small amounts of reclaim randomly (a few hundred
> > > > : thousand).
> > > > :
> > > > : 2) A burst of reads or traffic can cause extra pressure, which kswapd
> > > > : occasionally responds to by freeing up 40g+ of the pagecache all at once
> > > > : (!) while pausing the system (Argh).
> > > > :
> > > > : 3) A blip in an upstream provider or failover from a peer causes the
> > > > : kernel to allocate massive amounts of memory for retransmission
> > > > : queues/etc, potentially along with buffered IO reads and (some, but not
> > > > : often a ton) of new allocations from an application. This paired with 2)
> > > > : can cause the box to stall for 15+ seconds.
> > > >
> > > > Can we prioritise these?  2) looks just awful - kswapd shouldn't just
> > > > go off and free 40G of pagecache.  Do you know what's actually in that
> > > > pagecache?  Large number of small files or small number of (very) large
> > > > files?
> > > 
> > > We have a handful of huge files (6-12ish 200g+) that are mmap'ed and
> > > accessed via address. occasionally madvise (WILLNEED) applied to the
> > > address ranges before attempting to use them. There're a mix of other
> > > files but nothing significant. The mmap's are READONLY and writes are done
> > > via pwrite-ish functions.
> > > 
> > > I could use some guidance on inspecting/tracing the problem. I've been
> > > trying to reproduce it in a lab, and respecting to 2)'s issue I've found:
> > > 
> > > - The amount of memory freed back up is either a percentage of total
> > > memory or a percentage of free memory. (a machine with 48G of ram will
> > > "only" free up an extra 4-7g)
> > > 
> > > - It's most likely to happen after a fresh boot, or if "3 > drop_caches"
> > > is applied with the application down. As it fills it seems to get itself
> > > into trouble, but becomes more stable after that. Unfortunately 1) and 3)
> > > still apply to a stable instance.
> > > 
> > > - Protecting the DMA32 zone with something like "1 1 32" into
> > > lowmem_reserve_ratio makes the mass-reclaiming less likely to happen.
> > > 
> > > - While watching "sar -B 1" I'll see kswapd wake up, and scan up to a few
> > > hundred thousand pages before finding anything it actually wants to
> > > reclaim (low vmeff). I've only been able to reproduce this from a clean
> > > start. It can take up to 3 seconds before kswapd starts actually
> > > reclaiming pages.
> > > 
> > > - So far as I can tell we're almost exclusively using 0 order allocations.
> > > THP is disabled.
> > > 
> > > There's not much dirty memory involved. It's not flushing out writes while
> > > reclaiming, it just kills off massive amount of cached memory.
> > 
> > Mapped file pages have to get scanned twice before they are reclaimed
> > because we don't have enough usage information after the first scan.
> > 
> > In your case, when you start this workload after a fresh boot or
> > dropping the caches, there will be 48G of mapped file pages that have
> > never been scanned before and that need to be looked at twice.
> > 
> > Unfortunately, if kswapd does not make progress (and it won't for some
> > time at first), it will scan more and more aggressively with
> > increasing scan priority.  And when the 48G of pages are finally
> > cycled, kswapd's scan window is a large percentage of your machine's
> > memory, and it will free every single page in it.
> > 
> > I think we should think about capping kswapd zone reclaim cycles just
> > as we do for direct reclaim.  It's a little ridiculous that it can run
> > unbounded and reclaim every page in a zone without ever checking back
> > against the watermark.  We still increase the scan window evenly when
> > we don't make forward progress, but we are more carefully inching zone
> > levels back toward the watermarks.
> > 
> 
> While on the surface I think this will appear to work, I worry that it
> will cause kswapds priorities to continually reset even when it's under
> real pressure as opposed to "failing to reclaim because of use-once".
> With nr_to_reclaim always at SWAP_CLUSTER_MAX, we'll hit this check and
> reset after each zone scan.
> 
>                 if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
>                         break;

But we hit that check now as well...?  I.e. unless there is a hard to
reclaim batch and kswapd is unable to make forward progress, priority
levels will always get reset after we scanned all zones and reclaimed
SWAP_CLUSTER_MAX or more in the process.

All I'm arguing is that, if we hit a hard to reclaim batch we should
continue to increase the number of pages to scan, but still bail out
if we reclaimed a batch successfully.  It does make sense to me to
look at more pages if we encounter unreclaimable ones.  It makes less
sense to me, however, to increase the reclaim goal as well in that
case.

> It'll fail the watermark check and restart of course but it does mean we
> would call shrink_slab() for every SWAP_CLUSTER_MAX*nr_unbalaced_zones
> pages scanned which will have other consequences. It'll behave differently
> but not necessarily better.

Right, I wasn't proposing to merge the patch as is.  But I do think
it's not okay that a batch of immediately unreclaimable pages can
cause kswapd to grow its reclaim target exponentially and we should
probably think about capping it one way or another.

shrink_slab()'s action is already based on the ratio between the
number of scanned pages and the number of lru pages, so I don't see
this as a fundamental issue, although it may require some tweaking.

> In general, IO causing anonymous workloads to stall has gotten a lot worse
> during the last few kernels without us properly realising it other than
> interactivity in the presence of IO has gone down the crapper again. Late
> last week I fixed up an mmtests that runs memcachetest as the primary
> workload while doing varying amounts of IO in the background and found this
> 
> http://www.csn.ul.ie/~mel/postings/reclaim-20130221/global-dhp__parallelio-memcachetest-ext4/hydra/report.html
> 
> Snippet looks like this;
>                                             3.0.56                      3.6.10                       3.7.4                   3.8.0-rc4
>                                           mainline                    mainline                    mainline                    mainline
> Ops memcachetest-0M             10125.00 (  0.00%)          10091.00 ( -0.34%)          11038.00 (  9.02%)          10864.00 (  7.30%)
> Ops memcachetest-749M           10097.00 (  0.00%)           8546.00 (-15.36%)           8770.00 (-13.14%)           4872.00 (-51.75%)
> Ops memcachetest-1623M          10161.00 (  0.00%)           3149.00 (-69.01%)           3645.00 (-64.13%)           2760.00 (-72.84%)
> Ops memcachetest-2498M           8095.00 (  0.00%)           2527.00 (-68.78%)           2461.00 (-69.60%)           2282.00 (-71.81%)
> Ops memcachetest-3372M           7814.00 (  0.00%)           2369.00 (-69.68%)           2396.00 (-69.34%)           2323.00 (-70.27%)
> Ops memcachetest-4247M           3818.00 (  0.00%)           2366.00 (-38.03%)           2391.00 (-37.38%)           2274.00 (-40.44%)
> Ops memcachetest-5121M           3852.00 (  0.00%)           2335.00 (-39.38%)           2384.00 (-38.11%)           2233.00 (-42.03%)
> 
> This is showing transactions/second -- more the better. 3.0.56 was pretty
> bad in itself because a large amount of IO in the background wrecked the
> throughput. It's gotten a lot worse since then. 3.8 results have
> completed but a quick check tells me the results are no better which is
> not surprising as there were no relevant commits since 3.8-rc4.

That does look horrible.  What kind of background IO is that?
Mapped/unmapped?  Read/write?  Linear or clustered?  I'm guessing some
of it is write at least as there are more page writes than swap outs.

> Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-749M                     0.00 (  0.00%)          36002.00 (-99.00%)          50499.00 (-99.00%)         155135.00 (-99.00%)
> Ops swapin-1623M                    8.00 (  0.00%)         176816.00 (-2210100.00%)         172010.00 (-2150025.00%)         206212.00 (-2577550.00%)
> Ops swapin-2498M                26291.00 (  0.00%)         195448.00 (-643.40%)         200911.00 (-664.18%)         209180.00 (-695.63%)
> Ops swapin-3372M                27787.00 (  0.00%)         179221.00 (-544.98%)         183509.00 (-560.41%)         182371.00 (-556.32%)
> Ops swapin-4247M               105081.00 (  0.00%)         157617.00 (-50.00%)         158054.00 (-50.41%)         167478.00 (-59.38%)
> Ops swapin-5121M                89589.00 (  0.00%)         148095.00 (-65.30%)         151012.00 (-68.56%)         159079.00 (-77.57%)
> 
> This is indicating that we are making the wrong reclaim decisions
> because of the amount of swapins.

I would have expected e986850 "mm,vmscan: only evict file pages when
we have plenty" to make some difference.  But depending on the IO
pattern, the file pages may all just sit on the active list.

> Ops majorfaults-0M                  1.00 (  0.00%)              1.00 (  0.00%)              9.00 (-800.00%)              0.00 (  0.00%)
> Ops majorfaults-749M                2.00 (  0.00%)           5356.00 (-267700.00%)           7872.00 (-393500.00%)          22472.00 (-1123500.00%)
> Ops majorfaults-1623M              30.00 (  0.00%)          26950.00 (-89733.33%)          25074.00 (-83480.00%)          28815.00 (-95950.00%)
> Ops majorfaults-2498M            6459.00 (  0.00%)          27719.00 (-329.15%)          27904.00 (-332.02%)          29001.00 (-349.00%)
> Ops majorfaults-3372M            5133.00 (  0.00%)          25565.00 (-398.05%)          26444.00 (-415.18%)          25789.00 (-402.42%)
> Ops majorfaults-4247M           19822.00 (  0.00%)          22767.00 (-14.86%)          22936.00 (-15.71%)          23475.00 (-18.43%)
> Ops majorfaults-5121M           17689.00 (  0.00%)          21292.00 (-20.37%)          21820.00 (-23.35%)          22234.00 (-25.69%)
> 
> Major faults are also high.
> 
> I have not had enough time to investigate this because other bugs cropped
> up. I can tell you that it's not bisectable as there are multiple root
> causes and it's not always reliably reproducible (with this test at least).
> 
> Unfortunately I'm also dropping offline today for a week and then I'll
> have to play catchup again when I get back. It's going to be close to 2
> weeks before I can start figuring out what went wrong here but I plan to
> start with 3.0 and work forward and see how I get on.

Would you have that mmtest configuration available somewhere by any
chance?  I can't see it in mmtests.git.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

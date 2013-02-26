Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id E18C76B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 11:25:31 -0500 (EST)
Date: Tue, 26 Feb 2013 16:25:20 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] add extra free kbytes tunable
Message-ID: <20130226162520.GD22498@suse.de>
References: <alpine.DEB.2.02.1302111734090.13090@dflat>
 <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com>
 <511EB5CB.2060602@redhat.com>
 <alpine.DEB.2.02.1302171546120.10836@dflat>
 <20130219152936.f079c971.akpm@linux-foundation.org>
 <alpine.DEB.2.02.1302192100100.23162@dflat>
 <20130222175634.GA4824@cmpxchg.org>
 <20130226104731.GB22498@suse.de>
 <20130226151315.GG24384@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130226151315.GG24384@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dormando <dormando@rydia.net>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "hughd@google.com" <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>

On Tue, Feb 26, 2013 at 10:13:15AM -0500, Johannes Weiner wrote:
> > > <SNIP>
> > > I think we should think about capping kswapd zone reclaim cycles just
> > > as we do for direct reclaim.  It's a little ridiculous that it can run
> > > unbounded and reclaim every page in a zone without ever checking back
> > > against the watermark.  We still increase the scan window evenly when
> > > we don't make forward progress, but we are more carefully inching zone
> > > levels back toward the watermarks.
> > > 
> > 
> > While on the surface I think this will appear to work, I worry that it
> > will cause kswapds priorities to continually reset even when it's under
> > real pressure as opposed to "failing to reclaim because of use-once".
> > With nr_to_reclaim always at SWAP_CLUSTER_MAX, we'll hit this check and
> > reset after each zone scan.
> > 
> >                 if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> >                         break;
> 
> But we hit that check now as well...? 

Eventually yes.

> I.e. unless there is a hard to
> reclaim batch and kswapd is unable to make forward progress, priority
> levels will always get reset after we scanned all zones and reclaimed
> SWAP_CLUSTER_MAX or more in the process.
> 

The reset happens after it has reclaimed a lot of pages. I agree with
you that this is likely the wrong thing to do. I'm just pointing out
that this simple patch changes behaviour in a big way.

> All I'm arguing is that, if we hit a hard to reclaim batch we should
> continue to increase the number of pages to scan, but still bail out
> if we reclaimed a batch successfully.  It does make sense to me to
> look at more pages if we encounter unreclaimable ones.  It makes less
> sense to me, however, to increase the reclaim goal as well in that
> case.
> 

Bail out from the reclaim maybe but care should be taken to ensure we do
not hammer slab on each "bail" or reset the scanning priorities if the
watermark was not met by that batch of SWAP_CLUSTER_MAX reclaims.

We also have to think about what it means for pressure being applied
equally to each zone. We will still apply equal scanning pressure but
not necessarily reclaim pressure. Does that matter? I don't know.

> > It'll fail the watermark check and restart of course but it does mean we
> > would call shrink_slab() for every SWAP_CLUSTER_MAX*nr_unbalaced_zones
> > pages scanned which will have other consequences. It'll behave differently
> > but not necessarily better.
> 
> Right, I wasn't proposing to merge the patch as is.  But I do think
> it's not okay that a batch of immediately unreclaimable pages can
> cause kswapd to grow its reclaim target exponentially and we should
> probably think about capping it one way or another.
> 

I agree with you. MMtest results I looked at over the weekend showed
that kswapd tends to be extremely spiky. Doing nothing following by
reclaiming an excessive amount of memory and going back to doing
nothing. This partially explains it.

> shrink_slab()'s action is already based on the ratio between the
> number of scanned pages and the number of lru pages, so I don't see
> this as a fundamental issue, although it may require some tweaking.
> 
> > In general, IO causing anonymous workloads to stall has gotten a lot worse
> > during the last few kernels without us properly realising it other than
> > interactivity in the presence of IO has gone down the crapper again. Late
> > last week I fixed up an mmtests that runs memcachetest as the primary
> > workload while doing varying amounts of IO in the background and found this
> > 
> > http://www.csn.ul.ie/~mel/postings/reclaim-20130221/global-dhp__parallelio-memcachetest-ext4/hydra/report.html
> > 
> > Snippet looks like this;
> >                                             3.0.56                      3.6.10                       3.7.4                   3.8.0-rc4
> >                                           mainline                    mainline                    mainline                    mainline
> > Ops memcachetest-0M             10125.00 (  0.00%)          10091.00 ( -0.34%)          11038.00 (  9.02%)          10864.00 (  7.30%)
> > Ops memcachetest-749M           10097.00 (  0.00%)           8546.00 (-15.36%)           8770.00 (-13.14%)           4872.00 (-51.75%)
> > Ops memcachetest-1623M          10161.00 (  0.00%)           3149.00 (-69.01%)           3645.00 (-64.13%)           2760.00 (-72.84%)
> > Ops memcachetest-2498M           8095.00 (  0.00%)           2527.00 (-68.78%)           2461.00 (-69.60%)           2282.00 (-71.81%)
> > Ops memcachetest-3372M           7814.00 (  0.00%)           2369.00 (-69.68%)           2396.00 (-69.34%)           2323.00 (-70.27%)
> > Ops memcachetest-4247M           3818.00 (  0.00%)           2366.00 (-38.03%)           2391.00 (-37.38%)           2274.00 (-40.44%)
> > Ops memcachetest-5121M           3852.00 (  0.00%)           2335.00 (-39.38%)           2384.00 (-38.11%)           2233.00 (-42.03%)
> > 
> > This is showing transactions/second -- more the better. 3.0.56 was pretty
> > bad in itself because a large amount of IO in the background wrecked the
> > throughput. It's gotten a lot worse since then. 3.8 results have
> > completed but a quick check tells me the results are no better which is
> > not surprising as there were no relevant commits since 3.8-rc4.
> 
> That does look horrible.  What kind of background IO is that?

dd to a large file conv=fdatasync

> Mapped/unmapped? 

unmapped.

> Read/write? 

write

> Linear or clustered? 

Not sure what you mean by "clusters". It's a linear write rather than a
random write.

The objective of the test was to detect one aspect of situations like
"during backup my main application performance goes to hell". It would be
possible to generate other types of background IO as there are elements
of the config-global-dhp__io-largeread-starvation test that can be broken
out and reused.

> I'm guessing some
> of it is write at least as there are more page writes than swap outs.
> 
> > Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
> > Ops swapin-749M                     0.00 (  0.00%)          36002.00 (-99.00%)          50499.00 (-99.00%)         155135.00 (-99.00%)
> > Ops swapin-1623M                    8.00 (  0.00%)         176816.00 (-2210100.00%)         172010.00 (-2150025.00%)         206212.00 (-2577550.00%)
> > Ops swapin-2498M                26291.00 (  0.00%)         195448.00 (-643.40%)         200911.00 (-664.18%)         209180.00 (-695.63%)
> > Ops swapin-3372M                27787.00 (  0.00%)         179221.00 (-544.98%)         183509.00 (-560.41%)         182371.00 (-556.32%)
> > Ops swapin-4247M               105081.00 (  0.00%)         157617.00 (-50.00%)         158054.00 (-50.41%)         167478.00 (-59.38%)
> > Ops swapin-5121M                89589.00 (  0.00%)         148095.00 (-65.30%)         151012.00 (-68.56%)         159079.00 (-77.57%)
> > 
> > This is indicating that we are making the wrong reclaim decisions
> > because of the amount of swapins.
> 
> I would have expected e986850 "mm,vmscan: only evict file pages when
> we have plenty" to make some difference.  But depending on the IO
> pattern, the file pages may all just sit on the active list.
> 

Maybe it did help and what we're seeing is a side-ffect of cda73a10 (mm:
do not sleep in balance_pgdat if there's no i/o congestion) that is keeping
kswapd awake and reclaiming for longer. It would not be the first time we
removed a congestion_wait() to find that we depended on that sledge hammer.

> > Ops majorfaults-0M                  1.00 (  0.00%)              1.00 (  0.00%)              9.00 (-800.00%)              0.00 (  0.00%)
> > Ops majorfaults-749M                2.00 (  0.00%)           5356.00 (-267700.00%)           7872.00 (-393500.00%)          22472.00 (-1123500.00%)
> > Ops majorfaults-1623M              30.00 (  0.00%)          26950.00 (-89733.33%)          25074.00 (-83480.00%)          28815.00 (-95950.00%)
> > Ops majorfaults-2498M            6459.00 (  0.00%)          27719.00 (-329.15%)          27904.00 (-332.02%)          29001.00 (-349.00%)
> > Ops majorfaults-3372M            5133.00 (  0.00%)          25565.00 (-398.05%)          26444.00 (-415.18%)          25789.00 (-402.42%)
> > Ops majorfaults-4247M           19822.00 (  0.00%)          22767.00 (-14.86%)          22936.00 (-15.71%)          23475.00 (-18.43%)
> > Ops majorfaults-5121M           17689.00 (  0.00%)          21292.00 (-20.37%)          21820.00 (-23.35%)          22234.00 (-25.69%)
> > 
> > Major faults are also high.
> > 
> > I have not had enough time to investigate this because other bugs cropped
> > up. I can tell you that it's not bisectable as there are multiple root
> > causes and it's not always reliably reproducible (with this test at least).
> > 
> > Unfortunately I'm also dropping offline today for a week and then I'll
> > have to play catchup again when I get back. It's going to be close to 2
> > weeks before I can start figuring out what went wrong here but I plan to
> > start with 3.0 and work forward and see how I get on.
> 
> Would you have that mmtest configuration available somewhere by any
> chance?  I can't see it in mmtests.git.

Of course. It's configs/config-global-dhp__parallelio-memcachetest. That
does not create a filesystem but the difference between what's in mmtests
and what I used is below.

Current released mmtests also does not have a module that can compare
parallelio tests but I've pushed the support to git. If you git pull then
something like this should report something sensible

cp configs/config-global-dhp__parallelio-memcachetest config
./run-mmtests vanilla
(build boot new kernel)
./run-mmtests patched

To get a report do either this
./bin/compare-kernel.sh -d work/log -b parallelio -n vanilla,patched

or

cd work/log
../../compare-kernel.sh

This is the config file diff

@@ -43,10 +43,10 @@
 #export TESTDISK_RAID_OFFSET=63
 #export TESTDISK_RAID_SIZE=250019532
 #export TESTDISK_RAID_TYPE=raid0
-#export TESTDISK_PARTITION=/dev/sda6
-#export TESTDISK_FILESYSTEM=ext3
-#export TESTDISK_MKFS_PARAM="-f -d agcount=8"
-#export TESTDISK_MOUNT_ARGS=""
+export TESTDISK_PARTITION=/dev/sda6
+export TESTDISK_FILESYSTEM=ext4
+export TESTDISK_MKFS_PARAM=
+export TESTDISK_MOUNT_ARGS=
 #
 # Test NFS disk to setup (optional)
 #export TESTDISK_NFS_MOUNT=192.168.10.7:/exports/`hostname`

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

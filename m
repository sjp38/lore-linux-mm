Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF2D6B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 10:01:51 -0400 (EDT)
Date: Mon, 19 Oct 2009 15:01:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091019140151.GC9036@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091014103002.GA5027@csn.ul.ie> <200910141510.11059.elendil@planet.nl> <200910190133.33183.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200910190133.33183.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 01:33:29AM +0200, Frans Pop wrote:
> Another long mail, sorry.
> 
> On Wednesday 14 October 2009, Frans Pop wrote:
> > > There still has not been a mm-change identified that makes
> > > fragmentation significantly worse.
> >
> > My bisection shows a very clear point, even if not an individual commit,
> > in the 'akpm' merge where SKB errors suddenly become *much* more
> > frequent and easy to trigger.
> > I'm sorry to say this, but the fact that nothing has been identified yet
> > is IMO the result of a lack of effort, not because there is no such
> > change.
> 
> I was wrong. It turns out that I was creating the variations in the test 
> results around the akpm merge myself by tiny changes in the way I ran the 
> tests. It took another round of about 30 compilations and tests purely in 
> this range to show that, but those same tests also made me aware of other 
> patterns I should look at.
> 

Once again, thanks for persisting with this for so long. That many tests
and searching is a miserable undertaking.

> Until a few days ago I was concentrating on "do I see SKB allocation errors 
> or not". Since then I've also been looking more consciously at when they 
> happen, at disk access patterns and at desktop freeze patterns.
> 
> I think I did mention before that this whole issue is rather subtle :-/

Indeed

> So, my apologies for finguering the wrong area for so long, but it looked 
> solid given the info available at the time.
> 
> On Thursday 15 October 2009, Mel Gorman wrote:
> > Outside the range of commits suspected of causing problems was the
> > following. It's extremely low probability
> >
> > Commit 8aa7e84 Fix congestion_wait() sync/async vs read/write confusion
> >         This patch alters the call to congestion_wait() in the page
> >         allocator. Frankly, I don't get the change but it might worth
> >         checking if replacing BLK_RW_ASYNC with WRITE on top of 2.6.31
> >         makes any difference
> 
> This is the real culprit. Mel: thanks very much for looking beyond the 
> area I identified. Your overview of mm changes was exactly what I needed 
> and really helped a lot during my later tests.
> 

I'm surprised this made such a big difference which is why I described
it as "extremely low probability". It implies that the real problem isn't
fragmentation per-se but the timing of when pages get consumed.

Maybe what has really changed is how long direct reclaimers wait before trying
to allocate again. After the commit, if direct reclaimers are waiting longer
between direct reclaim attempts, it might mean that the GFP_KERNEL reclaimers
of high-order pages are doing less work before and hurting parallel GFP_ATOMIC
users. Jens, does this sound plausible?

> This commit definitely causes most of the problems; confirmed by reverting 
> it on top of 2.6.31 (also requires reverting 373c0a7e, which is a later 
> build fix).
> 
> The rest of this mail gives details on my tests and how I reached the above 
> conclusion.
> 
> TEST BASELINE (2.6.30)
> ======================
> I mentioned in an earlier mail that I run three instances of gitk for my 
> tests. Loading gitk seems to consist of 3 phases:
> 1) general initial scan of the repository (branches?)
> 2) reading commits: commit counter increases
> 3) reading references (including bisection good/bad points) and
>    uncommitted changes
> 
> Below times and comments per stage when the test is run with 2.6.30. As my 
> test starts after a clean boot, buffers are mostly empty.
> 
> 1st instance: 'gitk v2.6.29..master' (preparation)
> 1) ~20 seconds; user interface is mostly blank
> 2) ~5 seconds to read 35.000 commits; user interface is updated and counter
>    increases steadily as they are read
> 3) ~10 seconds; "branch"/"follows"/"precedes" info and tags are filled
>    in; fairly heavy disk activity
> 
> 2st instance: 'gitk master' (preparation)
> 1) 0 seconds (because data is already buffered)
> 2) ~25 seconds to read 167500 commits; counter increases steadily
> 3) 1-2 seconds (because data is already buffered)
> 
> 3st instance: 'gitk master' (the actual test)
> 1) 0 seconds because data is already buffered
> 2) ~55 seconds due to swapping overhead; minor music skip around commit
>    110.000; counter slower after 90.000, some short halts, but generally
>    increases steadily; moderate disk activity
> 3) ~55-60 seconds; because buffers have been emptied data must by read
>    again, with swapping; very heavy disk activity; fairly long music
>    skip (15-20 seconds), but no SKB allocation errors
> 
> So, the loading of the 3rd instance takes 1.5 minutes longer than the 
> second because of the swapping. And phase 3) is most affected by it.
> 
> AFTER WIRELESS CHANGE
> =====================
> After commit 4752c93c30 ("iwlcore: Allow skb allocation from tasklet") I 
> start getting the SKB errors. They can be triggered reliably if the whole 
> test is repeated 1 or 2 times, but generally not the first time the test 
> is run.

It's up to the wireless driver maintainer what to do here, but it seems
like that patch needs to be reverted and thought about some more before
trying again.

> 
> Or so I thought for a long time.
> It turns out that I will get SKB errors during the first run if I'm
> "sloppy" in the test execution. For example if I wait too long before 
> switching from the last gitk instance to konsole where I have 
> a 'tail -f /var/log/kern.log' running.

So the timing is critical of when the high-order atomic allocations
start kicking in.

> Another factor is the state of the repository: do I have master checked 
> out, or an older branch, or am I in the middle of a bisection. This 
> influences how data is read from the disk and thus the test results.
> A last factor may be the size of the kernel I'm using: my test/bisect 
> kernel is significantly smaller than my regular kernel.
> 
> If the test is run completely cleanly, I will not get SKB errors during the 
> first run. Also, this change does not affect the timings of the test at 
> all: the total load time of the 3rd instance is still ~1:55 and music 
> skips happen in roughly the same places. The pattern of disk activity also 
> remains unchanged.
> 
> If I do *not* run the test cleanly, any SKB errors during the first test 
> run will always be during phase 3), never during phase 2). This is what I 
> saw during tests in the 'akpm' range, and explains the inconsistent 
> results there.
> 
> After discovering this I've made a copy of the git repo so that I always 
> test using the exact same state and tightened my test procedure.
> 
> AFTER congestion_wait CHANGE
> ============================
> If I test commit 9f2d8be, which is just before the congestion_wait() 
> change, I still get the same pattern as described above. But when I test 
> with 8aa7e84 ("Fix congestion_wait() sync/async vs read/write confusion"), 
> things change dramatically when the 3rd gitk instance is started.
> 

So, assuming this is a timing problem, this commit affects the timing of
when pages are consumed by processes doing direct reclaim.

> During the 2nd phase I see the first SKB allocation errors with a music 
> skip between reading commits 95.000 and 110.000.
> About commit 115.000 there is a very long pause during which the counter 
> does not increase, music stops and the desktop freezes completely. The 
> first 30 seconds of that freeze there is only very low disk activity (which 
> seems strange);

I'm just going to have to depend on Jens here. Jens, the congestion_wait() is
on BLK_RW_ASYNC after the commit. Reclaim usually writes pages asynchronously
but lumpy reclaim actually waits of pages to write out synchronously so
it's not always async.

Either way, reclaim is usually worried about writing pages but it would appear
after this change that a lot of read activity can also stall a process in
direct reclaim. What might be happening in Frans's particular case is that the
tasklet that allocates high-order pages for the RX buffers is getting stalled
by congestion caused by other processes doing reads from the filesystem.
While it makes sense from a congestion point of view to halt the IO, the
reclaim operations from direct reclaimers is getting delayed for long enough
to cause problems for GFP_ATOMIC.

Does this sound plausible to you? If so, what's the best way of
addressing this? Changing congestion_wait back to WRITE (assuming that
works for Frans)? Changing it to SYNC (again, assuming it actually
works) or a revert?

> the next 25 seconds there suddenly is very high disk  
> activity during which things gradually unfreeze and more SKB errors are 
> displayed. After that the commit counter runs up fairly steadily again.
> 
> Phase 2) ends at ~1:45. Phase 3) (with more SKB errors) ends at ~2:05.
> 
> So this change almost doubles the time needed for phase 2) and causes SKB 
> allocation errors to occur during that phase. Also, before this commit the 
> desktop freezes are much shorter and less severe. With this change the 
> desktop is completely unusable for almost a minute during phase 2), with 
> even the mouse pointer frozen solid.
> Note that phase 3) becomes shorter, but that the total time needed to load 
> the 3rd instance increases by about 10-15 seconds.
> 
> Note: -rc2 and -rc3 had broken NFS, so I had to cherry-pick 3 NFS commits 
> from -rc4 on top of the commits I wanted to test.
> 
> WITH congestion_wait CHANGE REVERTED
> ====================================
> I've done quite a few tests of 2.6.31 with 373c0a7e and 8aa7e847 reverted 
> to confirm that's really the culprit. I've done this for .31-rc3, .31-rc4,
> .31-rc5, .31 and .31.1.
> 
> In all cases the huge freeze in phase 2) is gone and the general behavior 
> and timings are again as it was after the wireless change. During most 
> tests I did not get any SKB allocation errors during phase 2) or phase 3).
> 
> However with .31-rc5, .31 and .31.1 I have had some tests where I would see 
> a few SKB allocation errors during phase 3) (which is somewhat likely), 
> but also during phase 2). At this point I'm unsure whether this is just 
> noise, or maybe a minor influence from some change merged after .31-rc4.
> Looking through the commits there are several mm/page allocation changes.
> 

It could still be kswapd not being woken up often enough after direct
reclaimers. I took a look through the commits but none of the mm or
allocator changes struck me as likely candidates for making
fragmentation worse or altering the timing.

> For now I suggest ignoring this though as the impact (if any) is very minor 
> and it is not reproducible reliably enough.
> 
> Next I'll retest Mel's patches and also test Reinette's patches.
> 

Of the two patches, only the kswapd one should have any significance. As
David pointed out, the second patch is essentially a no-op as it should
not have been possible to enter direct reclaim with ALLOC_NO_WATERMARKS
set.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

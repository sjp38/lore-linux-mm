Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 08E536B0075
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 20:19:47 -0500 (EST)
Date: Thu, 24 Nov 2011 02:19:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be
 migreated without blocking within ->migratepage
Message-ID: <20111124011943.GO8397@redhat.com>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321635524-8586-5-git-send-email-mgorman@suse.de>
 <20111118213530.GA6323@redhat.com>
 <20111121111726.GA19415@suse.de>
 <20111121224545.GC8397@redhat.com>
 <20111122125906.GK19415@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111122125906.GK19415@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 22, 2011 at 12:59:06PM +0000, Mel Gorman wrote:
> On Mon, Nov 21, 2011 at 11:45:45PM +0100, Andrea Arcangeli wrote:
> > On Mon, Nov 21, 2011 at 11:17:26AM +0000, Mel Gorman wrote:
> > > On Fri, Nov 18, 2011 at 10:35:30PM +0100, Andrea Arcangeli wrote:
> > > > folks who wants low latency or no memory overhead should simply
> > > > disable compaction.
> > > 
> > > That strikes me as being somewhat heavy handed. Compaction should be as
> > > low latency as possible.
> > 
> > Yes I was meaning in the very short term. Optimizations are always
> > possible :) we've just to sort out some issues (as previous part of
> > the email discussed).
> > 
> 
> To put some figures on the latency impacts, I added a test to MM
> Tests similar to yours that is in three parts
> 
> 1. A process reads /dev/sda and writes to /dev/null

Yes also note, ironically this is likely to be a better test for this
without the __GFP_MOVABLE in block_dev.c. Even if we want it fixed,
maybe another source that reduces the non movable pages may be needed then.

> 2. A process reads from /dev/zero and writes to a filesystem on a USB stick
> 3. When memory is full, a process starts that creates an anonymous
>    mapping

Great.

> Looking at the vfat figures, we see
> 
> THPAVAIL
>             thpavail-3.0.0-vanilla-thpavailthpavail-3.1.0-vanilla-thpavail    thpavail-3.2.0         3.2.0-rc2         3.2.0-rc2
>                  3.0.0-vanilla     3.1.0-vanilla       rc2-vanilla migratedirty-v4r2    synclight-v4r2
> System Time         1.89 (    0.00%)    1.90 (   -0.21%)    3.83 (  -50.63%)   19.95 (  -90.52%)   71.91 (  -97.37%)
> +/-                 0.15 (    0.00%)    0.05 (  205.45%)    2.39 (  -93.87%)   27.59 (  -99.47%)    0.75 (  -80.49%)
> User Time           0.10 (    0.00%)    0.10 (   -4.00%)    0.10 (   -7.69%)    0.12 (  -17.24%)    0.11 (   -9.43%)
> +/-                 0.02 (    0.00%)    0.02 (  -24.28%)    0.03 (  -38.31%)    0.02 (    0.00%)    0.04 (  -56.57%)
> Elapsed Time      986.53 (    0.00%) 1189.77 (  -17.08%)  589.48 (   67.36%)  506.45 (   94.79%)   73.39 ( 1244.27%)
> +/-                35.52 (    0.00%)   90.09 (  -60.57%)   49.00 (  -27.51%)  213.56 (  -83.37%)    0.47 ( 7420.98%)
> THP Active        118.80 (    0.00%)   89.20 (  -33.18%)   35.40 ( -235.59%)    8.00 (-1385.00%)   44.00 ( -170.00%)
> +/-                65.57 (    0.00%)   35.37 (  -85.38%)   29.23 ( -124.33%)   12.51 ( -424.28%)   19.83 ( -230.65%)
> Fault Alloc       308.80 (    0.00%)  244.20 (  -26.45%)   59.40 ( -419.87%)   81.00 ( -281.23%)   95.80 ( -222.34%)
> +/-                81.62 (    0.00%)   80.53 (   -1.36%)   26.85 ( -203.98%)   67.85 (  -20.30%)   34.29 ( -138.05%)
> Fault Fallback    697.20 (    0.00%)  761.60 (   -8.46%)  946.40 (  -26.33%)  924.80 (  -24.61%)  909.80 (  -23.37%)
> +/-                81.62 (    0.00%)   80.52 (    1.37%)   26.65 (  206.28%)   67.93 (   20.16%)   34.25 (  138.33%)
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)        541.58    645.79   1220.88   1131.04    976.54
> Total Elapsed Time (seconds)               5066.05   6083.58   3068.08   2653.11    493.96

Notice how the fault alloc goes down from 308-244 to 59 in
rc2-vanilla, that's the vmscan.c patch I backed out in my series... So
that explains why I backed out that bit. Ok the elapsed time improved
because reclaim is used less, but nothing close to x10 times faster
thanks to it, even for this workload and even on vfat, and if you add
__GFP_MOVABLE to block_dev.c things will likely change for the better
too. (It was x10 times slower if that lead to swapping, likely not the
case here, but again the __GFP_MOVABLE should take care of it)

> Straight off, 3.0, 3.1 and 3.2-rc2 have a number of THPs in use. 3.0
> had a rougly 30% success rate with 10% of the mapping using THP but
> look at the cost in time. It took about 16 minutes per iteration (5
> iterations which is why total elapsed time looks large) to fault in a
> mapping the size of physical memory versus 1.5 minutes with my series
> (which is still very slow).

I'd be curious if you tested my exact status too.

> In my series system time is stupidly high but I haven't run oprofile
> to see exactly where. It could be because it's running compaction
> because defer_compaction() is not being called at the right times
> but it could also be because direct reclaim scanning is through the
> roof albeit better than 3.2-rc2 vanilla. I suspect direct reclaim
> scanning could be because we are not calling ->writepage in direct
> reclaim any more - 3.0 wrote 178215 pages while my series wrote 5.
> 
> The story looks better for ext4 as it is not writing page pages in
> fallback_migrate_page

That certianly has an effect on the usb stick as they're all vfat.

> THPAVAIL
>             thpavail-3.0.0-vanilla-thpavailthpavail-3.1.0-vanilla-thpavail    thpavail-3.2.0         3.2.0-rc2         3.2.0-rc2
>                  3.0.0-vanilla     3.1.0-vanilla       rc2-vanilla migratedirty-v4r2    synclight-v4r2
> System Time         2.64 (    0.00%)    2.49 (    6.10%)    3.09 (  -14.38%)    4.29 (  -38.40%)   12.20 (  -78.33%)
> +/-                 0.29 (    0.00%)    0.61 (  -51.80%)    1.17 (  -74.90%)    1.33 (  -78.04%)   16.27 (  -98.20%)
> User Time           0.12 (    0.00%)    0.08 (   51.28%)    0.10 (   13.46%)    0.10 (   13.46%)    0.09 (   34.09%)
> +/-                 0.03 (    0.00%)    0.02 (    6.30%)    0.01 (   94.49%)    0.01 (  158.69%)    0.03 (    0.00%)
> Elapsed Time      107.76 (    0.00%)   64.42 (   67.29%)   60.89 (   76.99%)   30.90 (  248.69%)   50.72 (  112.45%)
> +/-                39.83 (    0.00%)   17.03 (  133.90%)    8.75 (  355.08%)   17.20 (  131.65%)   22.87 (   74.14%)
> THP Active         82.80 (    0.00%)   84.20 (    1.66%)   35.00 ( -136.57%)   53.00 (  -56.23%)   36.40 ( -127.47%)
> +/-                81.42 (    0.00%)   80.82 (   -0.74%)   20.89 ( -289.73%)   34.50 ( -136.01%)   51.51 (  -58.07%)
> Fault Alloc       246.00 (    0.00%)  292.60 (   15.93%)   66.20 ( -271.60%)  129.40 (  -90.11%)   90.20 ( -172.73%)
> +/-               173.64 (    0.00%)  161.13 (   -7.76%)   21.30 ( -715.14%)   52.41 ( -231.32%)  104.14 (  -66.74%)
> Fault Fallback    759.60 (    0.00%)  712.40 (    6.63%)  939.80 (  -19.17%)  876.20 (  -13.31%)  915.60 (  -17.04%)
> +/-               173.49 (    0.00%)  161.13 (    7.67%)   21.30 (  714.44%)   52.16 (  232.59%)  104.00 (   66.82%)
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         63.41     50.64     39.79      58.8       171
> Total Elapsed Time (seconds)                732.79    483.23    447.17    335.28    412.21

Here again fault alloc goes down from 173-161 to 66 from 3.0-3.1 to
rc2. And elapsed time with ext4 is the same for 3.1.0 and rc2 (thanks
to ext4 instead of vfat). So again no big difference in the
vmscan.c backout.

I think we can keep a limit to how deep reclaim can go (maybe same
percentage logic we use in kswapd for the wmarks), but what was
implemented is too strig and just skipping reclaim when compaction
fails, doesn't sound ok. At least until compaction gets stronger in
being able to compact memory even when few ram is free. Compaction
can't free memory, it takes what is free, and creates "contigous free
pages" from "fragmented free pages". So the more free memory the
higher chance of compaction success. This is why not stopping relclaim
(if compaction fails) is good and increases the success rate
significantly (triple it in the above load) without actually slowing
down the elapsed time at all as shown above.

> THP availability is very variable between iterations and the stall
> times are nowhere near as bad as with vfat but still, my series cuts
> the time to fault in a mapping by half (and that is still very slow).

The results you got in compaction success for the first three columns
is similar to what I get. Of course this is an extreme load with flood
of allocations and tons of ram dirty so it's normal the success rate
of compaction is significantly lower than it would be in a light-VM
condition. But if reclaim is completely stopped by the vmscan patch
then even under light-VM condition the success rate of THP allocation
goes down.

> If you want, the __GFP_NO_KSWAPD check patch can be dropped as that
> will also keep David happy until this series is fully baked if we
> agree in principal that the current stalls are unacceptably large. It
> will be a stretch to complete it in time for 3.2 though meaning that
> stalls in 3.2 will be severe with THP enabled.

Well there's no risk that it will be worse than 3.1 at least. Also
with a more powerful async compaction the chance we end up in sync
compaction diminishes.

I think until we can compact all pages through async compaction, we
should keep sync compaction in. Pages from filesystems that requires a
fallback_migrate_page otherwise would become unmovable but they're in
the middle of a movable block, so that's not ok. We absolutely need a
sync compaction pass to get rid of those. Now you're improving that
part but until we can handle all type of pages I think a final pass of
sync compaction should run.

Now making async compaction more reliable means we call less reclaim
and less sync compaction so it's going to help and we should be still
better than before without having to decrease the reliability of
compaction.

> > When compaction_suitable is happy about the
> > wmarks, the compaction loop isn't still as reliable as it could be in
> > the movable zone, and doing more reclaim helps a lot, the more free
> > pages the more compaction goes ahead and has a change to compact more
> > stuff before the two scans meets in the middle. With Rik we thought
> > about a way to do just a no-swapping reclaim to shrink caches like
> > slab.
> > 
> 
> Ok, is there a patch? I'll investigate this later when I get the time
> but in the shorter term, I'll be looking at why the direct reclaim
> scan figures are so high.

No patch for this one, just my quick backout of the vmscan.c part
and your benchmark above explains why I did it.

> In retrospect, the main difference may be between raw access to the
> device and when the block device backs a filesystem that is currently
> mounted. While mounted, the filesystem may pin pages for metadata
> access which would prevent them ever being migrated and make them
> unsuitable for use with __GFP_MOVABLE.

The fs will search the bh from the hash and get access to the
pagecache from there (to avoid the aliasing between blkdev pagecache
and bh so when you write to /dev/sda on mounted fs it's immediately
seen by the filesystem and the writes from pagecache won't get
discared when the fs flushes its dirty buffers). The pin you mention
should be in the bh, like the superblocks.

But funny thing grow_dev_page already sets __GFP_MOVABLE. That's
pretty weird and it's probably source of a few not movable pages in
the movable block. But then many bh are movable... most of them are,
it's just the superblock that isn't.

But considering grow_dev_page sets __GFP_MOVABLE, any worry about pins
from the fs on the block_dev.c pagecache shouldn't be a concern...

> In Rik's case, this might be less of an issue. It's using the
> def_blk_aops as the address space operations that does not have a
> ->migratepage handler so minimally if they are dirty they have to be
> written out meaning it will behave more like vfat than ext4 in terms
> of compaction performance. I did not spot anything that would actually
> pin the buffers and prevent them from being released though but would
> prefer it was double checked.

Double checking is good idea.

The reason Rik's case can be improved greatly by the __GFP_MOVABLE in
block_dev.c, is that when there's very little movable memory, it's
less likely we compact stuff. All pagecache (actually looks like
buffercache in free but it's pagecache) goes into the non movable
pageblocks, so they get polluted by mixture of slab and stuff. So the
vast majority of memory becomes not compactable. Compaction works
better if all ram is movable of course. With that missing
__GFP_MOVABLE it meant async migration would fail always and invoke
reclaim way more than it would have done it on a real fs. And that
explains his swap storms I think. I havn't reproduced it but that's my
theory at least, and it should be tested.

> If you're going to test a series, can you look at the V4 I posted that
> attempts to reconcile our two series?

I had to look into other things sorry. Hope to get around testing this
too. I actually played on some other change in the compaction scan
which is more a test and not related to the above but I've nothing
conclusive yet.

Also what we have in 3.0/3.1 works _very_ well, there is no urgency to
make too many changes which weren't benchmarked/tested too much yet
and that will improve latency but reduce the allocation rate. If the
allocations are very long lived, giving a better chance to allocate
those pages is good even if there's write I/O. vfat + slow storage is
a bit of a pathological case it doesn't actually apply to all
hardware/fs combinations, __GFP_MOVABLE missing block_dev also was not
so common and it most certainly contributed to a reclaim more
aggressive than it would have happened with that fix. I think you can
push things one at time without urgency here, and I'd prefer maybe if
block_dev patch is applied and the other reversed in vmscan.c or
improved to start limiting only if we're above 8*high or some
percentage check to allow a little more reclaim than rc2 allows
(i.e. no reclaim at all which likely results in a failure in hugepage
allocation). Not unlimited as 3.1 is ok with me but if kswapd can free
a percentage I don't see why reclaim can't (consdiering more free
pages in movable pageblocks are needed to succeed compaction). The
ideal is to improve the compaction rate and at the same time reduce
reclaim aggressiveness. Let's start with the parts that are more
obviously right fixes and that don't risk regressions, we don't want
compaction regressions :).

Thanks for taking care of sorting this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

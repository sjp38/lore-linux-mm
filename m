Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D49096B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 07:59:15 -0500 (EST)
Date: Tue, 22 Nov 2011 12:59:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be
 migreated without blocking within ->migratepage
Message-ID: <20111122125906.GK19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321635524-8586-5-git-send-email-mgorman@suse.de>
 <20111118213530.GA6323@redhat.com>
 <20111121111726.GA19415@suse.de>
 <20111121224545.GC8397@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111121224545.GC8397@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 21, 2011 at 11:45:45PM +0100, Andrea Arcangeli wrote:
> On Mon, Nov 21, 2011 at 11:17:26AM +0000, Mel Gorman wrote:
> > On Fri, Nov 18, 2011 at 10:35:30PM +0100, Andrea Arcangeli wrote:
> > > folks who wants low latency or no memory overhead should simply
> > > disable compaction.
> > 
> > That strikes me as being somewhat heavy handed. Compaction should be as
> > low latency as possible.
> 
> Yes I was meaning in the very short term. Optimizations are always
> possible :) we've just to sort out some issues (as previous part of
> the email discussed).
> 

To put some figures on the latency impacts, I added a test to MM
Tests similar to yours that is in three parts

1. A process reads /dev/sda and writes to /dev/null
2. A process reads from /dev/zero and writes to a filesystem on a USB stick
3. When memory is full, a process starts that creates an anonymous
   mapping

http://www.csn.ul.ie/~mel/postings/compaction-20111122/writebackCPvfat/hydra/comparison.html
http://www.csn.ul.ie/~mel/postings/compaction-20111122/writebackCPext4/hydra/comparison.html

Looking at the vfat figures, we see

THPAVAIL
            thpavail-3.0.0-vanilla-thpavailthpavail-3.1.0-vanilla-thpavail    thpavail-3.2.0         3.2.0-rc2         3.2.0-rc2
                 3.0.0-vanilla     3.1.0-vanilla       rc2-vanilla migratedirty-v4r2    synclight-v4r2
System Time         1.89 (    0.00%)    1.90 (   -0.21%)    3.83 (  -50.63%)   19.95 (  -90.52%)   71.91 (  -97.37%)
+/-                 0.15 (    0.00%)    0.05 (  205.45%)    2.39 (  -93.87%)   27.59 (  -99.47%)    0.75 (  -80.49%)
User Time           0.10 (    0.00%)    0.10 (   -4.00%)    0.10 (   -7.69%)    0.12 (  -17.24%)    0.11 (   -9.43%)
+/-                 0.02 (    0.00%)    0.02 (  -24.28%)    0.03 (  -38.31%)    0.02 (    0.00%)    0.04 (  -56.57%)
Elapsed Time      986.53 (    0.00%) 1189.77 (  -17.08%)  589.48 (   67.36%)  506.45 (   94.79%)   73.39 ( 1244.27%)
+/-                35.52 (    0.00%)   90.09 (  -60.57%)   49.00 (  -27.51%)  213.56 (  -83.37%)    0.47 ( 7420.98%)
THP Active        118.80 (    0.00%)   89.20 (  -33.18%)   35.40 ( -235.59%)    8.00 (-1385.00%)   44.00 ( -170.00%)
+/-                65.57 (    0.00%)   35.37 (  -85.38%)   29.23 ( -124.33%)   12.51 ( -424.28%)   19.83 ( -230.65%)
Fault Alloc       308.80 (    0.00%)  244.20 (  -26.45%)   59.40 ( -419.87%)   81.00 ( -281.23%)   95.80 ( -222.34%)
+/-                81.62 (    0.00%)   80.53 (   -1.36%)   26.85 ( -203.98%)   67.85 (  -20.30%)   34.29 ( -138.05%)
Fault Fallback    697.20 (    0.00%)  761.60 (   -8.46%)  946.40 (  -26.33%)  924.80 (  -24.61%)  909.80 (  -23.37%)
+/-                81.62 (    0.00%)   80.52 (    1.37%)   26.65 (  206.28%)   67.93 (   20.16%)   34.25 (  138.33%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        541.58    645.79   1220.88   1131.04    976.54
Total Elapsed Time (seconds)               5066.05   6083.58   3068.08   2653.11    493.96

Straight off, 3.0, 3.1 and 3.2-rc2 have a number of THPs in use. 3.0
had a rougly 30% success rate with 10% of the mapping using THP but
look at the cost in time. It took about 16 minutes per iteration (5
iterations which is why total elapsed time looks large) to fault in a
mapping the size of physical memory versus 1.5 minutes with my series
(which is still very slow).

In my series system time is stupidly high but I haven't run oprofile
to see exactly where. It could be because it's running compaction
because defer_compaction() is not being called at the right times
but it could also be because direct reclaim scanning is through the
roof albeit better than 3.2-rc2 vanilla. I suspect direct reclaim
scanning could be because we are not calling ->writepage in direct
reclaim any more - 3.0 wrote 178215 pages while my series wrote 5.

The story looks better for ext4 as it is not writing page pages in
fallback_migrate_page

THPAVAIL
            thpavail-3.0.0-vanilla-thpavailthpavail-3.1.0-vanilla-thpavail    thpavail-3.2.0         3.2.0-rc2         3.2.0-rc2
                 3.0.0-vanilla     3.1.0-vanilla       rc2-vanilla migratedirty-v4r2    synclight-v4r2
System Time         2.64 (    0.00%)    2.49 (    6.10%)    3.09 (  -14.38%)    4.29 (  -38.40%)   12.20 (  -78.33%)
+/-                 0.29 (    0.00%)    0.61 (  -51.80%)    1.17 (  -74.90%)    1.33 (  -78.04%)   16.27 (  -98.20%)
User Time           0.12 (    0.00%)    0.08 (   51.28%)    0.10 (   13.46%)    0.10 (   13.46%)    0.09 (   34.09%)
+/-                 0.03 (    0.00%)    0.02 (    6.30%)    0.01 (   94.49%)    0.01 (  158.69%)    0.03 (    0.00%)
Elapsed Time      107.76 (    0.00%)   64.42 (   67.29%)   60.89 (   76.99%)   30.90 (  248.69%)   50.72 (  112.45%)
+/-                39.83 (    0.00%)   17.03 (  133.90%)    8.75 (  355.08%)   17.20 (  131.65%)   22.87 (   74.14%)
THP Active         82.80 (    0.00%)   84.20 (    1.66%)   35.00 ( -136.57%)   53.00 (  -56.23%)   36.40 ( -127.47%)
+/-                81.42 (    0.00%)   80.82 (   -0.74%)   20.89 ( -289.73%)   34.50 ( -136.01%)   51.51 (  -58.07%)
Fault Alloc       246.00 (    0.00%)  292.60 (   15.93%)   66.20 ( -271.60%)  129.40 (  -90.11%)   90.20 ( -172.73%)
+/-               173.64 (    0.00%)  161.13 (   -7.76%)   21.30 ( -715.14%)   52.41 ( -231.32%)  104.14 (  -66.74%)
Fault Fallback    759.60 (    0.00%)  712.40 (    6.63%)  939.80 (  -19.17%)  876.20 (  -13.31%)  915.60 (  -17.04%)
+/-               173.49 (    0.00%)  161.13 (    7.67%)   21.30 (  714.44%)   52.16 (  232.59%)  104.00 (   66.82%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         63.41     50.64     39.79      58.8       171
Total Elapsed Time (seconds)                732.79    483.23    447.17    335.28    412.21

THP availability is very variable between iterations and the stall
times are nowhere near as bad as with vfat but still, my series cuts
the time to fault in a mapping by half (and that is still very slow).

> > There might be some confusion on what commits were for. Commit
> > [e0887c19: vmscan: limit direct reclaim for higher order allocations]
> > was not about low latency but more about reclaim/compaction reclaiming
> > too much memory. IIRC, Rik's main problem was that there was too much
> > memory free on his machine when THP was enabled.
> > 
> > > the __GFP_NO_KSWAPD check too should be dropped I think,
> > 
> > Only if we can get rid of the major stalls. I haven't looked closely at
> > your series yet but I'll be searching for a replacment for patch 3 of
> > this series in it.
> 
> I reduced the migrate loops, for both async and sync compactions. I
> doubt it'll be very effective but it may help a bit.
> 

It may help the system times but lacking a profile, I think it's more
likely it's being spent in direct reclaim skipping over dirty pages.

> Also this one I also suggest it in the short term.
> 
> I mean until async migrate can deal with all type of pages (the issues
> you're trying to fix) the __GFP_NO_KSWAPD check would not be reliable
> enough as part of the movable zone wouldn't be movable. It'd defeat
> the reliability from the movable pageblock in compaction context. And
> I doubt a more advanced async compaction will be ok for 3.2, so I
> don't think 3.2 should have the __GFP_NO_KSWAPD and I tend to back
> Andrew's argument. My patch OTOH that only reduces the loops and
> doesn't alter the movable pageblock semantics in compaction context,
> sounds safer. It won't help equally well though.
> 

I don't think async compaction can or will deal with all types of
pages, but more of them can be dealt with.  In a revised series,
I keep sync compaction and took parts of your work to reduce the
latency (specifically sync-light but used symbolic names).

If you want, the __GFP_NO_KSWAPD check patch can be dropped as that
will also keep David happy until this series is fully baked if we
agree in principal that the current stalls are unacceptably large. It
will be a stretch to complete it in time for 3.2 though meaning that
stalls in 3.2 will be severe with THP enabled.

> > Ok. It's not even close to what I was testing but I can move to this
> > test so we're looking at the same thing for allocation success rates.
> 
> Note I guess we also need the below. This also should fix by practical
> means Rik's trouble (he was using KVM without O_DIRECT on raw
> blkdev). That explains why he experienced too much reclaim, the VM had
> no choice but to do reclaim because the blkdev cache was not staying
> in the movable pageblocks preventing compaction effectiveness (and
> likely they used lots of ram).
> 

Will comment on this patch below.

> We may still have to limit reclaim but not like the patch that went
> upstream implements.

That should be possible but again it will need to be balanced with
stall times.

> When compaction_suitable is happy about the
> wmarks, the compaction loop isn't still as reliable as it could be in
> the movable zone, and doing more reclaim helps a lot, the more free
> pages the more compaction goes ahead and has a change to compact more
> stuff before the two scans meets in the middle. With Rik we thought
> about a way to do just a no-swapping reclaim to shrink caches like
> slab.
> 

Ok, is there a patch? I'll investigate this later when I get the time
but in the shorter term, I'll be looking at why the direct reclaim
scan figures are so high.

> I mean the cp /dev/sda /dev/null scenario that happens without the
> below patch can still materialize in a fileserver with very large slab
> caches. We still have to invoke reclaim, maybe not too heavy, we
> shouldn't end up swapping, basically it should be a light reclaim (the
> opposite of lumpy reclaim). But with the current check upstream
> reclaim practically won't run at all if compaction fails, so it's
> normal the success rate goes down a lot. (btw I didn't verify yet at
> runtime if migration succeeds on the blkdev pagecache)
> 

This last "btw" is critical.

> ====
> mm: block_dev pagecache is movable
> 
> Allow block_dev pagecache to go in movable pageblocks. If compaction
> fails reclaim is invoked. So with raw devices being used without
> O_DIRECT, reclaim would run too much and because the cache pages would
> get mixed with slab and other not movable entities, the compaction
> reliability would decrease.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/block_dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index b07f1da..f7111c4 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -565,7 +565,7 @@ struct block_device *bdget(dev_t dev)
>  		inode->i_rdev = dev;
>  		inode->i_bdev = bdev;
>  		inode->i_data.a_ops = &def_blk_aops;
> -		mapping_set_gfp_mask(&inode->i_data, GFP_USER);
> +		mapping_set_gfp_mask(&inode->i_data, GFP_USER|__GFP_MOVABLE);
>  		inode->i_data.backing_dev_info = &default_backing_dev_info;
>  		spin_lock(&bdev_lock);
>  		list_add(&bdev->bd_list, &all_bdevs);

This is not the first time this patch existed. Look at the first part of
the patch in http://comments.gmane.org/gmane.linux.kernel.mm/13850 .
This was back in 2007 and the bio_alloc part was totally bogus but this
part initially looked right.

This is a long time ago so my recollection is rare but I found at the
time that hte allocations tended to be short-lived so tests would
initially look good but were not movable.

A few months later I wrote
http://kerneltrap.org/mailarchive/linux-kernel/2007/5/17/92186 where
I commented "bdget() no longer uses mobility flags after this patch
because it is does not appear that any pages allocated on behalf of
the mapping are movable so it needs to be revisited separately." I
don't remember if I revisited it.

In retrospect, the main difference may be between raw access to the
device and when the block device backs a filesystem that is currently
mounted. While mounted, the filesystem may pin pages for metadata
access which would prevent them ever being migrated and make them
unsuitable for use with __GFP_MOVABLE.

In Rik's case, this might be less of an issue. It's using the
def_blk_aops as the address space operations that does not have a
->migratepage handler so minimally if they are dirty they have to be
written out meaning it will behave more like vfat than ext4 in terms
of compaction performance. I did not spot anything that would actually
pin the buffers and prevent them from being released though but would
prefer it was double checked.

> ===
> 
> 
> > +		if (!trylock_buffer(bh)) {
> > +			/*
> > +			 * We failed to lock the buffer and cannot stall in
> > +			 * async migration. Release the taken locks
> > +			 */
> > +			struct buffer_head *failed_bh = bh;
> > +			put_bh(failed_bh);
> > +			bh = head;
> > +			while (bh != failed_bh) {
> > +				unlock_buffer(bh);
> > +				put_bh(bh);
> > +				bh = bh->b_this_page;
> > +			}
> > +			return false;
> 
> Ok!
> 
> > +	/* In the async case, migrate_page_move_mapping locked the buffers
> > +	 * with an IRQ-safe spinlock held. In the sync case, the buffers
> > +	 * need to be locked now
> > +	 */
> > +	if (sync)
> > +		BUG_ON(!buffer_migrate_lock_buffers(head, sync));
> 
> I seem to recall Andrew said we're ok with this now, but I generally
> still prefer stuff that shouldn't be optimized away to be outside of
> the BUG checks. No big deal.
> 
> Patch looks better now thanks, I'll try to do a closer review tomorrow
> and test it.
> 

If you're going to test a series, can you look at the V4 I posted that
attempts to reconcile our two series?

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A828E6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:55:37 -0500 (EST)
Message-ID: <4ECAF309.60908@redhat.com>
Date: Mon, 21 Nov 2011 19:55:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: make buffer cache __GFP_MOVABLE
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321635524-8586-5-git-send-email-mgorman@suse.de> <20111118213530.GA6323@redhat.com> <20111121111726.GA19415@suse.de> <20111121224545.GC8397@redhat.com>
In-Reply-To: <20111121224545.GC8397@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/21/2011 05:45 PM, Andrea Arcangeli wrote:
> On Mon, Nov 21, 2011 at 11:17:26AM +0000, Mel Gorman wrote:
>> On Fri, Nov 18, 2011 at 10:35:30PM +0100, Andrea Arcangeli wrote:
>>> folks who wants low latency or no memory overhead should simply
>>> disable compaction.
>>
>> That strikes me as being somewhat heavy handed. Compaction should be as
>> low latency as possible.
>
> Yes I was meaning in the very short term. Optimizations are always
> possible :) we've just to sort out some issues (as previous part of
> the email discussed).
>
>> There might be some confusion on what commits were for. Commit
>> [e0887c19: vmscan: limit direct reclaim for higher order allocations]
>> was not about low latency but more about reclaim/compaction reclaiming
>> too much memory. IIRC, Rik's main problem was that there was too much
>> memory free on his machine when THP was enabled.
>>
>>> the __GFP_NO_KSWAPD check too should be dropped I think,
>>
>> Only if we can get rid of the major stalls. I haven't looked closely at
>> your series yet but I'll be searching for a replacment for patch 3 of
>> this series in it.
>
> I reduced the migrate loops, for both async and sync compactions. I
> doubt it'll be very effective but it may help a bit.
>
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
>> Ok. It's not even close to what I was testing but I can move to this
>> test so we're looking at the same thing for allocation success rates.
>
> Note I guess we also need the below. This also should fix by practical
> means Rik's trouble (he was using KVM without O_DIRECT on raw
> blkdev). That explains why he experienced too much reclaim, the VM had
> no choice but to do reclaim because the blkdev cache was not staying
> in the movable pageblocks preventing compaction effectiveness (and
> likely they used lots of ram).
>
> We may still have to limit reclaim but not like the patch that went
> upstream implements. When compaction_suitable is happy about the
> wmarks, the compaction loop isn't still as reliable as it could be in
> the movable zone, and doing more reclaim helps a lot, the more free
> pages the more compaction goes ahead and has a change to compact more
> stuff before the two scans meets in the middle. With Rik we thought
> about a way to do just a no-swapping reclaim to shrink caches like
> slab.
>
> I mean the cp /dev/sda /dev/null scenario that happens without the
> below patch can still materialize in a fileserver with very large slab
> caches. We still have to invoke reclaim, maybe not too heavy, we
> shouldn't end up swapping, basically it should be a light reclaim (the
> opposite of lumpy reclaim). But with the current check upstream
> reclaim practically won't run at all if compaction fails, so it's
> normal the success rate goes down a lot. (btw I didn't verify yet at
> runtime if migration succeeds on the blkdev pagecache)
>
> ====
> mm: block_dev pagecache is movable
>
> Allow block_dev pagecache to go in movable pageblocks. If compaction
> fails reclaim is invoked. So with raw devices being used without
> O_DIRECT, reclaim would run too much and because the cache pages would
> get mixed with slab and other not movable entities, the compaction
> reliability would decrease.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>   fs/block_dev.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index b07f1da..f7111c4 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -565,7 +565,7 @@ struct block_device *bdget(dev_t dev)
>   		inode->i_rdev = dev;
>   		inode->i_bdev = bdev;
>   		inode->i_data.a_ops =&def_blk_aops;
> -		mapping_set_gfp_mask(&inode->i_data, GFP_USER);
> +		mapping_set_gfp_mask(&inode->i_data, GFP_USER|__GFP_MOVABLE);
>   		inode->i_data.backing_dev_info =&default_backing_dev_info;
>   		spin_lock(&bdev_lock);
>   		list_add(&bdev->bd_list,&all_bdevs);

Reviewed-by: Rik van Riel <riel@redhat.com>

Maybe prettier done by defining a GFP_USER_MOVABLE in the
proper include file and using that?

Still, we need this fix.

I believe this is safe because all the users of buffer cache
pages already need to protect the page against getting
reclaimed (by taking a refcount), which also protects against
migration.

Only pages without an extra refcount (not in current use by
anyone) can be migrated.

I do not believe this change could break any filesystem, but
adding linux-fsdevel to the CC anyway just to check...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

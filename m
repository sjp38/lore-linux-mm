Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 363BF6B002D
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 15:50:31 -0500 (EST)
Message-ID: <4ED2A28E.2070206@redhat.com>
Date: Sun, 27 Nov 2011 15:50:22 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be migreated
 without blocking within ->migratepage
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321635524-8586-5-git-send-email-mgorman@suse.de> <20111118213530.GA6323@redhat.com> <20111121111726.GA19415@suse.de> <20111121224545.GC8397@redhat.com> <20111122125906.GK19415@suse.de> <20111124011943.GO8397@redhat.com> <20111124122144.GR19415@suse.de>
In-Reply-To: <20111124122144.GR19415@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 11/24/2011 07:21 AM, Mel Gorman wrote:
> On Thu, Nov 24, 2011 at 02:19:43AM +0100, Andrea Arcangeli wrote:

>> But funny thing grow_dev_page already sets __GFP_MOVABLE. That's
>> pretty weird and it's probably source of a few not movable pages in
>> the movable block. But then many bh are movable... most of them are,
>> it's just the superblock that isn't.
>>
>> But considering grow_dev_page sets __GFP_MOVABLE, any worry about pins
>> from the fs on the block_dev.c pagecache shouldn't be a concern...
>>
>
> Except in quantity. We can cope with some pollution of MIGRATE_MOVABLE
> but if it gets excessive, it will cause a lot of trouble. Superblock
> bh's may not be movable but there are not many of them and they are
> long lived.

We're potentially doomed either way :)

If we allocate a lot of movable pages in non-movable
blocks, we can end up with a lot of slightly polluted
blocks even after reclaiming all the reclaimable page
cache.

If we allocate a few non-movable pages in movable
blocks, we can end up with the same situation.

Either way, we can potentially end up with a lot of
memory that cannot be defragmented.

Of course, it could take the mounting of a lot of
filesystems for this problem to be triggered, but we
know there are people doing that.

>> __GFP_MOVABLE missing block_dev also was not
>> so common and it most certainly contributed to a reclaim more
>> aggressive than it would have happened with that fix. I think you can
>> push things one at time without urgency here, and I'd prefer maybe if
>> block_dev patch is applied and the other reversed in vmscan.c or
>> improved to start limiting only if we're above 8*high or some
>> percentage check to allow a little more reclaim than rc2 allows
>
> The limiting is my current preferred option - at least until it is
> confirmed that it really is ok to mark block_dev pages movable and that
> Rik is ok with the revert.

I am fine with replacing the compaction checks with free limit
checks. Funny enough, the first iteration of the patch I submitted
to limit reclaim used a free limit check :)

I also suspect we will want to call shrink_slab regardless of
whether or not a memory zone is already over its free limit for
direct reclaim, since that has the potential to free an otherwise
unmovable page.

>> (i.e. no reclaim at all which likely results in a failure in hugepage
>> allocation). Not unlimited as 3.1 is ok with me but if kswapd can free
>> a percentage I don't see why reclaim can't (consdiering more free
>> pages in movable pageblocks are needed to succeed compaction). The
>> ideal is to improve the compaction rate and at the same time reduce
>> reclaim aggressiveness. Let's start with the parts that are more
>> obviously right fixes and that don't risk regressions, we don't want
>> compaction regressions :).
>>
>
> I don't think there are any "obviously right fixes" right now until the
> block_dev patch is proven to be ok and that reverting does not regress
> Rik's workload. Going to take time.

Ironically the test Andrea is measuring THP allocations with
(dd from /dev/sda to /dev/null) is functionally equivalent to
me running KVM guests with cache=writethrough directly from
a block device.

The difference is that Andrea is measuring THP allocation
success rate, while I am watching how well the programs (and
KVM guests) actually run.

Not surprisingly, swapping out the working set has a pretty
catastrophic effect on performance, even if it helps THP
allocation success :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

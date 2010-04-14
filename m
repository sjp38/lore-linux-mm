Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3C8FF6B01F0
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 03:54:17 -0400 (EDT)
Received: by iwn14 with SMTP id 14so5570627iwn.22
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 00:54:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100414044458.GF2493@dastard>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
	 <m2h28c262361004131724ycf9bf4a5xd9b1bad2b4797f50@mail.gmail.com>
	 <20100414044458.GF2493@dastard>
Date: Wed, 14 Apr 2010 16:54:17 +0900
Message-ID: <t2r28c262361004140054t807b7edbzc69e7830f6978735@mail.gmail.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 1:44 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Wed, Apr 14, 2010 at 09:24:33AM +0900, Minchan Kim wrote:
>> Hi, Dave.
>>
>> On Tue, Apr 13, 2010 at 9:17 AM, Dave Chinner <david@fromorbit.com> wrote:
>> > From: Dave Chinner <dchinner@redhat.com>
>> >
>> > When we enter direct reclaim we may have used an arbitrary amount of stack
>> > space, and hence enterring the filesystem to do writeback can then lead to
>> > stack overruns. This problem was recently encountered x86_64 systems with
>> > 8k stacks running XFS with simple storage configurations.
>> >
>> > Writeback from direct reclaim also adversely affects background writeback. The
>> > background flusher threads should already be taking care of cleaning dirty
>> > pages, and direct reclaim will kick them if they aren't already doing work. If
>> > direct reclaim is also calling ->writepage, it will cause the IO patterns from
>> > the background flusher threads to be upset by LRU-order writeback from
>> > pageout() which can be effectively random IO. Having competing sources of IO
>> > trying to clean pages on the same backing device reduces throughput by
>> > increasing the amount of seeks that the backing device has to do to write back
>> > the pages.
>> >
>> > Hence for direct reclaim we should not allow ->writepages to be entered at all.
>> > Set up the relevant scan_control structures to enforce this, and prevent
>> > sc->may_writepage from being set in other places in the direct reclaim path in
>> > response to other events.
>>
>> I think your solution is rather aggressive change as Mel and Kosaki
>> already pointed out.
>
> It may be agressive, but writeback from direct reclaim is, IMO, one
> of the worst aspects of the current VM design because of it's
> adverse effect on the IO subsystem.

Tend to agree. But De we need it by last resort if flusher thread
can't catch up
write stream?
Or In my opinion, Could I/O layer have better throttle logic than now?

>
> I'd prefer to remove it completely that continue to try and patch
> around it, especially given that everyone seems to agree that it
> does have an adverse affect on IO...

Of course, If everybody agree, we can do it.
For it, we need many benchmark result which is very hard.
Maybe I will help it in embedded system.

>
>> Do flush thread aware LRU of dirty pages in system level recency not
>> dirty pages recency?
>
> It writes back in the order inodes were dirtied. i.e. the LRU is a
> coarser measure, but it it still definitely there. It also takes
> into account fairness of IO between dirty inodes, so no one dirty
> inode prevents IO beining issued on a other dirty inodes on the
> LRU...

Thanks.
It seems to be lost recency.
I am not sure how much it affects system performance.

>
>> Of course flush thread can clean dirty pages faster than direct reclaimer.
>> But if it don't aware LRUness, hot page thrashing can be happened by
>> corner case.
>> It could lost write merge.
>>
>> And non-rotation storage might be not big of seek cost.
>
> Non-rotational storage still goes faster when it is fed large, well
> formed IOs.

Agreed. I missed. Nand device is stronger than HDD about random read.
But ramdom write is very weak in performance and wear-leveling.

>
>> I think we have to consider that case if we decide to change direct reclaim I/O.
>>
>> How do we separate the problem?
>>
>> 1. stack hogging problem.
>> 2. direct reclaim random write.
>
> AFAICT, the only way to _reliably_ avoid the stack usage problem is
> to avoid writeback in direct reclaim. That has the side effect of
> fixing #2 as well, so do they really need separating?

If we can do it, it's good.
but 2. problem is not easy to fix, I think.
Compared to 2, 1 is rather easy.
So I thought we can solve 1 firstly and then focusing 2.
If your suggestion is right, then we can apply your idea.
Then we don't need to revert the patch of 1 since small stack usage is
always good
if we don't lost big performance.

>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

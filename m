Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 354EF6B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 21:30:16 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so11987471pad.39
        for <linux-mm@kvack.org>; Wed, 28 May 2014 18:30:15 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id yd3si25837305pbc.42.2014.05.28.18.30.13
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 18:30:15 -0700 (PDT)
Date: Thu, 29 May 2014 11:30:07 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140529013007.GF6677@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 03:41:11PM -0700, Linus Torvalds wrote:
> On Wed, May 28, 2014 at 3:31 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > Indeed, the call chain reported here is not caused by swap issuing
> > IO.
> 
> Well, that's one way of reading that callchain.
> 
> I think it's the *wrong* way of reading it, though. Almost dishonestly
> so.

I guess you haven't met your insult quota for the day, Linus. :/

> Because very clearly, the swapout _is_ what causes the unplugging
> of the IO queue, and does so because it is allocating the BIO for its
> own IO.  The fact that that then fails (because of other IO's in
> flight), and causes *other* IO to be flushed, doesn't really change
> anything fundamental. It's still very much swap that causes that
> "let's start IO".

It is not rocket science to see how plugging outside memory
allocation context can lead to flushing that plug within direct
reclaim without having dispatched any IO at all from direct
reclaim....

You're focussing on the specific symptoms, not the bigger picture.
i.e. you're ignoring all the other "let's start IO" triggers in
direct reclaim. e.g there's two separate plug flush triggers in
shrink_inactive_list(), one of which is:

        /*
         * Stall direct reclaim for IO completions if underlying BDIs or zone
         * is congested. Allow kswapd to continue until it starts encountering
         * unqueued dirty pages or cycling through the LRU too quickly.
         */
        if (!sc->hibernation_mode && !current_is_kswapd())
                wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);

I'm not saying we shouldn't turn of swap from direct reclaim, just
that all we'd be doing by turning off swap is playing whack-a-stack
- the next report will simply be from one of the other direct
reclaim IO schedule points.

Regardless of whether it is swap or something external queues the
bio on the plug, perhaps we should look at why it's done inline
rather than by kblockd, where it was moved because it was blowing
the stack from schedule():

commit f4af3c3d077a004762aaad052049c809fd8c6f0c
Author: Jens Axboe <jaxboe@fusionio.com>
Date:   Tue Apr 12 14:58:51 2011 +0200

    block: move queue run on unplug to kblockd
    
    There are worries that we are now consuming a lot more stack in
    some cases, since we potentially call into IO dispatch from
    schedule() or io_schedule(). We can reduce this problem by moving
    the running of the queue to kblockd, like the old plugging scheme
    did as well.
    
    This may or may not be a good idea from a performance perspective,
    depending on how many tasks have queue plugs running at the same
    time. For even the slightly contended case, doing just a single
    queue run from kblockd instead of multiple runs directly from the
    unpluggers will be faster.
    
    Signed-off-by: Jens Axboe <jaxboe@fusionio.com>


commit a237c1c5bc5dc5c76a21be922dca4826f3eca8ca
Author: Jens Axboe <jaxboe@fusionio.com>
Date:   Sat Apr 16 13:27:55 2011 +0200

    block: let io_schedule() flush the plug inline
    
    Linus correctly observes that the most important dispatch cases
    are now done from kblockd, this isn't ideal for latency reasons.
    The original reason for switching dispatches out-of-line was to
    avoid too deep a stack, so by _only_ letting the "accidental"
    flush directly in schedule() be guarded by offload to kblockd,
    we should be able to get the best of both worlds.
    
    So add a blk_schedule_flush_plug() that offloads to kblockd,
    and only use that from the schedule() path.
    
    Signed-off-by: Jens Axboe <jaxboe@fusionio.com>

And now we have too deep a stack due to unplugging from io_schedule()...

> IOW, swap-out directly caused that extra 3kB of stack use in what was
> a deep call chain (due to memory allocation). I really don't
> understand why you are arguing anything else on a pure technicality.
>
> I thought you had some other argument for why swap was different, and
> against removing that "page_is_file_cache()" special case in
> shrink_page_list().

I've said in the past that swap is different to filesystem
->writepage implementations because it doesn't require significant
stack to do block allocation and doesn't trigger IO deep in that
allocation stack. Hence it has much lower stack overhead than the
filesystem ->writepage implementations and so is much less likely to
have stack issues.

This stack overflow shows us that just the memory reclaim + IO
layers are sufficient to cause a stack overflow, which is something
I've never seen before. That implies no IO in direct reclaim context
is safe - either from swap or io_schedule() unplugging. It also
lends a lot of weight to my assertion that the majority of the stack
growth over the past couple of years has been ocurring outside the
filesystems....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

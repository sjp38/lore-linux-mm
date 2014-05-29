Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A598E6B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 21:58:35 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ld10so101971pab.34
        for <linux-mm@kvack.org>; Wed, 28 May 2014 18:58:35 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id yy5si12241748pbb.144.2014.05.28.18.58.33
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 18:58:34 -0700 (PDT)
Date: Thu, 29 May 2014 11:58:30 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140529015830.GG6677@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529013007.GF6677@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 11:30:07AM +1000, Dave Chinner wrote:
> On Wed, May 28, 2014 at 03:41:11PM -0700, Linus Torvalds wrote:
> commit a237c1c5bc5dc5c76a21be922dca4826f3eca8ca
> Author: Jens Axboe <jaxboe@fusionio.com>
> Date:   Sat Apr 16 13:27:55 2011 +0200
> 
>     block: let io_schedule() flush the plug inline
>     
>     Linus correctly observes that the most important dispatch cases
>     are now done from kblockd, this isn't ideal for latency reasons.
>     The original reason for switching dispatches out-of-line was to
>     avoid too deep a stack, so by _only_ letting the "accidental"
>     flush directly in schedule() be guarded by offload to kblockd,
>     we should be able to get the best of both worlds.
>     
>     So add a blk_schedule_flush_plug() that offloads to kblockd,
>     and only use that from the schedule() path.
>     
>     Signed-off-by: Jens Axboe <jaxboe@fusionio.com>
> 
> And now we have too deep a stack due to unplugging from io_schedule()...

So, if we make io_schedule() push the plug list off to the kblockd
like is done for schedule()....

> > IOW, swap-out directly caused that extra 3kB of stack use in what was
> > a deep call chain (due to memory allocation). I really don't
> > understand why you are arguing anything else on a pure technicality.
> >
> > I thought you had some other argument for why swap was different, and
> > against removing that "page_is_file_cache()" special case in
> > shrink_page_list().
> 
> I've said in the past that swap is different to filesystem
> ->writepage implementations because it doesn't require significant
> stack to do block allocation and doesn't trigger IO deep in that
> allocation stack. Hence it has much lower stack overhead than the
> filesystem ->writepage implementations and so is much less likely to
> have stack issues.
> 
> This stack overflow shows us that just the memory reclaim + IO
> layers are sufficient to cause a stack overflow,

.... we solve this problem directly by being able to remove the IO
stack usage from the direct reclaim swap path.

IOWs, we don't need to turn swap off at all in direct reclaim
because all the swap IO can be captured in a plug list and
dispatched via kblockd. This could be done either by io_schedule()
or a new blk_flush_plug_list() wrapper that pushes the work to
kblockd...

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

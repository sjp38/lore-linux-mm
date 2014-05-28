Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7D06B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 18:31:47 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx10so1904415pab.0
        for <linux-mm@kvack.org>; Wed, 28 May 2014 15:31:47 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id bm3si4338075pbc.86.2014.05.28.15.31.46
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 15:31:46 -0700 (PDT)
Date: Thu, 29 May 2014 08:31:42 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140528223142.GO8554@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 09:09:23AM -0700, Linus Torvalds wrote:
> On Tue, May 27, 2014 at 11:53 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > So, my stupid idea is just let's expand stack size and keep an eye
> > toward stack consumption on each kernel functions via stacktrace of ftrace.
.....
> But what *does* stand out (once again) is that we probably shouldn't
> do swap-out in direct reclaim. This came up the last time we had stack
> issues (XFS) too. I really do suspect that direct reclaim should only
> do the kind of reclaim that does not need any IO at all.
> 
> I think we _do_ generally avoid IO in direct reclaim, but swap is
> special. And not for a good reason, afaik. DaveC, remind me, I think
> you said something about the swap case the last time this came up..

Right, we do generally avoid IO through filesystems via direct
reclaim because delayed allocation requires significant amounts
of additional memory, stack space and IO.

However, swap doesn't have that overhead - it's just the IO stack
that it drives through submit_bio(), and the worst case I'd seen
through that path was much less than other reclaim stack path usage.
I haven't seen swap in any of the stack overflows from production
machines, and I only rarely see it in worst case stack usage
profiles on my test machines.

Indeed, the call chain reported here is not caused by swap issuing
IO.  We scheduled in the swap code (throttling waiting for
congestion, I think) with a plugged block device (from the ext4
writeback layer) with pending bios queued on it and the scheduler
has triggered a flush of the device.  submit_bio in the swap path
has much less stack usage than io_schedule() because it doesn't have
any of the scheduler or plug list flushing overhead in the stack.

So, realistically, the swap path is not worst case stack usage here
and disabling it won't prevent this stack overflow from happening.
Direct reclaim will simply throttle elsewhere and that will still
cause the plug to be flushed, the IO to be issued and the stack to
overflow.

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

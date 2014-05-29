Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 61BC86B003D
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:26:39 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so12429276pab.33
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:26:39 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id hv12si15383818pac.103.2014.05.29.00.26.37
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 00:26:38 -0700 (PDT)
Date: Thu, 29 May 2014 17:26:33 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140529072633.GH6677@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 07:42:40PM -0700, Linus Torvalds wrote:
> On Wed, May 28, 2014 at 6:30 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > You're focussing on the specific symptoms, not the bigger picture.
> > i.e. you're ignoring all the other "let's start IO" triggers in
> > direct reclaim. e.g there's two separate plug flush triggers in
> > shrink_inactive_list(), one of which is:
> 
> Fair enough. I certainly agree that we should look at the other cases here too.
> 
> In fact, I also find it distasteful just how much stack space some of
> those VM routines are just using up on their own, never mind any
> actual IO paths at all. The fact that __alloc_pages_nodemask() uses
> 350 bytes of stackspace on its own is actually quite disturbing. The
> fact that kernel_map_pages() apparently has almost 400 bytes of stack
> is just crazy. Obviously that case only happens with
> CONFIG_DEBUG_PAGEALLOC, but still..

What concerns me about both __alloc_pages_nodemask() and
kernel_map_pages is that when I look at the code I see functions
that have no obvious stack usage problem. However, the compiler is
producing functions with huge stack footprints and it's not at all
obvious when I read the code. So in this case I'm more concerned
that we have a major disconnect between the source code structure
and the code that the compiler produces...

> > I'm not saying we shouldn't turn of swap from direct reclaim, just
> > that all we'd be doing by turning off swap is playing whack-a-stack
> > - the next report will simply be from one of the other direct
> > reclaim IO schedule points.
> 
> Playing whack-a-mole with this for a while might not be a bad idea,
> though. It's not like we will ever really improve unless we start
> whacking the worst cases. And it should still be a fairly limited
> number.

I guess I've been playing whack-a-stack for so long now and some of
the overruns have been so large I just don't see it as a viable
medium to long term solution.

> After all, historically, some of the cases we've played whack-a-mole
> on have been in XFS, so I'd think you'd be thrilled to see some other
> code get blamed this time around ;)

Blame shifting doesn't thrill me - I'm still at the pointy end of
stack overrun reports, and we've still got to do the hard work of
solving the problem. However, I am happy to see acknowlegement of
the problem so we can work out how to solve the issues...

> > Regardless of whether it is swap or something external queues the
> > bio on the plug, perhaps we should look at why it's done inline
> > rather than by kblockd, where it was moved because it was blowing
> > the stack from schedule():
> 
> So it sounds like we need to do this for io_schedule() too.
> 
> In fact, we've generally found it to be a mistake every time we
> "automatically" unblock some IO queue. And I'm not saying that because
> of stack space, but because we've _often_ had the situation that eager
> unblocking results in IO that could have been done as bigger requests.
> 
> Of course, we do need to worry about latency for starting IO, but any
> of these kinds of memory-pressure writeback patterns are pretty much
> by definition not about the latency of one _particular_ IO, so they
> don't tent to be latency-sensitive. Quite the reverse: we start
> writeback and then end up waiting on something else altogether
> (possibly a writeback that got started much earlier).

*nod*

> swapout certainly is _not_ IO-latency-sensitive, especially these
> days. And while we _do_ want to throttle in direct reclaim, if it's
> about throttling I'd certainly think that it sounds quite reasonable
> to push any unplugging to kblockd than try to do that synchronously.
> If we are throttling in direct-reclaim, we need to slow things _down_
> for the writer, not worry about latency.

Right, we are adding latency to the caller by having to swap so
a small amount of additional IO dispatch latency for IO we aren't
going to wait directly on doesn't really matter at all.

> >                That implies no IO in direct reclaim context
> > is safe - either from swap or io_schedule() unplugging. It also
> > lends a lot of weight to my assertion that the majority of the stack
> > growth over the past couple of years has been ocurring outside the
> > filesystems....
> 
> I think Minchan's stack trace definitely backs you up on that. The
> filesystem part - despite that one ext4_writepages() function - is a
> very small part of the whole. It sits at about ~1kB of stack. Just the
> VM "top-level" writeback code is about as much, and then the VM page
> alloc/shrinking code when the filesystem needs memory is *twice* that,
> and then the block layer and the virtio code are another 1kB each.

*nod*

As i said early, look at this in the context of the bigger picture.
We can also have more stack using layers in the IO stack and/or more
stack-expensive layers. e.g.  it could be block -> dm -> md -> SCSI
-> mempool_alloc in that stack rather than block -> virtio ->
kmalloc. Hence 1k of virtio stack could be 1.5k of SCSI stack,
md/dm could contribute a few hundred bytes each (or more depending
on how many layers of dm/md there are), and so on.

When you start adding all that up, it doesn't paint a pretty
picture. That's one of the main reasons why I don't think the
whack-a-stack approach will solve the problem in the medium to long
term...

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

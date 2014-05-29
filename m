Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 589486B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 22:42:41 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ij19so13613411vcb.28
        for <linux-mm@kvack.org>; Wed, 28 May 2014 19:42:41 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id u6si12291542ven.33.2014.05.28.19.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 19:42:40 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so13574926veb.34
        for <linux-mm@kvack.org>; Wed, 28 May 2014 19:42:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140529013007.GF6677@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
Date: Wed, 28 May 2014 19:42:40 -0700
Message-ID: <CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 6:30 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> You're focussing on the specific symptoms, not the bigger picture.
> i.e. you're ignoring all the other "let's start IO" triggers in
> direct reclaim. e.g there's two separate plug flush triggers in
> shrink_inactive_list(), one of which is:

Fair enough. I certainly agree that we should look at the other cases here too.

In fact, I also find it distasteful just how much stack space some of
those VM routines are just using up on their own, never mind any
actual IO paths at all. The fact that __alloc_pages_nodemask() uses
350 bytes of stackspace on its own is actually quite disturbing. The
fact that kernel_map_pages() apparently has almost 400 bytes of stack
is just crazy. Obviously that case only happens with
CONFIG_DEBUG_PAGEALLOC, but still..

> I'm not saying we shouldn't turn of swap from direct reclaim, just
> that all we'd be doing by turning off swap is playing whack-a-stack
> - the next report will simply be from one of the other direct
> reclaim IO schedule points.

Playing whack-a-mole with this for a while might not be a bad idea,
though. It's not like we will ever really improve unless we start
whacking the worst cases. And it should still be a fairly limited
number.

After all, historically, some of the cases we've played whack-a-mole
on have been in XFS, so I'd think you'd be thrilled to see some other
code get blamed this time around ;)

> Regardless of whether it is swap or something external queues the
> bio on the plug, perhaps we should look at why it's done inline
> rather than by kblockd, where it was moved because it was blowing
> the stack from schedule():

So it sounds like we need to do this for io_schedule() too.

In fact, we've generally found it to be a mistake every time we
"automatically" unblock some IO queue. And I'm not saying that because
of stack space, but because we've _often_ had the situation that eager
unblocking results in IO that could have been done as bigger requests.

Of course, we do need to worry about latency for starting IO, but any
of these kinds of memory-pressure writeback patterns are pretty much
by definition not about the latency of one _particular_ IO, so they
don't tent to be latency-sensitive. Quite the reverse: we start
writeback and then end up waiting on something else altogether
(possibly a writeback that got started much earlier).

swapout certainly is _not_ IO-latency-sensitive, especially these
days. And while we _do_ want to throttle in direct reclaim, if it's
about throttling I'd certainly think that it sounds quite reasonable
to push any unplugging to kblockd than try to do that synchronously.
If we are throttling in direct-reclaim, we need to slow things _down_
for the writer, not worry about latency.

> I've said in the past that swap is different to filesystem
> ->writepage implementations because it doesn't require significant
> stack to do block allocation and doesn't trigger IO deep in that
> allocation stack. Hence it has much lower stack overhead than the
> filesystem ->writepage implementations and so is much less likely to
> have stack issues.

Clearly it is true that it lacks the actual filesystem part needed for
the writeback. At the same time, Minchan's example is certainly a good
one of a filesystem (ext4) already being reasonably deep in its own
stack space when it then wants memory.

Looking at that callchain, I have to say that ext4 doesn't look
horrible compared to the whole block layer and virtio.. Yes,
"ext4_writepages()" is using almost 400 bytes of stack, and most of
that seems to be due to:

        struct mpage_da_data mpd;
        struct blk_plug plug;

which looks at least understandable (nothing like the mess in the VM
code where the stack usage is because gcc creates horrible spills)

> This stack overflow shows us that just the memory reclaim + IO
> layers are sufficient to cause a stack overflow, which is something
> I've never seen before.

Well, we've definitely have had some issues with deeper callchains
with md, but I suspect virtio might be worse, and the new blk-mq code
is lilkely worse in this respect too.

And Minchan running out of stack is at least _partly_ due to his debug
options (that DEBUG_PAGEALLOC thing as an extreme example, but I
suspect there's a few other options there that generate more bloated
data structures too too).

>                That implies no IO in direct reclaim context
> is safe - either from swap or io_schedule() unplugging. It also
> lends a lot of weight to my assertion that the majority of the stack
> growth over the past couple of years has been ocurring outside the
> filesystems....

I think Minchan's stack trace definitely backs you up on that. The
filesystem part - despite that one ext4_writepages() function - is a
very small part of the whole. It sits at about ~1kB of stack. Just the
VM "top-level" writeback code is about as much, and then the VM page
alloc/shrinking code when the filesystem needs memory is *twice* that,
and then the block layer and the virtio code are another 1kB each.

The rest is just kthread overhead and that DEBUG_PAGEALLOC thing.
Other debug options might be bloating Minchan's stack use numbers in
general, but probably not by massive amounts. Locks will generally be
_hugely_ bigger due to lock debugging, but that's seldom on the stack.

So no, this is not a filesystem problem. This is definitely core VM
and block layer, no arguments what-so-ever.

I note that Jens wasn't cc'd. Added him in.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

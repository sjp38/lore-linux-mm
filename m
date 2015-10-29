Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE9582F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:23:59 -0400 (EDT)
Received: by wmff134 with SMTP id f134so27923784wmf.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 09:23:58 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id s136si5700307wmb.3.2015.10.29.09.23.57
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 09:23:58 -0700 (PDT)
Date: Thu, 29 Oct 2015 17:23:56 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151029162356.GQ29811@alap3.anarazel.de>
References: <20151022131555.GC4378@alap3.anarazel.de>
 <20151024213912.GE8773@dastard>
 <20151028092752.GF29811@alap3.anarazel.de>
 <20151028204834.GP8773@dastard>
 <20151028232312.GL29811@alap3.anarazel.de>
 <20151029015422.GT8773@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029015422.GT8773@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 2015-10-29 12:54:22 +1100, Dave Chinner wrote:
> On Thu, Oct 29, 2015 at 12:23:12AM +0100, Andres Freund wrote:
> > The blocking/latency of the fsync doesn't actually matter at all *for
> > this callsite*. It's called from a dedicated background process - if
> > it's slowed down by a couple seconds it doesn't matter much.
> > The problem is that if you have a couple gigabytes of dirty data being
> > fsync()ed at once, latency for concurrent reads and writes often goes
> > absolutely apeshit. And those concurrent reads and writes might
> > actually be latency sensitive.
> 
> Right, but my point is with an async fsync/fdatasync you don't need
> this background process - you can just trickle out async fdatasync
> calls instead of trckling out calls to sync_file_range().

We don't want to do the checkpointing from normal backends that process
user queries, so there has to be a background process anyway. Depending
on settings we only do the checkpoints in 5 to 60 minutes intervals
(spread over that interval).


> > By calling sync_file_range() over small ranges of pages shortly after
> > they've been written we make it unlikely (but still possible) that much
> > data has to be flushed at fsync() time.
> 
> Right, but you still need the fsync call, whereas with a async fsync
> call you don't - when you gather the completion, no further action
> needs to be taken on that dirty range.

I assume that the actual IOs issued by the async fsync and a plain fsync
would be pretty similar. So the problem that an fsync of large amounts
of dirty data causes latency increases for other issuers of IO wouldn't
be gone, no?


> > At the moment using fdatasync() instead of fsync() is a considerable
> > performance advantage... If I understand the above proposal correctly,
> > it'd allow specifying ranges, is that right?
> 
> Well, the patch I sent doesn't do ranges, but it could easily be
> passed in as the iocb has offset/len parameters that are used by
> IOCB_CMD_PREAD/PWRITE.

That'd be cool. Then we could issue those for asynchronous transaction
commits, and to have more wal writes concurrently in progress by the
background wal writer.



I'll try the patch from 20151028232641.GS8773@dastard and see wether I
can make it be advantageous for throughput (for WAL flushing, not the
checkpointer process).  Wish I had a better storage system, my guess
it'll be more advantageous there. We'll see.


Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

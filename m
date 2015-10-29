Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4844182F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 21:54:27 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so24865347pac.3
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 18:54:27 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id z4si66236755par.49.2015.10.28.18.54.25
        for <linux-mm@kvack.org>;
        Wed, 28 Oct 2015 18:54:26 -0700 (PDT)
Date: Thu, 29 Oct 2015 12:54:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151029015422.GT8773@dastard>
References: <20151022131555.GC4378@alap3.anarazel.de>
 <20151024213912.GE8773@dastard>
 <20151028092752.GF29811@alap3.anarazel.de>
 <20151028204834.GP8773@dastard>
 <20151028232312.GL29811@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151028232312.GL29811@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 29, 2015 at 12:23:12AM +0100, Andres Freund wrote:
> Hi,
> 
> On 2015-10-29 07:48:34 +1100, Dave Chinner wrote:
> > > The idea of using SYNC_FILE_RANGE_WRITE beforehand is that
> > > the fsync() will only have to do very little work. The language in
> > > sync_file_range(2) doesn't inspire enough confidence for using it as an
> > > actual integrity operation :/
> > 
> > So really you're trying to minimise the blocking/latency of fsync()?
> 
> The blocking/latency of the fsync doesn't actually matter at all *for
> this callsite*. It's called from a dedicated background process - if
> it's slowed down by a couple seconds it doesn't matter much.
> The problem is that if you have a couple gigabytes of dirty data being
> fsync()ed at once, latency for concurrent reads and writes often goes
> absolutely apeshit. And those concurrent reads and writes might
> actually be latency sensitive.

Right, but my point is with an async fsync/fdatasync you don't need
this background process - you can just trickle out async fdatasync
calls instead of trckling out calls to sync_file_range().

> By calling sync_file_range() over small ranges of pages shortly after
> they've been written we make it unlikely (but still possible) that much
> data has to be flushed at fsync() time.

Right, but you still need the fsync call, whereas with a async fsync
call you don't - when you gather the completion, no further action
needs to be taken on that dirty range.

> At the moment using fdatasync() instead of fsync() is a considerable
> performance advantage... If I understand the above proposal correctly,
> it'd allow specifying ranges, is that right?

Well, the patch I sent doesn't do ranges, but it could easily be
passed in as the iocb has offset/len parameters that are used by
IOCB_CMD_PREAD/PWRITE. io_prep_fsync/io_fsync both memset the iocb
to zero, so if we pass in a non-zero length, we could treat it as a
ranged f(d)sync quite easily.

> There'll be some concern about portability around this - issuing
> sync_file_range() every now and then isn't particularly invasive. Using
> aio might end up being that, not sure.

It's still a non-portable/linux only solution, because it is using
the linux native aio interface, not the glibc one...

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

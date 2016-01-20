Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 019A86B0009
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:46:21 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id g73so35154127ioe.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 13:46:20 -0800 (PST)
Date: Thu, 21 Jan 2016 08:45:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160120214546.GX6033@dastard>
References: <20160112022548.GD6033@dastard>
 <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
 <20160112033708.GE6033@dastard>
 <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
 <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
 <20160115202131.GH6330@kvack.org>
 <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
 <20160120195957.GV6033@dastard>
 <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
 <20160120204449.GC12249@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160120204449.GC12249@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 20, 2016 at 03:44:49PM -0500, Benjamin LaHaise wrote:
> On Wed, Jan 20, 2016 at 12:29:32PM -0800, Linus Torvalds wrote:
> > On Wed, Jan 20, 2016 at 11:59 AM, Dave Chinner <david@fromorbit.com> wrote:
> > >>
> > >> Are there other users outside of Solace? It would be good to get comments..
> > >
> > > I know of quite a few storage/db products that use AIO. The most
> > > recent high profile project that have been reporting issues with AIO
> > > on XFS is http://www.scylladb.com/. That project is architected
> > > around non-blocking AIO for scalability reasons...
> > 
> > I was more wondering about the new interfaces, making sure that the
> > feature set actually matches what people want to do..
> 
> I suspect this will be an ongoing learning exercise as people start to use 
> the new functionality and find gaps in terms of what is needed.  Certainly 
> there is a bunch of stuff we need to add to cover the cases where disk i/o 
> is required.  getdents() is one example, but the ABI issues we have with it 
> are somewhat more complicated given the history associated with that 
> interface.
> 
> > That said, I also agree that it would be interesting to hear what the
> > performance impact is for existing performance-sensitive users. Could
> > we make that "aio_may_use_threads()" case be unconditional, making
> > things simpler?
> 
> Making it unconditional is a goal, but some work is required before that 
> can be the case.  The O_DIRECT issue is one such matter -- it requires some 
> changes to the filesystems to ensure that they adhere to the non-blocking 
> nature of the new interface (ie taking i_mutex is a Bad Thing that users 
> really do not want to be exposed to; if taking it blocks, the code should 
> punt to a helper thread).

Filesystems *must take locks* in the IO path. We have to serialise
against truncate and other operations at some point in the IO path
(e.g. block mapping vs concurrent allocation and/or removal), and
that can only be done sanely with sleeping locks.  There is no way
of knowing in advance if we are going to block, and so either we
always use threads for IO submission or we accept that occasionally
the AIO submission will block.

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

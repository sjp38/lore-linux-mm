Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 710386B0253
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:39:41 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id g73so109889408ioe.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 20:39:41 -0800 (PST)
Date: Sat, 23 Jan 2016 15:39:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160123043922.GF6033@dastard>
References: <20160112033708.GE6033@dastard>
 <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
 <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
 <20160115202131.GH6330@kvack.org>
 <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
 <20160120195957.GV6033@dastard>
 <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
 <20160120204449.GC12249@kvack.org>
 <20160120214546.GX6033@dastard>
 <CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Benjamin LaHaise <bcrl@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Wed, Jan 20, 2016 at 03:07:26PM -0800, Linus Torvalds wrote:
> On Jan 20, 2016 1:46 PM, "Dave Chinner" <david@fromorbit.com> wrote:
> > >
> > > > That said, I also agree that it would be interesting to hear what the
> > > > performance impact is for existing performance-sensitive users. Could
> > > > we make that "aio_may_use_threads()" case be unconditional, making
> > > > things simpler?
> > >
> > > Making it unconditional is a goal, but some work is required before that
> > > can be the case.  The O_DIRECT issue is one such matter -- it requires
> some
> > > changes to the filesystems to ensure that they adhere to the
> non-blocking
> > > nature of the new interface (ie taking i_mutex is a Bad Thing that users
> > > really do not want to be exposed to; if taking it blocks, the code
> should
> > > punt to a helper thread).
> >
> > Filesystems *must take locks* in the IO path.
> 
> I agree.
> 
> I also would prefer to make the aio code have as little interaction and
> magic flags with the filesystem code as humanly possible.
> 
> I wonder if we could make the rough rule be that the only synchronous case
> the aio code ever has is more or less entirely in the generic vfs caches?
> IOW, could we possibly aim to make the rule be that if we call down to the
> filesystem layer, we do that within a thread?

We have to go through the filesystem layer locking even on page
cache hits, and even if we get into the page cache copy-in/copy-out
code we can still get stuck on things like page locks and page
faults. Even if hte pages are cached, we can still get caught on
deeper filesystem locks for block mapping. e.g. read from a hole,
get zeros back, page cache is populated. Write data into range,
fetch page, realise it's unmapped, need to do block/delayed
allocation which requires filesystem locks and potentially
transactions and IO....

> We could do things like that for the name loopkup for openat() too, where
> we could handle the successful RCU loopkup synchronously, but then if we
> fall out of RCU mode we'd do the thread.

We'd have to do quite a bit of work to unwind back out to the AIO
layer before we can dispatch the open operation again in a thread,
wouldn't we?

So I'm not convinced that conditional thread dispatch makes sense. I
think the simplest thing to do is make all AIO use threads/
workqueues by default, and if the application is smart enough to
only do things that minimise blocking they can turn off the threaded
dispatch and get the same behaviour they get now.

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

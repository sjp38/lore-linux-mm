Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id E20696B028B
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 20:00:46 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id z60so9146963qgd.8
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 17:00:46 -0700 (PDT)
Date: Fri, 21 Mar 2014 17:00:42 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140322000042.GS10561@lenny.home.zabbo.net>
References: <20140321043041.8428.79003.stgit@birch.djwong.org>
 <20140321182332.GP10561@lenny.home.zabbo.net>
 <20140321222025.GA9074@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140321222025.GA9074@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 21, 2014 at 03:20:25PM -0700, Darrick J. Wong wrote:
> On Fri, Mar 21, 2014 at 11:23:32AM -0700, Zach Brown wrote:
> > On Thu, Mar 20, 2014 at 09:30:41PM -0700, Darrick J. Wong wrote:
> > > This RFC provides a rough implementation of a mechanism to allow
> > > userspace to attach protection information (e.g. T10 DIF) data to a
> > > disk write and to receive the information alongside a disk read.  The
> > > interface is an extension to the AIO interface: two new commands
> > > (IOCB_CMD_P{READ,WRITE}VM) are provided.  The last struct iovec in the
> > > arg list is interpreted to point to a buffer containing a header,
> > > followed by the the PI data.
> > 
> > Instead of adding commands that indicate that the final element is a
> > magical pi buffer, why not expand the iocb?
> > 
> > In the user iocb, a bit in aio_flags could indicate that aio_reserved2
> > is a pointer to an extension of the iocb.  In that extension could be a
> > full iov *, nr_segs for PI data.
> > 
> > You'd then translate that into a bigger kernel kiocb with a specific
> > pointer to PI data rather than having to bubble the tests for this magic
> > final iovec down through the kernel.
> > 
> > +       if (iocb->ki_flags & KIOCB_USE_PI) {
> > +               nr_segs--;
> > +               pi_iov = (struct iovec *)(iov + nr_segs);
> > +       }
> > 
> > I suggest this because there's already pressure to extend the iocb.
> > Folks want io priority inputs, completion time outputs, etc.
> 
> I'm curious about the reqprio field -- it seems like it was put there to
> request some kind of IO priority change, but the kernel doesn't use it.

The user-facing iocbs were derived from the posix aio interface which
has a reqprio field (aio(7), aio_reqprio).  I don't think anything's
ever been done with it.

I don't know more about what current io prio stuff people might want to
specify..  ioprio_set(2) args instead of having to bounce through
syscalls and current-> for each op?  cgroup bits?  No idea.

> If aio_reserved2 becomes a (flag-guarded) pointer to an array of aio
> extensions, I'd be tempted to reuse the reqprio to signal the length of the
> extension array, and if anyone wants to start using reqprio, they could add it
> as an extension.

I'll admit, I'm hesitant to cannibalize reqprio for this.  It's a lame
s16.  But maybe it'll be the least awful alternative.

> (More about this in my response to Ben LaHaise.)

(I'll go reply over there too.)

> > And heck, on the sync rw syscall side, add variant that have a pointer
> > to this same extension struct.  There's nothing inherently aio specific
> > about having lots more per-io inputs and outputs.
> 
> I'm curious -- what kinds of extensions do you envision for sync()?

Sorry, that was poorly worded.  By 'sync' I meant the synchronous
classic sys_*write* syscalls.  Maybe we should add another variant with
a "struct io_goo *" pointer, or whatever.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

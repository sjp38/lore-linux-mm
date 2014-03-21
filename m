Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id AE15A6B0283
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 18:20:33 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so2877863pdi.7
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 15:20:33 -0700 (PDT)
Date: Fri, 21 Mar 2014 15:20:25 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140321222025.GA9074@birch.djwong.org>
References: <20140321043041.8428.79003.stgit@birch.djwong.org>
 <20140321182332.GP10561@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140321182332.GP10561@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 21, 2014 at 11:23:32AM -0700, Zach Brown wrote:
> On Thu, Mar 20, 2014 at 09:30:41PM -0700, Darrick J. Wong wrote:
> > This RFC provides a rough implementation of a mechanism to allow
> > userspace to attach protection information (e.g. T10 DIF) data to a
> > disk write and to receive the information alongside a disk read.  The
> > interface is an extension to the AIO interface: two new commands
> > (IOCB_CMD_P{READ,WRITE}VM) are provided.  The last struct iovec in the
> > arg list is interpreted to point to a buffer containing a header,
> > followed by the the PI data.
> 
> Instead of adding commands that indicate that the final element is a
> magical pi buffer, why not expand the iocb?
> 
> In the user iocb, a bit in aio_flags could indicate that aio_reserved2
> is a pointer to an extension of the iocb.  In that extension could be a
> full iov *, nr_segs for PI data.
> 
> You'd then translate that into a bigger kernel kiocb with a specific
> pointer to PI data rather than having to bubble the tests for this magic
> final iovec down through the kernel.
> 
> +       if (iocb->ki_flags & KIOCB_USE_PI) {
> +               nr_segs--;
> +               pi_iov = (struct iovec *)(iov + nr_segs);
> +       }
> 
> I suggest this because there's already pressure to extend the iocb.
> Folks want io priority inputs, completion time outputs, etc.

I'm curious about the reqprio field -- it seems like it was put there to
request some kind of IO priority change, but the kernel doesn't use it.

If aio_reserved2 becomes a (flag-guarded) pointer to an array of aio
extensions, I'd be tempted to reuse the reqprio to signal the length of the
extension array, and if anyone wants to start using reqprio, they could add it
as an extension.

(More about this in my response to Ben LaHaise.)

> It's a much cleaner way to extend the interface without an explosion of
> command enums that are really combinations of per-io arguments that are
> present or not.

Agreed.

> And heck, on the sync rw syscall side, add variant that have a pointer
> to this same extension struct.  There's nothing inherently aio specific
> about having lots more per-io inputs and outputs.

I'm curious -- what kinds of extensions do you envision for sync()?

--D
> 
> - z
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

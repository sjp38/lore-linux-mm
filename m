Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 358216B0287
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 18:54:44 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so3005253pbb.29
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 15:54:43 -0700 (PDT)
Date: Fri, 21 Mar 2014 15:54:37 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140321225437.GB9074@birch.djwong.org>
References: <20140321043041.8428.79003.stgit@birch.djwong.org>
 <20140321182332.GP10561@lenny.home.zabbo.net>
 <20140321214410.GE23173@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140321214410.GE23173@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Zach Brown <zab@redhat.com>, axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 21, 2014 at 05:44:10PM -0400, Benjamin LaHaise wrote:
> Hi folks,
> 
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
> 
> I'm inclined to agree with Zach on this item.  Ultimately, we need an 
> extensible data structure that can be grown without completely revising 
> the ABI as new parameters are added.  We need something that is either 
> TLV based, or an extensible array.

Ok.  Let's define IOCB_FLAG_EXTENSIONS as an iocb.aio_flags flag to indicate
that this struct iocb has extensions attached to it.  Then, iocb.aio_reserved2
becomes a pointer to an array of extension descriptors, and iocb.aio_reqprio
becomes a u16 that tells us the array length.  The libaio.h equivalents are
iocb.u.c.flags, iocb.u.c.__pad3, and iocb.aio_reqprio, respectively.

Next, let's define a conceptual structure for aio extensions:

struct iocb_extension {
	void *ie_buf;
	unsigned int ie_buflen;
	unsigned int ie_type;
	unsigned int ie_flags;
};

The actual definitions can be defined in a similar fashion to the other aio
structures so that the structures are padded to the same layout regardless of
bitness.  As mentioned above, iocb.aio_reserved2 points to an array of these.

Question: Do we want to allow ie_buf to be struct iovec[]?  Can we leave that
to the extension designer to decide if they want to support either a S-G list,
one big (vaddr) buffer, or toggle flags?

For the PI passthrough, I'll define IOCB_EXT_PI as the first ie_type, and move
the flags argument out of the PI buffer and into ie_flags.

I could also make an IOCB_EXT_REQPRIO where ie_flags = reqprio, but since the
kernel ignores it right now, I don't see much point.

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
> There are already folks at other companies looking at similar extensions.  
> I think there are folks at Google who have similar requirements.

To everyone else interested in AIO extensions: I'd love to hear your ideas.

> Do you have time to put in some effort into defining these extensions?

I think so.  Let's see how much we can get done.

--D
> 
> 		-ben
> 
> > It's a much cleaner way to extend the interface without an explosion of
> > command enums that are really combinations of per-io arguments that are
> > present or not.
> > 
> > And heck, on the sync rw syscall side, add variant that have a pointer
> > to this same extension struct.  There's nothing inherently aio specific
> > about having lots more per-io inputs and outputs.
> > 
> > - z
> 
> -- 
> "Thought is the essence of where you are now."
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

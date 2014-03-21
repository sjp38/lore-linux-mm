Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 21 Mar 2014 17:44:10 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [RFC PATCH 0/5] userspace PI passthrough via AIO/DIO
Message-ID: <20140321214410.GE23173@kvack.org>
References: <20140321043041.8428.79003.stgit@birch.djwong.org> <20140321182332.GP10561@lenny.home.zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140321182332.GP10561@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

Hi folks,

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

I'm inclined to agree with Zach on this item.  Ultimately, we need an 
extensible data structure that can be grown without completely revising 
the ABI as new parameters are added.  We need something that is either 
TLV based, or an extensible array.

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

There are already folks at other companies looking at similar extensions.  
I think there are folks at Google who have similar requirements.

Do you have time to put in some effort into defining these extensions?

		-ben

> It's a much cleaner way to extend the interface without an explosion of
> command enums that are really combinations of per-io arguments that are
> present or not.
> 
> And heck, on the sync rw syscall side, add variant that have a pointer
> to this same extension struct.  There's nothing inherently aio specific
> about having lots more per-io inputs and outputs.
> 
> - z

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

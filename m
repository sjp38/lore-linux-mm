Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2CA556B005A
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 11:27:07 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 19 Aug 2009 17:27:07 +0200
References: <cover.1250187913.git.mst@redhat.com> <200908191546.44193.arnd@arndb.de> <20090819142038.GA3862@redhat.com>
In-Reply-To: <20090819142038.GA3862@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908191727.07681.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> On Wed, Aug 19, 2009 at 03:46:44PM +0200, Arnd Bergmann wrote:
> > On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> >
> > Leaving that aside for now, you could replace VHOST_NET_SET_SOCKET,
> > VHOST_SET_OWNER, VHOST_RESET_OWNER
> 
> SET/RESET OWNER is still needed: otherwise if you share a descriptor
> with another process, it can corrupt your memory.

How? The point of using user threads is that you only ever access the
address space of the thread that called the ioctl.

> > and your kernel thread with a new
> > VHOST_NET_SPLICE blocking ioctl that does all the transfers in the
> > context of the calling thread.
> 
> For one, you'd want a thread per virtqueue.

Don't understand why. The thread can be blocked on all four ends
of the device and wake up whenever there is some work do to in
any direction. If we have data to be transferred in both ways,
we save one thread switch. It probably won't hurt much to have one
thread per direction, but I don't see the point.

> Second, an incoming traffic might arrive on another CPU, we want
> to keep it local.  I guess you would also want ioctls to wake up
> the threads spuriously ...

Outbound traffic should just stay on whatever CPU was sending it
from the guest. For inbound traffic, we should only wake up
the thread on the CPU that got the data to start with.

Why would I wake up the threads spuriously? Do you mean for
stopping the transmission or something else? I guess a pthread_kill
would be enough for shutting it down.

> > This would improve the driver on various fronts:
> > 
> > - no need for playing tricks with use_mm/unuse_mm
> > - possibly fewer global TLB flushes from switch_mm, which
> >   may improve performance.
> 
> Why would there be less flushes?

I just read up on task->active_mm handling. There probably wouldn't
be any. I got that wrong.

> > - based on that, the ability to use any kind of file
> >   descriptor that can do writev/readv or sendmsg/recvmsg
> >   without the nastiness you mentioned.
> 
> Yes, it's an interesting approach. As I said, need to tread very
> carefully though, I don't think all issues are figured out. For example:
> what happens if we pass our own fd here? Will refcount on file ever get
> to 0 on exit?  There may be others ...

right.

> > The disadvantage of course is that you need to add a user
> > thread for each guest device to make up for the workqueue
> > that you save.
> 
> More importantly, you lose control of CPU locality.  Simply put, a
> natural threading model in virtualization is one thread per guest vcpu.
> Asking applications to add multiple helper threads just so they can
> block forever is wrong, IMO, as userspace has no idea which CPU
> they should be on, what priority to use, etc.

But the kernel also doesn't know this, you get the same problem in
another way. If you have multiple guests running at different priorities,
the kernel will use those priorities to do the more important transfers
first, while with a global workqueue every guest gets the same priority.

You say that the natural model is to have one thread per guest
CPU, but you have a thread per host CPU instead. If the numbers
are different, you probably lose either way. It gets worse if you
try to apply NUMA policies.
 
> > > > to
> > > > avoid some of the implications of kernel threads like the missing
> > > > ability to handle transfer errors in user space.
> > > 
> > > Are you talking about TCP here?
> > > Transfer errors are typically asynchronous - possibly eventfd
> > > as I expose for vhost net is sufficient there.
> > 
> > I mean errors in general if we allow random file descriptors to be used.
> > E.g. tun_chr_aio_read could return EBADFD, EINVAL, EFAULT, ERESTARTSYS,
> > EIO, EAGAIN and possibly others. We can handle some in kernel, others
> > should never happen with vhost_net, but if something unexpected happens
> > it would be nice to just bail out to user space.
> 
> And note that there might be more than one error.  I guess, that's
> another problem with trying to layer on top of vfs.

Why is that different from any other system call? We just return when
we hit the first error condition.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

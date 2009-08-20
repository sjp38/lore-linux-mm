Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B98B36B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 04:33:47 -0400 (EDT)
Date: Thu, 20 Aug 2009 11:31:55 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090820083155.GB5448@redhat.com>
References: <cover.1250187913.git.mst@redhat.com> <200908191546.44193.arnd@arndb.de> <20090819142038.GA3862@redhat.com> <200908191727.07681.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908191727.07681.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 05:27:07PM +0200, Arnd Bergmann wrote:
> On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > On Wed, Aug 19, 2009 at 03:46:44PM +0200, Arnd Bergmann wrote:
> > > On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > >
> > > Leaving that aside for now, you could replace VHOST_NET_SET_SOCKET,
> > > VHOST_SET_OWNER, VHOST_RESET_OWNER
> > 
> > SET/RESET OWNER is still needed: otherwise if you share a descriptor
> > with another process, it can corrupt your memory.
> 
> How? The point of using user threads is that you only ever access the
> address space of the thread that called the ioctl.

Think about this example with processes A and B sharing an fd:
A does SET_USED_ADDRESS
B does SET_USED_ADDRESS
A does VHOST_NET_SPLICE
See how stuff gets written into a random place in memory of A?

> > > and your kernel thread with a new
> > > VHOST_NET_SPLICE blocking ioctl that does all the transfers in the
> > > context of the calling thread.
> > 
> > For one, you'd want a thread per virtqueue.
> 
> Don't understand why. The thread can be blocked on all four ends
> of the device and wake up whenever there is some work do to in
> any direction. If we have data to be transferred in both ways,
> we save one thread switch. It probably won't hurt much to have one
> thread per direction, but I don't see the point.
> > Second, an incoming traffic might arrive on another CPU, we want
> > to keep it local.  I guess you would also want ioctls to wake up
> > the threads spuriously ...
> 
> Outbound traffic should just stay on whatever CPU was sending it
> from the guest. For inbound traffic, we should only wake up
> the thread on the CPU that got the data to start with.

Exactly. Since we have RX and TX virtqueues, this would mean thread per
direction or virtqueue, same thing. OTOH if RX and TX happen to run on the
same CPU, thread switch would be just a waste of time: but userspace
does not know it, only guest and kernel know.

> Why would I wake up the threads spuriously? Do you mean for
> stopping the transmission or something else? I guess a pthread_kill
> would be enough for shutting it down.

If you kill and restart them you lost priority etc parameters, but maybe.

> > > This would improve the driver on various fronts:
> > > 
> > > - no need for playing tricks with use_mm/unuse_mm
> > > - possibly fewer global TLB flushes from switch_mm, which
> > >   may improve performance.
> > 
> > Why would there be less flushes?
> 
> I just read up on task->active_mm handling. There probably wouldn't
> be any. I got that wrong.
> 
> > > - based on that, the ability to use any kind of file
> > >   descriptor that can do writev/readv or sendmsg/recvmsg
> > >   without the nastiness you mentioned.
> > 
> > Yes, it's an interesting approach. As I said, need to tread very
> > carefully though, I don't think all issues are figured out. For example:
> > what happens if we pass our own fd here? Will refcount on file ever get
> > to 0 on exit?  There may be others ...
> 
> right.
> 
> > > The disadvantage of course is that you need to add a user
> > > thread for each guest device to make up for the workqueue
> > > that you save.
> > 
> > More importantly, you lose control of CPU locality.  Simply put, a
> > natural threading model in virtualization is one thread per guest vcpu.
> > Asking applications to add multiple helper threads just so they can
> > block forever is wrong, IMO, as userspace has no idea which CPU
> > they should be on, what priority to use, etc.
> 
> But the kernel also doesn't know this, you get the same problem in
> another way. If you have multiple guests running at different priorities,
> the kernel will use those priorities to do the more important transfers
> first, while with a global workqueue every guest gets the same priority.

We could create more threads if this becomes a problem. I just think it
should be transparent to userspace. Possibly it's useful to look at the
packet header as well to decide on priority: this is something userspace
can't do.

> You say that the natural model is to have one thread per guest
> CPU,

Sorry I was not clear. I think userspace should create thread per guest.
We can create as many as we need for networking but I think this should
be behind the scenes, so userspace shouldn't bother with host CPUs, it
will just get it wrong. Think of CPU hotplug, interrupts migrating
between CPUs, etc ...

> but you have a thread per host CPU instead. If the numbers
> are different, you probably lose either way.

The trick I used is to keep as much as possible local
TX done on the CPU that runs the guest,
RX done on the CPU that runs the NIC interrupt.
a smart SMP guest sees which cpu gets interrupts
from NIC and schedules RX there, and it shouldn't matter
if the numbers of CPUs are different.

> It gets worse if you try to apply NUMA policies.

I believe the best we could do is avoid switching CPUs
until we know the actual destination.

> > > > > to
> > > > > avoid some of the implications of kernel threads like the missing
> > > > > ability to handle transfer errors in user space.
> > > > 
> > > > Are you talking about TCP here?
> > > > Transfer errors are typically asynchronous - possibly eventfd
> > > > as I expose for vhost net is sufficient there.
> > > 
> > > I mean errors in general if we allow random file descriptors to be used.
> > > E.g. tun_chr_aio_read could return EBADFD, EINVAL, EFAULT, ERESTARTSYS,
> > > EIO, EAGAIN and possibly others. We can handle some in kernel, others
> > > should never happen with vhost_net, but if something unexpected happens
> > > it would be nice to just bail out to user space.
> > 
> > And note that there might be more than one error.  I guess, that's
> > another problem with trying to layer on top of vfs.
> 
> Why is that different from any other system call?

With other system calls nothing happens while you process the error.
Here, the guest (other queues) and the network keep running (unless
there is a thread per queue, maybe we can block a queue, but we both
agreed above we don't want that).

> We just return when
> we hit the first error condition.
> 
> 	Arnd <><

If you assume losing the code for the second error condition is OK, why
is the first one so important?  That's why I used a counter (eventfd)
per virtqueue, on error userspace can scan the ring and poll the socket
and discover what's wrong, and counter ensures we can detect that error
happened while we were not looking.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

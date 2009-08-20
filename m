Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 146536B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 09:13:30 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 20 Aug 2009 15:10:54 +0200
References: <cover.1250187913.git.mst@redhat.com> <200908191727.07681.arnd@arndb.de> <20090820083155.GB5448@redhat.com>
In-Reply-To: <20090820083155.GB5448@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908201510.54482.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Thursday 20 August 2009, Michael S. Tsirkin wrote:
> On Wed, Aug 19, 2009 at 05:27:07PM +0200, Arnd Bergmann wrote:
> > On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > > On Wed, Aug 19, 2009 at 03:46:44PM +0200, Arnd Bergmann wrote:
> > > > On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > > >
> > > > Leaving that aside for now, you could replace VHOST_NET_SET_SOCKET,
> > > > VHOST_SET_OWNER, VHOST_RESET_OWNER
> > > 
> > > SET/RESET OWNER is still needed: otherwise if you share a descriptor
> > > with another process, it can corrupt your memory.
> > 
> > How? The point of using user threads is that you only ever access the
> > address space of the thread that called the ioctl.
> 
> Think about this example with processes A and B sharing an fd:
> A does SET_USED_ADDRESS
> B does SET_USED_ADDRESS
> A does VHOST_NET_SPLICE
> See how stuff gets written into a random place in memory of A?

Yes, I didn't think of that. It doesn't seem like a big problem
though, because it's a clear misuse of the API (I guess your
current code returns an error for one of the SET_USED_ADDRESS
ioctls), so I would see it as a classic garbage-in garbage-out
case.

It may even work in the case that the sharing of the fd resulted
from a fork, where the address contains the same buffer in both
processes. I can't think of a reason why you would want to use
it like that though.

> > Why would I wake up the threads spuriously? Do you mean for
> > stopping the transmission or something else? I guess a pthread_kill
> > would be enough for shutting it down.
> 
> If you kill and restart them you lost priority etc parameters, but maybe.

If you want to restart it, just send a nonfatal signal (SIGUSR1,
SIGRTMIN, ...) instead of a SIGKILL.

> > > More importantly, you lose control of CPU locality.  Simply put, a
> > > natural threading model in virtualization is one thread per guest vcpu.
> > > Asking applications to add multiple helper threads just so they can
> > > block forever is wrong, IMO, as userspace has no idea which CPU
> > > they should be on, what priority to use, etc.
> > 
> > But the kernel also doesn't know this, you get the same problem in
> > another way. If you have multiple guests running at different priorities,
> > the kernel will use those priorities to do the more important transfers
> > first, while with a global workqueue every guest gets the same priority.
> 
> We could create more threads if this becomes a problem. I just think it
> should be transparent to userspace. Possibly it's useful to look at the
> packet header as well to decide on priority: this is something userspace
> can't do.

Being transparent to user space would be nice, I agree. Letting user space
choose would also be nice, e.g. if you want to distribute eight available
hardware queue pairs to three guests in a non-obvious way. The
implementation depends to some degree on how we want to do multiqueue
RX/TX in virtio-net in the long run. For best cache locality and NUMA
behaviour, we might want to have one virtqueue per guest CPU and control
them independently from the host.

Priorities of the packets are dealt with in the packet scheduler for
external interfaces, I guess that is sufficient. I'm not sure if we
need to honor the same priorities for guest-to-guest communication,
my feeling is that we don't need to.

> > You say that the natural model is to have one thread per guest
> > CPU,
> 
> Sorry I was not clear. I think userspace should create thread per guest.
> We can create as many as we need for networking but I think this should
> be behind the scenes, so userspace shouldn't bother with host CPUs, it
> will just get it wrong. Think of CPU hotplug, interrupts migrating
> between CPUs, etc ...

Yes, I hope we can avoid letting qemu know about host CPUs.
I'm not sure we can avoid it completely, because something needs
to set physical IRQ affinity and such for the virtual devices
if you want to get the best locality.

> > but you have a thread per host CPU instead. If the numbers
> > are different, you probably lose either way.
> 
> The trick I used is to keep as much as possible local
> TX done on the CPU that runs the guest,
> RX done on the CPU that runs the NIC interrupt.
> a smart SMP guest sees which cpu gets interrupts
> from NIC and schedules RX there, and it shouldn't matter
> if the numbers of CPUs are different.

yes, that sounds good.

> > It gets worse if you try to apply NUMA policies.
> 
> I believe the best we could do is avoid switching CPUs
> until we know the actual destination.

My point is that the RX data in the guest address space
should be on the same NUMA node that gets the interrupt.

> > > And note that there might be more than one error.  I guess, that's
> > > another problem with trying to layer on top of vfs.
> > 
> > Why is that different from any other system call?
> 
> With other system calls nothing happens while you process the error.
> Here, the guest (other queues) and the network keep running (unless
> there is a thread per queue, maybe we can block a queue, but we both
> agreed above we don't want that).

Well, I would expect error conditions to be fatal for the connections
normally, so blocking the queue is totally fine here IMHO. The ioctl
would never return while a guest is running and connected to a
working NIC.

> > We just return when
> > we hit the first error condition.
> 
> If you assume losing the code for the second error condition is OK, why
> is the first one so important?  That's why I used a counter (eventfd)
> per virtqueue, on error userspace can scan the ring and poll the socket
> and discover what's wrong, and counter ensures we can detect that error
> happened while we were not looking.

I guess we were talking about different kinds of errors here, and I'm
still not sure which one you are talking about.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

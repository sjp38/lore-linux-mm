Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 78DD46B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 10:22:07 -0400 (EDT)
Date: Wed, 19 Aug 2009 17:20:38 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090819142038.GA3862@redhat.com>
References: <cover.1250187913.git.mst@redhat.com> <200908191104.50672.arnd@arndb.de> <20090819130417.GB3080@redhat.com> <200908191546.44193.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908191546.44193.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 03:46:44PM +0200, Arnd Bergmann wrote:
> On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > > Maybe we could instead extend the 'splice' system call to work on a
> > > vhost_net file descriptor.  If we do that, we can put the access back
> > > into a user thread (or two) that stays in splice indefinetely
> > 
> > An issue with exposing internal threading model to userspace
> > in this way is that we lose control of e.g. CPU locality -
> > and it is very hard for userspace to get it right.
> 
> Good point, I hadn't thought about that in this context.
> 
> For macvtap, my idea was to open the same tap char device multiple
> times and use each fd exclusively on one *guest* CPU. I'm not sure
> if virtio-net can already handle SMP guests efficiently. We might
> actually need to extend it to have more pairs of virtqueues, one
> for each guest CPU, which can then be bound to a host queue (or queue
> pair) in the physical nic.
> 
> Leaving that aside for now, you could replace VHOST_NET_SET_SOCKET,
> VHOST_SET_OWNER, VHOST_RESET_OWNER

SET/RESET OWNER is still needed: otherwise if you share a descriptor
with another process, it can corrupt your memory.

> and your kernel thread with a new
> VHOST_NET_SPLICE blocking ioctl that does all the transfers in the
> context of the calling thread.

For one, you'd want a thread per virtqueue.  Second, an incoming traffic
might arrive on another CPU, we want to keep it local.  I guess you
would also want ioctls to wake up the threads spuriously ...

> This would improve the driver on various fronts:
> 
> - no need for playing tricks with use_mm/unuse_mm
> - possibly fewer global TLB flushes from switch_mm, which
>   may improve performance.

Why would there be less flushes?

> - ability to pass down error codes from socket or guest to
>   user space by returning from ioctl

virtio can not pass error codes. translation errors are
simple enough to just have a counter.

> - based on that, the ability to use any kind of file
>   descriptor that can do writev/readv or sendmsg/recvmsg
>   without the nastiness you mentioned.

Yes, it's an interesting approach. As I said, need to tread very
carefully though, I don't think all issues are figured out. For example:
what happens if we pass our own fd here? Will refcount on file ever get
to 0 on exit?  There may be others ...

> The disadvantage of course is that you need to add a user
> thread for each guest device to make up for the workqueue
> that you save.

More importantly, you lose control of CPU locality.  Simply put, a
natural threading model in virtualization is one thread per guest vcpu.
Asking applications to add multiple helper threads just so they can
block forever is wrong, IMO, as userspace has no idea which CPU
they should be on, what priority to use, etc.


> > > to
> > > avoid some of the implications of kernel threads like the missing
> > > ability to handle transfer errors in user space.
> > 
> > Are you talking about TCP here?
> > Transfer errors are typically asynchronous - possibly eventfd
> > as I expose for vhost net is sufficient there.
> 
> I mean errors in general if we allow random file descriptors to be used.
> E.g. tun_chr_aio_read could return EBADFD, EINVAL, EFAULT, ERESTARTSYS,
> EIO, EAGAIN and possibly others. We can handle some in kernel, others
> should never happen with vhost_net, but if something unexpected happens
> it would be nice to just bail out to user space.

And note that there might be more than one error.  I guess, that's
another problem with trying to layer on top of vfs.

> > > > I wonder - can we expose the underlying socket used by tap, or will that
> > > > create complex lifetime issues?
> > > 
> > > I think this could get more messy in the long run than calling vfs_readv
> > > on a random fd. It would mean deep internal knowledge of the tap driver
> > > in vhost_net, which I really would prefer to avoid.
> > 
> > No, what I had in mind is adding a GET_SOCKET ioctl to tap.
> > vhost would then just use the socket.
> 
> Right, that would work with tun/tap at least. It sounds a bit fishy
> but I can't see a reason why it would be hard to do.
> I'd have to think about how to get it working with macvtap, or if
> there is much value left in macvtap after that anyway.
> 
> > > So how about making the qemu command line interface an extension to
> > > what Or Gerlitz has done for the raw packet sockets?
> >
> > Not sure I see the connection, but I have not thought about qemu
> > side of things too much yet - trying to get kernel bits in place
> > first so that there's a stable ABI to work with.
> 
> Ok, fair enough. The kernel bits are obviously more time critical
> right now, since they should get into 2.6.32.
> 
> 	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

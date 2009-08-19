Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 503096B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 09:50:08 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 19 Aug 2009 15:46:44 +0200
References: <cover.1250187913.git.mst@redhat.com> <200908191104.50672.arnd@arndb.de> <20090819130417.GB3080@redhat.com>
In-Reply-To: <20090819130417.GB3080@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908191546.44193.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 19 August 2009, Michael S. Tsirkin wrote:
> > Maybe we could instead extend the 'splice' system call to work on a
> > vhost_net file descriptor.  If we do that, we can put the access back
> > into a user thread (or two) that stays in splice indefinetely
> 
> An issue with exposing internal threading model to userspace
> in this way is that we lose control of e.g. CPU locality -
> and it is very hard for userspace to get it right.

Good point, I hadn't thought about that in this context.

For macvtap, my idea was to open the same tap char device multiple
times and use each fd exclusively on one *guest* CPU. I'm not sure
if virtio-net can already handle SMP guests efficiently. We might
actually need to extend it to have more pairs of virtqueues, one
for each guest CPU, which can then be bound to a host queue (or queue
pair) in the physical nic.

Leaving that aside for now, you could replace VHOST_NET_SET_SOCKET,
VHOST_SET_OWNER, VHOST_RESET_OWNER and your kernel thread with a new
VHOST_NET_SPLICE blocking ioctl that does all the transfers in the
context of the calling thread.

This would improve the driver on various fronts:

- no need for playing tricks with use_mm/unuse_mm
- possibly fewer global TLB flushes from switch_mm, which
  may improve performance.
- ability to pass down error codes from socket or guest to
  user space by returning from ioctl
- based on that, the ability to use any kind of file
  descriptor that can do writev/readv or sendmsg/recvmsg
  without the nastiness you mentioned.

The disadvantage of course is that you need to add a user
thread for each guest device to make up for the workqueue
that you save.

> > to
> > avoid some of the implications of kernel threads like the missing
> > ability to handle transfer errors in user space.
> 
> Are you talking about TCP here?
> Transfer errors are typically asynchronous - possibly eventfd
> as I expose for vhost net is sufficient there.

I mean errors in general if we allow random file descriptors to be used.
E.g. tun_chr_aio_read could return EBADFD, EINVAL, EFAULT, ERESTARTSYS,
EIO, EAGAIN and possibly others. We can handle some in kernel, others
should never happen with vhost_net, but if something unexpected happens
it would be nice to just bail out to user space.

> > > I wonder - can we expose the underlying socket used by tap, or will that
> > > create complex lifetime issues?
> > 
> > I think this could get more messy in the long run than calling vfs_readv
> > on a random fd. It would mean deep internal knowledge of the tap driver
> > in vhost_net, which I really would prefer to avoid.
> 
> No, what I had in mind is adding a GET_SOCKET ioctl to tap.
> vhost would then just use the socket.

Right, that would work with tun/tap at least. It sounds a bit fishy
but I can't see a reason why it would be hard to do.
I'd have to think about how to get it working with macvtap, or if
there is much value left in macvtap after that anyway.

> > So how about making the qemu command line interface an extension to
> > what Or Gerlitz has done for the raw packet sockets?
>
> Not sure I see the connection, but I have not thought about qemu
> side of things too much yet - trying to get kernel bits in place
> first so that there's a stable ABI to work with.

Ok, fair enough. The kernel bits are obviously more time critical
right now, since they should get into 2.6.32.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

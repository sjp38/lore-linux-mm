Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CD5F46B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 09:06:52 -0400 (EDT)
Date: Wed, 19 Aug 2009 16:04:17 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090819130417.GB3080@redhat.com>
References: <cover.1250187913.git.mst@redhat.com> <200908141340.36176.arnd@arndb.de> <20090816065110.GA3008@redhat.com> <200908191104.50672.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908191104.50672.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 11:04:50AM +0200, Arnd Bergmann wrote:
> On Sunday 16 August 2009, Michael S. Tsirkin wrote:
> > On Fri, Aug 14, 2009 at 01:40:36PM +0200, Arnd Bergmann wrote:
> > > 
> > > * most of the transports are sockets, tap uses a character device.
> > >   This could be dealt with by having both a struct socket * in
> > >   struct vhost_net *and* a struct file *, or by always keeping the
> > >   struct file and calling vfs_readv/vfs_writev for the data transport
> > >   in both cases.
> > 
> > I am concerned that character devices might have weird side effects with
> > read/write operations and that calling them from kernel thread the way I
> > do might have security implications. Can't point at anything specific
> > though at the moment.
> 
> I understand your feelings about passing a chardev fd into your driver
> and I agree that we need to be very careful if we want to allow it.
> 
> Maybe we could instead extend the 'splice' system call to work on a
> vhost_net file descriptor.  If we do that, we can put the access back
> into a user thread (or two) that stays in splice indefinetely

An issue with exposing internal threading model to userspace
in this way is that we lose control of e.g. CPU locality -
and it is very hard for userspace to get it right.

> to
> avoid some of the implications of kernel threads like the missing
> ability to handle transfer errors in user space.

Are you talking about TCP here?
Transfer errors are typically asynchronous - possibly eventfd
as I expose for vhost net is sufficient there.

> > I wonder - can we expose the underlying socket used by tap, or will that
> > create complex lifetime issues?
> 
> I think this could get more messy in the long run than calling vfs_readv
> on a random fd. It would mean deep internal knowledge of the tap driver
> in vhost_net, which I really would prefer to avoid.

No, what I had in mind is adding a GET_SOCKET ioctl to tap.
vhost would then just use the socket.

> > > * Each transport has a slightly different header, we have
> > >   - raw ethernet frames (raw, udp multicast, tap)
> > >   - 32-bit length + raw frames, possibly fragmented (tcp)
> > >   - 80-bit header + raw frames, possibly fragmented (tap with vnet_hdr)
> > >   To handle these three cases, we need either different ioctl numbers
> > >   so that vhost_net can choose the right one, or a flags field in
> > >   VHOST_NET_SET_SOCKET, like
> > > 
> > >   #define VHOST_NET_RAW		1
> > >   #define VHOST_NET_LEN_HDR	2
> > >   #define VHOST_NET_VNET_HDR	4
> > > 
> > >   struct vhost_net_socket {
> > > 	unsigned int flags;
> > > 	int fd;
> > >   };
> > >   #define VHOST_NET_SET_SOCKET _IOW(VHOST_VIRTIO, 0x30, struct vhost_net_socket)
> > 
> > It seems we can query the socket to find out the type, 
> 
> yes, I understand that you can do that, but I still think that decision
> should be left to user space. Adding a length header for TCP streams but
> not for UDP is something that we would normally want to do, but IMHO
> vhost_net should not need to know about this.
> 
> > or use the features ioctl.
> 
> Right, I had forgotten about that one. It's probably equivalent
> to the flags I suggested, except that one allows you to set features
> after starting the communication, while the other one prevents
> you from doing that.
> 
> > > Qemu could then automatically try to use vhost_net, if it's available
> > > in the kernel, or just fall back on software vlan otherwise.
> > > Does that make sense?
> > 
> > I agree, long term it should be enabled automatically when possible.
> 
> So how about making the qemu command line interface an extension to
> what Or Gerlitz has done for the raw packet sockets?
> 
> 	Arnd <><

Not sure I see the connection, but I have not thought about qemu
side of things too much yet - trying to get kernel bits in place
first so that there's a stable ABI to work with.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

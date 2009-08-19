Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B71666B0055
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 05:06:06 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 19 Aug 2009 11:04:50 +0200
References: <cover.1250187913.git.mst@redhat.com> <200908141340.36176.arnd@arndb.de> <20090816065110.GA3008@redhat.com>
In-Reply-To: <20090816065110.GA3008@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908191104.50672.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Or Gerlitz <ogerlitz@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Sunday 16 August 2009, Michael S. Tsirkin wrote:
> On Fri, Aug 14, 2009 at 01:40:36PM +0200, Arnd Bergmann wrote:
> > 
> > * most of the transports are sockets, tap uses a character device.
> >   This could be dealt with by having both a struct socket * in
> >   struct vhost_net *and* a struct file *, or by always keeping the
> >   struct file and calling vfs_readv/vfs_writev for the data transport
> >   in both cases.
> 
> I am concerned that character devices might have weird side effects with
> read/write operations and that calling them from kernel thread the way I
> do might have security implications. Can't point at anything specific
> though at the moment.

I understand your feelings about passing a chardev fd into your driver
and I agree that we need to be very careful if we want to allow it.

Maybe we could instead extend the 'splice' system call to work on a
vhost_net file descriptor. If we do that, we can put the access back
into a user thread (or two) that stays in splice indefinetely to
avoid some of the implications of kernel threads like the missing
ability to handle transfer errors in user space.

> I wonder - can we expose the underlying socket used by tap, or will that
> create complex lifetime issues?

I think this could get more messy in the long run than calling vfs_readv
on a random fd. It would mean deep internal knowledge of the tap driver
in vhost_net, which I really would prefer to avoid.

> > * Each transport has a slightly different header, we have
> >   - raw ethernet frames (raw, udp multicast, tap)
> >   - 32-bit length + raw frames, possibly fragmented (tcp)
> >   - 80-bit header + raw frames, possibly fragmented (tap with vnet_hdr)
> >   To handle these three cases, we need either different ioctl numbers
> >   so that vhost_net can choose the right one, or a flags field in
> >   VHOST_NET_SET_SOCKET, like
> > 
> >   #define VHOST_NET_RAW		1
> >   #define VHOST_NET_LEN_HDR	2
> >   #define VHOST_NET_VNET_HDR	4
> > 
> >   struct vhost_net_socket {
> > 	unsigned int flags;
> > 	int fd;
> >   };
> >   #define VHOST_NET_SET_SOCKET _IOW(VHOST_VIRTIO, 0x30, struct vhost_net_socket)
> 
> It seems we can query the socket to find out the type, 

yes, I understand that you can do that, but I still think that decision
should be left to user space. Adding a length header for TCP streams but
not for UDP is something that we would normally want to do, but IMHO
vhost_net should not need to know about this.

> or use the features ioctl.

Right, I had forgotten about that one. It's probably equivalent
to the flags I suggested, except that one allows you to set features
after starting the communication, while the other one prevents
you from doing that.

> > Qemu could then automatically try to use vhost_net, if it's available
> > in the kernel, or just fall back on software vlan otherwise.
> > Does that make sense?
> 
> I agree, long term it should be enabled automatically when possible.

So how about making the qemu command line interface an extension to
what Or Gerlitz has done for the raw packet sockets?

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

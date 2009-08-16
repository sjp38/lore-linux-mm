Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3B05E6B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 02:52:38 -0400 (EDT)
Date: Sun, 16 Aug 2009 09:51:10 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090816065110.GA3008@redhat.com>
References: <cover.1250187913.git.mst@redhat.com> <20090813182931.GC6585@redhat.com> <200908141340.36176.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908141340.36176.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 01:40:36PM +0200, Arnd Bergmann wrote:
> On Thursday 13 August 2009, Michael S. Tsirkin wrote:
> > What it is: vhost net is a character device that can be used to reduce
> > the number of system calls involved in virtio networking.
> > Existing virtio net code is used in the guest without modification.
> 
> AFAICT, you have addressed all my comments, mostly by convincing me
> that you got it right anyway ;-).
> 
> I hope this gets into 2.6.32, good work!
> 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> 
> One idea though:
> 
> > +	/* Parameter checking */
> > +	if (sock->sk->sk_type != SOCK_RAW) {
> > +		r = -ESOCKTNOSUPPORT;
> > +		goto done;
> > +	}
> > +
> > +	r = sock->ops->getname(sock, (struct sockaddr *)&uaddr.sa,
> > +			       &uaddr_len, 0);
> > +	if (r)
> > +		goto done;
> > +
> > +	if (uaddr.sa.sll_family != AF_PACKET) {
> > +		r = -EPFNOSUPPORT;
> > +		goto done;
> > +	}
> 
> You currently limit the scope of the driver by only allowing raw packet
> sockets to be passed into the network driver. In qemu, we currently support
> some very similar transports:
> 
> * raw packet (not in a release yet)
> * tcp connection
> * UDP multicast
> * tap character device
> * VDE with Unix local sockets
> 
> My primary interest right now is the tap support, but I think it would
> be interesting in general to allow different file descriptor types
> in vhost_net_set_socket. AFAICT, there are two major differences
> that we need to handle for this:
> 
> * most of the transports are sockets, tap uses a character device.
>   This could be dealt with by having both a struct socket * in
>   struct vhost_net *and* a struct file *, or by always keeping the
>   struct file and calling vfs_readv/vfs_writev for the data transport
>   in both cases.

I am concerned that character devices might have weird side effects with
read/write operations and that calling them from kernel thread the way I
do might have security implications. Can't point at anything specific
though at the moment.
I wonder - can we expose the underlying socket used by tap, or will that
create complex lifetime issues?

> * Each transport has a slightly different header, we have
>   - raw ethernet frames (raw, udp multicast, tap)
>   - 32-bit length + raw frames, possibly fragmented (tcp)
>   - 80-bit header + raw frames, possibly fragmented (tap with vnet_hdr)
>   To handle these three cases, we need either different ioctl numbers
>   so that vhost_net can choose the right one, or a flags field in
>   VHOST_NET_SET_SOCKET, like
> 
>   #define VHOST_NET_RAW		1
>   #define VHOST_NET_LEN_HDR	2
>   #define VHOST_NET_VNET_HDR	4
> 
>   struct vhost_net_socket {
> 	unsigned int flags;
> 	int fd;
>   };
>   #define VHOST_NET_SET_SOCKET _IOW(VHOST_VIRTIO, 0x30, struct vhost_net_socket)

It seems we can query the socket to find out the type, or use the
features ioctl.

> If both of those are addressed, we can treat vhost_net as a generic
> way to do network handling in the kernel independent of the qemu
> model (raw, tap, ...) for it. 
> 
> Your qemu patch would have to work differently, so instead of 
> 
> qemu -net nic,vhost=eth0
> 
> you would do the same as today with the raw packet socket extension
> 
> qemu -net nic -net raw,ifname=eth0 
> 
> Qemu could then automatically try to use vhost_net, if it's available
> in the kernel, or just fall back on software vlan otherwise.
> Does that make sense?
> 
> 	Arnd <>

I agree, long term it should be enabled automatically when possible.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

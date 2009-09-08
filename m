Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 556756B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 13:20:32 -0400 (EDT)
Date: Tue, 8 Sep 2009 10:20:35 -0700
From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090908172035.GB319@ovro.caltech.edu>
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090907101537.GH3031@redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Mon, Sep 07, 2009 at 01:15:37PM +0300, Michael S. Tsirkin wrote:
> On Thu, Sep 03, 2009 at 11:39:45AM -0700, Ira W. Snyder wrote:
> > On Thu, Aug 27, 2009 at 07:07:50PM +0300, Michael S. Tsirkin wrote:
> > > What it is: vhost net is a character device that can be used to reduce
> > > the number of system calls involved in virtio networking.
> > > Existing virtio net code is used in the guest without modification.
> > > 
> > > There's similarity with vringfd, with some differences and reduced scope
> > > - uses eventfd for signalling
> > > - structures can be moved around in memory at any time (good for migration)
> > > - support memory table and not just an offset (needed for kvm)
> > > 
> > > common virtio related code has been put in a separate file vhost.c and
> > > can be made into a separate module if/when more backends appear.  I used
> > > Rusty's lguest.c as the source for developing this part : this supplied
> > > me with witty comments I wouldn't be able to write myself.
> > > 
> > > What it is not: vhost net is not a bus, and not a generic new system
> > > call. No assumptions are made on how guest performs hypercalls.
> > > Userspace hypervisors are supported as well as kvm.
> > > 
> > > How it works: Basically, we connect virtio frontend (configured by
> > > userspace) to a backend. The backend could be a network device, or a
> > > tun-like device. In this version I only support raw socket as a backend,
> > > which can be bound to e.g. SR IOV, or to macvlan device.  Backend is
> > > also configured by userspace, including vlan/mac etc.
> > > 
> > > Status:
> > > This works for me, and I haven't see any crashes.
> > > I have done some light benchmarking (with v4), compared to userspace, I
> > > see improved latency (as I save up to 4 system calls per packet) but not
> > > bandwidth/CPU (as TSO and interrupt mitigation are not supported).  For
> > > ping benchmark (where there's no TSO) troughput is also improved.
> > > 
> > > Features that I plan to look at in the future:
> > > - tap support
> > > - TSO
> > > - interrupt mitigation
> > > - zero copy
> > > 
> > 
> > Hello Michael,
> > 
> > I've started looking at vhost with the intention of using it over PCI to
> > connect physical machines together.
> > 
> > The part that I am struggling with the most is figuring out which parts
> > of the rings are in the host's memory, and which parts are in the
> > guest's memory.
> 
> All rings are in guest's memory, to match existing virtio code.

Ok, this makes sense.

> vhost
> assumes that the memory space of the hypervisor userspace process covers
> the whole of guest memory.

Is this necessary? Why? The assumption seems very wrong when you're
doing data transport between two physical systems via PCI.

I know vhost has not been designed for this specific situation, but it
is good to be looking toward other possible uses.

> And there's a translation table.
> Ring addresses are userspace addresses, they do not undergo translation.
> 
> > If I understand everything correctly, the rings are all userspace
> > addresses, which means that they can be moved around in physical memory,
> > and get pushed out to swap.
> 
> Unless they are locked, yes.
> 
> > AFAIK, this is impossible to handle when
> > connecting two physical systems, you'd need the rings available in IO
> > memory (PCI memory), so you can ioreadXX() them instead. To the best of
> > my knowledge, I shouldn't be using copy_to_user() on an __iomem address.
> > Also, having them migrate around in memory would be a bad thing.
> > 
> > Also, I'm having trouble figuring out how the packet contents are
> > actually copied from one system to the other. Could you point this out
> > for me?
> 
> The code in net/packet/af_packet.c does it when vhost calls sendmsg.
> 

Ok. The sendmsg() implementation uses memcpy_fromiovec(). Is it possible
to make this use a DMA engine instead? I know this was suggested in an
earlier thread.

> > Is there somewhere I can find the userspace code (kvm, qemu, lguest,
> > etc.) code needed for interacting with the vhost misc device so I can
> > get a better idea of how userspace is supposed to work?
> 
> Look in archives for kvm@vger.kernel.org. the subject is qemu-kvm: vhost net.
> 
> > (Features
> > negotiation, etc.)
> > 
> 
> That's not yet implemented as there are no features yet.  I'm working on
> tap support, which will add a feature bit.  Overall, qemu does an ioctl
> to query supported features, and then acks them with another ioctl.  I'm
> also trying to avoid duplicating functionality available elsewhere.  So
> that to check e.g. TSO support, you'd just look at the underlying
> hardware device you are binding to.
> 

Ok. Do you have plans to support the VIRTIO_NET_F_MRG_RXBUF feature in
the future? I found that this made an enormous improvement in throughput
on my virtio-net <-> virtio-net system. Perhaps it isn't needed with
vhost-net.

Thanks for replying,
Ira

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

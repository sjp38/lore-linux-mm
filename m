Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A16B06B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 11:17:48 -0400 (EDT)
From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Date: Fri, 11 Sep 2009 23:17:33 +0800
Subject: RE: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <C85CEDA13AB1CF4D9D597824A86D2B9006AECB9C1D@PDSMSX501.ccr.corp.intel.com>
References: <cover.1251388414.git.mst@redhat.com>
 <20090827160750.GD23722@redhat.com>
 <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com>
 <20090908172035.GB319@ovro.caltech.edu> <20090908201428.GA12420@redhat.com>
In-Reply-To: <20090908201428.GA12420@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, "s.hetze@linux-ag.com" <s.hetze@linux-ag.com>
List-ID: <linux-mm.kvack.org>

Michael,
We are very interested in your patch and want to have a try with it.
I have collected your 3 patches in kernel side and 4 patches in queue side.
The patches are listed here:

PATCHv5-1-3-mm-export-use_mm-unuse_mm-to-modules.patch
PATCHv5-2-3-mm-reduce-atomic-use-on-use_mm-fast-path.patch
PATCHv5-3-3-vhost_net-a-kernel-level-virtio-server.patch

PATCHv3-1-4-qemu-kvm-move-virtio-pci[1].o-to-near-pci.o.patch
PATCHv3-2-4-virtio-move-features-to-an-inline-function.patch
PATCHv3-3-4-qemu-kvm-vhost-net-implementation.patch
PATCHv3-4-4-qemu-kvm-add-compat-eventfd.patch

I applied the kernel patches on v2.6.31-rc4 and the qemu patches on latest =
kvm qemu.
But seems there are some patches are needed at least irqfd and ioeventfd pa=
tches on
current qemu. I cannot create a kvm guest with "-net nic,model=3Dvirtio,vho=
st=3DvethX".

May you kindly advice us the patch lists all exactly to make it work?
Thanks a lot. :-)

Thanks
Xiaohui
-----Original Message-----
From: kvm-owner@vger.kernel.org [mailto:kvm-owner@vger.kernel.org] On Behal=
f Of Michael S. Tsirkin
Sent: Wednesday, September 09, 2009 4:14 AM
To: Ira W. Snyder
Cc: netdev@vger.kernel.org; virtualization@lists.linux-foundation.org; kvm@=
vger.kernel.org; linux-kernel@vger.kernel.org; mingo@elte.hu; linux-mm@kvac=
k.org; akpm@linux-foundation.org; hpa@zytor.com; gregory.haskins@gmail.com;=
 Rusty Russell; s.hetze@linux-ag.com
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server

On Tue, Sep 08, 2009 at 10:20:35AM -0700, Ira W. Snyder wrote:
> On Mon, Sep 07, 2009 at 01:15:37PM +0300, Michael S. Tsirkin wrote:
> > On Thu, Sep 03, 2009 at 11:39:45AM -0700, Ira W. Snyder wrote:
> > > On Thu, Aug 27, 2009 at 07:07:50PM +0300, Michael S. Tsirkin wrote:
> > > > What it is: vhost net is a character device that can be used to red=
uce
> > > > the number of system calls involved in virtio networking.
> > > > Existing virtio net code is used in the guest without modification.
> > > >=20
> > > > There's similarity with vringfd, with some differences and reduced =
scope
> > > > - uses eventfd for signalling
> > > > - structures can be moved around in memory at any time (good for mi=
gration)
> > > > - support memory table and not just an offset (needed for kvm)
> > > >=20
> > > > common virtio related code has been put in a separate file vhost.c =
and
> > > > can be made into a separate module if/when more backends appear.  I=
 used
> > > > Rusty's lguest.c as the source for developing this part : this supp=
lied
> > > > me with witty comments I wouldn't be able to write myself.
> > > >=20
> > > > What it is not: vhost net is not a bus, and not a generic new syste=
m
> > > > call. No assumptions are made on how guest performs hypercalls.
> > > > Userspace hypervisors are supported as well as kvm.
> > > >=20
> > > > How it works: Basically, we connect virtio frontend (configured by
> > > > userspace) to a backend. The backend could be a network device, or =
a
> > > > tun-like device. In this version I only support raw socket as a bac=
kend,
> > > > which can be bound to e.g. SR IOV, or to macvlan device.  Backend i=
s
> > > > also configured by userspace, including vlan/mac etc.
> > > >=20
> > > > Status:
> > > > This works for me, and I haven't see any crashes.
> > > > I have done some light benchmarking (with v4), compared to userspac=
e, I
> > > > see improved latency (as I save up to 4 system calls per packet) bu=
t not
> > > > bandwidth/CPU (as TSO and interrupt mitigation are not supported). =
 For
> > > > ping benchmark (where there's no TSO) troughput is also improved.
> > > >=20
> > > > Features that I plan to look at in the future:
> > > > - tap support
> > > > - TSO
> > > > - interrupt mitigation
> > > > - zero copy
> > > >=20
> > >=20
> > > Hello Michael,
> > >=20
> > > I've started looking at vhost with the intention of using it over PCI=
 to
> > > connect physical machines together.
> > >=20
> > > The part that I am struggling with the most is figuring out which par=
ts
> > > of the rings are in the host's memory, and which parts are in the
> > > guest's memory.
> >=20
> > All rings are in guest's memory, to match existing virtio code.
>=20
> Ok, this makes sense.
>=20
> > vhost
> > assumes that the memory space of the hypervisor userspace process cover=
s
> > the whole of guest memory.
>=20
> Is this necessary? Why?

Because with virtio ring can give us arbitrary guest addresses.  If
guest was limited to using a subset of addresses, hypervisor would only
have to map these.

> The assumption seems very wrong when you're
> doing data transport between two physical systems via PCI.
> I know vhost has not been designed for this specific situation, but it
> is good to be looking toward other possible uses.
>=20
> > And there's a translation table.
> > Ring addresses are userspace addresses, they do not undergo translation=
.
> >=20
> > > If I understand everything correctly, the rings are all userspace
> > > addresses, which means that they can be moved around in physical memo=
ry,
> > > and get pushed out to swap.
> >=20
> > Unless they are locked, yes.
> >=20
> > > AFAIK, this is impossible to handle when
> > > connecting two physical systems, you'd need the rings available in IO
> > > memory (PCI memory), so you can ioreadXX() them instead. To the best =
of
> > > my knowledge, I shouldn't be using copy_to_user() on an __iomem addre=
ss.
> > > Also, having them migrate around in memory would be a bad thing.
> > >=20
> > > Also, I'm having trouble figuring out how the packet contents are
> > > actually copied from one system to the other. Could you point this ou=
t
> > > for me?
> >=20
> > The code in net/packet/af_packet.c does it when vhost calls sendmsg.
> >=20
>=20
> Ok. The sendmsg() implementation uses memcpy_fromiovec(). Is it possible
> to make this use a DMA engine instead?

Maybe.

> I know this was suggested in an earlier thread.

Yes, it might even give some performance benefit with e.g. I/O AT.

> > > Is there somewhere I can find the userspace code (kvm, qemu, lguest,
> > > etc.) code needed for interacting with the vhost misc device so I can
> > > get a better idea of how userspace is supposed to work?
> >=20
> > Look in archives for kvm@vger.kernel.org. the subject is qemu-kvm: vhos=
t net.
> >=20
> > > (Features
> > > negotiation, etc.)
> > >=20
> >=20
> > That's not yet implemented as there are no features yet.  I'm working o=
n
> > tap support, which will add a feature bit.  Overall, qemu does an ioctl
> > to query supported features, and then acks them with another ioctl.  I'=
m
> > also trying to avoid duplicating functionality available elsewhere.  So
> > that to check e.g. TSO support, you'd just look at the underlying
> > hardware device you are binding to.
> >=20
>=20
> Ok. Do you have plans to support the VIRTIO_NET_F_MRG_RXBUF feature in
> the future? I found that this made an enormous improvement in throughput
> on my virtio-net <-> virtio-net system. Perhaps it isn't needed with
> vhost-net.

Yes, I'm working on it.

> Thanks for replying,
> Ira
--
To unsubscribe from this list: send the line "unsubscribe kvm" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

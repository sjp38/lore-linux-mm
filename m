Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CE25D6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:08:26 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1297863qwf.44
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 13:08:28 -0700 (PDT)
Message-ID: <4AAFF437.7060100@gmail.com>
Date: Tue, 15 Sep 2009 16:08:23 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com>
In-Reply-To: <4AAFACB5.9050808@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig07558A0474366E63F11D21AB"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig07558A0474366E63F11D21AB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/15/2009 04:50 PM, Gregory Haskins wrote:
>>> Why?  vhost will call get_user_pages() or copy_*_user() which ought t=
o
>>> do the right thing.
>>>     =20
>> I was speaking generally, not specifically to Ira's architecture.  Wha=
t
>> I mean is that vbus was designed to work without assuming that the
>> memory is pageable.  There are environments in which the host is not
>> capable of mapping hvas/*page, but the memctx->copy_to/copy_from
>> paradigm could still work (think rdma, for instance).
>>   =20
>=20
> Sure, vbus is more flexible here.
>=20
>>>> As an aside: a bigger issue is that, iiuc, Ira wants more than a sin=
gle
>>>> ethernet channel in his design (multiple ethernets, consoles, etc). =
 A
>>>> vhost solution in this environment is incomplete.
>>>>
>>>>       =20
>>> Why?  Instantiate as many vhost-nets as needed.
>>>     =20
>> a) what about non-ethernets?
>>   =20
>=20
> There's virtio-console, virtio-blk etc.  None of these have kernel-mode=

> servers, but these could be implemented if/when needed.

IIUC, Ira already needs at least ethernet and console capability.

>=20
>> b) what do you suppose this protocol to aggregate the connections woul=
d
>> look like? (hint: this is what a vbus-connector does).
>>   =20
>=20
> You mean multilink?  You expose the device as a multiqueue.

No, what I mean is how do you surface multiple ethernet and consoles to
the guests?  For Ira's case, I think he needs at minimum at least one of
each, and he mentioned possibly having two unique ethernets at one point.=


His slave boards surface themselves as PCI devices to the x86
host.  So how do you use that to make multiple vhost-based devices (say
two virtio-nets, and a virtio-console) communicate across the transport?

There are multiple ways to do this, but what I am saying is that
whatever is conceived will start to look eerily like a vbus-connector,
since this is one of its primary purposes ;)


>=20
>> c) how do you manage the configuration, especially on a per-board basi=
s?
>>   =20
>=20
> pci (for kvm/x86).

Ok, for kvm understood (and I would also add "qemu" to that mix).  But
we are talking about vhost's application in a non-kvm environment here,
right?.

So if the vhost-X devices are in the "guest", and the x86 board is just
a slave...How do you tell each ppc board how many devices and what
config (e.g. MACs, etc) to instantiate?  Do you assume that they should
all be symmetric and based on positional (e.g. slot) data?  What if you
want asymmetric configurations (if not here, perhaps in a different
environment)?

>=20
>> Actually I have patches queued to allow vbus to be managed via ioctls =
as
>> well, per your feedback (and it solves the permissions/lifetime
>> critisims in alacrityvm-v0.1).
>>   =20
>=20
> That will make qemu integration easier.
>=20
>>>   The only difference is the implementation.  vhost-net
>>> leaves much more to userspace, that's the main difference.
>>>     =20
>> Also,
>>
>> *) vhost is virtio-net specific, whereas vbus is a more generic device=

>> model where thing like virtio-net or venet ride on top.
>>   =20
>=20
> I think vhost-net is separated into vhost and vhost-net.

Thats good.

>=20
>> *) vhost is only designed to work with environments that look very
>> similar to a KVM guest (slot/hva translatable).  vbus can bridge vario=
us
>> environments by abstracting the key components (such as memory access)=
=2E
>>   =20
>=20
> Yes.  virtio is really virtualization oriented.

I would say that its vhost in particular that is virtualization
oriented.  virtio, as a concept, generally should work in physical
systems, if perhaps with some minor modifications.  The biggest "limit"
is having "virt" in its name ;)

>=20
>> *) vhost requires an active userspace management daemon, whereas vbus
>> can be driven by transient components, like scripts (ala udev)
>>   =20
>=20
> vhost by design leaves configuration and handshaking to userspace.  I
> see it as an advantage.

The misconception here is that vbus by design _doesn't define_ where
configuration/handshaking happens.  It is primarily implemented by a
modular component called a "vbus-connector", and _I_ see this
flexibility as an advantage.  vhost on the other hand depends on a
active userspace component and a slots/hva memory design, which is more
limiting in where it can be used and forces you to split the logic.
However, I think we both more or less agree on this point already.

For the record, vbus itself is simply a resource container for
virtual-devices, which provides abstractions for the various points of
interest to generalizing PV (memory, signals, etc) and the proper
isolation and protection guarantees.  What you do with it is defined by
the modular virtual-devices (e.g. virtion-net, venet, sched, hrt, scsi,
rdma, etc) and vbus-connectors (vbus-kvm, etc) you plug into it.

As an example, you could emulate the vhost design in vbus by writing a
"vbus-vhost" connector.  This connector would be very thin and terminate
locally in QEMU.  It would provide a ioctl-based verb namespace similar
to the existing vhost verbs we have today.  QEMU would then similarly
reflect the vbus-based virtio device as a PCI device to the guest, so
that virtio-pci works unmodified.

You would then have most of the advantages of the work I have done for
commoditizing/abstracting the key points for in-kernel PV, like the
memctx.  In addition, much of the work could be reused in multiple
environments since any vbus-compliant device model that is plugged into
the framework would work with any connector that is plugged in (e.g.
vbus-kvm (alacrityvm), vbus-vhost (KVM), and "vbus-ira").

The only tradeoff is in features offered by the connector (e.g.
vbus-vhost has the advantage that existing PV guests can continue to
work unmodified, vbus-kvm has the advantage that it supports new
features like generic shared memory, non-virtio based devices,
priortizable interrupts, no dependencies on PCI for non PCI guests, etc).=


Kind Regards,
-Greg


--------------enig07558A0474366E63F11D21AB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqv9DcACgkQP5K2CMvXmqEAUQCgi3OZrI/ESQUs6T/RGe0cbq3E
U2sAn1XqqK7iHyH0N9TIo7CTpXZiXP4t
=yBBN
-----END PGP SIGNATURE-----

--------------enig07558A0474366E63F11D21AB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

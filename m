Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2F0CC6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 07:44:42 -0400 (EDT)
Received: by qyk16 with SMTP id 16so1436967qyk.20
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 04:44:41 -0700 (PDT)
Message-ID: <4AB0CFA5.6040104@gmail.com>
Date: Wed, 16 Sep 2009 07:44:37 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com>
In-Reply-To: <4AB0A070.1050400@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig565B27D77C8F4682027D8B84"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig565B27D77C8F4682027D8B84
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/15/2009 11:08 PM, Gregory Haskins wrote:
>>
>>> There's virtio-console, virtio-blk etc.  None of these have kernel-mo=
de
>>> servers, but these could be implemented if/when needed.
>>>     =20
>> IIUC, Ira already needs at least ethernet and console capability.
>>
>>   =20
>=20
> He's welcome to pick up the necessary code from qemu.

The problem isn't where to find the models...the problem is how to
aggregate multiple models to the guest.

>=20
>>>> b) what do you suppose this protocol to aggregate the connections wo=
uld
>>>> look like? (hint: this is what a vbus-connector does).
>>>>
>>>>       =20
>>> You mean multilink?  You expose the device as a multiqueue.
>>>     =20
>> No, what I mean is how do you surface multiple ethernet and consoles t=
o
>> the guests?  For Ira's case, I think he needs at minimum at least one =
of
>> each, and he mentioned possibly having two unique ethernets at one poi=
nt.
>>   =20
>=20
> You instantiate multiple vhost-nets.  Multiple ethernet NICs is a
> supported configuration for kvm.

But this is not KVM.

>=20
>> His slave boards surface themselves as PCI devices to the x86
>> host.  So how do you use that to make multiple vhost-based devices (sa=
y
>> two virtio-nets, and a virtio-console) communicate across the transpor=
t?
>>   =20
>=20
> I don't really see the difference between 1 and N here.

A KVM surfaces N virtio-devices as N pci-devices to the guest.  What do
we do in Ira's case where the entire guest represents itself as a PCI
device to the host, and nothing the other way around?


>=20
>> There are multiple ways to do this, but what I am saying is that
>> whatever is conceived will start to look eerily like a vbus-connector,=

>> since this is one of its primary purposes ;)
>>   =20
>=20
> I'm not sure if you're talking about the configuration interface or dat=
a
> path here.

I am talking about how we would tunnel the config space for N devices
across his transport.

As an aside, the vbus-kvm connector makes them one and the same, but
they do not have to be.  Its all in the connector design.

>=20
>>>> c) how do you manage the configuration, especially on a per-board
>>>> basis?
>>>>
>>>>       =20
>>> pci (for kvm/x86).
>>>     =20
>> Ok, for kvm understood (and I would also add "qemu" to that mix).  But=

>> we are talking about vhost's application in a non-kvm environment here=
,
>> right?.
>>
>> So if the vhost-X devices are in the "guest",
>=20
> They aren't in the "guest".  The best way to look at it is
>=20
> - a device side, with a dma engine: vhost-net
> - a driver side, only accessing its own memory: virtio-net
>=20
> Given that Ira's config has the dma engine in the ppc boards, that's
> where vhost-net would live (the ppc boards acting as NICs to the x86
> board, essentially).

That sounds convenient given his hardware, but it has its own set of
problems.  For one, the configuration/inventory of these boards is now
driven by the wrong side and has to be addressed.  Second, the role
reversal will likely not work for many models other than ethernet (e.g.
virtio-console or virtio-blk drivers running on the x86 board would be
naturally consuming services from the slave boards...virtio-net is an
exception because 802.x is generally symmetrical).

IIUC, vbus would support having the device models live properly on the
x86 side, solving both of these problems.  It would be impossible to
reverse vhost given its current design.

>=20
>> and the x86 board is just
>> a slave...How do you tell each ppc board how many devices and what
>> config (e.g. MACs, etc) to instantiate?  Do you assume that they shoul=
d
>> all be symmetric and based on positional (e.g. slot) data?  What if yo=
u
>> want asymmetric configurations (if not here, perhaps in a different
>> environment)?
>>   =20
>=20
> I have no idea, that's for Ira to solve.

Bingo.  Thus my statement that the vhost proposal is incomplete.  You
have the virtio-net and vhost-net pieces covering the fast-path
end-points, but nothing in the middle (transport, aggregation,
config-space), and nothing on the management-side.  vbus provides most
of the other pieces, and can even support the same virtio-net protocol
on top.  The remaining part would be something like a udev script to
populate the vbus with devices on board-insert events.

> If he could fake the PCI
> config space as seen by the x86 board, he would just show the normal pc=
i
> config and use virtio-pci (multiple channels would show up as a
> multifunction device).  Given he can't, he needs to tunnel the virtio
> config space some other way.

Right, and note that vbus was designed to solve this.  This tunneling
can, of course, be done without vbus using some other design.  However,
whatever solution is created will look incredibly close to what I've
already done, so my point is "why reinvent it"?

>=20
>>> Yes.  virtio is really virtualization oriented.
>>>     =20
>> I would say that its vhost in particular that is virtualization
>> oriented.  virtio, as a concept, generally should work in physical
>> systems, if perhaps with some minor modifications.  The biggest "limit=
"
>> is having "virt" in its name ;)
>>   =20
>=20
> Let me rephrase.  The virtio developers are virtualization oriented.  I=
f
> it works for non-virt applications, that's good, but not a design goal.=

>=20

Fair enough.  Vbus was designed to support both HW and virt (as well as
other models, like containers), including tunneling virtio within those
environments.  That is probably why IMO vbus is a better fit than vhost
here.  (FWIW: I would love to see vhost use the vbus framework, then we
all win.  You can do this and still retain virtio-pci compatiblity (at
least theoretically).  I am still open to working with the team on this).=


Kind Regards,
-Greg


--------------enig565B27D77C8F4682027D8B84
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqwz6UACgkQP5K2CMvXmqGizACdElmC6EpcS5tbXDuA+LvYGkVG
SQwAnR7mTl5QZAyTWDko91BQZXCcQ7rT
=/ake
-----END PGP SIGNATURE-----

--------------enig565B27D77C8F4682027D8B84--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

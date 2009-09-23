Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 382326B005A
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 10:26:11 -0400 (EDT)
Received: by qyk10 with SMTP id 10so598214qyk.12
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 07:26:18 -0700 (PDT)
Message-ID: <4ABA3005.60905@gmail.com>
Date: Wed, 23 Sep 2009 10:26:13 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com>
In-Reply-To: <4AB89C48.4020903@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig018D6C9E90E6E69889E172C8"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig018D6C9E90E6E69889E172C8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/22/2009 12:43 AM, Ira W. Snyder wrote:
>>
>>> Sure, virtio-ira and he is on his own to make a bus-model under that,=
 or
>>> virtio-vbus + vbus-ira-connector to use the vbus framework.  Either
>>> model can work, I agree.
>>>
>>>     =20
>> Yes, I'm having to create my own bus model, a-la lguest, virtio-pci, a=
nd
>> virtio-s390. It isn't especially easy. I can steal lots of code from t=
he
>> lguest bus model, but sometimes it is good to generalize, especially
>> after the fourth implemention or so. I think this is what GHaskins tri=
ed
>> to do.
>>   =20
>=20
> Yes.  vbus is more finely layered so there is less code duplication.

To clarify, Ira was correct in stating this generalizing some of these
components was one of the goals for the vbus project: IOW vbus finely
layers and defines what's below virtio, not replaces it.

You can think of a virtio-stack like this:

--------------------------
| virtio-net
--------------------------
| virtio-ring
--------------------------
| virtio-bus
--------------------------
| ? undefined ?
--------------------------

IOW: The way I see it, virtio is a device interface model only.  The
rest of it is filled in by the virtio-transport and some kind of back-end=
=2E

So today, we can complete the "? undefined ?" block like this for KVM:

--------------------------
| virtio-pci
--------------------------
             |
--------------------------
| kvm.ko
--------------------------
| qemu
--------------------------
| tuntap
--------------------------

In this case, kvm.ko and tuntap are providing plumbing, and qemu is
providing a backend device model (pci-based, etc).

You can, of course, plug a different stack in (such as virtio-lguest,
virtio-ira, etc) but you are more or less on your own to recreate many
of the various facilities contained in that stack (such as things
provided by QEMU, like discovery/hotswap/addressing), as Ira is discoveri=
ng.

Vbus tries to commoditize more components in the stack (like the bus
model and backend-device model) so they don't need to be redesigned each
time we solve this "virtio-transport" problem.  IOW: stop the
proliferation of the need for pci-bus, lguest-bus, foo-bus underneath
virtio.  Instead, we can then focus on the value add on top, like the
models themselves or the simple glue between them.

So now you might have something like

--------------------------
| virtio-vbus
--------------------------
| vbus-proxy
--------------------------
| kvm-guest-connector
--------------------------
             |
--------------------------
| kvm.ko
--------------------------
| kvm-host-connector.ko
--------------------------
| vbus.ko
--------------------------
| virtio-net-backend.ko
--------------------------

so now we don't need to worry about the bus-model or the device-model
framework.  We only need to implement the connector, etc.  This is handy
when you find yourself in an environment that doesn't support PCI (such
as Ira's rig, or userspace containers), or when you want to add features
that PCI doesn't have (such as fluid event channels for things like IPC
services, or priortizable interrupts, etc).

>=20
> The virtio layering was more or less dictated by Xen which doesn't have=

> shared memory (it uses grant references instead).  As a matter of fact
> lguest, kvm/pci, and kvm/s390 all have shared memory, as you do, so tha=
t
> part is duplicated.  It's probably possible to add a virtio-shmem.ko
> library that people who do have shared memory can reuse.

Note that I do not believe the Xen folk use virtio, so while I can
appreciate the foresight that went into that particular aspect of the
design of the virtio model, I am not sure if its a realistic constraint.

The reason why I decided to not worry about that particular model is
twofold:

1) Trying to support non shared-memory designs is prohibitively high for
my performance goals (for instance, requiring an exit on each
->add_buf() in addition to the ->kick()).

2) The Xen guys are unlikely to diverge from something like
xenbus/xennet anyway, so it would be for naught.

Therefore, I just went with a device model optimized for shared-memory
outright.

That said, I believe we can refactor what is called the
"vbus-proxy-device" into this virtio-shmem interface that you and
Anthony have described.  We could make the feature optional and only
support on architectures where this makes sense.

<snip>

Kind Regards,
-Greg


--------------enig018D6C9E90E6E69889E172C8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkq6MAUACgkQP5K2CMvXmqG1hQCeIovZyEMNNCZ5tLvhRzoDRU0p
1ukAoIcSD9Jxc+va4gqc7pwGR3iOIWDb
=cmA0
-----END PGP SIGNATURE-----

--------------enig018D6C9E90E6E69889E172C8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

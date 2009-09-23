Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 862E76B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 11:10:56 -0400 (EDT)
Received: by qyk10 with SMTP id 10so636815qyk.12
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 08:10:48 -0700 (PDT)
Message-ID: <4ABA3A73.5090508@gmail.com>
Date: Wed, 23 Sep 2009 11:10:43 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com>
In-Reply-To: <4ABA32AF.50602@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5B75B8792B906F18C2BBDA7B"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5B75B8792B906F18C2BBDA7B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/23/2009 05:26 PM, Gregory Haskins wrote:
>>
>>  =20
>>>> Yes, I'm having to create my own bus model, a-la lguest, virtio-pci,=

>>>> and
>>>> virtio-s390. It isn't especially easy. I can steal lots of code from=

>>>> the
>>>> lguest bus model, but sometimes it is good to generalize, especially=

>>>> after the fourth implemention or so. I think this is what GHaskins
>>>> tried
>>>> to do.
>>>>
>>>>       =20
>>> Yes.  vbus is more finely layered so there is less code duplication.
>>>     =20
>> To clarify, Ira was correct in stating this generalizing some of these=

>> components was one of the goals for the vbus project: IOW vbus finely
>> layers and defines what's below virtio, not replaces it.
>>
>> You can think of a virtio-stack like this:
>>
>> --------------------------
>> | virtio-net
>> --------------------------
>> | virtio-ring
>> --------------------------
>> | virtio-bus
>> --------------------------
>> | ? undefined ?
>> --------------------------
>>
>> IOW: The way I see it, virtio is a device interface model only.  The
>> rest of it is filled in by the virtio-transport and some kind of
>> back-end.
>>
>> So today, we can complete the "? undefined ?" block like this for KVM:=

>>
>> --------------------------
>> | virtio-pci
>> --------------------------
>>               |
>> --------------------------
>> | kvm.ko
>> --------------------------
>> | qemu
>> --------------------------
>> | tuntap
>> --------------------------
>>
>> In this case, kvm.ko and tuntap are providing plumbing, and qemu is
>> providing a backend device model (pci-based, etc).
>>
>> You can, of course, plug a different stack in (such as virtio-lguest,
>> virtio-ira, etc) but you are more or less on your own to recreate many=

>> of the various facilities contained in that stack (such as things
>> provided by QEMU, like discovery/hotswap/addressing), as Ira is
>> discovering.
>>
>> Vbus tries to commoditize more components in the stack (like the bus
>> model and backend-device model) so they don't need to be redesigned ea=
ch
>> time we solve this "virtio-transport" problem.  IOW: stop the
>> proliferation of the need for pci-bus, lguest-bus, foo-bus underneath
>> virtio.  Instead, we can then focus on the value add on top, like the
>> models themselves or the simple glue between them.
>>
>> So now you might have something like
>>
>> --------------------------
>> | virtio-vbus
>> --------------------------
>> | vbus-proxy
>> --------------------------
>> | kvm-guest-connector
>> --------------------------
>>               |
>> --------------------------
>> | kvm.ko
>> --------------------------
>> | kvm-host-connector.ko
>> --------------------------
>> | vbus.ko
>> --------------------------
>> | virtio-net-backend.ko
>> --------------------------
>>
>> so now we don't need to worry about the bus-model or the device-model
>> framework.  We only need to implement the connector, etc.  This is han=
dy
>> when you find yourself in an environment that doesn't support PCI (suc=
h
>> as Ira's rig, or userspace containers), or when you want to add featur=
es
>> that PCI doesn't have (such as fluid event channels for things like IP=
C
>> services, or priortizable interrupts, etc).
>>   =20
>=20
> Well, vbus does more, for example it tunnels interrupts instead of
> exposing them 1:1 on the native interface if it exists.

As I've previously explained, that trait is a function of the
kvm-connector I've chosen to implement, not of the overall design of vbus=
=2E

The reason why my kvm-connector is designed that way is because my early
testing/benchmarking shows one of the issues in KVM performance is the
ratio of exits per IO operation are fairly high, especially as your
scale io-load.  Therefore, the connector achieves a substantial
reduction in that ratio by treating "interrupts" to the same kind of
benefits that NAPI brought to general networking: That is, we enqueue
"interrupt" messages into a lockless ring and only hit the IDT for the
first occurrence.  Subsequent interrupts are injected in a
parallel/lockless manner, without hitting the IDT nor incurring an extra
EOI.  This pays dividends as the IO rate increases, which is when the
guest needs the most help.

OTOH, it is entirely possible to design the connector such that we
maintain a 1:1 ratio of signals to traditional IDT interrupts.  It is
also possible to design a connector which surfaces as something else,
such as PCI devices (by terminating the connector in QEMU and utilizing
its PCI emulation facilities), which would naturally employ 1:1 mapping.

So if 1:1 mapping is a critical feature (I would argue to the contrary),
vbus can support it.

> It also pulls parts of the device model into the host kernel.

That is the point.  Most of it needs to be there for performance.  And
what doesn't need to be there for performance can either be:

a) skipped at the discretion of the connector/device-model designer

OR

b) included because its trivially small subset of the model (e.g. a
mac-addr attribute) and its nice to have a cohesive solution instead of
requiring a separate binary blob that can get out of sync, etc.

The example Ive provided to date (venet on kvm) utilizes (b), but it
certainly doesn't have to.  Therefore, I don't think vbus as a whole can
be judged on this one point.

>=20
>>> The virtio layering was more or less dictated by Xen which doesn't ha=
ve
>>> shared memory (it uses grant references instead).  As a matter of fac=
t
>>> lguest, kvm/pci, and kvm/s390 all have shared memory, as you do, so t=
hat
>>> part is duplicated.  It's probably possible to add a virtio-shmem.ko
>>> library that people who do have shared memory can reuse.
>>>     =20
>> Note that I do not believe the Xen folk use virtio, so while I can
>> appreciate the foresight that went into that particular aspect of the
>> design of the virtio model, I am not sure if its a realistic constrain=
t.
>>   =20
>=20
> Since a virtio goal was to reduce virtual device driver proliferation,
> it was necessary to accommodate Xen.

Fair enough, but I don't think the Xen community will ever use it.

To your point, a vbus goal was to reduce the bus-model and
backend-device-model proliferation for environments served by Linux as
the host.  This naturally complements virtio's driver non-proliferation
goal, but probably excludes Xen for reasons beyond the lack of shmem
(since it has its own non-linux hypervisor kernel).

In any case, I've already stated that we simply make the virtio-shmem
(vbus-proxy-device) facility optionally defined, and unavailable on
non-shmem based architectures to work around that issue.

The alternative is that we abstract the shmem concept further (ala
->add_buf() from the virtqueue world) but it is probably pointless to
try to accommodate shared-memory if you don't really have it, and no-one
will likely use it.

Kind Regards,
-Greg


--------------enig5B75B8792B906F18C2BBDA7B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkq6OnMACgkQP5K2CMvXmqFK7gCfRr08U1PGhr8SulFvwY5YQJnO
APoAn0k3pmKeK+oy9y4Bbyw3OXcjdLt9
=xUnP
-----END PGP SIGNATURE-----

--------------enig5B75B8792B906F18C2BBDA7B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

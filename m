Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A46706B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 15:22:55 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1590969qwf.44
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 12:23:01 -0700 (PDT)
Message-ID: <4AB13B09.5040308@gmail.com>
Date: Wed, 16 Sep 2009 15:22:49 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com>
In-Reply-To: <4AB10B67.2050108@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8A5C8AA90691DAD872962AF3"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8A5C8AA90691DAD872962AF3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/16/2009 05:10 PM, Gregory Haskins wrote:
>>
>>> If kvm can do it, others can.
>>>     =20
>> The problem is that you seem to either hand-wave over details like thi=
s,
>> or you give details that are pretty much exactly what vbus does alread=
y.
>>   My point is that I've already sat down and thought about these issue=
s
>> and solved them in a freely available GPL'ed software package.
>>   =20
>=20
> In the kernel.  IMO that's the wrong place for it.

In conversations with Ira, he indicated he needs kernel-to-kernel
ethernet for performance, and needs at least an ethernet and console
connectivity.  You could conceivably build a solution for this system 3
basic ways:

1) "completely" in userspace: use things like tuntap on the ppc boards,
and tunnel packets across a custom point-to-point connection formed over
the pci link to a userspace app on the x86 board.  This app then
reinjects the packets into the x86 kernel as a raw socket or tuntap,
etc.  Pretty much vanilla tuntap/vpn kind of stuff.  Advantage: very
little kernel code.  Problem: performance (citation: hopefully obvious).

2) "partially" in userspace: have an in-kernel virtio-net driver talk to
a userspace based virtio-net backend.  This is the (current, non-vhost
oriented) KVM/qemu model.  Advantage, re-uses existing kernel-code.
Problem: performance (citation: see alacrityvm numbers).

3) "in-kernel": You can do something like virtio-net to vhost to
potentially meet some of the requirements, but not all.

In order to fully meet (3), you would need to do some of that stuff you
mentioned in the last reply with muxing device-nr/reg-nr.  In addition,
we need to have a facility for mapping eventfds and establishing a
signaling mechanism (like PIO+qid), etc. KVM does this with
IRQFD/IOEVENTFD, but we dont have KVM in this case so it needs to be
invented.

To meet performance, this stuff has to be in kernel and there has to be
a way to manage it.  Since vbus was designed to do exactly that, this is
what I would advocate.  You could also reinvent these concepts and put
your own mux and mapping code in place, in addition to all the other
stuff that vbus does.  But I am not clear why anyone would want to.

So no, the kernel is not the wrong place for it.  Its the _only_ place
for it.  Otherwise, just use (1) and be done with it.

>  Further, if we adopt
> vbus, if drop compatibility with existing guests or have to support bot=
h
> vbus and virtio-pci.

We already need to support both (at least to support Ira).  virtio-pci
doesn't work here.  Something else (vbus, or vbus-like) is needed.

>=20
>> So the question is: is your position that vbus is all wrong and you wi=
sh
>> to create a new bus-like thing to solve the problem?
>=20
> I don't intend to create anything new, I am satisfied with virtio.  If
> it works for Ira, excellent.  If not, too bad.

I think that about sums it up, then.


>  I believe it will work without too much trouble.

Afaict it wont for the reasons I mentioned.

>=20
>> If so, how is it
>> different from what Ive already done?  More importantly, what specific=

>> objections do you have to what Ive done, as perhaps they can be fixed
>> instead of starting over?
>>   =20
>=20
> The two biggest objections are:
> - the host side is in the kernel

As it needs to be.

> - the guest side is a new bus instead of reusing pci (on x86/kvm),
> making Windows support more difficult

Thats a function of the vbus-connector, which is different from
vbus-core.  If you don't like it (and I know you don't), we can write
one that interfaces to qemu's pci system.  I just don't like the
limitations that imposes, nor do I think we need that complexity of
dealing with a split PCI model, so I chose to not implement vbus-kvm
this way.

With all due respect, based on all of your comments in aggregate I
really do not think you are truly grasping what I am actually building he=
re.

>=20
> I guess these two are exactly what you think are vbus' greatest
> advantages, so we'll probably have to extend our agree-to-disagree on
> this one.
>=20
> I also had issues with using just one interrupt vector to service all
> events, but that's easily fixed.

Again, function of the connector.

>=20
>>> There is no guest and host in this scenario.  There's a device side
>>> (ppc) and a driver side (x86).  The driver side can access configurat=
ion
>>> information on the device side.  How to multiplex multiple devices is=
 an
>>> interesting exercise for whoever writes the virtio binding for that
>>> setup.
>>>     =20
>> Bingo.  So now its a question of do you want to write this layer from
>> scratch, or re-use my framework.
>>   =20
>=20
> You will have to implement a connector or whatever for vbus as well.=20
> vbus has more layers so it's probably smaller for vbus.

Bingo! That is precisely the point.

All the stuff for how to map eventfds, handle signal mitigation, demux
device/function pointers, isolation, etc, are built in.  All the
connector has to do is transport the 4-6 verbs and provide a memory
mapping/copy function, and the rest is reusable.  The device models
would then work in all environments unmodified, and likewise the
connectors could use all device-models unmodified.

>=20
>>>>>
>>>>>         =20
>>>> I am talking about how we would tunnel the config space for N device=
s
>>>> across his transport.
>>>>
>>>>       =20
>>> Sounds trivial.
>>>     =20
>> No one said it was rocket science.  But it does need to be designed an=
d
>> implemented end-to-end, much of which Ive already done in what I hope =
is
>> an extensible way.
>>   =20
>=20
> It was already implemented three times for virtio, so apparently that's=

> extensible too.

And to my point, I'm trying to commoditize as much of that process as
possible on both the front and backends (at least for cases where
performance matters) so that you don't need to reinvent the wheel for
each one.

>=20
>>>   Write an address containing the device number and
>>> register number to on location, read or write data from another.
>>>     =20
>> You mean like the "u64 devh", and "u32 func" fields I have here for th=
e
>> vbus-kvm connector?
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-=
2.6.git;a=3Dblob;f=3Dinclude/linux/vbus_pci.h;h=3Dfe337590e644017392e4c9d=
9236150adb2333729;hb=3Dded8ce2005a85c174ba93ee26f8d67049ef11025#l64
>>
>>
>>   =20
>=20
> Probably.
>=20
>=20
>=20
>>>> That sounds convenient given his hardware, but it has its own set of=

>>>> problems.  For one, the configuration/inventory of these boards is n=
ow
>>>> driven by the wrong side and has to be addressed.
>>>>       =20
>>> Why is it the wrong side?
>>>     =20
>> "Wrong" is probably too harsh a word when looking at ethernet.  Its
>> certainly "odd", and possibly inconvenient.  It would be like having
>> vhost in a KVM guest, and virtio-net running on the host.  You could d=
o
>> it, but its weird and awkward.  Where it really falls apart and enters=

>> the "wrong" category is for non-symmetric devices, like disk-io.
>>
>>   =20
>=20
>=20
> It's not odd or wrong or wierd or awkward.

Its weird IMO because IIUC the ppc boards are not really "NICs".  Yes,
their arrangement as bus-master PCI devices makes them look and smell
like "devices", but that is an implementation detail of its transport
(like hypercalls/PIO in KVM) and not relevant to its broader role in the
system.

They are more or less like "guests" from the KVM world.  The x86 is
providing connectivity resources to these guests, not the other way
around.  It is not a goal to make the x86 look like it has a multihomed
array of ppc based NIC adapters.  The only reason we would treat these
ppc boards like NICs is because (iiuc) that is the only way vhost can be
hacked to work with the system, not because its the optimal design.

FWIW: There are a ton of chassis-based systems that look similar to
Ira's out there (PCI inter-connected nodes), and I would like to support
them, too.  So its not like this is a one-off.


> An ethernet NIC is not
> symmetric, one side does DMA and issues interrupts, the other uses its
> own memory.

I never said a NIC was.  I meant the ethernet _protocol_ is symmetric.
I meant it in the sense that you can ingress/egress packets in either
direction and as long as "TX" on one side is "RX" on the other and vice
versa, it all kind of works.  You can even loop it back and it still work=
s.

Contrast this to something like a disk-block protocol where a "read"
message is expected to actually do a read, etc.  In this case, you
cannot arbitrarily assign the location of the "driver" and "device" like
you can with ethernet.  The device should presumably be where the
storage is, and the driver should be where the consumer is.

>  That's exactly the case with Ira's setup.

See "implementation detail" comment above.


>=20
> If the ppc boards were to emulate a disk controller, you'd run
> virtio-blk on x86 and vhost-blk on the ppc boards.

Agreed.

>=20
>>>> Second, the role
>>>> reversal will likely not work for many models other than ethernet (e=
=2Eg.
>>>> virtio-console or virtio-blk drivers running on the x86 board would =
be
>>>> naturally consuming services from the slave boards...virtio-net is a=
n
>>>> exception because 802.x is generally symmetrical).
>>>>
>>>>       =20
>>> There is no role reversal.
>>>     =20
>> So if I have virtio-blk driver running on the x86 and vhost-blk device=

>> running on the ppc board, I can use the ppc board as a block-device.
>> What if I really wanted to go the other way?
>>   =20
>=20
> You mean, if the x86 board was able to access the disks and dma into th=
e
> ppb boards memory?  You'd run vhost-blk on x86 and virtio-net on ppc.

But as we discussed, vhost doesn't work well if you try to run it on the
x86 side due to its assumptions about pagable "guest" memory, right?  So
is that even an option?  And even still, you would still need to solve
the aggregation problem so that multiple devices can coexist.

>=20
> As long as you don't use the words "guest" and "host" but keep to
> "driver" and "device", it all works out.
>=20
>>> The side doing dma is the device, the side
>>> accessing its own memory is the driver.  Just like that other 1e12
>>> driver/device pairs out there.
>>>     =20
>> IIUC, his ppc boards really can be seen as "guests" (they are linux
>> instances that are utilizing services from the x86, not the other way
>> around).
>=20
> They aren't guests.  Guests don't dma into their host's memory.

Thats not relevant.  They are not guests in the sense of isolated
virtualized guests like KVM.  They are guests in the sense that they are
subordinate linux instances which utilize IO resources on the x86 (host).=


The way this would work is that the x86 would be driving the dma
controller on the ppc board, not the other way around.  The fact that
the controller lives on the ppc board is an implementation detail.

The way I envision this to work would be that the ppc board exports two
functions in its device:

1) a vbus-bridge like device
2) a dma-controller that accepts "gpas" as one parameter

so function (1) does the 4-6 verbs I mentioned for device addressing,
etc.  function (2) is utilized by the x86 memctx whenever a
->copy_from() or ->copy_to() operation is invoked.  The ppc board's
would be doing their normal virtio kind of things, like
->add_buf(_pa(skb->data))).

>=20
>> vhost forces the model to have the ppc boards act as IO-hosts,
>> whereas vbus would likely work in either direction due to its more
>> refined abstraction layer.
>>   =20
>=20
> vhost=3Ddevice=3Ddma, virtio=3Ddriver=3Down-memory.

I agree that virtio=3Ddriver=3Down-memory.  The problem is vhost !=3D dma=
=2E
vhost =3D hva*, and it just so happens that Ira's ppc boards support host=

mapping/dma so it kind of works.

What I have been trying to say is that the extra abstraction to the
memctx gets the "vhost" side away from hva*, such that it can support
hva if that makes sense, or something else (like a custom dma engine if
it doesn't)

>=20
>>> Of course vhost is incomplete, in the same sense that Linux is
>>> incomplete.  Both require userspace.
>>>     =20
>> A vhost based solution to Iras design is missing more than userspace.
>> Many of those gaps are addressed by a vbus based solution.
>>   =20
>=20
> Maybe.  Ira can fill the gaps or use vbus.
>=20
>=20

Agreed.

Kind Regards,
-Greg



--------------enig8A5C8AA90691DAD872962AF3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqxOwkACgkQP5K2CMvXmqGEJgCfaEc3EkZ/Y3/Mno/4/XypLjpO
ms0AnRS1V0MtT+18ryuZ043Zl/kL6iSo
=2BoS
-----END PGP SIGNATURE-----

--------------enig8A5C8AA90691DAD872962AF3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1A4006B005A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 10:10:58 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1487405qwf.44
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 07:11:00 -0700 (PDT)
Message-ID: <4AB0F1EF.5050102@gmail.com>
Date: Wed, 16 Sep 2009 10:10:55 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com>
In-Reply-To: <4AB0E2A2.3080409@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig96A6E6B1F5308E397068EC7E"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig96A6E6B1F5308E397068EC7E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/16/2009 02:44 PM, Gregory Haskins wrote:
>> The problem isn't where to find the models...the problem is how to
>> aggregate multiple models to the guest.
>>   =20
>=20
> You mean configuration?
>=20
>>> You instantiate multiple vhost-nets.  Multiple ethernet NICs is a
>>> supported configuration for kvm.
>>>     =20
>> But this is not KVM.
>>
>>   =20
>=20
> If kvm can do it, others can.

The problem is that you seem to either hand-wave over details like this,
or you give details that are pretty much exactly what vbus does already.
 My point is that I've already sat down and thought about these issues
and solved them in a freely available GPL'ed software package.

So the question is: is your position that vbus is all wrong and you wish
to create a new bus-like thing to solve the problem?  If so, how is it
different from what Ive already done?  More importantly, what specific
objections do you have to what Ive done, as perhaps they can be fixed
instead of starting over?

>=20
>>>> His slave boards surface themselves as PCI devices to the x86
>>>> host.  So how do you use that to make multiple vhost-based devices (=
say
>>>> two virtio-nets, and a virtio-console) communicate across the
>>>> transport?
>>>>
>>>>       =20
>>> I don't really see the difference between 1 and N here.
>>>     =20
>> A KVM surfaces N virtio-devices as N pci-devices to the guest.  What d=
o
>> we do in Ira's case where the entire guest represents itself as a PCI
>> device to the host, and nothing the other way around?
>>   =20
>=20
> There is no guest and host in this scenario.  There's a device side
> (ppc) and a driver side (x86).  The driver side can access configuratio=
n
> information on the device side.  How to multiplex multiple devices is a=
n
> interesting exercise for whoever writes the virtio binding for that set=
up.

Bingo.  So now its a question of do you want to write this layer from
scratch, or re-use my framework.

>=20
>>>> There are multiple ways to do this, but what I am saying is that
>>>> whatever is conceived will start to look eerily like a vbus-connecto=
r,
>>>> since this is one of its primary purposes ;)
>>>>
>>>>       =20
>>> I'm not sure if you're talking about the configuration interface or d=
ata
>>> path here.
>>>     =20
>> I am talking about how we would tunnel the config space for N devices
>> across his transport.
>>   =20
>=20
> Sounds trivial.

No one said it was rocket science.  But it does need to be designed and
implemented end-to-end, much of which Ive already done in what I hope is
an extensible way.

>  Write an address containing the device number and
> register number to on location, read or write data from another.

You mean like the "u64 devh", and "u32 func" fields I have here for the
vbus-kvm connector?

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Dinclude/linux/vbus_pci.h;h=3Dfe337590e644017392e4c9d9=
236150adb2333729;hb=3Dded8ce2005a85c174ba93ee26f8d67049ef11025#l64

> Just
> like the PCI cf8/cfc interface.
>=20
>>> They aren't in the "guest".  The best way to look at it is
>>>
>>> - a device side, with a dma engine: vhost-net
>>> - a driver side, only accessing its own memory: virtio-net
>>>
>>> Given that Ira's config has the dma engine in the ppc boards, that's
>>> where vhost-net would live (the ppc boards acting as NICs to the x86
>>> board, essentially).
>>>     =20
>> That sounds convenient given his hardware, but it has its own set of
>> problems.  For one, the configuration/inventory of these boards is now=

>> driven by the wrong side and has to be addressed.
>=20
> Why is it the wrong side?

"Wrong" is probably too harsh a word when looking at ethernet.  Its
certainly "odd", and possibly inconvenient.  It would be like having
vhost in a KVM guest, and virtio-net running on the host.  You could do
it, but its weird and awkward.  Where it really falls apart and enters
the "wrong" category is for non-symmetric devices, like disk-io.

>=20
>> Second, the role
>> reversal will likely not work for many models other than ethernet (e.g=
=2E
>> virtio-console or virtio-blk drivers running on the x86 board would be=

>> naturally consuming services from the slave boards...virtio-net is an
>> exception because 802.x is generally symmetrical).
>>   =20
>=20
> There is no role reversal.

So if I have virtio-blk driver running on the x86 and vhost-blk device
running on the ppc board, I can use the ppc board as a block-device.
What if I really wanted to go the other way?

> The side doing dma is the device, the side
> accessing its own memory is the driver.  Just like that other 1e12
> driver/device pairs out there.

IIUC, his ppc boards really can be seen as "guests" (they are linux
instances that are utilizing services from the x86, not the other way
around).  vhost forces the model to have the ppc boards act as IO-hosts,
whereas vbus would likely work in either direction due to its more
refined abstraction layer.

>=20
>>> I have no idea, that's for Ira to solve.
>>>     =20
>> Bingo.  Thus my statement that the vhost proposal is incomplete.  You
>> have the virtio-net and vhost-net pieces covering the fast-path
>> end-points, but nothing in the middle (transport, aggregation,
>> config-space), and nothing on the management-side.  vbus provides most=

>> of the other pieces, and can even support the same virtio-net protocol=

>> on top.  The remaining part would be something like a udev script to
>> populate the vbus with devices on board-insert events.
>>   =20
>=20
> Of course vhost is incomplete, in the same sense that Linux is
> incomplete.  Both require userspace.

A vhost based solution to Iras design is missing more than userspace.
Many of those gaps are addressed by a vbus based solution.

>=20
>>> If he could fake the PCI
>>> config space as seen by the x86 board, he would just show the normal =
pci
>>> config and use virtio-pci (multiple channels would show up as a
>>> multifunction device).  Given he can't, he needs to tunnel the virtio=

>>> config space some other way.
>>>     =20
>> Right, and note that vbus was designed to solve this.  This tunneling
>> can, of course, be done without vbus using some other design.  However=
,
>> whatever solution is created will look incredibly close to what I've
>> already done, so my point is "why reinvent it"?
>>   =20
>=20
> virtio requires binding for this tunnelling, so does vbus.

We aren't talking about virtio.  Virtio would work with either vbus or
vhost.  This is purely a question of what the layers below virtio and
the device backend looks like.

>  Its the same problem with the same solution.

I disagree.

Kind Regards,
-Greg



--------------enig96A6E6B1F5308E397068EC7E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqw8e8ACgkQP5K2CMvXmqE+cwCfVWx10aAmZSOf8h+AHJ+349hq
1j8An0MQ1dT//bW4eUIdHLNrS/qwwEil
=TYzE
-----END PGP SIGNATURE-----

--------------enig96A6E6B1F5308E397068EC7E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

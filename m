Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BA80F6B005C
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:12:03 -0400 (EDT)
Received: by qyk40 with SMTP id 40so4759283qyk.8
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 20:12:05 -0700 (PDT)
Message-ID: <4AB1A8FD.2010805@gmail.com>
Date: Wed, 16 Sep 2009 23:11:57 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com>
In-Reply-To: <4AB151D7.10402@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig92A1482E6A3735B2BC3814F5"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig92A1482E6A3735B2BC3814F5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/16/2009 10:22 PM, Gregory Haskins wrote:
>> Avi Kivity wrote:
>>  =20
>>> On 09/16/2009 05:10 PM, Gregory Haskins wrote:
>>>    =20
>>>>> If kvm can do it, others can.
>>>>>
>>>>>         =20
>>>> The problem is that you seem to either hand-wave over details like
>>>> this,
>>>> or you give details that are pretty much exactly what vbus does
>>>> already.
>>>>    My point is that I've already sat down and thought about these
>>>> issues
>>>> and solved them in a freely available GPL'ed software package.
>>>>
>>>>       =20
>>> In the kernel.  IMO that's the wrong place for it.
>>>     =20
>> 3) "in-kernel": You can do something like virtio-net to vhost to
>> potentially meet some of the requirements, but not all.
>>
>> In order to fully meet (3), you would need to do some of that stuff yo=
u
>> mentioned in the last reply with muxing device-nr/reg-nr.  In addition=
,
>> we need to have a facility for mapping eventfds and establishing a
>> signaling mechanism (like PIO+qid), etc. KVM does this with
>> IRQFD/IOEVENTFD, but we dont have KVM in this case so it needs to be
>> invented.
>>   =20
>=20
> irqfd/eventfd is the abstraction layer, it doesn't need to be reabstrac=
ted.

Not per se, but it needs to be interfaced.  How do I register that
eventfd with the fastpath in Ira's rig? How do I signal the eventfd
(x86->ppc, and ppc->x86)?

To take it to the next level, how do I organize that mechanism so that
it works for more than one IO-stream (e.g. address the various queues
within ethernet or a different device like the console)?  KVM has
IOEVENTFD and IRQFD managed with MSI and PIO.  This new rig does not
have the luxury of an established IO paradigm.

Is vbus the only way to implement a solution?  No.  But it is _a_ way,
and its one that was specifically designed to solve this very problem
(as well as others).

(As an aside, note that you generally will want an abstraction on top of
irqfd/eventfd like shm-signal or virtqueues to do shared-memory based
event mitigation, but I digress.  That is a separate topic).

>=20
>> To meet performance, this stuff has to be in kernel and there has to b=
e
>> a way to manage it.
>=20
> and management belongs in userspace.

vbus does not dictate where the management must be.  Its an extensible
framework, governed by what you plug into it (ala connectors and devices)=
=2E

For instance, the vbus-kvm connector in alacrityvm chooses to put DEVADD
and DEVDROP hotswap events into the interrupt stream, because they are
simple and we already needed the interrupt stream anyway for fast-path.

As another example: venet chose to put ->call(MACQUERY) "config-space"
into its call namespace because its simple, and we already need
->calls() for fastpath.  It therefore exports an attribute to sysfs that
allows the management app to set it.

I could likewise have designed the connector or device-model differently
as to keep the mac-address and hotswap-events somewhere else (QEMU/PCI
userspace) but this seems silly to me when they are so trivial, so I didn=
't.

>=20
>> Since vbus was designed to do exactly that, this is
>> what I would advocate.  You could also reinvent these concepts and put=

>> your own mux and mapping code in place, in addition to all the other
>> stuff that vbus does.  But I am not clear why anyone would want to.
>>   =20
>=20
> Maybe they like their backward compatibility and Windows support.

This is really not relevant to this thread, since we are talking about
Ira's hardware.  But if you must bring this up, then I will reiterate
that you just design the connector to interface with QEMU+PCI and you
have that too if that was important to you.

But on that topic: Since you could consider KVM a "motherboard
manufacturer" of sorts (it just happens to be virtual hardware), I don't
know why KVM seems to consider itself the only motherboard manufacturer
in the world that has to make everything look legacy.  If a company like
ASUS wants to add some cutting edge IO controller/bus, they simply do
it.  Pretty much every product release may contain a different array of
devices, many of which are not backwards compatible with any prior
silicon.  The guy/gal installing Windows on that system may see a "?" in
device-manager until they load a driver that supports the new chip, and
subsequently it works.  It is certainly not a requirement to make said
chip somehow work with existing drivers/facilities on bare metal, per
se.  Why should virtual systems be different?

So, yeah, the current design of the vbus-kvm connector means I have to
provide a driver.  This is understood, and I have no problem with that.

The only thing that I would agree has to be backwards compatible is the
BIOS/boot function.  If you can't support running an image like the
Windows installer, you are hosed.  If you can't use your ethernet until
you get a chance to install a driver after the install completes, its
just like most other systems in existence.  IOW: It's not a big deal.

For cases where the IO system is needed as part of the boot/install, you
provide BIOS and/or an install-disk support for it.

>=20
>> So no, the kernel is not the wrong place for it.  Its the _only_ place=

>> for it.  Otherwise, just use (1) and be done with it.
>>
>>   =20
>=20
> I'm talking about the config stuff, not the data path.

As stated above, where config stuff lives is a function of what you
interface to vbus.  Data-path stuff must be in the kernel for
performance reasons, and this is what I was referring to.  I think we
are generally both in agreement, here.

What I was getting at is that you can't just hand-wave the datapath
stuff.  We do fast path in KVM with IRQFD/IOEVENTFD+PIO, and we do
device discovery/addressing with PCI.  Neither of those are available
here in Ira's case yet the general concepts are needed.  Therefore, we
have to come up with something else.

>=20
>>>   Further, if we adopt
>>> vbus, if drop compatibility with existing guests or have to support b=
oth
>>> vbus and virtio-pci.
>>>     =20
>> We already need to support both (at least to support Ira).  virtio-pci=

>> doesn't work here.  Something else (vbus, or vbus-like) is needed.
>>   =20
>=20
> virtio-ira.

Sure, virtio-ira and he is on his own to make a bus-model under that, or
virtio-vbus + vbus-ira-connector to use the vbus framework.  Either
model can work, I agree.

>=20
>>>> So the question is: is your position that vbus is all wrong and you
>>>> wish
>>>> to create a new bus-like thing to solve the problem?
>>>>       =20
>>> I don't intend to create anything new, I am satisfied with virtio.  I=
f
>>> it works for Ira, excellent.  If not, too bad.
>>>     =20
>> I think that about sums it up, then.
>>   =20
>=20
> Yes.  I'm all for reusing virtio, but I'm not going switch to vbus or
> support both for this esoteric use case.

With all due respect, no one asked you to.  This sub-thread was
originally about using vhost in Ira's rig.  When problems surfaced in
that proposed model, I highlighted that I had already addressed that
problem in vbus, and here we are.

>=20
>>>> If so, how is it
>>>> different from what Ive already done?  More importantly, what specif=
ic
>>>> objections do you have to what Ive done, as perhaps they can be fixe=
d
>>>> instead of starting over?
>>>>
>>>>       =20
>>> The two biggest objections are:
>>> - the host side is in the kernel
>>>     =20
>> As it needs to be.
>>   =20
>=20
> vhost-net somehow manages to work without the config stuff in the kerne=
l.

I was referring to data-path stuff, like signal and memory
configuration/routing.

As an aside, it should be noted that vhost under KVM has
IRQFD/IOEVENTFD, PCI-emulation, QEMU, etc to complement it and fill in
some of the pieces one needs for a complete solution.  Not all
environments have all of those pieces (nor should they), and those
pieces need to come from somewhere.

It should also be noted that what remains (config/management) after the
data-path stuff is laid out is actually quite simple.  It consists of
pretty much an enumerated list of device-ids within a container,
DEVADD(id), DEVDROP(id) events, and some sysfs attributes as defined on
a per-device basis (many of which are often needed regardless of whether
the "config-space" operation is handled in-kernel or not)

Therefore, the configuration aspect of the system does not necessitate a
complicated (e.g. full PCI emulation) or external (e.g. userspace)
component per se.  The parts of vbus that could be construed as
"management" are (afaict) built using accepted/best-practices for
managing arbitrary kernel subsystems (sysfs, configfs, ioctls, etc) so
there is nothing new or reasonably controversial there.  It is for this
reason that I think the objection to "in-kernel config" is unfounded.

Disagreements on this point may be settled by the connector design,
while still utilizing vbus, and thus retaining most of the other
benefits of using the vbus framework.  The connector ultimately dictates
how and what is exposed to the "guest".

>=20
>> With all due respect, based on all of your comments in aggregate I
>> really do not think you are truly grasping what I am actually building=

>> here.
>>   =20
>=20
> Thanks.
>=20
>=20
>=20
>>>> Bingo.  So now its a question of do you want to write this layer fro=
m
>>>> scratch, or re-use my framework.
>>>>
>>>>       =20
>>> You will have to implement a connector or whatever for vbus as well.
>>> vbus has more layers so it's probably smaller for vbus.
>>>     =20
>> Bingo!
>=20
> (addictive, isn't it)

Apparently.

>=20
>> That is precisely the point.
>>
>> All the stuff for how to map eventfds, handle signal mitigation, demux=

>> device/function pointers, isolation, etc, are built in.  All the
>> connector has to do is transport the 4-6 verbs and provide a memory
>> mapping/copy function, and the rest is reusable.  The device models
>> would then work in all environments unmodified, and likewise the
>> connectors could use all device-models unmodified.
>>   =20
>=20
> Well, virtio has a similar abstraction on the guest side.  The host sid=
e
> abstraction is limited to signalling since all configuration is in
> userspace.  vhost-net ought to work for lguest and s390 without change.=


But IIUC that is primarily because the revectoring work is already in
QEMU for virtio-u and it rides on that, right?  Not knocking that, thats
nice and a distinct advantage.  It should just be noted that its based
on sunk-cost, and not truly free.  Its just already paid for, which is
different.  It also means it only works in environments based on QEMU,
which not all are (as evident by this sub-thread).

>=20
>>> It was already implemented three times for virtio, so apparently that=
's
>>> extensible too.
>>>     =20
>> And to my point, I'm trying to commoditize as much of that process as
>> possible on both the front and backends (at least for cases where
>> performance matters) so that you don't need to reinvent the wheel for
>> each one.
>>   =20
>=20
> Since you're interested in any-to-any connectors it makes sense to you.=
=20
> I'm only interested in kvm-host-to-kvm-guest, so reducing the already
> minor effort to implement a new virtio binding has little appeal to me.=

>=20

Fair enough.

>>> You mean, if the x86 board was able to access the disks and dma into =
the
>>> ppb boards memory?  You'd run vhost-blk on x86 and virtio-net on ppc.=

>>>     =20
>> But as we discussed, vhost doesn't work well if you try to run it on t=
he
>> x86 side due to its assumptions about pagable "guest" memory, right?  =
So
>> is that even an option?  And even still, you would still need to solve=

>> the aggregation problem so that multiple devices can coexist.
>>   =20
>=20
> I don't know.  Maybe it can be made to work and maybe it cannot.  It
> probably can with some determined hacking.
>=20

I guess you can say the same for any of the solutions.

Kind Regards,
-Greg


--------------enig92A1482E6A3735B2BC3814F5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqxqP0ACgkQP5K2CMvXmqG16gCfcsvkD+VHHlMU0i6nww4kc3kv
AhMAn2FLhwcAbqikOLwUXd9qdJVuv9Vn
=fPvh
-----END PGP SIGNATURE-----

--------------enig92A1482E6A3735B2BC3814F5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F0B46B0055
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 17:15:09 -0400 (EDT)
Received: by qyk10 with SMTP id 10so934865qyk.12
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 14:15:12 -0700 (PDT)
Message-ID: <4ABA8FDC.5010008@gmail.com>
Date: Wed, 23 Sep 2009 17:15:08 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com>
In-Reply-To: <4ABA78DC.7070604@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBB15392F7D96A8C0DF803714"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBB15392F7D96A8C0DF803714
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/23/2009 08:58 PM, Gregory Haskins wrote:
>>>
>>>> It also pulls parts of the device model into the host kernel.
>>>>       =20
>>> That is the point.  Most of it needs to be there for performance.
>>>     =20
>> To clarify this point:
>>
>> There are various aspects about designing high-performance virtual
>> devices such as providing the shortest paths possible between the
>> physical resources and the consumers.  Conversely, we also need to
>> ensure that we meet proper isolation/protection guarantees at the same=

>> time.  What this means is there are various aspects to any
>> high-performance PV design that require to be placed in-kernel to
>> maximize the performance yet properly isolate the guest.
>>
>> For instance, you are required to have your signal-path (interrupts an=
d
>> hypercalls), your memory-path (gpa translation), and
>> addressing/isolation model in-kernel to maximize performance.
>>   =20
>=20
> Exactly.  That's what vhost puts into the kernel and nothing more.

Actually, no.  Generally, _KVM_ puts those things into the kernel, and
vhost consumes them.  Without KVM (or something equivalent), vhost is
incomplete.  One of my goals with vbus is to generalize the "something
equivalent" part here.

I know you may not care about non-kvm use cases, and thats fine.  No one
says you have to.  However, note that some of use do care about these
non-kvm cases, and thus its a distinction I am making here as a benefit
of the vbus framework.

>=20
>> Vbus accomplishes its in-kernel isolation model by providing a
>> "container" concept, where objects are placed into this container by
>> userspace.  The host kernel enforces isolation/protection by using a
>> namespace to identify objects that is only relevant within a specific
>> container's context (namely, a "u32 dev-id").  The guest addresses the=

>> objects by its dev-id, and the kernel ensures that the guest can't
>> access objects outside of its dev-id namespace.
>>   =20
>=20
> vhost manages to accomplish this without any kernel support.

No, vhost manages to accomplish this because of KVMs kernel support
(ioeventfd, etc).   Without a KVM-like in-kernel support, vhost is a
merely a kind of "tuntap"-like clone signalled by eventfds.

vbus on the other hand, generalizes one more piece of the puzzle
(namely, the function of pio+ioeventfd and userspace's programming of
it) by presenting the devid namespace and container concept.

This goes directly to my rebuttal of your claim that vbus places too
much in the kernel.  I state that, one way or the other, address decode
and isolation _must_ be in the kernel for performance.  Vbus does this
with a devid/container scheme.  vhost+virtio-pci+kvm does it with
pci+pio+ioeventfd.


>  The guest
> simply has not access to any vhost resources other than the guest->host=

> doorbell, which is handed to the guest outside vhost (so it's somebody
> else's problem, in userspace).

You mean _controlled_ by userspace, right?  Obviously, the other side of
the kernel still needs to be programmed (ioeventfd, etc).  Otherwise,
vhost would be pointless: e.g. just use vanilla tuntap if you don't need
fast in-kernel decoding.

>=20
>> All that is required is a way to transport a message with a "devid"
>> attribute as an address (such as DEVCALL(devid)) and the framework
>> provides the rest of the decode+execute function.
>>   =20
>=20
> vhost avoids that.

No, it doesn't avoid it.  It just doesn't specify how its done, and
relies on something else to do it on its behalf.

Conversely, vbus specifies how its done, but not how to transport the
verb "across the wire".  That is the role of the vbus-connector abstracti=
on.

>=20
>> Contrast this to vhost+virtio-pci (called simply "vhost" from here).
>>   =20
>=20
> It's the wrong name.  vhost implements only the data path.

Understood, but vhost+virtio-pci is what I am contrasting, and I use
"vhost" for short from that point on because I am too lazy to type the
whole name over and over ;)

>=20
>> It is not immune to requiring in-kernel addressing support either, but=

>> rather it just does it differently (and its not as you might expect vi=
a
>> qemu).
>>
>> Vhost relies on QEMU to render PCI objects to the guest, which the gue=
st
>> assigns resources (such as BARs, interrupts, etc).
>=20
> vhost does not rely on qemu.  It relies on its user to handle
> configuration.  In one important case it's qemu+pci.  It could just as
> well be the lguest launcher.

I meant vhost=3Dvhost+virtio-pci here.  Sorry for the confusion.

The point I am making specifically is that vhost in general relies on
other in-kernel components to function.  I.e. It cannot function without
having something like the PCI model to build an IO namespace.  That
namespace (in this case, pio addresses+data tuples) are used for the
in-kernel addressing function under KVM + virtio-pci.

The case of the lguest launcher is a good one to highlight.  Yes, you
can presumably also use lguest with vhost, if the requisite facilities
are exposed to lguest-bus, and some eventfd based thing like ioeventfd
is written for the host (if it doesnt exist already).

And when the next virt design "foo" comes out, it can make a "foo-bus"
model, and implement foo-eventfd on the backend, etc, etc.

Ira can make ira-bus, and ira-eventfd, etc, etc.

Each iteration will invariably introduce duplicated parts of the stack.
 Vbus tries to generalize some of those pieces so we can reuse them.

I chose the very non-specific name "virtual-bus" for the design
intentionally to decouple it from any one particular "hypervisor" (e.g.
xenbus, lguest-bus, etc) and promote it as a general purpose bus for
hopefully any hypervisor (or physical systems too, e.g. Iras).  I assume
"virtio" was chosen to reflect a similar positioning at the device-model
layer.

Had vbus come out before lguest, I would have proposed that lguest
should use it natively instead of creating lguest-bus.  While its
probably too late in that specific case, perhaps going forward this is
the direction we can take, just like perhaps virtio is the device model
direction we can take.

Likewise, the backend is generalized so one model can be written that
works in all environments that support vbus.  The connector takes care
of the "wire" details, and the other stuff functions to serve the bus
portion of the stack (signal-routing, memory-routing,
isolation/addressing, etc).

>=20
>>    A PCI-BAR in this
>> example may represent a PIO address for triggering some operation in t=
he
>> device-model's fast-path.  For it to have meaning in the fast-path, KV=
M
>> has to have in-kernel knowledge of what a PIO-exit is, and what to do
>> with it (this is where pio-bus and ioeventfd come in).  The programmin=
g
>> of the PIO-exit and the ioeventfd are likewise controlled by some
>> userspace management entity (i.e. qemu).   The PIO address and value
>> tuple form the address, and the ioeventfd framework within KVM provide=

>> the decode+execute function.
>>   =20
>=20
> Right.
>=20
>> This idea seemingly works fine, mind you, but it rides on top of a *lo=
t*
>> of stuff including but not limited to: the guests pci stack, the qemu
>> pci emulation, kvm pio support, and ioeventfd.  When you get into
>> situations where you don't have PCI or even KVM underneath you (e.g. a=

>> userspace container, Ira's rig, etc) trying to recreate all of that PC=
I
>> infrastructure for the sake of using PCI is, IMO, a lot of overhead fo=
r
>> little gain.
>>   =20
>=20
> For the N+1th time, no.  vhost is perfectly usable without pci.  Can we=

> stop raising and debunking this point?

Again, I understand vhost is decoupled from PCI, and I don't mean to
imply anything different.  I use PCI as an example here because a) its
the only working example of vhost today (to my knowledge), and b) you
have stated in the past that PCI is the only "right" way here, to
paraphrase.  Perhaps you no longer feel that way, so I apologize if you
feel you already recanted your position on PCI and I missed it.

I digress.  My point here isn't PCI.  The point here is the missing
component for when PCI is not present.  The component that is partially
satisfied by vbus's devid addressing scheme.  If you are going to use
vhost, and you don't have PCI, you've gotta build something to replace it=
=2E


>=20
>> All you really need is a simple decode+execute mechanism, and a way to=

>> program it from userspace control.  vbus tries to do just that:
>> commoditize it so all you need is the transport of the control message=
s
>> (like DEVCALL()), but the decode+execute itself is reuseable, even
>> across various environments (like KVM or Iras rig).
>>   =20
>=20
> If you think it should be "commodotized", write libvhostconfig.so.

I know you are probably being facetious here, but what do you propose
for the parts that must be in-kernel?

>=20
>> And your argument, I believe, is that vbus allows both to be implement=
ed
>> in the kernel (though to reiterate, its optional) and is therefore a b=
ad
>> design, so lets discuss that.
>>
>> I believe the assertion is that things like config-space are best left=

>> to userspace, and we should only relegate fast-path duties to the
>> kernel.  The problem is that, in my experience, a good deal of
>> config-space actually influences the fast-path and thus needs to
>> interact with the fast-path mechanism eventually anyway.
>> Whats left
>> over that doesn't fall into this category may cheaply ride on existing=

>> plumbing, so its not like we created something new or unnatural just t=
o
>> support this subclass of config-space.
>>   =20
>=20
> Flexibility is reduced, because changing code in the kernel is more
> expensive than in userspace, and kernel/user interfaces aren't typicall=
y
> as wide as pure userspace interfaces.  Security is reduced, since a bug=

> in the kernel affects the host, while a bug in userspace affects just o=
n
> guest.

For a mac-address attribute?  Thats all we are really talking about
here.  These points you raise, while true of any kernel code I suppose,
are a bit of a stretch in this context.

>=20
> Example: feature negotiation.  If it happens in userspace, it's easy to=

> limit what features we expose to the guest.

Its not any harder in the kernel.  I do this today.

And when you are done negotiating said features, you will generally have
to turn around and program the feature into the backend anyway (e.g.
ioctl() to vhost module).  Now you have to maintain some knowledge of
that particular feature and how to program it in two places.

Conversely, I am eliminating the (unnecessary) middleman by letting the
feature negotiating take place directly between the two entities that
will consume it.


>  If it happens in the
> kernel, we need to add an interface to let the kernel know which
> features it should expose to the guest.

You need this already either way for both models anyway.  As an added
bonus, vbus has generalized that interface using sysfs attributes, so
all models are handled in a similar and community accepted way.

>  We also need to add an
> interface to let userspace know which features were negotiated, if we
> want to implement live migration.  Something fairly trivial bloats rapi=
dly.

Can you elaborate on the requirements for live-migration?  Wouldnt an
opaque save/restore model work here? (e.g. why does userspace need to be
able to interpret the in-kernel state, just pass it along as a blob to
the new instance).

>=20
>> For example: take an attribute like the mac-address assigned to a NIC.=

>> This clearly doesn't need to be in-kernel and could go either way (suc=
h
>> as a PCI config-space register).
>>
>> As another example: consider an option bit that enables a new feature
>> that affects the fast-path, like RXBUF merging.  If we use the split
>> model where config space is handled by userspace and fast-path is
>> in-kernel, the userspace component is only going to act as a proxy.
>> I.e. it will pass the option down to the kernel eventually.  Therefore=
,
>> there is little gain in trying to split this type of slow-path out to
>> userspace.  In fact, its more work.
>>   =20
>=20
> As you can see above, userspace needs to be involved in this, and the
> number of interfaces required is smaller if it's in userspace:

Actually, no.  My experience has been the opposite.  Anytime I sat down
and tried to satisfy your request to move things to the userspace,
things got ugly and duplicative really quick.  I suspect part of the
reason you may think its easier because you already have part of
virtio-net in userspace and its surrounding support, but that is not the
case moving forward for new device types.

> you only
> need to know which features the kernel supports (they can be enabled
> unconditionally, just not exposed).
>=20
> Further, some devices are perfectly happy to be implemented in
> userspace, so we need userspace configuration support anyway.  Why
> reimplement it in the kernel?

Thats fine.  vbus is targetted for high-performance IO.  So if you have
a robust userspace (like KVM+QEMU) and low-performance constraints (say,
for a console or something), put it in userspace and vbus is not
involved.  I don't care.

However, if you are coming from somewhere else (like Ira's rig) where
you don't necessarily have a robust userspace module, vbus provides a
model that allows you to chose whether you want to do a vhost like
model, or a full resource container with the isolation guarantees, etc,
built in.

Kind Regards,
-Greg


--------------enigBB15392F7D96A8C0DF803714
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkq6j9wACgkQP5K2CMvXmqGnqwCfTCsI6qb4MQmdBbZu5wclNpqR
/SMAn1/moNtysUXULQZf7L4ym/5TkM5O
=LyfR
-----END PGP SIGNATURE-----

--------------enigBB15392F7D96A8C0DF803714--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

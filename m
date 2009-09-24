Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 442646B005A
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 14:03:34 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1535814bwz.38
        for <linux-mm@kvack.org>; Thu, 24 Sep 2009 11:03:31 -0700 (PDT)
Message-ID: <4ABBB46D.2000102@gmail.com>
Date: Thu, 24 Sep 2009 14:03:25 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com>
In-Reply-To: <4ABB1D44.5000007@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig618B4EF311E91BDA38250403"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig618B4EF311E91BDA38250403
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/24/2009 12:15 AM, Gregory Haskins wrote:
>>
>>>> There are various aspects about designing high-performance virtual
>>>> devices such as providing the shortest paths possible between the
>>>> physical resources and the consumers.  Conversely, we also need to
>>>> ensure that we meet proper isolation/protection guarantees at the sa=
me
>>>> time.  What this means is there are various aspects to any
>>>> high-performance PV design that require to be placed in-kernel to
>>>> maximize the performance yet properly isolate the guest.
>>>>
>>>> For instance, you are required to have your signal-path (interrupts =
and
>>>> hypercalls), your memory-path (gpa translation), and
>>>> addressing/isolation model in-kernel to maximize performance.
>>>>
>>>>       =20
>>> Exactly.  That's what vhost puts into the kernel and nothing more.
>>>     =20
>> Actually, no.  Generally, _KVM_ puts those things into the kernel, and=

>> vhost consumes them.  Without KVM (or something equivalent), vhost is
>> incomplete.  One of my goals with vbus is to generalize the "something=

>> equivalent" part here.
>>   =20
>=20
> I don't really see how vhost and vbus are different here.  vhost expect=
s
> signalling to happen through a couple of eventfds and requires someone
> to supply them and implement kernel support (if needed).  vbus requires=

> someone to write a connector to provide the signalling implementation. =

> Neither will work out-of-the-box when implementing virtio-net over
> falling dominos, for example.

I realize in retrospect that my choice of words above implies vbus _is_
complete, but this is not what I was saying.  What I was trying to
convey is that vbus is _more_ complete.  Yes, in either case some kind
of glue needs to be written.  The difference is that vbus implements
more of the glue generally, and leaves less required to be customized
for each iteration.

Going back to our stack diagrams, you could think of a vhost solution
like this:

--------------------------
| virtio-net
--------------------------
| virtio-ring
--------------------------
| virtio-bus
--------------------------
| ? undefined-1 ?
--------------------------
| vhost
--------------------------

and you could think of a vbus solution like this

--------------------------
| virtio-net
--------------------------
| virtio-ring
--------------------------
| virtio-bus
--------------------------
| bus-interface
--------------------------
| ? undefined-2 ?
--------------------------
| bus-model
--------------------------
| virtio-net-device (vhost ported to vbus model? :)
--------------------------


So the difference between vhost and vbus in this particular context is
that you need to have "undefined-1" do device discovery/hotswap,
config-space, address-decode/isolation, signal-path routing, memory-path
routing, etc.  Today this function is filled by things like virtio-pci,
pci-bus, KVM/ioeventfd, and QEMU for x86.  I am not as familiar with
lguest, but presumably it is filled there by components like
virtio-lguest, lguest-bus, lguest.ko, and lguest-launcher.  And to use
more contemporary examples, we might have virtio-domino, domino-bus,
domino.ko, and domino-launcher as well as virtio-ira, ira-bus, ira.ko,
and ira-launcher.

Contrast this to the vbus stack:  The bus-X components (when optionally
employed by the connector designer) do device-discovery, hotswap,
config-space, address-decode/isolation, signal-path and memory-path
routing, etc in a general (and pv-centric) way. The "undefined-2"
portion is the "connector", and just needs to convey messages like
"DEVCALL" and "SHMSIGNAL".  The rest is handled in other parts of the sta=
ck.

So to answer your question, the difference is that the part that has to
be customized in vbus should be a fraction of what needs to be
customized with vhost because it defines more of the stack.  And, as
eluded to in my diagram, both virtio-net and vhost (with some
modifications to fit into the vbus framework) are potentially
complementary, not competitors.

>=20
>>>> Vbus accomplishes its in-kernel isolation model by providing a
>>>> "container" concept, where objects are placed into this container by=

>>>> userspace.  The host kernel enforces isolation/protection by using a=

>>>> namespace to identify objects that is only relevant within a specifi=
c
>>>> container's context (namely, a "u32 dev-id").  The guest addresses t=
he
>>>> objects by its dev-id, and the kernel ensures that the guest can't
>>>> access objects outside of its dev-id namespace.
>>>>
>>>>       =20
>>> vhost manages to accomplish this without any kernel support.
>>>     =20
>> No, vhost manages to accomplish this because of KVMs kernel support
>> (ioeventfd, etc).   Without a KVM-like in-kernel support, vhost is a
>> merely a kind of "tuntap"-like clone signalled by eventfds.
>>   =20
>=20
> Without a vbus-connector-falling-dominos, vbus-venet can't do anything
> either.

Mostly covered above...

However, I was addressing your assertion that vhost somehow magically
accomplishes this "container/addressing" function without any specific
kernel support.  This is incorrect.  I contend that this kernel support
is required and present.  The difference is that its defined elsewhere
(and typically in a transport/arch specific way).

IOW: You can basically think of the programmed PIO addresses as forming
its "container".  Only addresses explicitly added are visible, and
everything else is inaccessible.  This whole discussion is merely a
question of what's been generalized verses what needs to be
re-implemented each time.


> Both vhost and vbus need an interface,

Agreed

> vhost's is just narrower since it doesn't do configuration or enumerati=
on.

I would say that makes vhost solution's interface wider, not narrower.
With the vbus kvm-connector, simple vbus device instantiation implicitly
registers it in the address/enumeration namespace, and transmits a
devadd event.  It does all that with no more interface complexity than
instantiating a vhost device.  However, vhost has to then also
separately configure its address/enumeration space with other subsystems
(e.g. pci, ioeventfd, msi, etc), and define its config-space twice.

This means something in userspace has to proxy and/or refactor requests.
 This also means that the userspace component has to have some knowledge
of _how_ to proxy/refactor said requests (i.e. splitting the design),
which is another example of where the current vhost model really falls
apart IMO.

>=20
>> This goes directly to my rebuttal of your claim that vbus places too
>> much in the kernel.  I state that, one way or the other, address decod=
e
>> and isolation _must_ be in the kernel for performance.  Vbus does this=

>> with a devid/container scheme.  vhost+virtio-pci+kvm does it with
>> pci+pio+ioeventfd.
>>   =20
>=20
> vbus doesn't do kvm guest address decoding for the fast path.  It's
> still done by ioeventfd.

That is not correct.  vbus does its own native address decoding in the
fast path, such as here:

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Dkernel/vbus/client.c;h=3De85b2d92d629734866496b67455d=
d307486e394a;hb=3De6cbd4d1decca8e829db3b2b9b6ec65330b379e9#l331

The connector delivers a SHMSIGNAL(id) message, and its decoded
generically by an rcu protected radix tree.

I think what you are thinking of is that my KVM-connector in AlacrityVM
uses PIO/ioeventfd (*) as part of its transport to deliver that
SHMSIGNAL message.  In this sense, I am doing two address-decodes (one
for the initial pio, one for the subsequent shmsignal), but this is an
implementation detail of the KVM connector.

(Also note that its an implementation detail that the KVM maintainer
forced me into ;)  The original vbus design utilized a global hypercall
in place of the PIO, and thus the shmsignal was the only real decode
occurring)

(*) actually I dropped ioeventfd in my latest tree, but this is a
separate topic.  I still use KVM's pio-bus, however.

>=20
>>>   The guest
>>> simply has not access to any vhost resources other than the guest->ho=
st
>>> doorbell, which is handed to the guest outside vhost (so it's somebod=
y
>>> else's problem, in userspace).
>>>     =20
>> You mean _controlled_ by userspace, right?  Obviously, the other side =
of
>> the kernel still needs to be programmed (ioeventfd, etc).  Otherwise,
>> vhost would be pointless: e.g. just use vanilla tuntap if you don't ne=
ed
>> fast in-kernel decoding.
>>   =20
>=20
> Yes (though for something like level-triggered interrupts we're probabl=
y
> keeping it in userspace, enjoying the benefits of vhost data path while=

> paying more for signalling).

Thats fine.  I am primarily interested in the high-performance IO, so
low-perf/legacy components can fall back to something else like
userspace if that best serves them.

>=20
>>>> All that is required is a way to transport a message with a "devid"
>>>> attribute as an address (such as DEVCALL(devid)) and the framework
>>>> provides the rest of the decode+execute function.
>>>>
>>>>       =20
>>> vhost avoids that.
>>>     =20
>> No, it doesn't avoid it.  It just doesn't specify how its done, and
>> relies on something else to do it on its behalf.
>>   =20
>=20
> That someone else can be in userspace, apart from the actual fast path.=


No, this "devcall" like decoding _is_ fast path and it can't be in
userspace if you care about performance.  And if you don't care about
performance, you can use existing facilities (like QEMU+tuntap) so vhost
and vbus alike would become unnecessary in that scenario.

>=20
>> Conversely, vbus specifies how its done, but not how to transport the
>> verb "across the wire".  That is the role of the vbus-connector
>> abstraction.
>>   =20
>=20
> So again, vbus does everything in the kernel (since it's so easy and
> cheap) but expects a vbus-connector.  vhost does configuration in
> userspace (since it's so clunky and fragile) but expects a couple of
> eventfds.

Well, we are talking about fast-path here, so I am not sure why
config-space is coming up in this context.  I digress. I realize you are
being sarcastic, but your easy+cheap/clunky+fragile assessment is more
accurate than you perhaps realize.

You keep extolling that vhost does most things in userspace and that is
an advantage.  But the simple fact is that they both functionally do
almost the same amount in-kernel, because they _have_ to.  This includes
the obvious stuff like signal and memory routing, but also the less
obvious stuff like most of config-space.  Ultimately, most of
config-space needs to terminate at the device-model (the one exception
is perhaps "read-only attributes", like "MACQUERY").  Therefore, even if
you use a vhost like model, most of your parameters will invariably be a
translation from one config space to another and passed on (e.g. pci
config-cycle to ioctl()).

The disparity of in-kernel vs userspace functionality that remains
between the two implementations are basically the enumeration/hotswap
and read-only attribute functions.  These functions are prohibitively
complex in the vhost+virtio-pci+kvm model (full ICH/pci chipset
emulation, etc), so I understand why we wouldnt want to move those
in-kernel.  However, vbus was designed from scratch specifically for PV
to be flexible and simple.  As a result, the remaining functions in the
kvm-connector take advantage of this simplicity and just ride on the
existing model that we needed for fast-path anyway.  What this means is
there are of no significant consequence to do these few minor details
in-kernel, other than this long discussion.

In fact, it's actually a simpler design to unify things this way because
you avoid splitting the device model up. Consider how painful the vhost
implementation would be if it didn't already have the userspace
virtio-net to fall-back on.  This is effectively what we face for new
devices going forward if that model is to persist.


>=20
>>>> Contrast this to vhost+virtio-pci (called simply "vhost" from here).=

>>>>
>>>>       =20
>>> It's the wrong name.  vhost implements only the data path.
>>>     =20
>> Understood, but vhost+virtio-pci is what I am contrasting, and I use
>> "vhost" for short from that point on because I am too lazy to type the=

>> whole name over and over ;)
>>   =20
>=20
> If you #define A A+B+C don't expect intelligent conversation afterwards=
=2E

Fair enough, but I did attempt to declare the definition before using
it.  Sorry again for the confusion.

>=20
>>>> It is not immune to requiring in-kernel addressing support either, b=
ut
>>>> rather it just does it differently (and its not as you might expect =
via
>>>> qemu).
>>>>
>>>> Vhost relies on QEMU to render PCI objects to the guest, which the
>>>> guest
>>>> assigns resources (such as BARs, interrupts, etc).
>>>>       =20
>>> vhost does not rely on qemu.  It relies on its user to handle
>>> configuration.  In one important case it's qemu+pci.  It could just a=
s
>>> well be the lguest launcher.
>>>     =20
>> I meant vhost=3Dvhost+virtio-pci here.  Sorry for the confusion.
>>
>> The point I am making specifically is that vhost in general relies on
>> other in-kernel components to function.  I.e. It cannot function witho=
ut
>> having something like the PCI model to build an IO namespace.  That
>> namespace (in this case, pio addresses+data tuples) are used for the
>> in-kernel addressing function under KVM + virtio-pci.
>>
>> The case of the lguest launcher is a good one to highlight.  Yes, you
>> can presumably also use lguest with vhost, if the requisite facilities=

>> are exposed to lguest-bus, and some eventfd based thing like ioeventfd=

>> is written for the host (if it doesnt exist already).
>>
>> And when the next virt design "foo" comes out, it can make a "foo-bus"=

>> model, and implement foo-eventfd on the backend, etc, etc.
>>   =20
>=20
> It's exactly the same with vbus needing additional connectors for
> additional transports.

No, see my reply above.

>=20
>> Ira can make ira-bus, and ira-eventfd, etc, etc.
>>
>> Each iteration will invariably introduce duplicated parts of the stack=
=2E
>>   =20
>=20
> Invariably?

As in "always"

>  Use libraries (virtio-shmem.ko, libvhost.so).

What do you suppose vbus is?  vbus-proxy.ko =3D virtio-shmem.ko, and you
dont need libvhost.so per se since you can just use standard kernel
interfaces (like configfs/sysfs).  I could create an .so going forward
for the new ioctl-based interface, I suppose.

>=20
>=20
>>> For the N+1th time, no.  vhost is perfectly usable without pci.  Can =
we
>>> stop raising and debunking this point?
>>>     =20
>> Again, I understand vhost is decoupled from PCI, and I don't mean to
>> imply anything different.  I use PCI as an example here because a) its=

>> the only working example of vhost today (to my knowledge), and b) you
>> have stated in the past that PCI is the only "right" way here, to
>> paraphrase.  Perhaps you no longer feel that way, so I apologize if yo=
u
>> feel you already recanted your position on PCI and I missed it.
>>   =20
>=20
> For kvm/x86 pci definitely remains king.

For full virtualization, sure.  I agree.  However, we are talking about
PV here.  For PV, PCI is not a requirement and is a technical dead-end IM=
O.

KVM seems to be the only virt solution that thinks otherwise (*), but I
believe that is primarily a condition of its maturity.  I aim to help
advance things here.

(*) citation: xen has xenbus, lguest has lguest-bus, vmware has some
vmi-esq thing (I forget what its called) to name a few.  Love 'em or
hate 'em, most other hypervisors do something along these lines.  I'd
like to try to create one for KVM, but to unify them all (at least for
the Linux-based host designs).

>  I was talking about the two
> lguest users and Ira.
>=20
>> I digress.  My point here isn't PCI.  The point here is the missing
>> component for when PCI is not present.  The component that is partiall=
y
>> satisfied by vbus's devid addressing scheme.  If you are going to use
>> vhost, and you don't have PCI, you've gotta build something to replace=

>> it.
>>   =20
>=20
> Yes, that's why people have keyboards.  They'll write that glue code if=

> they need it.  If it turns out to be a hit an people start having virti=
o
> transport module writing parties, they'll figure out a way to share cod=
e.

Sigh...  The party has already started.  I tried to invite you months ago=
=2E..

>=20
>>>> All you really need is a simple decode+execute mechanism, and a way =
to
>>>> program it from userspace control.  vbus tries to do just that:
>>>> commoditize it so all you need is the transport of the control messa=
ges
>>>> (like DEVCALL()), but the decode+execute itself is reuseable, even
>>>> across various environments (like KVM or Iras rig).
>>>>
>>>>       =20
>>> If you think it should be "commodotized", write libvhostconfig.so.
>>>     =20
>> I know you are probably being facetious here, but what do you propose
>> for the parts that must be in-kernel?
>>   =20
>=20
> On the guest side, virtio-shmem.ko can unify the ring access.  It
> probably makes sense even today.  On the host side I eventfd is the
> kernel interface and libvhostconfig.so can provide the configuration
> when an existing ABI is not imposed.

That won't cut it.  For one, creating an eventfd is only part of the
equation.  I.e. you need to have originate/terminate somewhere
interesting (and in-kernel, otherwise use tuntap).

>=20
>>>> And your argument, I believe, is that vbus allows both to be
>>>> implemented
>>>> in the kernel (though to reiterate, its optional) and is therefore a=

>>>> bad
>>>> design, so lets discuss that.
>>>>
>>>> I believe the assertion is that things like config-space are best le=
ft
>>>> to userspace, and we should only relegate fast-path duties to the
>>>> kernel.  The problem is that, in my experience, a good deal of
>>>> config-space actually influences the fast-path and thus needs to
>>>> interact with the fast-path mechanism eventually anyway.
>>>> Whats left
>>>> over that doesn't fall into this category may cheaply ride on existi=
ng
>>>> plumbing, so its not like we created something new or unnatural just=
 to
>>>> support this subclass of config-space.
>>>>
>>>>       =20
>>> Flexibility is reduced, because changing code in the kernel is more
>>> expensive than in userspace, and kernel/user interfaces aren't typica=
lly
>>> as wide as pure userspace interfaces.  Security is reduced, since a b=
ug
>>> in the kernel affects the host, while a bug in userspace affects just=
 on
>>> guest.
>>>     =20
>> For a mac-address attribute?  Thats all we are really talking about
>> here.  These points you raise, while true of any kernel code I suppose=
,
>> are a bit of a stretch in this context.
>>   =20
>=20
> Look at the virtio-net feature negotiation.  There's a lot more there
> than the MAC address, and it's going to grow.

Agreed, but note that makes my point.  That feature negotiation almost
invariably influences the device-model, not some config-space shim.
IOW: terminating config-space at some userspace shim is pointless.  The
model ultimately needs the result of whatever transpires during that
negotiation anyway.

>=20
>>> Example: feature negotiation.  If it happens in userspace, it's easy =
to
>>> limit what features we expose to the guest.
>>>     =20
>> Its not any harder in the kernel.  I do this today.
>>
>> And when you are done negotiating said features, you will generally ha=
ve
>> to turn around and program the feature into the backend anyway (e.g.
>> ioctl() to vhost module).  Now you have to maintain some knowledge of
>> that particular feature and how to program it in two places.
>>   =20
>=20
> No, you can leave it enabled unconditionally in vhost (the guest won't
> use what it doesn't know about).

Perhaps, but IMO sending a "feature-mask"-like object down is far easier
then proxying/refactoring config-space and sending that down.  I'd still
chalk the win here to the vbus model used in AlacrityVM.

FWIW: venet has the ability to enable/disable features on the host side,
so clearly userspace config-space is not required for the basic premise.

>=20
>> Conversely, I am eliminating the (unnecessary) middleman by letting th=
e
>> feature negotiating take place directly between the two entities that
>> will consume it.
>>   =20
>=20
> The middleman is necessary, if you want to support live migration

Orchestrating live-migration has nothing to do with whether config-space
is serviced by a middle-man or not.  It shouldn't be required to have
device-specific knowledge at all beyond what was initially needed to
create/config the object at boot time.

IOW, the orchestrator merely needs to know that a device-model object is
present and a method to serialize and reconstitute its state (if
appropriate).

, or to
> restrict a guest to a subset of your features.

No, that is incorrect.  We are not talking about directly exposing
something like HW cpuid here.  These are all virtual models, and they
can optionally expose as much or as little as we want.  They do this
under administrative control by userspace, and independent of the
location of the config-space handler.

>=20
>>>   If it happens in the
>>> kernel, we need to add an interface to let the kernel know which
>>> features it should expose to the guest.
>>>     =20
>> You need this already either way for both models anyway.  As an added
>> bonus, vbus has generalized that interface using sysfs attributes, so
>> all models are handled in a similar and community accepted way.
>>   =20
>=20
> vhost doesn't need it since userspace takes care of it.

Ok, but see my related reply above.

>=20
>>>   We also need to add an
>>> interface to let userspace know which features were negotiated, if we=

>>> want to implement live migration.  Something fairly trivial bloats
>>> rapidly.
>>>     =20
>> Can you elaborate on the requirements for live-migration?  Wouldnt an
>> opaque save/restore model work here? (e.g. why does userspace need to =
be
>> able to interpret the in-kernel state, just pass it along as a blob to=

>> the new instance).
>>   =20
>=20
> A blob would work, if you commit to forward and backward compatibility
> in the kernel side (i.e. an older kernel must be able to accept a blob
> from a newer one).

Thats understood and acceptable.

> I don't like blobs though, they tie you to the implemenetation.

What would you suggest otherwise?

>=20
>>> As you can see above, userspace needs to be involved in this, and the=

>>> number of interfaces required is smaller if it's in userspace:
>>>     =20
>> Actually, no.  My experience has been the opposite.  Anytime I sat dow=
n
>> and tried to satisfy your request to move things to the userspace,
>> things got ugly and duplicative really quick.  I suspect part of the
>> reason you may think its easier because you already have part of
>> virtio-net in userspace and its surrounding support, but that is not t=
he
>> case moving forward for new device types.
>>   =20
>=20
> I can't comment on your experience, but we'll definitely build on
> existing code for new device types.

Fair enough.  I'll build on my experience, either reusing existing code
or implementing new designs where appropriate.  If you or anyone else
want to join me in my efforts, the more the merrier.

>=20
>>> you only
>>> need to know which features the kernel supports (they can be enabled
>>> unconditionally, just not exposed).
>>>
>>> Further, some devices are perfectly happy to be implemented in
>>> userspace, so we need userspace configuration support anyway.  Why
>>> reimplement it in the kernel?
>>>     =20
>> Thats fine.  vbus is targetted for high-performance IO.  So if you hav=
e
>> a robust userspace (like KVM+QEMU) and low-performance constraints (sa=
y,
>> for a console or something), put it in userspace and vbus is not
>> involved.  I don't care.
>>   =20
>=20
> So now the hypothetical non-pci hypervisor needs to support two busses.=


No.  The hypothetical hypervisor only needs to decide where
low-performance devices should live.  If that is best served by
making/reusing a unique bus for them, I have no specific problem with
that.  Systems are typically composed of multiple buses anyway.

Conversely, there is nothing wrong with putting low-performance devices
on a bus designed for high-performance either, and vbus can accommodate
both types.  The latter is what I would advocate for simplicity's sake,
but its not a requirement.

Kind Regards,
-Greg



--------------enig618B4EF311E91BDA38250403
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkq7tG0ACgkQP5K2CMvXmqHttQCdGkCliRbLD3BM4cx73OFytPDh
Sa8AoIftAZfEMb4D7fxexTeGW45jAYc8
=NgYI
-----END PGP SIGNATURE-----

--------------enig618B4EF311E91BDA38250403--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

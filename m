Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 010AB6B0055
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:32:24 -0400 (EDT)
Received: by qyk10 with SMTP id 10so2515828qyk.12
        for <linux-mm@kvack.org>; Fri, 25 Sep 2009 14:32:23 -0700 (PDT)
Message-ID: <4ABD36E3.9070503@gmail.com>
Date: Fri, 25 Sep 2009 17:32:19 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com> <4ABC7DCE.2000404@redhat.com>
In-Reply-To: <4ABC7DCE.2000404@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA591432984AD67F75B533AA4"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA591432984AD67F75B533AA4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/24/2009 09:03 PM, Gregory Haskins wrote:
>>
>>> I don't really see how vhost and vbus are different here.  vhost expe=
cts
>>> signalling to happen through a couple of eventfds and requires someon=
e
>>> to supply them and implement kernel support (if needed).  vbus requir=
es
>>> someone to write a connector to provide the signalling implementation=
=2E
>>> Neither will work out-of-the-box when implementing virtio-net over
>>> falling dominos, for example.
>>>     =20
>> I realize in retrospect that my choice of words above implies vbus _is=
_
>> complete, but this is not what I was saying.  What I was trying to
>> convey is that vbus is _more_ complete.  Yes, in either case some kind=

>> of glue needs to be written.  The difference is that vbus implements
>> more of the glue generally, and leaves less required to be customized
>> for each iteration.
>>   =20
>=20
>=20
> No argument there.  Since you care about non-virt scenarios and virtio
> doesn't, naturally vbus is a better fit for them as the code stands.

Thanks for finally starting to acknowledge there's a benefit, at least.

To be more precise, IMO virtio is designed to be a performance oriented
ring-based driver interface that supports all types of hypervisors (e.g.
shmem based kvm, and non-shmem based Xen).  vbus is designed to be a
high-performance generic shared-memory interconnect (for rings or
otherwise) framework for environments where linux is the underpinning
"host" (physical or virtual).  They are distinctly different, but
complementary (the former addresses the part of the front-end, and
latter addresses the back-end, and a different part of the front-end).

In addition, the kvm-connector used in AlacrityVM's design strives to
add value and improve performance via other mechanisms, such as dynamic
 allocation, interrupt coalescing (thus reducing exit-ratio, which is a
serious issue in KVM) and priortizable/nestable signals.

Today there is a large performance disparity between what a KVM guest
sees and what a native linux application sees on that same host.  Just
take a look at some of my graphs between "virtio", and "native", for
example:

http://developer.novell.com/wiki/images/b/b7/31-rc4_throughput.png

A dominant vbus design principle is to try to achieve the same IO
performance for all "linux applications" whether they be literally
userspace applications, or things like KVM vcpus or Ira's physical
boards.  It also aims to solve problems not previously expressible with
current technologies (even virtio), like nested real-time.

And even though you repeatedly insist otherwise, the neat thing here is
that the two technologies mesh (at least under certain circumstances,
like when virtio is deployed on a shared-memory friendly linux backend
like KVM).  I hope that my stack diagram below depicts that clearly.


> But that's not a strong argument for vbus; instead of adding vbus you
> could make virtio more friendly to non-virt

Actually, it _is_ a strong argument then because adding vbus is what
helps makes virtio friendly to non-virt, at least for when performance
matters.

> (there's a limit how far you
> can take this, not imposed by the code, but by virtio's charter as a
> virtual device driver framework).
>=20
>> Going back to our stack diagrams, you could think of a vhost solution
>> like this:
>>
>> --------------------------
>> | virtio-net
>> --------------------------
>> | virtio-ring
>> --------------------------
>> | virtio-bus
>> --------------------------
>> | ? undefined-1 ?
>> --------------------------
>> | vhost
>> --------------------------
>>
>> and you could think of a vbus solution like this
>>
>> --------------------------
>> | virtio-net
>> --------------------------
>> | virtio-ring
>> --------------------------
>> | virtio-bus
>> --------------------------
>> | bus-interface
>> --------------------------
>> | ? undefined-2 ?
>> --------------------------
>> | bus-model
>> --------------------------
>> | virtio-net-device (vhost ported to vbus model? :)
>> --------------------------
>>
>>
>> So the difference between vhost and vbus in this particular context is=

>> that you need to have "undefined-1" do device discovery/hotswap,
>> config-space, address-decode/isolation, signal-path routing, memory-pa=
th
>> routing, etc.  Today this function is filled by things like virtio-pci=
,
>> pci-bus, KVM/ioeventfd, and QEMU for x86.  I am not as familiar with
>> lguest, but presumably it is filled there by components like
>> virtio-lguest, lguest-bus, lguest.ko, and lguest-launcher.  And to use=

>> more contemporary examples, we might have virtio-domino, domino-bus,
>> domino.ko, and domino-launcher as well as virtio-ira, ira-bus, ira.ko,=

>> and ira-launcher.
>>
>> Contrast this to the vbus stack:  The bus-X components (when optionall=
y
>> employed by the connector designer) do device-discovery, hotswap,
>> config-space, address-decode/isolation, signal-path and memory-path
>> routing, etc in a general (and pv-centric) way. The "undefined-2"
>> portion is the "connector", and just needs to convey messages like
>> "DEVCALL" and "SHMSIGNAL".  The rest is handled in other parts of the
>> stack.
>>
>>   =20
>=20
> Right.  virtio assumes that it's in a virt scenario and that the guest
> architecture already has enumeration and hotplug mechanisms which it
> would prefer to use.  That happens to be the case for kvm/x86.

No, virtio doesn't assume that.  It's stack provides the "virtio-bus"
abstraction and what it does assume is that it will be wired up to
something underneath. Kvm/x86 conveniently has pci, so the virtio-pci
adapter was created to reuse much of that facility.  For other things
like lguest and s360, something new had to be created underneath to make
up for the lack of pci-like support.

vbus, in conjunction with the kvm-connector, tries to unify that process
a little more by creating a PV-optimized bus.  The idea is that it can
be reused in that situation instead of creating a new hypervisor
specific bus each time.  It's also designed for high-performance, so you
get that important trait for free simply by tying into it.

>=20
>> So to answer your question, the difference is that the part that has t=
o
>> be customized in vbus should be a fraction of what needs to be
>> customized with vhost because it defines more of the stack.
>=20
> But if you want to use the native mechanisms, vbus doesn't have any
> added value.

First of all, thats incorrect.  If you want to use the "native"
mechanisms (via the way the vbus-connector is implemented, for instance)
you at least still have the benefit that the backend design is more
broadly re-useable in more environments (like non-virt, for instance),
because vbus does a proper job of defining the requisite
layers/abstractions compared to vhost.  So it adds value even in that
situation.

Second of all, with PV there is no such thing as "native".  It's
software so it can be whatever we want.  Sure, you could argue that the
guest may have built-in support for something like PCI protocol.
However, PCI protocol itself isn't suitable for high-performance PV out
of the can.  So you will therefore invariably require new software
layers on top anyway, even if part of the support is already included.

And lastly, why would you _need_ to use the so called "native"
mechanism?  The short answer is, "you don't".  Any given system (guest
or bare-metal) already have a wide-range of buses (try running "tree
/sys/bus" in Linux).  More importantly, the concept of adding new buses
is widely supported in both the Windows and Linux driver model (and
probably any other guest-type that matters).  Therefore, despite claims
to the contrary, its not hard or even unusual to add a new bus to the mix=
=2E

In summary, vbus is simply one more bus of many, purpose built to
support high-end IO in a virt-like model, giving controlled access to
the linux-host underneath it.  You can write a high-performance layer
below the OS bus-model (vbus), or above it (virtio-pci) but either way
you are modifying the stack to add these capabilities, so we might as
well try to get this right.

With all due respect, you are making a big deal out of a minor issue.

>=20
>> And, as
>> eluded to in my diagram, both virtio-net and vhost (with some
>> modifications to fit into the vbus framework) are potentially
>> complementary, not competitors.
>>   =20
>=20
> Only theoretically.  The existing installed base would have to be throw=
n
> away

"Thrown away" is pure hyperbole.  The installed base, worse case, needs
to load a new driver for a missing device.  This is pretty much how
every machine works today, anyway.  And if loading a driver was actually
some insurmountable hurdle, as its sometimes implied (but its not in
reality), you can alternatively make vbus look like a legacy bus if you
are willing to sacrifice some of features, like exit-ratio reduction and
priority.

FWIW: AlacrityVM isn't willing to sacrifice those features, so we will
provide a Linux and Windows driver for explicit bus support, as well as
open-specs and community development assistance to any other guest that
wants to add support in the future.

> or we'd need to support both.
>=20
>

No matter what model we talk about, there's always going to be a "both"
since the userspace virtio models are probably not going to go away (nor
should they).

>=20
>=20
>>> Without a vbus-connector-falling-dominos, vbus-venet can't do anythin=
g
>>> either.
>>>     =20
>> Mostly covered above...
>>
>> However, I was addressing your assertion that vhost somehow magically
>> accomplishes this "container/addressing" function without any specific=

>> kernel support.  This is incorrect.  I contend that this kernel suppor=
t
>> is required and present.  The difference is that its defined elsewhere=

>> (and typically in a transport/arch specific way).
>>
>> IOW: You can basically think of the programmed PIO addresses as formin=
g
>> its "container".  Only addresses explicitly added are visible, and
>> everything else is inaccessible.  This whole discussion is merely a
>> question of what's been generalized verses what needs to be
>> re-implemented each time.
>>   =20
>=20
> Sorry, this is too abstract for me.

With all due respect, understanding my point above is required to have
any kind of meaningful discussion here.

>=20
>=20
>=20
>>> vbus doesn't do kvm guest address decoding for the fast path.  It's
>>> still done by ioeventfd.
>>>     =20
>> That is not correct.  vbus does its own native address decoding in the=

>> fast path, such as here:
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-=
2.6.git;a=3Dblob;f=3Dkernel/vbus/client.c;h=3De85b2d92d629734866496b67455=
dd307486e394a;hb=3De6cbd4d1decca8e829db3b2b9b6ec65330b379e9#l331
>>
>>
>>   =20
>=20
> All this is after kvm has decoded that vbus is addresses.  It can't wor=
k
> without someone outside vbus deciding that.

How the connector message is delivered is really not relevant.  Some
architectures will simply deliver the message point-to-point (like the
original hypercall design for KVM, or something like Ira's rig), and
some will need additional demuxing (like pci-bridge/pio based KVM).
It's an implementation detail of the connector.

However, the real point here is that something needs to establish a
scoped namespace mechanism, add items to that namespace, and advertise
the presence of the items to the guest.  vbus has this facility built in
to its stack.  vhost doesn't, so it must come from elsewhere.


>=20
>> In fact, it's actually a simpler design to unify things this way becau=
se
>> you avoid splitting the device model up. Consider how painful the vhos=
t
>> implementation would be if it didn't already have the userspace
>> virtio-net to fall-back on.  This is effectively what we face for new
>> devices going forward if that model is to persist.
>>   =20
>=20
>=20
> It doesn't have just virtio-net, it has userspace-based hostplug

vbus has hotplug too: mkdir and rmdir

As an added bonus, its device-model is modular.  A developer can write a
new device model, compile it, insmod it to the host kernel, hotplug it
to the running guest with mkdir/ln, and the come back out again
(hotunplug with rmdir, rmmod, etc).  They may do this all without taking
the guest down, and while eating QEMU based IO solutions for breakfast
performance wise.

Afaict, qemu can't do either of those things.

> and a bunch of other devices impemented in userspace.

Thats fine.  I am primarily interested in the high-performance
components, so most of those other items can stay there in userspace if
that is their ideal location.

>  Currently qemu has
> virtio bindings for pci and syborg (whatever that is), and device model=
s
> for baloon, block, net, and console, so it seems implementing device
> support in userspace is not as disasterous as you make it to be.

I intentionally qualified "device" with "new" in my statement.  And in
that context I was talking about ultimately developing/supporting
in-kernel models, not pure legacy userspace ones.  I have no doubt the
implementation of the original userpsace devices was not a difficult or
horrific endeavor.

Requiring new models to be implemented (at least) twice is a poor design
IMO, however.  Requiring them to split such a minor portion of their
functionality (like read-only attributes) is a poor design, too.  I have
already demonstrated there are other ways to achieve the same
high-performance goals without requiring two models developed/tested
each time and for each manager.  For the times I went and tried to
satisfy your request in this manner, developing the code and managing
the resources in two places, for lack of a better description, made me
want to wretch. So I gave up, resolved that my original design was
better, and hoped that I could convince you and the community of the same=
=2E

>=20
>>> Invariably?
>>>     =20
>> As in "always"
>>   =20
>=20
> Refactor instead of duplicating.

There is no duplicating.  vbus has no equivalent today as virtio doesn't
define these layers.

>=20
>>  =20
>>>   Use libraries (virtio-shmem.ko, libvhost.so).
>>>     =20
>> What do you suppose vbus is?  vbus-proxy.ko =3D virtio-shmem.ko, and y=
ou
>> dont need libvhost.so per se since you can just use standard kernel
>> interfaces (like configfs/sysfs).  I could create an .so going forward=

>> for the new ioctl-based interface, I suppose.
>>   =20
>=20
> Refactor instead of rewriting.

There is no rewriting.  vbus has no equivalent today as virtio doesn't
define these layers.

By your own admission, you said if you wanted that capability, use a
library.  What I think you are not understanding is vbus _is_ that
library.  So what is the problem, exactly?

>=20
>=20
>=20
>>> For kvm/x86 pci definitely remains king.
>>>     =20
>> For full virtualization, sure.  I agree.  However, we are talking abou=
t
>> PV here.  For PV, PCI is not a requirement and is a technical dead-end=

>> IMO.
>>
>> KVM seems to be the only virt solution that thinks otherwise (*), but =
I
>> believe that is primarily a condition of its maturity.  I aim to help
>> advance things here.
>>
>> (*) citation: xen has xenbus, lguest has lguest-bus, vmware has some
>> vmi-esq thing (I forget what its called) to name a few.  Love 'em or
>> hate 'em, most other hypervisors do something along these lines.  I'd
>> like to try to create one for KVM, but to unify them all (at least for=

>> the Linux-based host designs).
>>   =20
>=20
> VMware are throwing VMI away (won't be supported in their new product,
> and they've sent a patch to rip it off from Linux);

vmware only cares about x86 iiuc, so probably not a good example.

> Xen has to tunnel
> xenbus in pci for full virtualization (which is where Windows is, and
> where Linux will be too once people realize it's faster).  lguest is
> meant as an example hypervisor, not an attempt to take over the world.

So pick any other hypervisor, and the situation is often similar.

>=20
> "PCI is a dead end" could not be more wrong, it's what guests support.

It's what _some_ guests support.  Even for the guests that support it,
it's not well designed for PV.  Therefore, you have to do a bunch of
dancing and waste resources on top to squeeze every last drop of
performance out of your platform.  In addition, it has a bunch of
baggage that goes with it that is not necessary to do the job in a
software environment.  It is therefore burdensome to recreate if you
don't already have something to leverage, like QEMU, just for the sake
of creating the illusion that its there.

Sounds pretty dead to me, sorry.  We don't need it.

Alternatively, you can just try to set a stake in the ground for looking
forward and fixing those PV-specific problems hopefully once and for
all, like vbus and the kvm-connector tries to do.  Sure, there will be
some degree of pain first as we roll out the subsystem and deploy
support, but thats true for lots of things.  It's simply a platform
investment.


> An right now you can have a guest using pci to access a mix of
> userspace-emulated devices, userspace-emulated-but-kernel-accelerated
> virtio devices, and real host devices.  All on one dead-end bus.  Try
> that with vbus.

vbus is not interested in userspace devices.  The charter is to provide
facilities for utilizing the host linux kernel's IO capabilities in the
most efficient, yet safe, manner possible.  Those devices that fit
outside that charter can ride on legacy mechanisms if that suits them bes=
t.

>=20
>=20
>>>> I digress.  My point here isn't PCI.  The point here is the missing
>>>> component for when PCI is not present.  The component that is partia=
lly
>>>> satisfied by vbus's devid addressing scheme.  If you are going to us=
e
>>>> vhost, and you don't have PCI, you've gotta build something to repla=
ce
>>>> it.
>>>>
>>>>       =20
>>> Yes, that's why people have keyboards.  They'll write that glue code =
if
>>> they need it.  If it turns out to be a hit an people start having vir=
tio
>>> transport module writing parties, they'll figure out a way to share
>>> code.
>>>     =20
>> Sigh...  The party has already started.  I tried to invite you months
>> ago...
>>   =20
>=20
> I've been voting virtio since 2007.

That doesn't have much to do with whats underneath it, since it doesn't
define these layers.  See my stack diagram's for details.

>=20
>>> On the guest side, virtio-shmem.ko can unify the ring access.  It
>>> probably makes sense even today.  On the host side I eventfd is the
>>> kernel interface and libvhostconfig.so can provide the configuration
>>> when an existing ABI is not imposed.
>>>     =20
>> That won't cut it.  For one, creating an eventfd is only part of the
>> equation.  I.e. you need to have originate/terminate somewhere
>> interesting (and in-kernel, otherwise use tuntap).
>>   =20
>=20
> vbus needs the same thing so it cancels out.

No, it does not.  vbus just needs a relatively simple single message
pipe between the guest and host (think "hypercall tunnel", if you will).
 Per queue/device addressing is handled by the same conceptual namespace
as the one that would trigger eventfds in the model you mention.  And
that namespace is built in to the vbus stack, and objects are registered
automatically as they are created.

Contrast that to vhost, which requires some other kernel interface to
exist, and to be managed manually for each object that is created.  Your
libvhostconfig would need to somehow know how to perform this
registration operation, and there would have to be something in the
kernel to receive it, presumably on a per platform basis.  Solving this
problem generally would probably end up looking eerily like vbus,
because thats what vbus does.

>=20
>>> Look at the virtio-net feature negotiation.  There's a lot more there=

>>> than the MAC address, and it's going to grow.
>>>     =20
>> Agreed, but note that makes my point.  That feature negotiation almost=

>> invariably influences the device-model, not some config-space shim.
>> IOW: terminating config-space at some userspace shim is pointless.  Th=
e
>> model ultimately needs the result of whatever transpires during that
>> negotiation anyway.
>>   =20
>=20
> Well, let's see.  Can vbus today:
>=20
> - let userspace know which features are available (so it can decide if
> live migration is possible)

yes, its in sysfs.

> - let userspace limit which features are exposed to the guest (so it ca=
n
> make live migration possible among hosts of different capabilities)

yes, its in sysfs.

> - let userspace know which features were negotiated (so it can transfer=

> them to the other host during live migration)

no, but we can easily add ->save()/->restore() to the model going
forward, and the negotiated features are just a subcomponent if its
serialized stream.

> - let userspace tell the kernel which features were negotiated (when
> live migration completes, to avoid requiring the guest to re-negotiate)=


that would be the function of the ->restore() deserializer.

> - do all that from an unprivileged process

yes, in the upcoming alacrityvm v0.3 with the ioctl based control plane.

> - securely wrt other unprivileged processes

yes, same mechanism plus it has a fork-inheritance model.

Bottom line: vbus isn't done, especially w.r.t. live-migration..but that
is not an valid argument against the idea if you believe in
release-early/release-often. kvm wasn't (isn't) done either when it was
proposed/merged.

Kind Regards,
-Greg


--------------enigA591432984AD67F75B533AA4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkq9NuMACgkQP5K2CMvXmqGKxgCffLE9z5r+VM3y3XQPwFlK8VFg
4HUAnjFMVMxZ97oIpMUFPDOSQCDyHZh2
=xu8M
-----END PGP SIGNATURE-----

--------------enigA591432984AD67F75B533AA4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C1ECB6B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 13:58:39 -0400 (EDT)
Received: by fxm2 with SMTP id 2so802174fxm.4
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 10:58:46 -0700 (PDT)
Message-ID: <4ABA61D1.80703@gmail.com>
Date: Wed, 23 Sep 2009 13:58:41 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com>
In-Reply-To: <4ABA3A73.5090508@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2960FB4A219017B9F4183E21"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2960FB4A219017B9F4183E21
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gregory Haskins wrote:
> Avi Kivity wrote:
>> On 09/23/2009 05:26 PM, Gregory Haskins wrote:
>>>  =20
>>>>> Yes, I'm having to create my own bus model, a-la lguest, virtio-pci=
,
>>>>> and
>>>>> virtio-s390. It isn't especially easy. I can steal lots of code fro=
m
>>>>> the
>>>>> lguest bus model, but sometimes it is good to generalize, especiall=
y
>>>>> after the fourth implemention or so. I think this is what GHaskins
>>>>> tried
>>>>> to do.
>>>>>
>>>>>       =20
>>>> Yes.  vbus is more finely layered so there is less code duplication.=

>>>>     =20
>>> To clarify, Ira was correct in stating this generalizing some of thes=
e
>>> components was one of the goals for the vbus project: IOW vbus finely=

>>> layers and defines what's below virtio, not replaces it.
>>>
>>> You can think of a virtio-stack like this:
>>>
>>> --------------------------
>>> | virtio-net
>>> --------------------------
>>> | virtio-ring
>>> --------------------------
>>> | virtio-bus
>>> --------------------------
>>> | ? undefined ?
>>> --------------------------
>>>
>>> IOW: The way I see it, virtio is a device interface model only.  The
>>> rest of it is filled in by the virtio-transport and some kind of
>>> back-end.
>>>
>>> So today, we can complete the "? undefined ?" block like this for KVM=
:
>>>
>>> --------------------------
>>> | virtio-pci
>>> --------------------------
>>>               |
>>> --------------------------
>>> | kvm.ko
>>> --------------------------
>>> | qemu
>>> --------------------------
>>> | tuntap
>>> --------------------------
>>>
>>> In this case, kvm.ko and tuntap are providing plumbing, and qemu is
>>> providing a backend device model (pci-based, etc).
>>>
>>> You can, of course, plug a different stack in (such as virtio-lguest,=

>>> virtio-ira, etc) but you are more or less on your own to recreate man=
y
>>> of the various facilities contained in that stack (such as things
>>> provided by QEMU, like discovery/hotswap/addressing), as Ira is
>>> discovering.
>>>
>>> Vbus tries to commoditize more components in the stack (like the bus
>>> model and backend-device model) so they don't need to be redesigned e=
ach
>>> time we solve this "virtio-transport" problem.  IOW: stop the
>>> proliferation of the need for pci-bus, lguest-bus, foo-bus underneath=

>>> virtio.  Instead, we can then focus on the value add on top, like the=

>>> models themselves or the simple glue between them.
>>>
>>> So now you might have something like
>>>
>>> --------------------------
>>> | virtio-vbus
>>> --------------------------
>>> | vbus-proxy
>>> --------------------------
>>> | kvm-guest-connector
>>> --------------------------
>>>               |
>>> --------------------------
>>> | kvm.ko
>>> --------------------------
>>> | kvm-host-connector.ko
>>> --------------------------
>>> | vbus.ko
>>> --------------------------
>>> | virtio-net-backend.ko
>>> --------------------------
>>>
>>> so now we don't need to worry about the bus-model or the device-model=

>>> framework.  We only need to implement the connector, etc.  This is ha=
ndy
>>> when you find yourself in an environment that doesn't support PCI (su=
ch
>>> as Ira's rig, or userspace containers), or when you want to add featu=
res
>>> that PCI doesn't have (such as fluid event channels for things like I=
PC
>>> services, or priortizable interrupts, etc).
>>>   =20
>> Well, vbus does more, for example it tunnels interrupts instead of
>> exposing them 1:1 on the native interface if it exists.
>=20
> As I've previously explained, that trait is a function of the
> kvm-connector I've chosen to implement, not of the overall design of vb=
us.
>=20
> The reason why my kvm-connector is designed that way is because my earl=
y
> testing/benchmarking shows one of the issues in KVM performance is the
> ratio of exits per IO operation are fairly high, especially as your
> scale io-load.  Therefore, the connector achieves a substantial
> reduction in that ratio by treating "interrupts" to the same kind of
> benefits that NAPI brought to general networking: That is, we enqueue
> "interrupt" messages into a lockless ring and only hit the IDT for the
> first occurrence.  Subsequent interrupts are injected in a
> parallel/lockless manner, without hitting the IDT nor incurring an extr=
a
> EOI.  This pays dividends as the IO rate increases, which is when the
> guest needs the most help.
>=20
> OTOH, it is entirely possible to design the connector such that we
> maintain a 1:1 ratio of signals to traditional IDT interrupts.  It is
> also possible to design a connector which surfaces as something else,
> such as PCI devices (by terminating the connector in QEMU and utilizing=

> its PCI emulation facilities), which would naturally employ 1:1 mapping=
=2E
>=20
> So if 1:1 mapping is a critical feature (I would argue to the contrary)=
,
> vbus can support it.
>=20
>> It also pulls parts of the device model into the host kernel.
>=20
> That is the point.  Most of it needs to be there for performance.

To clarify this point:

There are various aspects about designing high-performance virtual
devices such as providing the shortest paths possible between the
physical resources and the consumers.  Conversely, we also need to
ensure that we meet proper isolation/protection guarantees at the same
time.  What this means is there are various aspects to any
high-performance PV design that require to be placed in-kernel to
maximize the performance yet properly isolate the guest.

For instance, you are required to have your signal-path (interrupts and
hypercalls), your memory-path (gpa translation), and
addressing/isolation model in-kernel to maximize performance.

Vbus accomplishes its in-kernel isolation model by providing a
"container" concept, where objects are placed into this container by
userspace.  The host kernel enforces isolation/protection by using a
namespace to identify objects that is only relevant within a specific
container's context (namely, a "u32 dev-id").  The guest addresses the
objects by its dev-id, and the kernel ensures that the guest can't
access objects outside of its dev-id namespace.

All that is required is a way to transport a message with a "devid"
attribute as an address (such as DEVCALL(devid)) and the framework
provides the rest of the decode+execute function.

Contrast this to vhost+virtio-pci (called simply "vhost" from here).
It is not immune to requiring in-kernel addressing support either, but
rather it just does it differently (and its not as you might expect via
qemu).

Vhost relies on QEMU to render PCI objects to the guest, which the guest
assigns resources (such as BARs, interrupts, etc).  A PCI-BAR in this
example may represent a PIO address for triggering some operation in the
device-model's fast-path.  For it to have meaning in the fast-path, KVM
has to have in-kernel knowledge of what a PIO-exit is, and what to do
with it (this is where pio-bus and ioeventfd come in).  The programming
of the PIO-exit and the ioeventfd are likewise controlled by some
userspace management entity (i.e. qemu).   The PIO address and value
tuple form the address, and the ioeventfd framework within KVM provide
the decode+execute function.

This idea seemingly works fine, mind you, but it rides on top of a *lot*
of stuff including but not limited to: the guests pci stack, the qemu
pci emulation, kvm pio support, and ioeventfd.  When you get into
situations where you don't have PCI or even KVM underneath you (e.g. a
userspace container, Ira's rig, etc) trying to recreate all of that PCI
infrastructure for the sake of using PCI is, IMO, a lot of overhead for
little gain.

All you really need is a simple decode+execute mechanism, and a way to
program it from userspace control.  vbus tries to do just that:
commoditize it so all you need is the transport of the control messages
(like DEVCALL()), but the decode+execute itself is reuseable, even
across various environments (like KVM or Iras rig).

And we face similar situations with the signal-path and memory-path
components...but lets take a look at the slow-path side.


>  And what doesn't need to be there for performance can either be:
>=20
> a) skipped at the discretion of the connector/device-model designer
>=20
> OR
>=20
> b) included because its trivially small subset of the model (e.g. a
> mac-addr attribute) and its nice to have a cohesive solution instead of=

> requiring a separate binary blob that can get out of sync, etc.
>=20
> The example Ive provided to date (venet on kvm) utilizes (b), but it
> certainly doesn't have to.  Therefore, I don't think vbus as a whole ca=
n
> be judged on this one point.


For a given model, we have a grouping of operations for fast path and
slow path.  Fast path would be things like we just talked about
(signal-path, memory-path, addressing model).  Slow path would be things
like device discovery (and hotswap), config-space, etc.

And your argument, I believe, is that vbus allows both to be implemented
in the kernel (though to reiterate, its optional) and is therefore a bad
design, so lets discuss that.

I believe the assertion is that things like config-space are best left
to userspace, and we should only relegate fast-path duties to the
kernel.  The problem is that, in my experience, a good deal of
config-space actually influences the fast-path and thus needs to
interact with the fast-path mechanism eventually anyway.  Whats left
over that doesn't fall into this category may cheaply ride on existing
plumbing, so its not like we created something new or unnatural just to
support this subclass of config-space.

For example: take an attribute like the mac-address assigned to a NIC.
This clearly doesn't need to be in-kernel and could go either way (such
as a PCI config-space register).

As another example: consider an option bit that enables a new feature
that affects the fast-path, like RXBUF merging.  If we use the split
model where config space is handled by userspace and fast-path is
in-kernel, the userspace component is only going to act as a proxy.
I.e. it will pass the option down to the kernel eventually.  Therefore,
there is little gain in trying to split this type of slow-path out to
userspace.  In fact, its more work.

vbus addresses this observation by providing a very simple (yet
hopefully powerful) model of providing two basic verbs to a device:

dev->call()
dev->shm()

It makes no distinction of slow or fast-path type operations, per se.
Just a mechanism for synchronous or asynchronous communication.  It is
expected that a given component will build "config-space" primarily from
the synchronous ->call() interface if it requires one.  However, it gets
this for free since we need ->call() for fast-path too (like the
rt-scheduler device, etc).

So I can then use ->call to perform a fast-path scheduler update (has to
go in-kernel for performance), an "enable rxbuf-merge" function (has to
end-up in-kernel eventually), or a "macquery" (doesn't need to be
in-kernel).

My choice was to support that third operation in-kernel as well, because
its way more complicated to do it another way that it is to simply
export a sysfs attribute to set it.  Userspace is still completely in
control..it sets the value.  It just doesnt have to write plumbing to
make it accessible.  The basic vbus model inherently provides this.

Thats enough for now.  We can talk about discovery/hotswap at a later tim=
e.

Kind Regards,
-Greg


--------------enig2960FB4A219017B9F4183E21
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkq6YdEACgkQP5K2CMvXmqGZBQCghw6prAw9k8PjmGtKYVpsNUt9
WOcAn0bSahCftRGmgimravnt/fqFYUEM
=J665
-----END PGP SIGNATURE-----

--------------enig2960FB4A219017B9F4183E21--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

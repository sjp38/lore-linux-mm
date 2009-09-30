Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 408096B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 15:45:57 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1377251bwz.38
        for <linux-mm@kvack.org>; Wed, 30 Sep 2009 13:04:29 -0700 (PDT)
Message-ID: <4AC3B9C6.5090408@gmail.com>
Date: Wed, 30 Sep 2009 16:04:22 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com> <4ABC7DCE.2000404@redhat.com> <4ABD36E3.9070503@gmail.com> <4ABF33B2.4000805@redhat.com>
In-Reply-To: <4ABF33B2.4000805@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFF1C78857214B551CF98A1FD"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFF1C78857214B551CF98A1FD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/26/2009 12:32 AM, Gregory Haskins wrote:
>>>>
>>>> I realize in retrospect that my choice of words above implies vbus _=
is_
>>>> complete, but this is not what I was saying.  What I was trying to
>>>> convey is that vbus is _more_ complete.  Yes, in either case some ki=
nd
>>>> of glue needs to be written.  The difference is that vbus implements=

>>>> more of the glue generally, and leaves less required to be customize=
d
>>>> for each iteration.
>>>>
>>>>       =20
>>>
>>> No argument there.  Since you care about non-virt scenarios and virti=
o
>>> doesn't, naturally vbus is a better fit for them as the code stands.
>>>     =20
>> Thanks for finally starting to acknowledge there's a benefit, at least=
=2E
>>   =20
>=20
> I think I've mentioned vbus' finer grained layers as helpful here,
> though I doubt the value of this.  Hypervisors are added rarely, while
> devices and drivers are added (and modified) much more often.  I don't
> buy the anything-to-anything promise.

The ease in which a new hypervisor should be able to integrate into the
stack is only one of vbus's many benefits.

>=20
>> To be more precise, IMO virtio is designed to be a performance oriente=
d
>> ring-based driver interface that supports all types of hypervisors (e.=
g.
>> shmem based kvm, and non-shmem based Xen).  vbus is designed to be a
>> high-performance generic shared-memory interconnect (for rings or
>> otherwise) framework for environments where linux is the underpinning
>> "host" (physical or virtual).  They are distinctly different, but
>> complementary (the former addresses the part of the front-end, and
>> latter addresses the back-end, and a different part of the front-end).=

>>   =20
>=20
> They're not truly complementary since they're incompatible.

No, that is incorrect.  Not to be rude, but for clarity:

  Complementary \Com`ple*men"ta*ry\, a.
     Serving to fill out or to complete; as, complementary
     numbers.
     [1913 Webster]

Citation: www.dict.org

IOW: Something being complementary has nothing to do with guest/host
binary compatibility.  virtio-pci and virtio-vbus are both equally
complementary to virtio since they fill in the bottom layer of the
virtio stack.

So yes, vbus is truly complementary to virtio afaict.

> A 2.6.27 guest, or Windows guest with the existing virtio drivers, won'=
t work
> over vbus.

Binary compatibility with existing virtio drivers, while nice to have,
is not a specific requirement nor goal.  We will simply load an updated
KMP/MSI into those guests and they will work again.  As previously
discussed, this is how more or less any system works today.  It's like
we are removing an old adapter card and adding a new one to "uprev the
silicon".

>  Further, non-shmem virtio can't work over vbus.

Actually I misspoke earlier when I said virtio works over non-shmem.
Thinking about it some more, both virtio and vbus fundamentally require
shared-memory, since sharing their metadata concurrently on both sides
is their raison d'=C3=AAtre.

The difference is that virtio utilizes a pre-translation/mapping (via
->add_buf) from the guest side.  OTOH, vbus uses a post translation
scheme (via memctx) from the host-side.  If anything, vbus is actually
more flexible because it doesn't assume the entire guest address space
is directly mappable.

In summary, your statement is incorrect (though it is my fault for
putting that idea in your head).

>  Since
> virtio is guest-oriented and host-agnostic, it can't ignore
> non-shared-memory hosts (even though it's unlikely virtio will be
> adopted there)

Well, to be fair no one said it has to ignore them.  Either virtio-vbus
transport is present and available to the virtio stack, or it isn't.  If
its present, it may or may not publish objects for consumption.
Providing a virtio-vbus transport in no way limits or degrades the
existing capabilities of the virtio stack.  It only enhances them.

I digress.  The whole point is moot since I realized that the non-shmem
distinction isn't accurate anyway.  They both require shared-memory for
the metadata, and IIUC virtio requires the entire address space to be
mappable whereas vbus only assumes the metadata is.

>=20
>> In addition, the kvm-connector used in AlacrityVM's design strives to
>> add value and improve performance via other mechanisms, such as dynami=
c
>>   allocation, interrupt coalescing (thus reducing exit-ratio, which is=
 a
>> serious issue in KVM)
>=20
> Do you have measurements of inter-interrupt coalescing rates (excluding=

> intra-interrupt coalescing).

I actually do not have a rig setup to explicitly test inter-interrupt
rates at the moment.  Once things stabilize for me, I will try to
re-gather some numbers here.  Last time I looked, however, there were
some decent savings for inter as well.

Inter rates are interesting because they are what tends to ramp up with
IO load more than intra since guest interrupt mitigation techniques like
NAPI often quell intra-rates naturally.  This is especially true for
data-center, cloud, hpc-grid, etc, kind of workloads (vs vanilla
desktops, etc) that tend to have multiple IO ports (multi-homed nics,
disk-io, etc).  Those various ports tend to be workload-related to one
another (e.g. 3-tier web stack may use multi-homed network and disk-io
at the same time, trigged by one IO event).

An interesting thing here is that you don't even need a fancy
multi-homed setup to see the effects of my exit-ratio reduction work:
even single port configurations suffer from the phenomenon since many
devices have multiple signal-flows (e.g. network adapters tend to have
at least 3 flows: rx-ready, tx-complete, and control-events (link-state,
etc).  Whats worse, is that the flows often are indirectly related (for
instance, many host adapters will free tx skbs during rx operations, so
you tend to get bursts of tx-completes at the same time as rx-ready.  If
the flows map 1:1 with IDT, they will suffer the same problem.

In any case, here is an example run of a simple single-homed guest over
standard GigE.  Whats interesting here is that .qnotify to .notify
ratio, as this is the interrupt-to-signal ratio.  In this case, its
170047/151918, which comes out to about 11% savings in interrupt injectio=
ns:

vbus-guest:/home/ghaskins # netperf -H dev
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
dev.laurelwood.net (192.168.1.10) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

1048576  16384  16384    10.01     940.77
vbus-guest:/home/ghaskins # cat /sys/kernel/debug/pci-to-vbus-bridge
  .events                        : 170048
  .qnotify                       : 151918
  .qinject                       : 0
  .notify                        : 170047
  .inject                        : 18238
  .bridgecalls                   : 18
  .buscalls                      : 12
vbus-guest:/home/ghaskins # cat /proc/interrupts
            CPU0
   0:         87   IO-APIC-edge      timer
   1:          6   IO-APIC-edge      i8042
   4:        733   IO-APIC-edge      serial
   6:          2   IO-APIC-edge      floppy
   7:          0   IO-APIC-edge      parport0
   8:          0   IO-APIC-edge      rtc0
   9:          0   IO-APIC-fasteoi   acpi
  10:          0   IO-APIC-fasteoi   virtio1
  12:         90   IO-APIC-edge      i8042
  14:       3041   IO-APIC-edge      ata_piix
  15:       1008   IO-APIC-edge      ata_piix
  24:     151933   PCI-MSI-edge      vbus
  25:          0   PCI-MSI-edge      virtio0-config
  26:        190   PCI-MSI-edge      virtio0-input
  27:         28   PCI-MSI-edge      virtio0-output
 NMI:          0   Non-maskable interrupts
 LOC:       9854   Local timer interrupts
 SPU:          0   Spurious interrupts
 CNT:          0   Performance counter interrupts
 PND:          0   Performance pending work
 RES:          0   Rescheduling interrupts
 CAL:          0   Function call interrupts
 TLB:          0   TLB shootdowns
 TRM:          0   Thermal event interrupts
 THR:          0   Threshold APIC interrupts
 MCE:          0   Machine check exceptions
 MCP:          1   Machine check polls
 ERR:          0
 MIS:          0

Its important to note here that we are actually looking at the interrupt
rate, not the exit rate (which is usually a multiple of the interrupt
rate, since you have to factor in as many as three exits per interrupt
(IPI, window, EOI).  Therefore we saved about 18k interrupts in this 10
second burst, but we may have actually saved up to 54k exits in the
process. This is only over a 10 second window at GigE rates, so YMMV.
These numbers get even more dramatic on higher end hardware, but I
haven't had a chance to generate new numbers yet.

Looking at some external stats paints an even bleaker picture: "exits"
as reported by kvm_stat for virtio-pci based virtio-net tip the scales
at 65k/s vs 36k/s for vbus based venet.  And virtio is consuming ~30% of
my quad-core's cpu, vs 19% for venet during the test.  Its hard to know
which innovation or innovations may be responsible for the entire
reduction, but certainly the interrupt-to-signal ratio mentioned above
is probably helping.

The even worse news for 1:1 models is that the ratio of
exits-per-interrupt climbs with load (exactly when it hurts the most)
since that is when the probability that the vcpu will need all three
exits is the highest.

>=20
>> and priortizable/nestable signals.
>>   =20
>=20
> That doesn't belong in a bus.

Everyone is of course entitled to an opinion, but the industry as a
whole would disagree with you.  Signal path routing (1:1, aggregated,
etc) is at the discretion of the bus designer.  Most buses actually do
_not_ support 1:1 with IDT (think USB, SCSI, IDE, etc).

PCI is somewhat of an outlier in that regard afaict.  Its actually a
nice feature of PCI when its used within its design spec (HW).  For
SW/PV, 1:1 suffers from, among other issues, that "triple-exit scaling"
issue in the signal path I mentioned above.  This is one of the many
reasons I think PCI is not the best choice for PV.

>=20
>> Today there is a large performance disparity between what a KVM guest
>> sees and what a native linux application sees on that same host.  Just=

>> take a look at some of my graphs between "virtio", and "native", for
>> example:
>>
>> http://developer.novell.com/wiki/images/b/b7/31-rc4_throughput.png
>>   =20
>=20
> That's a red herring.  The problem is not with virtio as an ABI, but
> with its implementation in userspace.  vhost-net should offer equivalen=
t
> performance to vbus.

That's pure speculation.  I would advise you to reserve such statements
until after a proper bakeoff can be completed.  This is not to mention
that vhost-net does nothing to address our other goals, like scheduler
coordination and non-802.x fabrics.

>=20
>> A dominant vbus design principle is to try to achieve the same IO
>> performance for all "linux applications" whether they be literally
>> userspace applications, or things like KVM vcpus or Ira's physical
>> boards.  It also aims to solve problems not previously expressible wit=
h
>> current technologies (even virtio), like nested real-time.
>>
>> And even though you repeatedly insist otherwise, the neat thing here i=
s
>> that the two technologies mesh (at least under certain circumstances,
>> like when virtio is deployed on a shared-memory friendly linux backend=

>> like KVM).  I hope that my stack diagram below depicts that clearly.
>>   =20
>=20
> Right, when you ignore the points where they don't fit, it's a perfect
> mesh.

Where doesn't it fit?

>=20
>>> But that's not a strong argument for vbus; instead of adding vbus you=

>>> could make virtio more friendly to non-virt
>>>     =20
>> Actually, it _is_ a strong argument then because adding vbus is what
>> helps makes virtio friendly to non-virt, at least for when performance=

>> matters.
>>   =20
>=20
> As vhost-net shows, you can do that without vbus

Citation please.  Afaict, the one use case that we looked at for vhost
outside of KVM failed to adapt properly, so I do not see how this is true=
=2E

> and without breaking compatibility.

Compatibility with what?  vhost hasn't even been officially deployed in
KVM environments afaict, nevermind non-virt.  Therefore, how could it
possibly have compatibility constraints with something non-virt already?
 Citation please.

>=20
>=20
>=20
>>> Right.  virtio assumes that it's in a virt scenario and that the gues=
t
>>> architecture already has enumeration and hotplug mechanisms which it
>>> would prefer to use.  That happens to be the case for kvm/x86.
>>>     =20
>> No, virtio doesn't assume that.  It's stack provides the "virtio-bus"
>> abstraction and what it does assume is that it will be wired up to
>> something underneath. Kvm/x86 conveniently has pci, so the virtio-pci
>> adapter was created to reuse much of that facility.  For other things
>> like lguest and s360, something new had to be created underneath to ma=
ke
>> up for the lack of pci-like support.
>>   =20
>=20
> Right, I was wrong there.  But it does allow you to have a 1:1 mapping
> between native devices and virtio devices.

vbus allows you to have 1:1 if that is what you want, but we strive to
do better.

>=20
>=20
>>>> So to answer your question, the difference is that the part that has=
 to
>>>> be customized in vbus should be a fraction of what needs to be
>>>> customized with vhost because it defines more of the stack.
>>>>       =20
>>> But if you want to use the native mechanisms, vbus doesn't have any
>>> added value.
>>>     =20
>> First of all, thats incorrect.  If you want to use the "native"
>> mechanisms (via the way the vbus-connector is implemented, for instanc=
e)
>> you at least still have the benefit that the backend design is more
>> broadly re-useable in more environments (like non-virt, for instance),=

>> because vbus does a proper job of defining the requisite
>> layers/abstractions compared to vhost.  So it adds value even in that
>> situation.
>>   =20
>=20
> Maybe.  If vhost-net isn't sufficient I'm sure there will be patches se=
nt.

It isn't, and I've already done that.

>=20
>> Second of all, with PV there is no such thing as "native".  It's
>> software so it can be whatever we want.  Sure, you could argue that th=
e
>> guest may have built-in support for something like PCI protocol.

[1]

>> However, PCI protocol itself isn't suitable for high-performance PV ou=
t
>> of the can.  So you will therefore invariably require new software
>> layers on top anyway, even if part of the support is already included.=

>>   =20
>=20
> Of course there is such a thing as native, a pci-ready guest has tons o=
f
> support built into it

I specifically mentioned that already ([1]).

You are also overstating its role, since the basic OS is what implements
the native support for bus-objects, hotswap, etc, _not_ PCI.  PCI just
rides underneath and feeds trivial events up, as do other bus-types
(usb, scsi, vbus, etc).  And once those events are fed, you still need a
PV layer to actually handle the bus interface in a high-performance
manner so its not like you really have a "native" stack in either case.

> that doesn't need to be retrofitted.

No, that is incorrect.  You have to heavily modify the pci model with
layers on top to get any kind of performance out of it.  Otherwise, we
would just use realtek emulation, which is technically the native PCI
you are apparently so enamored with.

Not to mention there are things you just plain can't do in PCI today,
like dynamically assign signal-paths, priority, and coalescing, etc.

> Since
> practically everyone (including Xen) does their paravirt drivers atop
> pci, the claim that pci isn't suitable for high performance is incorrec=
t.

Actually IIUC, I think Xen bridges to their own bus as well (and only
where they have to), just like vbus.  They don't use PCI natively.  PCI
is perfectly suited as a bridge transport for PV, as I think the Xen and
vbus examples have demonstrated.  Its the 1:1 device-model where PCI has
the most problems.

>=20
>=20
>> And lastly, why would you _need_ to use the so called "native"
>> mechanism?  The short answer is, "you don't".  Any given system (guest=

>> or bare-metal) already have a wide-range of buses (try running "tree
>> /sys/bus" in Linux).  More importantly, the concept of adding new buse=
s
>> is widely supported in both the Windows and Linux driver model (and
>> probably any other guest-type that matters).  Therefore, despite claim=
s
>> to the contrary, its not hard or even unusual to add a new bus to the
>> mix.
>>   =20
>=20
> The short answer is "compatibility".

There was a point in time where the same could be said for virtio-pci
based drivers vs realtek and e1000, so that argument is demonstrably
silly.  No one tried to make virtio work in a binary compatible way with
realtek emulation, yet we all survived the requirement for loading a
virtio driver to my knowledge.

The bottom line is: Binary device compatibility is not required in any
other system (as long as you follow sensible versioning/id rules), so
why is KVM considered special?

The fact is, it isn't special (at least not in this regard).  What _is_
required is "support" and we fully intend to support these proposed
components.  I assure you that at least the users that care about
maximum performance will not generally mind loading a driver.  Most of
them would have to anyway if they want to get beyond realtek emulation.

>=20
>=20
>> In summary, vbus is simply one more bus of many, purpose built to
>> support high-end IO in a virt-like model, giving controlled access to
>> the linux-host underneath it.  You can write a high-performance layer
>> below the OS bus-model (vbus), or above it (virtio-pci) but either way=

>> you are modifying the stack to add these capabilities, so we might as
>> well try to get this right.
>>
>> With all due respect, you are making a big deal out of a minor issue.
>>   =20
>=20
> It's not minor to me.

I am certainly in no position to tell you how to feel, but this
declaration would seem from my perspective to be more of a means to an
end than a legitimate concern.  Otherwise we would never have had virtio
support in the first place, since it was not "compatible" with previous
releases.

>=20
>>>> And, as
>>>> eluded to in my diagram, both virtio-net and vhost (with some
>>>> modifications to fit into the vbus framework) are potentially
>>>> complementary, not competitors.
>>>>
>>>>       =20
>>> Only theoretically.  The existing installed base would have to be thr=
own
>>> away
>>>     =20
>> "Thrown away" is pure hyperbole.  The installed base, worse case, need=
s
>> to load a new driver for a missing device.
>=20
> Yes, we all know how fun this is.

Making systems perform 5x faster _is_ fun, yes.  I love what I do for a
living.

>  Especially if the device changed is your boot disk.

If and when that becomes a priority concern, that would be a function
transparently supported in the BIOS shipped with the hypervisor, and
would thus be invisible to the user.

>  You may not care about the pain caused to users, but I do, so I will
> continue to insist on compatibility.

No, you are incorrect on two counts.

1) Of course I care about pain to users or I wouldn't be funded.  Right
now the pain from my perspective is caused to users in the
high-performance community who want to deploy KVM based solutions.  They
are unable to do so due to its performance disparity compared to
bare-metal, outside of pass-through hardware which is not widely
available in a lot of existing deployments.  I aim to fix that disparity
while reusing the existing hardware investment by writing smarter
software, and I assure you that these users won't mind loading a driver
in the guest to take advantage of it.

For the users that don't care about maximum performance, there is no
change (and thus zero pain) required.  They can use realtek or virtio if
they really want to.  Neither is going away to my knowledge, and lets
face it: 2.6Gb/s out of virtio to userspace isn't *that* bad.  But "good
enough" isn't good enough, and I won't rest till we get to native
performance.  Additionally, I want to support previously unavailable
modes of operations (e.g. real-time) and advanced fabrics (e.g. IB).

2) True pain to users is not caused by lack of binary compatibility.
Its caused by lack of support.  And its a good thing or we would all be
emulating 8086 architecture forever...

=2E.oh wait, I guess we kind of do that already ;).  But at least we can
slip in something more advanced once in a while (APIC vs PIC, USB vs
uart, iso9660 vs floppy, for instance) and update the guest stack
instead of insisting it must look like ISA forever for compatibility's sa=
ke.

>=20
>>> or we'd need to support both.
>>>
>>>
>>>     =20
>> No matter what model we talk about, there's always going to be a "both=
"
>> since the userspace virtio models are probably not going to go away (n=
or
>> should they).
>>   =20
>=20
> virtio allows you to have userspace-only, kernel-only, or
> start-with-userspace-and-move-to-kernel-later, all transparent to the
> guest.  In many cases we'll stick with userspace-only.

The user will not care where the model lives, per se.  Only that it is
supported, and it works well.

Likewise, I know from experience that the developer will not like
writing the same code twice, so the "runs in both" model is not
necessarily a great design trait either.

>=20
>>> All this is after kvm has decoded that vbus is addresses.  It can't w=
ork
>>> without someone outside vbus deciding that.
>>>     =20
>> How the connector message is delivered is really not relevant.  Some
>> architectures will simply deliver the message point-to-point (like the=

>> original hypercall design for KVM, or something like Ira's rig), and
>> some will need additional demuxing (like pci-bridge/pio based KVM).
>> It's an implementation detail of the connector.
>>
>> However, the real point here is that something needs to establish a
>> scoped namespace mechanism, add items to that namespace, and advertise=

>> the presence of the items to the guest.  vbus has this facility built =
in
>> to its stack.  vhost doesn't, so it must come from elsewhere.
>>   =20
>=20
> So we have: vbus needs a connector, vhost needs a connector.  vbus
> doesn't need userspace to program the addresses (but does need userspac=
e
> to instantiate the devices and to program the bus address decode)

First of all, bus-decode is substantially easier than per-device decode
(you have to track all those per-device/per-signal fds somewhere,
integrate with hotswap, etc), and its only done once per guest at
startup and left alone.  So its already not apples to apples.

Second, while its true that the general kvm-connector bus-decode needs
to be programmed,  that is a function of adapting to the environment
that _you_ created for me.  The original kvm-connector was discovered
via cpuid and hypercalls, and didn't need userspace at all to set it up.
 Therefore it would be entirely unfair of you to turn around and somehow
try to use that trait of the design against me since you yourself
imposed it.

As an additional data point, our other connectors have no such
bus-decode programming requirement.  Therefore, this is clearly
just a property of the KVM environment, not a function of the overall
vbus design.

> vhost needs userspace to instantiate the devices and program the addres=
ses.
>=20

Right.  And among other shortcomings it also requires a KVM-esque memory
model (which is not always going to work as we recently discussed), and
a redundant device-model to back it up in userspace, which is a
development and maintenance burden, and an external bus-model (filled by
pio-bus in KVM today).

>>>> In fact, it's actually a simpler design to unify things this way
>>>> because
>>>> you avoid splitting the device model up. Consider how painful the vh=
ost
>>>> implementation would be if it didn't already have the userspace
>>>> virtio-net to fall-back on.  This is effectively what we face for ne=
w
>>>> devices going forward if that model is to persist.
>>>>
>>>>       =20
>>>
>>> It doesn't have just virtio-net, it has userspace-based hostplug
>>>     =20
>> vbus has hotplug too: mkdir and rmdir
>>   =20
>=20
> Does that work from nonprivileged processes?

It will with the ioctl based control interface that I'll merge shortly.

>  Does it work on Windows?

This question doesn't make sense.  Hotswap control occurs on the host,
which is always Linux.

If you were asking about whether a windows guest will support hotswap:
the answer is "yes".  Our windows driver presents a unique PDO/FDO pair
for each logical device instance that is pushed out (just like the built
in usb, pci, scsi bus drivers that windows supports natively).

>=20
>> As an added bonus, its device-model is modular.  A developer can write=
 a
>> new device model, compile it, insmod it to the host kernel, hotplug it=

>> to the running guest with mkdir/ln, and the come back out again
>> (hotunplug with rmdir, rmmod, etc).  They may do this all without taki=
ng
>> the guest down, and while eating QEMU based IO solutions for breakfast=

>> performance wise.
>>
>> Afaict, qemu can't do either of those things.
>>   =20
>=20
> We've seen that herring before,

Citation?

> and it's redder than ever.

This is more hyperbole.  I doubt that there would be many that would
argue that a modular architecture (that we get for free with LKM
support) is not desirable, even if its never used dynamically with a
running guest.  OTOH, I actually use this dynamic feature all the time
as I test my components, so its at least useful to me.

>=20
>=20
>=20
>>> Refactor instead of duplicating.
>>>     =20
>> There is no duplicating.  vbus has no equivalent today as virtio doesn=
't
>> define these layers.
>>   =20
>=20
> So define them if they're missing.

I just did.

>=20
>=20
>>>>
>>>>      =20
>>>>>    Use libraries (virtio-shmem.ko, libvhost.so).
>>>>>
>>>>>         =20
>>>> What do you suppose vbus is?  vbus-proxy.ko =3D virtio-shmem.ko, and=
 you
>>>> dont need libvhost.so per se since you can just use standard kernel
>>>> interfaces (like configfs/sysfs).  I could create an .so going forwa=
rd
>>>> for the new ioctl-based interface, I suppose.
>>>>
>>>>       =20
>>> Refactor instead of rewriting.
>>>     =20
>> There is no rewriting.  vbus has no equivalent today as virtio doesn't=

>> define these layers.
>>
>> By your own admission, you said if you wanted that capability, use a
>> library.  What I think you are not understanding is vbus _is_ that
>> library.  So what is the problem, exactly?
>>   =20
>=20
> It's not compatible.

No, that is incorrect.  What you are apparently not understanding is
that not only is vbus that library, but its extensible.  So even if
compatibility is your goal (it doesn't need to be IMO) it can be
accommodated by how you interface to the library.

>  If you were truly worried about code duplication
> in virtio, you'd refactor it to remove the duplication,

My primary objective is creating an extensible, high-performance,
shared-memory interconnect for systems that utilize a Linux host as
their IO-hub.  It just so happens that virtio can sit nicely on top of
such a model because shmem-rings are a subclass of shmem.  As a result
of its design, vbus also helps to reduce code duplication in the stack
for new environments due to its extensible nature.

However, vbus also has goals beyond what virtio is providing today that
are of more concern, and part of that is designing a connector/bus that
eliminates the shortcomings in the current pci-based design.

> without affecting existing guests.

Already covered above.

>=20
>>>>> For kvm/x86 pci definitely remains king.
>>>>>
>>>>>         =20
>>>> For full virtualization, sure.  I agree.  However, we are talking ab=
out
>>>> PV here.  For PV, PCI is not a requirement and is a technical dead-e=
nd
>>>> IMO.
>>>>
>>>> KVM seems to be the only virt solution that thinks otherwise (*), bu=
t I
>>>> believe that is primarily a condition of its maturity.  I aim to hel=
p
>>>> advance things here.
>>>>
>>>> (*) citation: xen has xenbus, lguest has lguest-bus, vmware has some=

>>>> vmi-esq thing (I forget what its called) to name a few.  Love 'em or=

>>>> hate 'em, most other hypervisors do something along these lines.  I'=
d
>>>> like to try to create one for KVM, but to unify them all (at least f=
or
>>>> the Linux-based host designs).
>>>>
>>>>       =20
>>> VMware are throwing VMI away (won't be supported in their new product=
,
>>> and they've sent a patch to rip it off from Linux);
>>>     =20
>> vmware only cares about x86 iiuc, so probably not a good example.
>>   =20
>=20
> Well, you brought it up.  Between you and me, I only care about x86 too=
=2E

Fair enough.

>=20
>>> Xen has to tunnel
>>> xenbus in pci for full virtualization (which is where Windows is, and=

>>> where Linux will be too once people realize it's faster).  lguest is
>>> meant as an example hypervisor, not an attempt to take over the world=
=2E
>>>     =20
>> So pick any other hypervisor, and the situation is often similar.
>>   =20
>=20
> The situation is often pci.

Even if that were true, which is debatable, do not confuse "convenient"
with "optimal".  If you don't care about maximum performance and
advanced features like QOS, sure go ahead and use PCI.  Why not.

>=20
>>
>>> An right now you can have a guest using pci to access a mix of
>>> userspace-emulated devices, userspace-emulated-but-kernel-accelerated=

>>> virtio devices, and real host devices.  All on one dead-end bus.  Try=

>>> that with vbus.
>>>     =20
>> vbus is not interested in userspace devices.  The charter is to provid=
e
>> facilities for utilizing the host linux kernel's IO capabilities in th=
e
>> most efficient, yet safe, manner possible.  Those devices that fit
>> outside that charter can ride on legacy mechanisms if that suits them
>> best.
>>   =20
>=20
> vbus isn't, but I am.  I would prefer not to have to expose
> implementation decisions (kernel vs userspace) to the guest (vbus vs pc=
i).
>=20
>>>> That won't cut it.  For one, creating an eventfd is only part of the=

>>>> equation.  I.e. you need to have originate/terminate somewhere
>>>> interesting (and in-kernel, otherwise use tuntap).
>>>>
>>>>       =20
>>> vbus needs the same thing so it cancels out.
>>>     =20
>> No, it does not.  vbus just needs a relatively simple single message
>> pipe between the guest and host (think "hypercall tunnel", if you will=
).
>>   =20
>=20
> That's ioeventfd.  So far so similar.

No, that is incorrect.  For one, vhost uses them on a per-signal path
basis, whereas vbus only has one channel for the entire guest->host.

Second, I do not use ioeventfd anymore because it has too many problems
with the surrounding technology.  However, that is a topic for a
different thread.


>=20
>>   Per queue/device addressing is handled by the same conceptual namesp=
ace
>> as the one that would trigger eventfds in the model you mention.  And
>> that namespace is built in to the vbus stack, and objects are register=
ed
>> automatically as they are created.
>>
>> Contrast that to vhost, which requires some other kernel interface to
>> exist, and to be managed manually for each object that is created.  Yo=
ur
>> libvhostconfig would need to somehow know how to perform this
>> registration operation, and there would have to be something in the
>> kernel to receive it, presumably on a per platform basis.  Solving thi=
s
>> problem generally would probably end up looking eerily like vbus,
>> because thats what vbus does.
>>   =20
>=20
> vbus devices aren't magically instantiated.  Userspace needs to
> instantiate them too.  Sure, there's less work on the host side since
> you're using vbus instead of the native interface, but more work on the=

> guest side since you're using vbus instead of the native interface.


No, that is incorrect.  The amount of "work" that a guest does is
actually the same in both cases, since the guest OS peforms the hotswap
handling natively for all bus types (at least for Linux and Windows).
You still need to have a PV layer to interface with those objects in
both cases, as well, so there is no such thing as "native interface" for
PV.  Its only a matter of where it occurs in the stack.

>=20
>=20
>=20
>>> Well, let's see.  Can vbus today:
>>>
>>> - let userspace know which features are available (so it can decide i=
f
>>> live migration is possible)
>>>     =20
>> yes, its in sysfs.
>>
>>  =20
>>> - let userspace limit which features are exposed to the guest (so it =
can
>>> make live migration possible among hosts of different capabilities)
>>>     =20
>> yes, its in sysfs.
>>   =20
>=20
> Per-device?

Yes, see /sys/vbus/devices/$dev/ to get per-instance attributes

>  non-privileged-user capable?

The short answer is "not yet (I think)".  I need to write a patch to
properly set the mode attribute in sysfs, but I think this will be trivia=
l.

>=20
>>> - let userspace know which features were negotiated (so it can transf=
er
>>> them to the other host during live migration)
>>>     =20
>> no, but we can easily add ->save()/->restore() to the model going
>> forward, and the negotiated features are just a subcomponent if its
>> serialized stream.
>>
>>  =20
>>> - let userspace tell the kernel which features were negotiated (when
>>> live migration completes, to avoid requiring the guest to re-negotiat=
e)
>>>     =20
>> that would be the function of the ->restore() deserializer.
>>
>>  =20
>>> - do all that from an unprivileged process
>>>     =20
>> yes, in the upcoming alacrityvm v0.3 with the ioctl based control plan=
e.
>>   =20
>=20
> Ah, so you have two control planes.

So what?  If anything, it goes to show how extensible the framework is
that a new plane could be added in 119 lines of code:

~/git/linux-2.6> stg show vbus-add-admin-ioctls.patch | diffstat
 Makefile       |    3 -
 config-ioctl.c |  117
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+), 1 deletion(-)

if and when having two control planes exceeds its utility, I will submit
a simple patch that removes the useless one.

>=20
>> Bottom line: vbus isn't done, especially w.r.t. live-migration..but th=
at
>> is not an valid argument against the idea if you believe in
>> release-early/release-often. kvm wasn't (isn't) done either when it wa=
s
>> proposed/merged.
>>
>>   =20
>=20
> kvm didn't have an existing counterpart in Linux when it was
> proposed/merged.
>=20

And likewise, neither does vbus.

Kind Regards,
-Greg










--------------enigFF1C78857214B551CF98A1FD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrDucYACgkQP5K2CMvXmqFgawCcDhiQkZ6RNmM3fZg+u5vPTPIT
o8wAn0Nes4wHsIZLAtH+6CCZ5orvy2Yh
=qkIs
-----END PGP SIGNATURE-----

--------------enigFF1C78857214B551CF98A1FD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

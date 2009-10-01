Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CFE7D6B005D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 14:39:27 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so141200qwc.44
        for <linux-mm@kvack.org>; Thu, 01 Oct 2009 12:24:32 -0700 (PDT)
Message-ID: <4AC501EB.8090608@gmail.com>
Date: Thu, 01 Oct 2009 15:24:27 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com> <4ABC7DCE.2000404@redhat.com> <4ABD36E3.9070503@gmail.com> <4ABF33B2.4000805@redhat.com> <4AC3B9C6.5090408@gmail.com> <4AC46989.7030502@redhat.com>
In-Reply-To: <4AC46989.7030502@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD39FC577A73B17A2F573919D"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD39FC577A73B17A2F573919D
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/30/2009 10:04 PM, Gregory Haskins wrote:
>=20
>=20
>>> A 2.6.27 guest, or Windows guest with the existing virtio drivers,
>>> won't work
>>> over vbus.
>>>     =20
>> Binary compatibility with existing virtio drivers, while nice to have,=

>> is not a specific requirement nor goal.  We will simply load an update=
d
>> KMP/MSI into those guests and they will work again.  As previously
>> discussed, this is how more or less any system works today.  It's like=

>> we are removing an old adapter card and adding a new one to "uprev the=

>> silicon".
>>   =20
>=20
> Virtualization is about not doing that.  Sometimes it's necessary (when=

> you have made unfixable design mistakes), but just to replace a bus,
> with no advantages to the guest that has to be changed (other
> hypervisors or hypervisorless deployment scenarios aren't).

The problem is that your continued assertion that there is no advantage
to the guest is a completely unsubstantiated claim.  As it stands right
now, I have a public git tree that, to my knowledge, is the fastest KVM
PV networking implementation around.  It also has capabilities that are
demonstrably not found elsewhere, such as the ability to render generic
shared-memory interconnects (scheduling, timers), interrupt-priority
(qos), and interrupt-coalescing (exit-ratio reduction).  I designed each
of these capabilities after carefully analyzing where KVM was coming up
short.

Those are facts.

I can't easily prove which of my new features alone are what makes it
special per se, because I don't have unit tests for each part that
breaks it down.  What I _can_ state is that its the fastest and most
feature rich KVM-PV tree that I am aware of, and others may download and
test it themselves to verify my claims.

The disproof, on the other hand, would be in a counter example that
still meets all the performance and feature criteria under all the same
conditions while maintaining the existing ABI.  To my knowledge, this
doesn't exist.

Therefore, if you believe my work is irrelevant, show me a git tree that
accomplishes the same feats in a binary compatible way, and I'll rethink
my position.  Until then, complaining about lack of binary compatibility
is pointless since it is not an insurmountable proposition, and the one
and only available solution declares it a required casualty.

>=20
>>>   Further, non-shmem virtio can't work over vbus.
>>>     =20
>> Actually I misspoke earlier when I said virtio works over non-shmem.
>> Thinking about it some more, both virtio and vbus fundamentally requir=
e
>> shared-memory, since sharing their metadata concurrently on both sides=

>> is their raison d'=C3=AAtre.
>>
>> The difference is that virtio utilizes a pre-translation/mapping (via
>> ->add_buf) from the guest side.  OTOH, vbus uses a post translation
>> scheme (via memctx) from the host-side.  If anything, vbus is actually=

>> more flexible because it doesn't assume the entire guest address space=

>> is directly mappable.
>>
>> In summary, your statement is incorrect (though it is my fault for
>> putting that idea in your head).
>>   =20
>=20
> Well, Xen requires pre-translation (since the guest has to give the hos=
t
> (which is just another guest) permissions to access the data).

Actually I am not sure that it does require pre-translation.  You might
be able to use the memctx->copy_to/copy_from scheme in post translation
as well, since those would be able to communicate to something like the
xen kernel.  But I suppose either method would result in extra exits, so
there is no distinct benefit using vbus there..as you say below "they're
just different".

The biggest difference is that my proposed model gets around the notion
that the entire guest address space can be represented by an arbitrary
pointer.  For instance, the copy_to/copy_from routines take a GPA, but
may use something indirect like a DMA controller to access that GPA.  On
the other hand, virtio fully expects a viable pointer to come out of the
interface iiuc.  This is in part what makes vbus more adaptable to non-vi=
rt.

> So neither is a superset of the other, they're just different.
>=20
> It doesn't really matter since Xen is unlikely to adopt virtio.

Agreed.

>=20
>> An interesting thing here is that you don't even need a fancy
>> multi-homed setup to see the effects of my exit-ratio reduction work:
>> even single port configurations suffer from the phenomenon since many
>> devices have multiple signal-flows (e.g. network adapters tend to have=

>> at least 3 flows: rx-ready, tx-complete, and control-events (link-stat=
e,
>> etc).  Whats worse, is that the flows often are indirectly related (fo=
r
>> instance, many host adapters will free tx skbs during rx operations, s=
o
>> you tend to get bursts of tx-completes at the same time as rx-ready.  =
If
>> the flows map 1:1 with IDT, they will suffer the same problem.
>>   =20
>=20
> You can simply use the same vector for both rx and tx and poll both at
> every interrupt.

Yes, but that has its own problems: e.g. additional exits or at least
additional overhead figuring out what happens each time.  This is even
more important as we scale out to MQ which may have dozens of queue
pairs.  You really want finer grained signal-path decode if you want
peak performance.

>=20
>> In any case, here is an example run of a simple single-homed guest ove=
r
>> standard GigE.  Whats interesting here is that .qnotify to .notify
>> ratio, as this is the interrupt-to-signal ratio.  In this case, its
>> 170047/151918, which comes out to about 11% savings in interrupt
>> injections:
>>
>> vbus-guest:/home/ghaskins # netperf -H dev
>> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> dev.laurelwood.net (192.168.1.10) port 0 AF_INET
>> Recv   Send    Send
>> Socket Socket  Message  Elapsed
>> Size   Size    Size     Time     Throughput
>> bytes  bytes   bytes    secs.    10^6bits/sec
>>
>> 1048576  16384  16384    10.01     940.77
>> vbus-guest:/home/ghaskins # cat /sys/kernel/debug/pci-to-vbus-bridge
>>    .events                        : 170048
>>    .qnotify                       : 151918
>>    .qinject                       : 0
>>    .notify                        : 170047
>>    .inject                        : 18238
>>    .bridgecalls                   : 18
>>    .buscalls                      : 12
>> vbus-guest:/home/ghaskins # cat /proc/interrupts
>>              CPU0
>>     0:         87   IO-APIC-edge      timer
>>     1:          6   IO-APIC-edge      i8042
>>     4:        733   IO-APIC-edge      serial
>>     6:          2   IO-APIC-edge      floppy
>>     7:          0   IO-APIC-edge      parport0
>>     8:          0   IO-APIC-edge      rtc0
>>     9:          0   IO-APIC-fasteoi   acpi
>>    10:          0   IO-APIC-fasteoi   virtio1
>>    12:         90   IO-APIC-edge      i8042
>>    14:       3041   IO-APIC-edge      ata_piix
>>    15:       1008   IO-APIC-edge      ata_piix
>>    24:     151933   PCI-MSI-edge      vbus
>>    25:          0   PCI-MSI-edge      virtio0-config
>>    26:        190   PCI-MSI-edge      virtio0-input
>>    27:         28   PCI-MSI-edge      virtio0-output
>>   NMI:          0   Non-maskable interrupts
>>   LOC:       9854   Local timer interrupts
>>   SPU:          0   Spurious interrupts
>>   CNT:          0   Performance counter interrupts
>>   PND:          0   Performance pending work
>>   RES:          0   Rescheduling interrupts
>>   CAL:          0   Function call interrupts
>>   TLB:          0   TLB shootdowns
>>   TRM:          0   Thermal event interrupts
>>   THR:          0   Threshold APIC interrupts
>>   MCE:          0   Machine check exceptions
>>   MCP:          1   Machine check polls
>>   ERR:          0
>>   MIS:          0
>>
>> Its important to note here that we are actually looking at the interru=
pt
>> rate, not the exit rate (which is usually a multiple of the interrupt
>> rate, since you have to factor in as many as three exits per interrupt=

>> (IPI, window, EOI).  Therefore we saved about 18k interrupts in this 1=
0
>> second burst, but we may have actually saved up to 54k exits in the
>> process. This is only over a 10 second window at GigE rates, so YMMV.
>> These numbers get even more dramatic on higher end hardware, but I
>> haven't had a chance to generate new numbers yet.
>>   =20
>=20
> (irq window exits should only be required on a small percentage of
> interrupt injections, since the guest will try to disable interrupts fo=
r
> short periods only)

Good point. You are probably right. Certainly the other 2 remain, however=
=2E

Ultimately, the fastest exit is the one you do not take.  That is what I
am trying to achieve.

>=20
>> Looking at some external stats paints an even bleaker picture: "exits"=

>> as reported by kvm_stat for virtio-pci based virtio-net tip the scales=

>> at 65k/s vs 36k/s for vbus based venet.  And virtio is consuming ~30% =
of
>> my quad-core's cpu, vs 19% for venet during the test.  Its hard to kno=
w
>> which innovation or innovations may be responsible for the entire
>> reduction, but certainly the interrupt-to-signal ratio mentioned above=

>> is probably helping.
>>   =20
>=20
> Can you please stop comparing userspace-based virtio hosts to
> kernel-based venet hosts?  We know the userspace implementation sucks.

Sorry, but its all I have right now.  Last time I tried vhost it
required a dedicated adapter which was a non-starter for my lab rig
since I share it with others.  I didn't want to tear apart the bridge
setup, especially since mst told me the performance was worse than
userspace.  Therefore, there was no real point in working hard to get it
running.  I figured I would wait till the config and performance issues
were resolved and there is a git tree to pull in.

>=20
>> The even worse news for 1:1 models is that the ratio of
>> exits-per-interrupt climbs with load (exactly when it hurts the most)
>> since that is when the probability that the vcpu will need all three
>> exits is the highest.
>>   =20
>=20
> Requiring all three exits means the guest is spending most of its time
> with interrupts disabled; that's unlikely.

(see "softirqs" above)

>=20
> Thanks for the numbers.  Are those 11% attributable to rx/tx
> piggybacking from the same interface?

Its hard to tell, since I am not instrumented to discern the difference
in this run.  I do know from previous traces on the 10GE rig that the
chelsio T3 that I am running reaps the pending-tx ring at the same time
as a rx polling, so its very likely that both events are often
coincident at least there.

>=20
> Also, 170K interupts -> 17K interrupts/sec -> 55kbit/interrupt ->
> 6.8kB/interrupt.  Ignoring interrupt merging and assuming equal rx/tx
> distribution, that's about 13kB/interrupt.  Seems rather low for a
> saturated link.

I am not following: Do you suspect that I have too few interrupts to
represent 940Mb/s, or that I have too little data/interrupt and this
ratio should be improved?

>=20
>>>    =20
>>>> and priortizable/nestable signals.
>>>>
>>>>       =20
>>> That doesn't belong in a bus.
>>>     =20
>> Everyone is of course entitled to an opinion, but the industry as a
>> whole would disagree with you.  Signal path routing (1:1, aggregated,
>> etc) is at the discretion of the bus designer.  Most buses actually do=

>> _not_ support 1:1 with IDT (think USB, SCSI, IDE, etc).
>>   =20
>=20
> With standard PCI, they do not.  But all modern host adapters support
> MSI and they will happily give you one interrupt per queue.

While MSI is a good technological advancement for PCI, I was referring
to signal:IDT ratio.  MSI would still classify as 1:1.

>=20
>> PCI is somewhat of an outlier in that regard afaict.  Its actually a
>> nice feature of PCI when its used within its design spec (HW).  For
>> SW/PV, 1:1 suffers from, among other issues, that "triple-exit scaling=
"
>> issue in the signal path I mentioned above.  This is one of the many
>> reasons I think PCI is not the best choice for PV.
>>   =20
>=20
> Look at the vmxnet3 submission (recently posted on virtualization@).=20
> It's a perfectly ordinary PCI NIC driver, apart from having so many 'V'=
s
> in the code.  16 rx queues, 8 tx queues, 25 MSIs, BARs for the
> registers.  So while the industry as a whole might disagree with me, it=

> seems VMware does not.

At the very least, BARs for the registers is worrisome, but I will
reserve judgment until I see the numbers and review the code.

>=20
>=20
>>>> http://developer.novell.com/wiki/images/b/b7/31-rc4_throughput.png
>>>>
>>>>       =20
>>> That's a red herring.  The problem is not with virtio as an ABI, but
>>> with its implementation in userspace.  vhost-net should offer equival=
ent
>>> performance to vbus.
>>>     =20
>> That's pure speculation.  I would advise you to reserve such statement=
s
>> until after a proper bakeoff can be completed.
>=20
> Let's do that then.  Please reserve the corresponding comparisons from
> your side as well.

That is quite the odd request.  My graphs are all built using readily
available code and open tools and do not speculate as to what someone
else may come up with in the future.  They reflect what is available
today.  Do you honestly think I should wait indefinitely for a competing
idea to try to catch up before I talk about my results?  That's
certainly an interesting perspective.

With all due respect, the only red-herring is your unsubstantiated
claims that my results do not matter.

>=20
>> This is not to mention
>> that vhost-net does nothing to address our other goals, like scheduler=

>> coordination and non-802.x fabrics.
>>   =20
>=20
> What are scheduler coordination and non-802.x fabrics?

We are working on real-time, IB and QOS, for examples, in addition to
the now well known 802.x venet driver.

>=20
>>> Right, when you ignore the points where they don't fit, it's a perfec=
t
>>> mesh.
>>>     =20
>> Where doesn't it fit?
>>   =20
>=20
> (avoiding infinite loop)

I'm serious.  Where doesn't it fit?  Point me at a URL if its already
discussed.

>=20
>>>>> But that's not a strong argument for vbus; instead of adding vbus y=
ou
>>>>> could make virtio more friendly to non-virt
>>>>>
>>>>>         =20
>>>> Actually, it _is_ a strong argument then because adding vbus is what=

>>>> helps makes virtio friendly to non-virt, at least for when performan=
ce
>>>> matters.
>>>>
>>>>       =20
>>> As vhost-net shows, you can do that without vbus
>>>     =20
>> Citation please.  Afaict, the one use case that we looked at for vhost=

>> outside of KVM failed to adapt properly, so I do not see how this is
>> true.
>>   =20
>=20
> I think Ira said he can make vhost work?
>=20

Not exactly.  It kind of works for 802.x only (albeit awkwardly) because
there is no strong distinction between "resource" and "consumer" with
ethernet.  So you can run it inverted without any serious consequences
(at least, not from consequences of the inversion).  Since the x86
boards are the actual resource providers in his system, other device
types will fail to map to the vhost model properly, like disk-io or
consoles for instance.

>>> and without breaking compatibility.
>>>     =20
>> Compatibility with what?  vhost hasn't even been officially deployed i=
n
>> KVM environments afaict, nevermind non-virt.  Therefore, how could it
>> possibly have compatibility constraints with something non-virt alread=
y?
>>   Citation please.
>>   =20
>=20
> virtio-net over pci is deployed.  Replacing the backend with vhost-net
> will require no guest modifications.

That _is_ a nice benefit, I agree.  I just do not agree its a hard
requirement.

>  Replacing the frontend with venet or virt-net/vbus-pci will require gu=
est modifications.

Understood, and I am ok with that.  I think its necessary to gain
critical performance enhancing features, and I think it will help in the
long term to support more guests.  I have not yet been proven wrong.

>=20
> Obviously virtio-net isn't deployed in non-virt.  But if we adopt vbus,=

> we have to migrate guests.

As a first step, lets just shoot for "support" instead of "adopt".

Ill continue to push patches to you that help interfacing with the guest
in a vbus neutral way (like irqfd/ioeventfd) and we can go from there.
Are you open to this work assuming it passes normal review cycles, etc?
 It would presumably be of use to others that want to interface to a
guest (e.g. vhost) as well.

>=20
>=20
>=20
>>> Of course there is such a thing as native, a pci-ready guest has tons=
 of
>>> support built into it
>>>     =20
>> I specifically mentioned that already ([1]).
>>
>> You are also overstating its role, since the basic OS is what implemen=
ts
>> the native support for bus-objects, hotswap, etc, _not_ PCI.  PCI just=

>> rides underneath and feeds trivial events up, as do other bus-types
>> (usb, scsi, vbus, etc).
>=20
> But we have to implement vbus for each guest we want to support.  That
> includes Windows and older Linux which has a different internal API, so=

> we have to port the code multiple times, to get existing functionality.=


Perhaps, but in reality its not very bad.  The windows driver will
already support any recent version that matters (at least back to
2000/XP), and the Linux side doesn't do anything weird so I know it
works at least back to 2.6.16 iirc, and probably further.

>=20
>> And once those events are fed, you still need a
>> PV layer to actually handle the bus interface in a high-performance
>> manner so its not like you really have a "native" stack in either case=
=2E
>>   =20
>=20
> virtio-net doesn't use any pv layer.

Well, it does when you really look closely at how it works.  For one, it
has the virtqueues library that would be (or at least _should be_)
common for all virtio-X adapters, etc etc.  Even if this layer is
collapsed into each driver on the Windows platform, its still there
nonetheless.

>=20
>>> that doesn't need to be retrofitted.
>>>     =20
>> No, that is incorrect.  You have to heavily modify the pci model with
>> layers on top to get any kind of performance out of it.  Otherwise, we=

>> would just use realtek emulation, which is technically the native PCI
>> you are apparently so enamored with.
>>   =20
>=20
> virtio-net doesn't modify the PCI model.

Sure it does.  It doesn't use MMIO/PIO bars for registers, it uses
vq->kick().  It doesn't use pci-config-space, it uses virtio->features.
 It doesn't use PCI interrupts, it uses a callback on the vq etc, etc.
You would never use raw "registers", as the exit rate would crush you.
You would never use raw interrupts, as you need a shared-memory based
mitigation scheme.

IOW: Virtio has a device model layer that tunnels over PCI.  It doesn't
actually use PCI directly.  This is in fact what allows the linux
version to work over lguest, s390 and vbus in addition to PCI.

>  And if you look at vmxnet3,
> they mention that it conforms to somthing called UPT, which allows
> hardware vendors to implement parts of their NIC model.  So vmxnet3 is
> apparently suitable to both hardware and software implementations.
>=20

That's interesting and all, but the charter for vbus is for optimal
software-to-software interfaces to a linux host, so I don't mind if my
spec doesn't look conducive to a hardware implementation.  As it turns
out, I'm sure it would work there as well, but some of the optimizations
wouldn't matter as much since hardware behaves differently.

>> Not to mention there are things you just plain can't do in PCI today,
>> like dynamically assign signal-paths,
>=20
> You can have dynamic MSI/queue routing with virtio, and each MSI can be=

> routed to a vcpu at will.

Can you arbitrarily create a new MSI/queue on a per-device basis on the
fly?   We want to do this for some upcoming designs.  Or do you need to
predeclare the vectors when the device is hot-added?

>=20
>> priority, and coalescing, etc.
>>   =20
>=20
> Do you mean interrupt priority?  Well, apic allows interrupt priorities=

> and Windows uses them; Linux doesn't.  I don't see a reason to provide
> more than native hardware.

The APIC model is not optimal for PV given the exits required for a
basic operation like an interrupt injection, and has scaling/flexibility
issues with its 16:16 priority mapping.

OTOH, you don't necessarily want to rip it out because of all the
additional features it has like the IPI facility and the handling of
many low-performance data-paths.  Therefore, I am of the opinion that
the optimal placement for advanced signal handling is directly at the
bus that provides the high-performance resources.  I could be convinced
otherwise with a compelling argument, but I think this is the path of
least resistance.

>=20
>>> Since
>>> practically everyone (including Xen) does their paravirt drivers atop=

>>> pci, the claim that pci isn't suitable for high performance is
>>> incorrect.
>>>     =20
>> Actually IIUC, I think Xen bridges to their own bus as well (and only
>> where they have to), just like vbus.  They don't use PCI natively.  PC=
I
>> is perfectly suited as a bridge transport for PV, as I think the Xen a=
nd
>> vbus examples have demonstrated.  Its the 1:1 device-model where PCI h=
as
>> the most problems.
>>   =20
>=20
> N:1 breaks down on large guests since one vcpu will have to process all=

> events.

Well, first of all that is not necessarily true.  Some high performance
buses like SCSI and FC work fine with an aggregated model, so its not a
foregone conclusion that aggregation kills SMP IO performance.  This is
especially true when you adding coalescing on top, like AlacrityVM does.

I do agree that other subsystems, like networking for instance, may
sometimes benefit from flexible signal-routing because of multiqueue,
etc, for particularly large guests.  However, the decision to make the
current kvm-connector used in AlacrityVM aggregate one priority FIFO per
IRQ was an intentional design tradeoff.  My experience with my target
user base is that these data-centers are typically deploying 1-4 vcpu
guests, so I optimized for that.  YMMV, so we can design a different
connector, or a different mode of the existing connector, to accommodate
large guests as well if that was something desirable.

> You could do N:M, with commands to change routings, but where's
> your userspace interface?

Well, we should be able to add that when/if its needed.  I just don't
think the need is there yet.  KVM tops out at 16 IIUC anyway.

> you can't tell from /proc/interrupts which
> vbus interupts are active

This should be trivial to add some kind of *fs display.  I will fix this
shortly.

> and irqbalance can't steer them towards less
> busy cpus since they're invisible to the interrupt controller.

(see N:M above)

>=20
>=20
>>>> And lastly, why would you _need_ to use the so called "native"
>>>> mechanism?  The short answer is, "you don't".  Any given system (gue=
st
>>>> or bare-metal) already have a wide-range of buses (try running "tree=

>>>> /sys/bus" in Linux).  More importantly, the concept of adding new bu=
ses
>>>> is widely supported in both the Windows and Linux driver model (and
>>>> probably any other guest-type that matters).  Therefore, despite cla=
ims
>>>> to the contrary, its not hard or even unusual to add a new bus to th=
e
>>>> mix.
>>>>
>>>>       =20
>>> The short answer is "compatibility".
>>>     =20
>> There was a point in time where the same could be said for virtio-pci
>> based drivers vs realtek and e1000, so that argument is demonstrably
>> silly.  No one tried to make virtio work in a binary compatible way wi=
th
>> realtek emulation, yet we all survived the requirement for loading a
>> virtio driver to my knowledge.
>>   =20
>=20
> The larger your installed base, the more difficult it is.  Of course
> it's doable, but I prefer not doing it and instead improving things in =
a
> binary backwards compatible manner.  If there is no choice we will bow
> to the inevitable and make our users upgrade.  But at this point there
> is a choice, and I prefer to stick with vhost-net until it is proven
> that it won't work.

Fair enough.  But note you are likely going to need to respin your
existing drivers anyway to gain peak performance, since there are known
shortcomings in the virtio-pci ABI today (like queue identification in
the interrupt hotpath) as it stands.  So that pain is coming one way or
the other.

>=20
>> The bottom line is: Binary device compatibility is not required in any=

>> other system (as long as you follow sensible versioning/id rules), so
>> why is KVM considered special?
>>   =20
>=20
> One of the benefits of virtualization is that the guest model is
> stable.  You can live-migrate guests and upgrade the hardware
> underneath.  You can have a single guest image that you clone to
> provision new guests.  If you switch to a new model, you give up those
> benefits, or you support both models indefinitely.

I understand what you are saying, but I don't buy it.  If you add a new
feature to an existing model even without something as drastic as a new
bus, you still have the same exact dilemma:  The migration target needs
feature parity with consumed features in the guest.  Its really the same
no matter what unless you never add guest-visible features.

>=20
> Note even hardware nowadays is binary compatible.  One e1000 driver
> supports a ton of different cards, and I think (not sure) newer cards
> will work with older drivers, just without all their features.

Noted, but that is not really the same thing.  Thats more like adding a
feature bit to virtio, not replacing GigE with 10GE.

>=20
>> The fact is, it isn't special (at least not in this regard).  What _is=
_
>> required is "support" and we fully intend to support these proposed
>> components.  I assure you that at least the users that care about
>> maximum performance will not generally mind loading a driver.  Most of=

>> them would have to anyway if they want to get beyond realtek emulation=
=2E
>>   =20
>=20
> For a new install, sure.  I'm talking about existing deployments (and
> those that will exist by the time vbus is ready for roll out).

The user will either specify "-net nic,model=3Dvenet", or they won't.  It=
s
their choice.  Changing those parameters, vbus or otherwise, has
ramifications w.r.t. what drivers must be loaded, and the user will
understand this.

>=20
>> I am certainly in no position to tell you how to feel, but this
>> declaration would seem from my perspective to be more of a means to an=

>> end than a legitimate concern.  Otherwise we would never have had virt=
io
>> support in the first place, since it was not "compatible" with previou=
s
>> releases.
>>   =20
>=20
> virtio was certainly not pain free, needing Windows drivers, updates to=

> management tools (you can't enable it by default, so you have to offer
> it as a choice), mkinitrd, etc.  I'd rather not have to go through that=

> again.

No general argument here, other than to reiterate that the driver is
going to have to be redeployed anyway, since it will likely need new
feature bits to fix the current ABI.

>=20
>>>   Especially if the device changed is your boot disk.
>>>     =20
>> If and when that becomes a priority concern, that would be a function
>> transparently supported in the BIOS shipped with the hypervisor, and
>> would thus be invisible to the user.
>>   =20
>=20
> No, you have to update the driver in your initrd (for Linux)

Thats fine, the distros generally do this automatically when you load
the updated KMP package.

> or properly install the new driver (for Windows).  It's especially
> difficult for Windows.

What is difficult here?  I never seem to have any problems and I have
all kinds of guests from XP to Win7.

>>>   You may not care about the pain caused to users, but I do, so I wil=
l
>>> continue to insist on compatibility.
>>>     =20
>> For the users that don't care about maximum performance, there is no
>> change (and thus zero pain) required.  They can use realtek or virtio =
if
>> they really want to.  Neither is going away to my knowledge, and lets
>> face it: 2.6Gb/s out of virtio to userspace isn't *that* bad.  But "go=
od
>> enough" isn't good enough, and I won't rest till we get to native
>> performance.
>=20
> I don't want to support both virtio and vbus in parallel.  There's
> enough work already.

Until I find some compelling reason that indicates I was wrong about all
of this, I will continue building a community around the vbus code base
and developing support for its components anyway.  So that effort is
going to happen in parallel regardless.

This is purely a question about whether you will work with me to make
vbus an available option in upstream KVM or not.

>  If we adopt vbus, we'll have to deprecate and eventually kill off virt=
io.

Thats more hyperbole.  virtio is technically fine and complementary as
it is.  No one says you have to do anything drastic w.r.t. virtio.  If
you _did_ adopt vbus, perhaps you would want to optionally deprecate
vhost or possibly the virtio-pci adapter, but that is about it.  The
rest of the infrastructure should be preserved if it was designed properl=
y.

>=20
>> 2) True pain to users is not caused by lack of binary compatibility.
>> Its caused by lack of support.  And its a good thing or we would all b=
e
>> emulating 8086 architecture forever...
>>
>> ..oh wait, I guess we kind of do that already ;).  But at least we can=

>> slip in something more advanced once in a while (APIC vs PIC, USB vs
>> uart, iso9660 vs floppy, for instance) and update the guest stack
>> instead of insisting it must look like ISA forever for compatibility's=

>> sake.
>>   =20
>=20
> PCI is continuously updated, with MSI, MSI-X, and IOMMU support being
> some recent updates.  I'd like to ride on top of that instead of having=

> to clone it for every guest I support.

While a noble goal, one of the points I keep making though, as someone
who has built the stack both ways, is almost none of the PCI stack is
actually needed to get the PV job done.  The part you do need is
primarily a function of the generic OS stack and trivial to interface
with anyway.

Plus, as a lesser point: it doesn't work everywhere so you end up
solving the same kind of vbus-like design problem again and again when
PCI is missing.

>=20
>>> So we have: vbus needs a connector, vhost needs a connector.  vbus
>>> doesn't need userspace to program the addresses (but does need usersp=
ace
>>> to instantiate the devices and to program the bus address decode)
>>>     =20
>> First of all, bus-decode is substantially easier than per-device decod=
e
>> (you have to track all those per-device/per-signal fds somewhere,
>> integrate with hotswap, etc), and its only done once per guest at
>> startup and left alone.  So its already not apples to apples.
>>   =20
>=20
> Right, it means you can hand off those eventfds to other qemus or other=

> pure userspace servers.  It's more flexible.
>=20
>> Second, while its true that the general kvm-connector bus-decode needs=

>> to be programmed,  that is a function of adapting to the environment
>> that _you_ created for me.  The original kvm-connector was discovered
>> via cpuid and hypercalls, and didn't need userspace at all to set it u=
p.
>>   Therefore it would be entirely unfair of you to turn around and some=
how
>> try to use that trait of the design against me since you yourself
>> imposed it.
>>   =20
>=20
> No kvm feature will ever be exposed to a guest without userspace
> intervention.  It's a basic requirement.  If it causes complexity (and
> it does) we have to live with it.

Right.  cpuid is exposed by userspace, so that was the control point in
the original design.  The presence of the PCI_BRIDGE in the new code
(again exported by userspace) is what controls it now.  From there,
there are various mechanisms we employ to control that features the
guest may see, such as the sysfs/attribute system, the revision of the
bridge, and the feature bits that it and its subordinate devices expose.

>=20
>>>   Does it work on Windows?
>>>     =20
>> This question doesn't make sense.  Hotswap control occurs on the host,=

>> which is always Linux.
>>
>> If you were asking about whether a windows guest will support hotswap:=

>> the answer is "yes".  Our windows driver presents a unique PDO/FDO pai=
r
>> for each logical device instance that is pushed out (just like the bui=
lt
>> in usb, pci, scsi bus drivers that windows supports natively).
>>   =20
>=20
> Ah, you have a Windows venet driver?

Almost.  It's WIP, but hopefully soon, along with core support for the
bus, etc.

>=20
>=20
>>>> As an added bonus, its device-model is modular.  A developer can
>>>> write a
>>>> new device model, compile it, insmod it to the host kernel, hotplug =
it
>>>> to the running guest with mkdir/ln, and the come back out again
>>>> (hotunplug with rmdir, rmmod, etc).  They may do this all without
>>>> taking
>>>> the guest down, and while eating QEMU based IO solutions for breakfa=
st
>>>> performance wise.
>>>>
>>>> Afaict, qemu can't do either of those things.
>>>>
>>>>       =20
>>> We've seen that herring before,
>>>     =20
>> Citation?
>>   =20
>=20
> It's the compare venet-in-kernel to virtio-in-userspace thing again.

No, you said KVM has "userspace hotplug".  I retorted that vbus not only
has hotplug, it also has a modular architecture.  You then countered
that this feature is a red-herring.  If this was previously discussed
and rejected for some reason, I would like to know the history.  Or did
I misunderstand you?

Or if you are somehow implying that the lack of modularity has to do
with virtio-in-userspace, I beg to differ.  Even with vhost, you still
have to have a paired model in qemu, so it will not be a modular
architecture by virtue of the vhost patch series either.  You would need
qemu to support modular devices as well, which I've been told that isn't
going to happen any time soon.


> Let's defer that until mst complete vhost-net mergable buffers, it whic=
h
> time we can compare vhost-net to venet and see how much vbus contribute=
s
> to performance and how much of it comes from being in-kernel.

I look forward to it.

>=20
>>>>> Refactor instead of duplicating.
>>>>>
>>>>>         =20
>>>> There is no duplicating.  vbus has no equivalent today as virtio
>>>> doesn't
>>>> define these layers.
>>>>
>>>>       =20
>>> So define them if they're missing.
>>>     =20
>> I just did.
>>   =20
>=20
> Since this is getting confusing to me, I'll start from scratch looking
> at the vbus layers, top to bottom:

I wouldn't describe it like this

>=20
> Guest side:
> 1. venet guest kernel driver - AFAICT, duplicates the virtio-net guest
> driver functionality
> 2. vbus guest driver (config and hotplug) - duplicates pci, or if you
> need non-pci support, virtio config and its pci bindings; needs
> reimplementation for all supported guests
> 3. vbus guest driver (interrupt coalescing, priority) - if needed,
> should be implemented as an irqchip (and be totally orthogonal to the
> driver); needs reimplementation for all supported guests
> 4. vbus guest driver (shm/ioq) - finder grained layering than virtio
> (which only supports the combination, due to the need for Xen support);=

> can be retrofitted to virtio at some cost
>=20
> Host side:
> 1. venet host kernel driver - is duplicated by vhost-net; doesn't
> support live migration, unprivileged users, or slirp
> 2. vbus host driver (config and hotplug) - duplicates pci support in
> userspace (which will need to be kept in any case); already has two
> userspace interfaces
> 3. vbus host driver (interrupt coalescing, priority) - if we think we
> need it (and I don't), should be part of kvm core, not a bus
> 4. vbus host driver (shm) - partially duplicated by vhost memory slots
> 5. vbus host driver (ioq) - duplicates userspace virtio, duplicated by
> vhost

For one, we have the common layer of shm-signal, and IOQ.  These
libraries were designed to be reused on both sides of the link.
Generally shm-signal has no counterpart in the existing model, though
its functionality is integrated into the virtqueue.  IOQ is duplicated
by virtqueue, but I think its a better design at least in this role, so
I use it pervasively throughout the stack.  We can discuss that in a
separate thread.

=46rom there, going down the stack, it looks like

    (guest-side)
|-------------------------
| venet (competes with virtio-net)
|-------------------------
| vbus-proxy (competes with pci-bus, config+hotplug, sync/async)
|-------------------------
| vbus-pcibridge (interrupt coalescing + priority, fastpath)
|-------------------------
           |
|-------------------------
| vbus-kvmconnector (interrupt coalescing + priority, fast-path)
|-------------------------
| vbus-core (hotplug, address decoding, etc)
|-------------------------
| venet-device (ioq frame/deframe to tap/macvlan/vmdq, etc)
|-------------------------

If you want to use virtio, insert a virtio layer between the "driver"
and "device" components at the outer edges of the stack.

>=20
>>>> There is no rewriting.  vbus has no equivalent today as virtio doesn=
't
>>>> define these layers.
>>>>
>>>> By your own admission, you said if you wanted that capability, use a=

>>>> library.  What I think you are not understanding is vbus _is_ that
>>>> library.  So what is the problem, exactly?
>>>>
>>>>       =20
>>> It's not compatible.
>>>     =20
>> No, that is incorrect.  What you are apparently not understanding is
>> that not only is vbus that library, but its extensible.  So even if
>> compatibility is your goal (it doesn't need to be IMO) it can be
>> accommodated by how you interface to the library.
>>   =20
>=20
> To me, compatible means I can live migrate an image to a new system
> without the user knowing about the change.  You'll be able to do that
> with vhost-net.

As soon as you add any new guest-visible feature, you are in the same
exact boat.

>=20
>>>>>
>>>>>         =20
>>>> No, it does not.  vbus just needs a relatively simple single message=

>>>> pipe between the guest and host (think "hypercall tunnel", if you
>>>> will).
>>>>
>>>>       =20
>>> That's ioeventfd.  So far so similar.
>>>     =20
>> No, that is incorrect.  For one, vhost uses them on a per-signal path
>> basis, whereas vbus only has one channel for the entire guest->host.
>>   =20
>=20
> You'll probably need to change that as you start running smp guests.

The hypercall channel is already SMP optimized over a single PIO path,
so I think we are covered there.  See "fastcall" in my code for details:

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Ddrivers/vbus/pci-bridge.c;h=3D81f7cdd2167ae2f53406850=
ebac448a2183842f2;hb=3Dfd1c156be7735f8b259579f18268a756beccfc96#l102

It just passes the cpuid into the PIO write so we can have parallel,
lockless "hypercalls".  This forms the basis of our guest scheduler
support, for instance.

>=20
>> Second, I do not use ioeventfd anymore because it has too many problem=
s
>> with the surrounding technology.  However, that is a topic for a
>> different thread.
>>   =20
>=20
> Please post your issues.  I see ioeventfd/irqfd as critical kvm interfa=
ces.

Will do.  It would be nice to come back to this interface.

>=20
>>> vbus devices aren't magically instantiated.  Userspace needs to
>>> instantiate them too.  Sure, there's less work on the host side since=

>>> you're using vbus instead of the native interface, but more work on t=
he
>>> guest side since you're using vbus instead of the native interface.
>>>     =20
>>
>> No, that is incorrect.  The amount of "work" that a guest does is
>> actually the same in both cases, since the guest OS peforms the hotswa=
p
>> handling natively for all bus types (at least for Linux and Windows).
>> You still need to have a PV layer to interface with those objects in
>> both cases, as well, so there is no such thing as "native interface" f=
or
>> PV.  Its only a matter of where it occurs in the stack.
>>   =20
>=20
> I'm missing something.  Where's the pv layer for virtio-net?

covered above

>=20
> Linux drivers have an abstraction layer to deal with non-pci.  But the
> Windows drivers are ordinary pci drivers with nothing that looks
> pv-ish.

They certainly do not have to be since Windows supports a similar notion
as the LDM in Linux.  In fact, we are exploiting that Windows facility
in our drivers.  It's rather unfortunate if its true that your
drivers were not designed this way, since virtio has a rather nice
stack model on Linux that could work in Windows as well.

>  You could implement virtio-net hardware if you wanted to.

Technically you could build vbus in hardware too, I suppose, since the
bridge is PCI compliant.  I would never advocate it, however, since many
of our tricks do not matter if its real hardware (e.g. they are
optimized for the costs associated with VM).

>=20
>>>   non-privileged-user capable?
>>>     =20
>> The short answer is "not yet (I think)".  I need to write a patch to
>> properly set the mode attribute in sysfs, but I think this will be
>> trivial.
>>
>>   =20
>=20
> (and selinux label)

If any of these things that are problems, they can simply be exposed via
the new ioctl admin interface, I suppose.

>=20
>>> Ah, so you have two control planes.
>>>     =20
>> So what?  If anything, it goes to show how extensible the framework is=

>> that a new plane could be added in 119 lines of code:
>>
>> ~/git/linux-2.6>  stg show vbus-add-admin-ioctls.patch | diffstat
>>   Makefile       |    3 -
>>   config-ioctl.c |  117
>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 119 insertions(+), 1 deletion(-)
>>
>> if and when having two control planes exceeds its utility, I will subm=
it
>> a simple patch that removes the useless one.
>>   =20
>=20
> It always begins with a 119-line patch and then grows, that's life.
>=20

I can't argue with that.

>>> kvm didn't have an existing counterpart in Linux when it was
>>> proposed/merged.
>>>     =20
>> And likewise, neither does vbus.
>>
>>   =20
>=20
> For virt uses, I don't see the need.  For non-virt, I have no opinion.
>=20
>=20

Well, I hope to change your mind on both counts, then.

Kind Regards,
-Greg




--------------enigD39FC577A73B17A2F573919D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrFAesACgkQP5K2CMvXmqEmXQCfULCi3hCBAX1vsIh1e/V1CrZy
LhwAnik6d51H5WOEGEK3mTAxJnztFYwB
=veFm
-----END PGP SIGNATURE-----

--------------enigD39FC577A73B17A2F573919D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

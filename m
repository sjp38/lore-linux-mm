Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9BD5D6B004D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 04:01:52 -0400 (EDT)
Message-ID: <4AC46989.7030502@redhat.com>
Date: Thu, 01 Oct 2009 10:34:17 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com> <4ABC7DCE.2000404@redhat.com> <4ABD36E3.9070503@gmail.com> <4ABF33B2.4000805@redhat.com> <4AC3B9C6.5090408@gmail.com>
In-Reply-To: <4AC3B9C6.5090408@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/30/2009 10:04 PM, Gregory Haskins wrote:


>> A 2.6.27 guest, or Windows guest with the existing virtio drivers, won't work
>> over vbus.
>>      
> Binary compatibility with existing virtio drivers, while nice to have,
> is not a specific requirement nor goal.  We will simply load an updated
> KMP/MSI into those guests and they will work again.  As previously
> discussed, this is how more or less any system works today.  It's like
> we are removing an old adapter card and adding a new one to "uprev the
> silicon".
>    

Virtualization is about not doing that.  Sometimes it's necessary (when 
you have made unfixable design mistakes), but just to replace a bus, 
with no advantages to the guest that has to be changed (other 
hypervisors or hypervisorless deployment scenarios aren't).

>>   Further, non-shmem virtio can't work over vbus.
>>      
> Actually I misspoke earlier when I said virtio works over non-shmem.
> Thinking about it some more, both virtio and vbus fundamentally require
> shared-memory, since sharing their metadata concurrently on both sides
> is their raison d'Aatre.
>
> The difference is that virtio utilizes a pre-translation/mapping (via
> ->add_buf) from the guest side.  OTOH, vbus uses a post translation
> scheme (via memctx) from the host-side.  If anything, vbus is actually
> more flexible because it doesn't assume the entire guest address space
> is directly mappable.
>
> In summary, your statement is incorrect (though it is my fault for
> putting that idea in your head).
>    

Well, Xen requires pre-translation (since the guest has to give the host 
(which is just another guest) permissions to access the data).  So 
neither is a superset of the other, they're just different.

It doesn't really matter since Xen is unlikely to adopt virtio.

> An interesting thing here is that you don't even need a fancy
> multi-homed setup to see the effects of my exit-ratio reduction work:
> even single port configurations suffer from the phenomenon since many
> devices have multiple signal-flows (e.g. network adapters tend to have
> at least 3 flows: rx-ready, tx-complete, and control-events (link-state,
> etc).  Whats worse, is that the flows often are indirectly related (for
> instance, many host adapters will free tx skbs during rx operations, so
> you tend to get bursts of tx-completes at the same time as rx-ready.  If
> the flows map 1:1 with IDT, they will suffer the same problem.
>    

You can simply use the same vector for both rx and tx and poll both at 
every interrupt.

> In any case, here is an example run of a simple single-homed guest over
> standard GigE.  Whats interesting here is that .qnotify to .notify
> ratio, as this is the interrupt-to-signal ratio.  In this case, its
> 170047/151918, which comes out to about 11% savings in interrupt injections:
>
> vbus-guest:/home/ghaskins # netperf -H dev
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> dev.laurelwood.net (192.168.1.10) port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>
> 1048576  16384  16384    10.01     940.77
> vbus-guest:/home/ghaskins # cat /sys/kernel/debug/pci-to-vbus-bridge
>    .events                        : 170048
>    .qnotify                       : 151918
>    .qinject                       : 0
>    .notify                        : 170047
>    .inject                        : 18238
>    .bridgecalls                   : 18
>    .buscalls                      : 12
> vbus-guest:/home/ghaskins # cat /proc/interrupts
>              CPU0
>     0:         87   IO-APIC-edge      timer
>     1:          6   IO-APIC-edge      i8042
>     4:        733   IO-APIC-edge      serial
>     6:          2   IO-APIC-edge      floppy
>     7:          0   IO-APIC-edge      parport0
>     8:          0   IO-APIC-edge      rtc0
>     9:          0   IO-APIC-fasteoi   acpi
>    10:          0   IO-APIC-fasteoi   virtio1
>    12:         90   IO-APIC-edge      i8042
>    14:       3041   IO-APIC-edge      ata_piix
>    15:       1008   IO-APIC-edge      ata_piix
>    24:     151933   PCI-MSI-edge      vbus
>    25:          0   PCI-MSI-edge      virtio0-config
>    26:        190   PCI-MSI-edge      virtio0-input
>    27:         28   PCI-MSI-edge      virtio0-output
>   NMI:          0   Non-maskable interrupts
>   LOC:       9854   Local timer interrupts
>   SPU:          0   Spurious interrupts
>   CNT:          0   Performance counter interrupts
>   PND:          0   Performance pending work
>   RES:          0   Rescheduling interrupts
>   CAL:          0   Function call interrupts
>   TLB:          0   TLB shootdowns
>   TRM:          0   Thermal event interrupts
>   THR:          0   Threshold APIC interrupts
>   MCE:          0   Machine check exceptions
>   MCP:          1   Machine check polls
>   ERR:          0
>   MIS:          0
>
> Its important to note here that we are actually looking at the interrupt
> rate, not the exit rate (which is usually a multiple of the interrupt
> rate, since you have to factor in as many as three exits per interrupt
> (IPI, window, EOI).  Therefore we saved about 18k interrupts in this 10
> second burst, but we may have actually saved up to 54k exits in the
> process. This is only over a 10 second window at GigE rates, so YMMV.
> These numbers get even more dramatic on higher end hardware, but I
> haven't had a chance to generate new numbers yet.
>    

(irq window exits should only be required on a small percentage of 
interrupt injections, since the guest will try to disable interrupts for 
short periods only)

> Looking at some external stats paints an even bleaker picture: "exits"
> as reported by kvm_stat for virtio-pci based virtio-net tip the scales
> at 65k/s vs 36k/s for vbus based venet.  And virtio is consuming ~30% of
> my quad-core's cpu, vs 19% for venet during the test.  Its hard to know
> which innovation or innovations may be responsible for the entire
> reduction, but certainly the interrupt-to-signal ratio mentioned above
> is probably helping.
>    

Can you please stop comparing userspace-based virtio hosts to 
kernel-based venet hosts?  We know the userspace implementation sucks.

> The even worse news for 1:1 models is that the ratio of
> exits-per-interrupt climbs with load (exactly when it hurts the most)
> since that is when the probability that the vcpu will need all three
> exits is the highest.
>    

Requiring all three exits means the guest is spending most of its time 
with interrupts disabled; that's unlikely.

Thanks for the numbers.  Are those 11% attributable to rx/tx 
piggybacking from the same interface?

Also, 170K interupts -> 17K interrupts/sec -> 55kbit/interrupt -> 
6.8kB/interrupt.  Ignoring interrupt merging and assuming equal rx/tx 
distribution, that's about 13kB/interrupt.  Seems rather low for a 
saturated link.

>>      
>>> and priortizable/nestable signals.
>>>
>>>        
>> That doesn't belong in a bus.
>>      
> Everyone is of course entitled to an opinion, but the industry as a
> whole would disagree with you.  Signal path routing (1:1, aggregated,
> etc) is at the discretion of the bus designer.  Most buses actually do
> _not_ support 1:1 with IDT (think USB, SCSI, IDE, etc).
>    

With standard PCI, they do not.  But all modern host adapters support 
MSI and they will happily give you one interrupt per queue.

> PCI is somewhat of an outlier in that regard afaict.  Its actually a
> nice feature of PCI when its used within its design spec (HW).  For
> SW/PV, 1:1 suffers from, among other issues, that "triple-exit scaling"
> issue in the signal path I mentioned above.  This is one of the many
> reasons I think PCI is not the best choice for PV.
>    

Look at the vmxnet3 submission (recently posted on virtualization@).  
It's a perfectly ordinary PCI NIC driver, apart from having so many 'V's 
in the code.  16 rx queues, 8 tx queues, 25 MSIs, BARs for the 
registers.  So while the industry as a whole might disagree with me, it 
seems VMware does not.


>>> http://developer.novell.com/wiki/images/b/b7/31-rc4_throughput.png
>>>
>>>        
>> That's a red herring.  The problem is not with virtio as an ABI, but
>> with its implementation in userspace.  vhost-net should offer equivalent
>> performance to vbus.
>>      
> That's pure speculation.  I would advise you to reserve such statements
> until after a proper bakeoff can be completed.

Let's do that then.  Please reserve the corresponding comparisons from 
your side as well.

> This is not to mention
> that vhost-net does nothing to address our other goals, like scheduler
> coordination and non-802.x fabrics.
>    

What are scheduler coordination and non-802.x fabrics?

>> Right, when you ignore the points where they don't fit, it's a perfect
>> mesh.
>>      
> Where doesn't it fit?
>    

(avoiding infinite loop)

>>>> But that's not a strong argument for vbus; instead of adding vbus you
>>>> could make virtio more friendly to non-virt
>>>>
>>>>          
>>> Actually, it _is_ a strong argument then because adding vbus is what
>>> helps makes virtio friendly to non-virt, at least for when performance
>>> matters.
>>>
>>>        
>> As vhost-net shows, you can do that without vbus
>>      
> Citation please.  Afaict, the one use case that we looked at for vhost
> outside of KVM failed to adapt properly, so I do not see how this is true.
>    

I think Ira said he can make vhost work?

>> and without breaking compatibility.
>>      
> Compatibility with what?  vhost hasn't even been officially deployed in
> KVM environments afaict, nevermind non-virt.  Therefore, how could it
> possibly have compatibility constraints with something non-virt already?
>   Citation please.
>    

virtio-net over pci is deployed.  Replacing the backend with vhost-net 
will require no guest modifications.  Replacing the frontend with venet 
or virt-net/vbus-pci will require guest modifications.

Obviously virtio-net isn't deployed in non-virt.  But if we adopt vbus, 
we have to migrate guests.



>> Of course there is such a thing as native, a pci-ready guest has tons of
>> support built into it
>>      
> I specifically mentioned that already ([1]).
>
> You are also overstating its role, since the basic OS is what implements
> the native support for bus-objects, hotswap, etc, _not_ PCI.  PCI just
> rides underneath and feeds trivial events up, as do other bus-types
> (usb, scsi, vbus, etc).

But we have to implement vbus for each guest we want to support.  That 
includes Windows and older Linux which has a different internal API, so 
we have to port the code multiple times, to get existing functionality.

> And once those events are fed, you still need a
> PV layer to actually handle the bus interface in a high-performance
> manner so its not like you really have a "native" stack in either case.
>    

virtio-net doesn't use any pv layer.

>> that doesn't need to be retrofitted.
>>      
> No, that is incorrect.  You have to heavily modify the pci model with
> layers on top to get any kind of performance out of it.  Otherwise, we
> would just use realtek emulation, which is technically the native PCI
> you are apparently so enamored with.
>    

virtio-net doesn't modify the PCI model.  And if you look at vmxnet3, 
they mention that it conforms to somthing called UPT, which allows 
hardware vendors to implement parts of their NIC model.  So vmxnet3 is 
apparently suitable to both hardware and software implementations.

> Not to mention there are things you just plain can't do in PCI today,
> like dynamically assign signal-paths,

You can have dynamic MSI/queue routing with virtio, and each MSI can be 
routed to a vcpu at will.

> priority, and coalescing, etc.
>    

Do you mean interrupt priority?  Well, apic allows interrupt priorities 
and Windows uses them; Linux doesn't.  I don't see a reason to provide 
more than native hardware.

>> Since
>> practically everyone (including Xen) does their paravirt drivers atop
>> pci, the claim that pci isn't suitable for high performance is incorrect.
>>      
> Actually IIUC, I think Xen bridges to their own bus as well (and only
> where they have to), just like vbus.  They don't use PCI natively.  PCI
> is perfectly suited as a bridge transport for PV, as I think the Xen and
> vbus examples have demonstrated.  Its the 1:1 device-model where PCI has
> the most problems.
>    

N:1 breaks down on large guests since one vcpu will have to process all 
events.  You could do N:M, with commands to change routings, but where's 
your userspace interface?  you can't tell from /proc/interrupts which 
vbus interupts are active, and irqbalance can't steer them towards less 
busy cpus since they're invisible to the interrupt controller.


>>> And lastly, why would you _need_ to use the so called "native"
>>> mechanism?  The short answer is, "you don't".  Any given system (guest
>>> or bare-metal) already have a wide-range of buses (try running "tree
>>> /sys/bus" in Linux).  More importantly, the concept of adding new buses
>>> is widely supported in both the Windows and Linux driver model (and
>>> probably any other guest-type that matters).  Therefore, despite claims
>>> to the contrary, its not hard or even unusual to add a new bus to the
>>> mix.
>>>
>>>        
>> The short answer is "compatibility".
>>      
> There was a point in time where the same could be said for virtio-pci
> based drivers vs realtek and e1000, so that argument is demonstrably
> silly.  No one tried to make virtio work in a binary compatible way with
> realtek emulation, yet we all survived the requirement for loading a
> virtio driver to my knowledge.
>    

The larger your installed base, the more difficult it is.  Of course 
it's doable, but I prefer not doing it and instead improving things in a 
binary backwards compatible manner.  If there is no choice we will bow 
to the inevitable and make our users upgrade.  But at this point there 
is a choice, and I prefer to stick with vhost-net until it is proven 
that it won't work.

> The bottom line is: Binary device compatibility is not required in any
> other system (as long as you follow sensible versioning/id rules), so
> why is KVM considered special?
>    

One of the benefits of virtualization is that the guest model is 
stable.  You can live-migrate guests and upgrade the hardware 
underneath.  You can have a single guest image that you clone to 
provision new guests.  If you switch to a new model, you give up those 
benefits, or you support both models indefinitely.

Note even hardware nowadays is binary compatible.  One e1000 driver 
supports a ton of different cards, and I think (not sure) newer cards 
will work with older drivers, just without all their features.

> The fact is, it isn't special (at least not in this regard).  What _is_
> required is "support" and we fully intend to support these proposed
> components.  I assure you that at least the users that care about
> maximum performance will not generally mind loading a driver.  Most of
> them would have to anyway if they want to get beyond realtek emulation.
>    

For a new install, sure.  I'm talking about existing deployments (and 
those that will exist by the time vbus is ready for roll out).

> I am certainly in no position to tell you how to feel, but this
> declaration would seem from my perspective to be more of a means to an
> end than a legitimate concern.  Otherwise we would never have had virtio
> support in the first place, since it was not "compatible" with previous
> releases.
>    

virtio was certainly not pain free, needing Windows drivers, updates to 
management tools (you can't enable it by default, so you have to offer 
it as a choice), mkinitrd, etc.  I'd rather not have to go through that 
again.

>>   Especially if the device changed is your boot disk.
>>      
> If and when that becomes a priority concern, that would be a function
> transparently supported in the BIOS shipped with the hypervisor, and
> would thus be invisible to the user.
>    

No, you have to update the driver in your initrd (for Linux) or properly 
install the new driver (for Windows).  It's especially difficult for 
Windows.

>>   You may not care about the pain caused to users, but I do, so I will
>> continue to insist on compatibility.
>>      
> For the users that don't care about maximum performance, there is no
> change (and thus zero pain) required.  They can use realtek or virtio if
> they really want to.  Neither is going away to my knowledge, and lets
> face it: 2.6Gb/s out of virtio to userspace isn't *that* bad.  But "good
> enough" isn't good enough, and I won't rest till we get to native
> performance.

I don't want to support both virtio and vbus in parallel.  There's 
enough work already.  If we adopt vbus, we'll have to deprecate and 
eventually kill off virtio.

> 2) True pain to users is not caused by lack of binary compatibility.
> Its caused by lack of support.  And its a good thing or we would all be
> emulating 8086 architecture forever...
>
> ..oh wait, I guess we kind of do that already ;).  But at least we can
> slip in something more advanced once in a while (APIC vs PIC, USB vs
> uart, iso9660 vs floppy, for instance) and update the guest stack
> instead of insisting it must look like ISA forever for compatibility's sake.
>    

PCI is continuously updated, with MSI, MSI-X, and IOMMU support being 
some recent updates.  I'd like to ride on top of that instead of having 
to clone it for every guest I support.

>> So we have: vbus needs a connector, vhost needs a connector.  vbus
>> doesn't need userspace to program the addresses (but does need userspace
>> to instantiate the devices and to program the bus address decode)
>>      
> First of all, bus-decode is substantially easier than per-device decode
> (you have to track all those per-device/per-signal fds somewhere,
> integrate with hotswap, etc), and its only done once per guest at
> startup and left alone.  So its already not apples to apples.
>    

Right, it means you can hand off those eventfds to other qemus or other 
pure userspace servers.  It's more flexible.

> Second, while its true that the general kvm-connector bus-decode needs
> to be programmed,  that is a function of adapting to the environment
> that _you_ created for me.  The original kvm-connector was discovered
> via cpuid and hypercalls, and didn't need userspace at all to set it up.
>   Therefore it would be entirely unfair of you to turn around and somehow
> try to use that trait of the design against me since you yourself
> imposed it.
>    

No kvm feature will ever be exposed to a guest without userspace 
intervention.  It's a basic requirement.  If it causes complexity (and 
it does) we have to live with it.

>>   Does it work on Windows?
>>      
> This question doesn't make sense.  Hotswap control occurs on the host,
> which is always Linux.
>
> If you were asking about whether a windows guest will support hotswap:
> the answer is "yes".  Our windows driver presents a unique PDO/FDO pair
> for each logical device instance that is pushed out (just like the built
> in usb, pci, scsi bus drivers that windows supports natively).
>    

Ah, you have a Windows venet driver?


>>> As an added bonus, its device-model is modular.  A developer can write a
>>> new device model, compile it, insmod it to the host kernel, hotplug it
>>> to the running guest with mkdir/ln, and the come back out again
>>> (hotunplug with rmdir, rmmod, etc).  They may do this all without taking
>>> the guest down, and while eating QEMU based IO solutions for breakfast
>>> performance wise.
>>>
>>> Afaict, qemu can't do either of those things.
>>>
>>>        
>> We've seen that herring before,
>>      
> Citation?
>    

It's the compare venet-in-kernel to virtio-in-userspace thing again.  
Let's defer that until mst complete vhost-net mergable buffers, it which 
time we can compare vhost-net to venet and see how much vbus contributes 
to performance and how much of it comes from being in-kernel.

>>>> Refactor instead of duplicating.
>>>>
>>>>          
>>> There is no duplicating.  vbus has no equivalent today as virtio doesn't
>>> define these layers.
>>>
>>>        
>> So define them if they're missing.
>>      
> I just did.
>    

Since this is getting confusing to me, I'll start from scratch looking 
at the vbus layers, top to bottom:

Guest side:
1. venet guest kernel driver - AFAICT, duplicates the virtio-net guest 
driver functionality
2. vbus guest driver (config and hotplug) - duplicates pci, or if you 
need non-pci support, virtio config and its pci bindings; needs 
reimplementation for all supported guests
3. vbus guest driver (interrupt coalescing, priority) - if needed, 
should be implemented as an irqchip (and be totally orthogonal to the 
driver); needs reimplementation for all supported guests
4. vbus guest driver (shm/ioq) - finder grained layering than virtio 
(which only supports the combination, due to the need for Xen support); 
can be retrofitted to virtio at some cost

Host side:
1. venet host kernel driver - is duplicated by vhost-net; doesn't 
support live migration, unprivileged users, or slirp
2. vbus host driver (config and hotplug) - duplicates pci support in 
userspace (which will need to be kept in any case); already has two 
userspace interfaces
3. vbus host driver (interrupt coalescing, priority) - if we think we 
need it (and I don't), should be part of kvm core, not a bus
4. vbus host driver (shm) - partially duplicated by vhost memory slots
5. vbus host driver (ioq) - duplicates userspace virtio, duplicated by vhost

>>> There is no rewriting.  vbus has no equivalent today as virtio doesn't
>>> define these layers.
>>>
>>> By your own admission, you said if you wanted that capability, use a
>>> library.  What I think you are not understanding is vbus _is_ that
>>> library.  So what is the problem, exactly?
>>>
>>>        
>> It's not compatible.
>>      
> No, that is incorrect.  What you are apparently not understanding is
> that not only is vbus that library, but its extensible.  So even if
> compatibility is your goal (it doesn't need to be IMO) it can be
> accommodated by how you interface to the library.
>    

To me, compatible means I can live migrate an image to a new system 
without the user knowing about the change.  You'll be able to do that 
with vhost-net.

>>>>
>>>>          
>>> No, it does not.  vbus just needs a relatively simple single message
>>> pipe between the guest and host (think "hypercall tunnel", if you will).
>>>
>>>        
>> That's ioeventfd.  So far so similar.
>>      
> No, that is incorrect.  For one, vhost uses them on a per-signal path
> basis, whereas vbus only has one channel for the entire guest->host.
>    

You'll probably need to change that as you start running smp guests.

> Second, I do not use ioeventfd anymore because it has too many problems
> with the surrounding technology.  However, that is a topic for a
> different thread.
>    

Please post your issues.  I see ioeventfd/irqfd as critical kvm interfaces.

>> vbus devices aren't magically instantiated.  Userspace needs to
>> instantiate them too.  Sure, there's less work on the host side since
>> you're using vbus instead of the native interface, but more work on the
>> guest side since you're using vbus instead of the native interface.
>>      
>
> No, that is incorrect.  The amount of "work" that a guest does is
> actually the same in both cases, since the guest OS peforms the hotswap
> handling natively for all bus types (at least for Linux and Windows).
> You still need to have a PV layer to interface with those objects in
> both cases, as well, so there is no such thing as "native interface" for
> PV.  Its only a matter of where it occurs in the stack.
>    

I'm missing something.  Where's the pv layer for virtio-net?

Linux drivers have an abstraction layer to deal with non-pci.  But the 
Windows drivers are ordinary pci drivers with nothing that looks 
pv-ish.  You could implement virtio-net hardware if you wanted to.

>>   non-privileged-user capable?
>>      
> The short answer is "not yet (I think)".  I need to write a patch to
> properly set the mode attribute in sysfs, but I think this will be trivial.
>
>    

(and selinux label)

>> Ah, so you have two control planes.
>>      
> So what?  If anything, it goes to show how extensible the framework is
> that a new plane could be added in 119 lines of code:
>
> ~/git/linux-2.6>  stg show vbus-add-admin-ioctls.patch | diffstat
>   Makefile       |    3 -
>   config-ioctl.c |  117
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 119 insertions(+), 1 deletion(-)
>
> if and when having two control planes exceeds its utility, I will submit
> a simple patch that removes the useless one.
>    

It always begins with a 119-line patch and then grows, that's life.

>> kvm didn't have an existing counterpart in Linux when it was
>> proposed/merged.
>>      
> And likewise, neither does vbus.
>
>    

For virt uses, I don't see the need.  For non-virt, I have no opinion.


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

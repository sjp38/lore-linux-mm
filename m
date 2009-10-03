Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 28DFF6B0092
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 06:01:02 -0400 (EDT)
Message-ID: <4AC720D0.6030300@redhat.com>
Date: Sat, 03 Oct 2009 12:00:48 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com> <4ABC7DCE.2000404@redhat.com> <4ABD36E3.9070503@gmail.com> <4ABF33B2.4000805@redhat.com> <4AC3B9C6.5090408@gmail.com> <4AC46989.7030502@redhat.com> <4AC501EB.8090608@gmail.com>
In-Reply-To: <4AC501EB.8090608@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 10/01/2009 09:24 PM, Gregory Haskins wrote:
>
>> Virtualization is about not doing that.  Sometimes it's necessary (when
>> you have made unfixable design mistakes), but just to replace a bus,
>> with no advantages to the guest that has to be changed (other
>> hypervisors or hypervisorless deployment scenarios aren't).
>>      
> The problem is that your continued assertion that there is no advantage
> to the guest is a completely unsubstantiated claim.  As it stands right
> now, I have a public git tree that, to my knowledge, is the fastest KVM
> PV networking implementation around.  It also has capabilities that are
> demonstrably not found elsewhere, such as the ability to render generic
> shared-memory interconnects (scheduling, timers), interrupt-priority
> (qos), and interrupt-coalescing (exit-ratio reduction).  I designed each
> of these capabilities after carefully analyzing where KVM was coming up
> short.
>
> Those are facts.
>
> I can't easily prove which of my new features alone are what makes it
> special per se, because I don't have unit tests for each part that
> breaks it down.  What I _can_ state is that its the fastest and most
> feature rich KVM-PV tree that I am aware of, and others may download and
> test it themselves to verify my claims.
>    

If you wish to introduce a feature which has downsides (and to me, vbus 
has downsides) then you must prove it is necessary on its own merits.  
venet is pretty cool but I need proof before I believe its performance 
is due to vbus and not to venet-host.

> The disproof, on the other hand, would be in a counter example that
> still meets all the performance and feature criteria under all the same
> conditions while maintaining the existing ABI.  To my knowledge, this
> doesn't exist.
>    

mst is working on it and we should have it soon.

> Therefore, if you believe my work is irrelevant, show me a git tree that
> accomplishes the same feats in a binary compatible way, and I'll rethink
> my position.  Until then, complaining about lack of binary compatibility
> is pointless since it is not an insurmountable proposition, and the one
> and only available solution declares it a required casualty.
>    

Fine, let's defer it until vhost-net is up and running.

>> Well, Xen requires pre-translation (since the guest has to give the host
>> (which is just another guest) permissions to access the data).
>>      
> Actually I am not sure that it does require pre-translation.  You might
> be able to use the memctx->copy_to/copy_from scheme in post translation
> as well, since those would be able to communicate to something like the
> xen kernel.  But I suppose either method would result in extra exits, so
> there is no distinct benefit using vbus there..as you say below "they're
> just different".
>
> The biggest difference is that my proposed model gets around the notion
> that the entire guest address space can be represented by an arbitrary
> pointer.  For instance, the copy_to/copy_from routines take a GPA, but
> may use something indirect like a DMA controller to access that GPA.  On
> the other hand, virtio fully expects a viable pointer to come out of the
> interface iiuc.  This is in part what makes vbus more adaptable to non-virt.
>    

No, virtio doesn't expect a pointer (this is what makes Xen possible).  
vhost does; but nothing prevents an interested party from adapting it.

>>> An interesting thing here is that you don't even need a fancy
>>> multi-homed setup to see the effects of my exit-ratio reduction work:
>>> even single port configurations suffer from the phenomenon since many
>>> devices have multiple signal-flows (e.g. network adapters tend to have
>>> at least 3 flows: rx-ready, tx-complete, and control-events (link-state,
>>> etc).  Whats worse, is that the flows often are indirectly related (for
>>> instance, many host adapters will free tx skbs during rx operations, so
>>> you tend to get bursts of tx-completes at the same time as rx-ready.  If
>>> the flows map 1:1 with IDT, they will suffer the same problem.
>>>
>>>        
>> You can simply use the same vector for both rx and tx and poll both at
>> every interrupt.
>>      
> Yes, but that has its own problems: e.g. additional exits or at least
> additional overhead figuring out what happens each time.

If you're just coalescing tx and rx, it's an additional memory read 
(which you have anyway in the vbus interrupt queue).

> This is even
> more important as we scale out to MQ which may have dozens of queue
> pairs.  You really want finer grained signal-path decode if you want
> peak performance.
>    

MQ definitely wants per-queue or per-queue-pair vectors, and it 
definitely doesn't want all interrupts to be serviced by a single 
interrupt queue (you could/should make the queue per-vcpu).

>>> Its important to note here that we are actually looking at the interrupt
>>> rate, not the exit rate (which is usually a multiple of the interrupt
>>> rate, since you have to factor in as many as three exits per interrupt
>>> (IPI, window, EOI).  Therefore we saved about 18k interrupts in this 10
>>> second burst, but we may have actually saved up to 54k exits in the
>>> process. This is only over a 10 second window at GigE rates, so YMMV.
>>> These numbers get even more dramatic on higher end hardware, but I
>>> haven't had a chance to generate new numbers yet.
>>>
>>>        
>> (irq window exits should only be required on a small percentage of
>> interrupt injections, since the guest will try to disable interrupts for
>> short periods only)
>>      
> Good point. You are probably right. Certainly the other 2 remain, however.
>
>    

You can easily eliminate most of the EOI exits by patching 
ack_APIC_irq() to do the following:

     if (atomic_inc_return(&vapic->eoi_count) < 0)
         null_hypercall();

Where eoi_count is a per-cpu shared counter that indicates how many EOIs 
were performed by the guest, with the sign bit a signal from the 
hypervisor that an lower-priority interrupt is pending.

We do something similar for the TPR, which is heavily exercised by 
Windows XP.

Note that svm provides a mechanism to queue interrupts without requiring 
the interrupt window; we don't use it in kvm (primarily because only a 
small fraction of injections would benefit).

> Ultimately, the fastest exit is the one you do not take.  That is what I
> am trying to achieve.
>    

The problem is that all those paravirtualizations bring their own 
problems and are quickly obsoleted by hardware advances.  Intel and AMD 
also see what you're seeing.  Sure, it takes hardware a long time to 
propagate to the field, but the same holds for software.

>
>>> The even worse news for 1:1 models is that the ratio of
>>> exits-per-interrupt climbs with load (exactly when it hurts the most)
>>> since that is when the probability that the vcpu will need all three
>>> exits is the highest.
>>>
>>>        
>> Requiring all three exits means the guest is spending most of its time
>> with interrupts disabled; that's unlikely.
>>      
> (see "softirqs" above)
>    

There are no softirqs above, please clarify.

>> Thanks for the numbers.  Are those 11% attributable to rx/tx
>> piggybacking from the same interface?
>>      
> Its hard to tell, since I am not instrumented to discern the difference
> in this run.  I do know from previous traces on the 10GE rig that the
> chelsio T3 that I am running reaps the pending-tx ring at the same time
> as a rx polling, so its very likely that both events are often
> coincident at least there.
>    

I assume you had only two active interrupts?  In that case, tx and rx 
mitigation should have prevented the same interrupt from coalescing with 
itself, so that leaves rx/tx coalescing as the only option?

>> Also, 170K interupts ->  17K interrupts/sec ->  55kbit/interrupt ->
>> 6.8kB/interrupt.  Ignoring interrupt merging and assuming equal rx/tx
>> distribution, that's about 13kB/interrupt.  Seems rather low for a
>> saturated link.
>>      
> I am not following: Do you suspect that I have too few interrupts to
> represent 940Mb/s, or that I have too little data/interrupt and this
> ratio should be improved?
>    

Too few bits/interrupt.  With tso, your "packets" should be 64KB at 
least, and you should expect multiple packets per tx interrupt.  Maybe 
these are all acks?

>>>>
>>>>          
>>> Everyone is of course entitled to an opinion, but the industry as a
>>> whole would disagree with you.  Signal path routing (1:1, aggregated,
>>> etc) is at the discretion of the bus designer.  Most buses actually do
>>> _not_ support 1:1 with IDT (think USB, SCSI, IDE, etc).
>>>
>>>        
>> With standard PCI, they do not.  But all modern host adapters support
>> MSI and they will happily give you one interrupt per queue.
>>      
> While MSI is a good technological advancement for PCI, I was referring
> to signal:IDT ratio.  MSI would still classify as 1:1.
>    

I meant, a multiqueue SCSI or network adapter is not N:1 but N:M since 
each queue would get its own interrupt.  So it looks like modern cards 
try to disaggregate, not aggregate.  Previously, non-MSI PCI forced them 
to aggregate by providing a small amount of irq pins.

>> Let's do that then.  Please reserve the corresponding comparisons from
>> your side as well.
>>      
> That is quite the odd request.  My graphs are all built using readily
> available code and open tools and do not speculate as to what someone
> else may come up with in the future.  They reflect what is available
> today.  Do you honestly think I should wait indefinitely for a competing
> idea to try to catch up before I talk about my results?  That's
> certainly an interesting perspective.
>    

You results are excellent and I'm not asking you hide them.  But you 
can't compare (more) complete code to incomplete code and state that 
this proves you are right, or to use results for an entire stack as 
proof that one component is what made it possible.

> With all due respect, the only red-herring is your unsubstantiated
> claims that my results do not matter.
>    

My claim is that your results are mostly due to venet-host.  I don't 
have a proof but you don't have a counterproof.  That is why I ask you 
to wait for vhost-net, it will give us more data so we can see what's what.

>>> This is not to mention
>>> that vhost-net does nothing to address our other goals, like scheduler
>>> coordination and non-802.x fabrics.
>>>
>>>        
>> What are scheduler coordination and non-802.x fabrics?
>>      
> We are working on real-time, IB and QOS, for examples, in addition to
> the now well known 802.x venet driver.
>    

Won't QoS require a departure from aggregated interrupts?  Suppose an 
low priority interrupt arrives and the guest starts processing, then a 
high priority interrupt.  Don't you need a real (IDT) interrupt to make 
the guest process the high-priority event?

>>>> Right, when you ignore the points where they don't fit, it's a perfect
>>>> mesh.
>>>>
>>>>          
>>> Where doesn't it fit?
>>>
>>>        
>> (avoiding infinite loop)
>>      
> I'm serious.  Where doesn't it fit?  Point me at a URL if its already
> discussed.
>    

Sorry, I lost the context; also my original comment wasn't very 
constructive, consider it retracted.

>>> Citation please.  Afaict, the one use case that we looked at for vhost
>>> outside of KVM failed to adapt properly, so I do not see how this is
>>> true.
>>>
>>>        
>> I think Ira said he can make vhost work?
>>
>>      
> Not exactly.  It kind of works for 802.x only (albeit awkwardly) because
> there is no strong distinction between "resource" and "consumer" with
> ethernet.  So you can run it inverted without any serious consequences
> (at least, not from consequences of the inversion).  Since the x86
> boards are the actual resource providers in his system, other device
> types will fail to map to the vhost model properly, like disk-io or
> consoles for instance.
>    

In that case vhost will have to be adapted or they will have to use 
something else.



>> virtio-net over pci is deployed.  Replacing the backend with vhost-net
>> will require no guest modifications.
>>      
> That _is_ a nice benefit, I agree.  I just do not agree its a hard
> requirement.
>    

Consider a cloud where the hypervisor is updated without the knowledge 
of the guest admins.  Either we break the guests and require the guest 
admins to login (without networking) to upgrade their drivers during 
production and then look for a new cloud, or we maintain both device 
models and ask the guest admins to upgrade their drivers so we can drop 
support for the old device, a request which they will rightly ignore.

>> Obviously virtio-net isn't deployed in non-virt.  But if we adopt vbus,
>> we have to migrate guests.
>>      
> As a first step, lets just shoot for "support" instead of "adopt".
>    

"support" means eventually "adopt", it isn't viable to maintain two 
models in parallel.

> Ill continue to push patches to you that help interfacing with the guest
> in a vbus neutral way (like irqfd/ioeventfd) and we can go from there.
> Are you open to this work assuming it passes normal review cycles, etc?
>   It would presumably be of use to others that want to interface to a
> guest (e.g. vhost) as well.
>    

Neutral interfaces are great, and I've already received feedback from 
third parties that they ought to work well for their uses.  I don't 
really like xinterface since I think it's too intrusive locking wise, 
especially when there's currently churn in kvm memory management.  But 
feel free to post your ideas or patches, maybe we can work something out.

>>> And once those events are fed, you still need a
>>> PV layer to actually handle the bus interface in a high-performance
>>> manner so its not like you really have a "native" stack in either case.
>>>
>>>        
>> virtio-net doesn't use any pv layer.
>>      
> Well, it does when you really look closely at how it works.  For one, it
> has the virtqueues library that would be (or at least _should be_)
> common for all virtio-X adapters, etc etc.  Even if this layer is
> collapsed into each driver on the Windows platform, its still there
> nonetheless.
>    

By "pv layer" I meant something that is visible along the guest/host 
interface.  virtio devices are completely independent from one another 
and (using virtio-pci) only talk through interfaces exposed by the 
relevant card.  If you wanted to, you could implement a virtio-pci card 
in silicon.

Practically the only difference between ordinary NICs and virtio-net is 
that interrupt status and enable/disable are stored in memory instead of 
NIC registers, but a real NIC could have done it the virtio way.

>>>> that doesn't need to be retrofitted.
>>>>
>>>>          
>>> No, that is incorrect.  You have to heavily modify the pci model with
>>> layers on top to get any kind of performance out of it.  Otherwise, we
>>> would just use realtek emulation, which is technically the native PCI
>>> you are apparently so enamored with.
>>>
>>>        
>> virtio-net doesn't modify the PCI model.
>>      
> Sure it does.  It doesn't use MMIO/PIO bars for registers, it uses
> vq->kick().

Which translates to a BAR register.

> It doesn't use pci-config-space, it uses virtio->features.
>    

Which translates to a BAR.

>   It doesn't use PCI interrupts, it uses a callback on the vq etc, etc.
> You would never use raw "registers", as the exit rate would crush you.
> You would never use raw interrupts, as you need a shared-memory based
> mitigation scheme.
>
> IOW: Virtio has a device model layer that tunnels over PCI.  It doesn't
> actually use PCI directly.  This is in fact what allows the linux
> version to work over lguest, s390 and vbus in addition to PCI.
>    

That's just a nice way to reuse the driver across multiple busses.  Kind 
of like isa/pci drivers that might even still exist in the source tree.  
On x86, virtio doesn't bypass PCI, just adds a layer above it.

>> You can have dynamic MSI/queue routing with virtio, and each MSI can be
>> routed to a vcpu at will.
>>      
> Can you arbitrarily create a new MSI/queue on a per-device basis on the
> fly?   We want to do this for some upcoming designs.  Or do you need to
> predeclare the vectors when the device is hot-added?
>    

You need to predeclare the number of vectors, but queue/interrupt 
assignment is runtime.


>>> priority, and coalescing, etc.
>>>
>>>        
>> Do you mean interrupt priority?  Well, apic allows interrupt priorities
>> and Windows uses them; Linux doesn't.  I don't see a reason to provide
>> more than native hardware.
>>      
> The APIC model is not optimal for PV given the exits required for a
> basic operation like an interrupt injection, and has scaling/flexibility
> issues with its 16:16 priority mapping.
>
> OTOH, you don't necessarily want to rip it out because of all the
> additional features it has like the IPI facility and the handling of
> many low-performance data-paths.  Therefore, I am of the opinion that
> the optimal placement for advanced signal handling is directly at the
> bus that provides the high-performance resources.  I could be convinced
> otherwise with a compelling argument, but I think this is the path of
> least resistance.
>    

With EOI PV you can reduce the cost of interrupt injection to slightly 
more than one exit/interrupt.  vbus might reduce it to slightly less 
than one exit/interrupt.

wrt priority, if you have 12 or fewer realtime interrupt sources you can 
map them to available priorities.  If you have more then you take extra 
interrupts, but at a ratio of 12:1 (so 24 realtime interrupts mean you 
may take a single extra exit).  The advantages of this is that all 
interrupts (not just vbus) are prioritized, and bare metal benefits as well.

If 12 is too low for you, pressure Intel to increase the TPR to 8 r/w 
bits, too bad they missed a chance with x2apic (which btw reduces the 
apic exit costs significantly).



>> N:1 breaks down on large guests since one vcpu will have to process all
>> events.
>>      
> Well, first of all that is not necessarily true.  Some high performance
> buses like SCSI and FC work fine with an aggregated model, so its not a
> foregone conclusion that aggregation kills SMP IO performance.  This is
> especially true when you adding coalescing on top, like AlacrityVM does.
>    

Nevertheless, the high performance adaptors provide multiqueue and MSI; 
one of the reasons is to distribute processing.

> I do agree that other subsystems, like networking for instance, may
> sometimes benefit from flexible signal-routing because of multiqueue,
> etc, for particularly large guests.  However, the decision to make the
> current kvm-connector used in AlacrityVM aggregate one priority FIFO per
> IRQ was an intentional design tradeoff.  My experience with my target
> user base is that these data-centers are typically deploying 1-4 vcpu
> guests, so I optimized for that.  YMMV, so we can design a different
> connector, or a different mode of the existing connector, to accommodate
> large guests as well if that was something desirable.
>
>    
>> You could do N:M, with commands to change routings, but where's
>> your userspace interface?
>>      
> Well, we should be able to add that when/if its needed.  I just don't
> think the need is there yet.  KVM tops out at 16 IIUC anyway.
>    

My feeling is that 16 will definitely need multiqueue, and perhaps even 4.

(we can probably up the 16, certainly with Marcelo's srcu work).

>> you can't tell from /proc/interrupts which
>> vbus interupts are active
>>      
> This should be trivial to add some kind of *fs display.  I will fix this
> shortly.
>    

And update irqbalance and other tools?  What about the Windows 
equivalent?  What happens when (say) Linux learns to migrate interrupts 
to where they're actually used?

This should really be done at the irqchip level, but before that, we 
need to be 100% certain it's worthwhile.

>> The larger your installed base, the more difficult it is.  Of course
>> it's doable, but I prefer not doing it and instead improving things in a
>> binary backwards compatible manner.  If there is no choice we will bow
>> to the inevitable and make our users upgrade.  But at this point there
>> is a choice, and I prefer to stick with vhost-net until it is proven
>> that it won't work.
>>      
> Fair enough.  But note you are likely going to need to respin your
> existing drivers anyway to gain peak performance, since there are known
> shortcomings in the virtio-pci ABI today (like queue identification in
> the interrupt hotpath) as it stands.  So that pain is coming one way or
> the other.
>    

We'll update the drivers but we won't require users to update.  The 
majority will not notice an upgrade; those who are interested in getting 
more performance will update their drivers (at their own schedule).

>> One of the benefits of virtualization is that the guest model is
>> stable.  You can live-migrate guests and upgrade the hardware
>> underneath.  You can have a single guest image that you clone to
>> provision new guests.  If you switch to a new model, you give up those
>> benefits, or you support both models indefinitely.
>>      
> I understand what you are saying, but I don't buy it.  If you add a new
> feature to an existing model even without something as drastic as a new
> bus, you still have the same exact dilemma:  The migration target needs
> feature parity with consumed features in the guest.  Its really the same
> no matter what unless you never add guest-visible features.
>    

When you upgrade your data center, you start upgrading your hypervisors 
(one by one, with live migration making it transparent) and certainly 
not exposing new features to running guests.  Once you are done you can 
expose the new features, and guests which can interested in them can 
upgrade their drivers and see them.

>> Note even hardware nowadays is binary compatible.  One e1000 driver
>> supports a ton of different cards, and I think (not sure) newer cards
>> will work with older drivers, just without all their features.
>>      
> Noted, but that is not really the same thing.  Thats more like adding a
> feature bit to virtio, not replacing GigE with 10GE.
>    

Right, and that's what virtio-net changes look like.

>>> If and when that becomes a priority concern, that would be a function
>>> transparently supported in the BIOS shipped with the hypervisor, and
>>> would thus be invisible to the user.
>>>
>>>        
>> No, you have to update the driver in your initrd (for Linux)
>>      
> Thats fine, the distros generally do this automatically when you load
> the updated KMP package.
>    

So it's not invisible to the user.  You update your hypervisor and now 
need to tell your users to add the new driver to their initrd and 
reboot.  They're not going to like you.


>> or properly install the new driver (for Windows).  It's especially
>> difficult for Windows.
>>      
> What is difficult here?  I never seem to have any problems and I have
> all kinds of guests from XP to Win7.
>    

If you accidentally reboot before you install the new driver, you won't 
boot; and there are issues with loading a new driver without the 
hardware present (not sure what exactly).

>> I don't want to support both virtio and vbus in parallel.  There's
>> enough work already.
>>      
> Until I find some compelling reason that indicates I was wrong about all
> of this, I will continue building a community around the vbus code base
> and developing support for its components anyway.  So that effort is
> going to happen in parallel regardless.
>
> This is purely a question about whether you will work with me to make
> vbus an available option in upstream KVM or not.
>    

Without xinterface there's no need for vbus support in kvm, so nothing's 
blocking you there.  I'm open to extending the host-side kvm interfaces 
to improve kernel integration.  However I still think vbus is the wrong 
design and shouldn't be merged.

>>   If we adopt vbus, we'll have to deprecate and eventually kill off virtio.
>>      
> Thats more hyperbole.  virtio is technically fine and complementary as
> it is.  No one says you have to do anything drastic w.r.t. virtio.  If
> you _did_ adopt vbus, perhaps you would want to optionally deprecate
> vhost or possibly the virtio-pci adapter, but that is about it.  The
> rest of the infrastructure should be preserved if it was designed properly.
>    

virtio-pci is what makes existing guests work (and vhost-net will 
certainly need to be killed off).  But I really don't see the point of 
layering virtio on top of vbus.

>> PCI is continuously updated, with MSI, MSI-X, and IOMMU support being
>> some recent updates.  I'd like to ride on top of that instead of having
>> to clone it for every guest I support.
>>      
> While a noble goal, one of the points I keep making though, as someone
> who has built the stack both ways, is almost none of the PCI stack is
> actually needed to get the PV job done.  The part you do need is
> primarily a function of the generic OS stack and trivial to interface
> with anyway.
>    

PCI doesn't stand in the way of pv, and allows us to have a uniform 
interface to purely emulated, pv, and assigned devices, with minimal 
changes to the guest.  To me that's the path of least resistance.

>>
>>>>> As an added bonus, its device-model is modular.  A developer can
>>>>> write a
>>>>> new device model, compile it, insmod it to the host kernel, hotplug it
>>>>> to the running guest with mkdir/ln, and the come back out again
>>>>> (hotunplug with rmdir, rmmod, etc).  They may do this all without
>>>>> taking
>>>>> the guest down, and while eating QEMU based IO solutions for breakfast
>>>>> performance wise.
>>>>>
>>>>> Afaict, qemu can't do either of those things.
>>>>>
>>>>>
>>>>>            
>>>> We've seen that herring before,
>>>>
>>>>          
>>> Citation?
>>>
>>>        
>> It's the compare venet-in-kernel to virtio-in-userspace thing again.
>>      
> No, you said KVM has "userspace hotplug".  I retorted that vbus not only
> has hotplug, it also has a modular architecture.  You then countered
> that this feature is a red-herring.  If this was previously discussed
> and rejected for some reason, I would like to know the history.  Or did
> I misunderstand you?
>    

I was talking about your breakfast (the performance comparison again).

> For one, we have the common layer of shm-signal, and IOQ.  These
> libraries were designed to be reused on both sides of the link.
> Generally shm-signal has no counterpart in the existing model, though
> its functionality is integrated into the virtqueue.

I agree that ioq/shm separation is a nice feature.


>  From there, going down the stack, it looks like
>
>      (guest-side)
> |-------------------------
> | venet (competes with virtio-net)
> |-------------------------
> | vbus-proxy (competes with pci-bus, config+hotplug, sync/async)
> |-------------------------
> | vbus-pcibridge (interrupt coalescing + priority, fastpath)
> |-------------------------
>             |
> |-------------------------
> | vbus-kvmconnector (interrupt coalescing + priority, fast-path)
> |-------------------------
> | vbus-core (hotplug, address decoding, etc)
> |-------------------------
> | venet-device (ioq frame/deframe to tap/macvlan/vmdq, etc)
> |-------------------------
>
> If you want to use virtio, insert a virtio layer between the "driver"
> and "device" components at the outer edges of the stack.
>    

But then it adds no value.  It's just another shim.

>> To me, compatible means I can live migrate an image to a new system
>> without the user knowing about the change.  You'll be able to do that
>> with vhost-net.
>>      
> As soon as you add any new guest-visible feature, you are in the same
> exact boat.
>    

No.  You support two-way migration while hiding new features.  You 
support one-way migration if you expose new features (suitable for data 
center upgrade).  You don't support any migration if you switch models.

>>> No, that is incorrect.  For one, vhost uses them on a per-signal path
>>> basis, whereas vbus only has one channel for the entire guest->host.
>>>
>>>        
>> You'll probably need to change that as you start running smp guests.
>>      
> The hypercall channel is already SMP optimized over a single PIO path,
> so I think we are covered there.  See "fastcall" in my code for details:
>
> http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=blob;f=drivers/vbus/pci-bridge.c;h=81f7cdd2167ae2f53406850ebac448a2183842f2;hb=fd1c156be7735f8b259579f18268a756beccfc96#l102
>
> It just passes the cpuid into the PIO write so we can have parallel,
> lockless "hypercalls".  This forms the basis of our guest scheduler
> support, for instance.
>    

This is... wierd.  Scheduler support should be part of kvm core and done 
using ordinary hypercalls, not as part of a bus model.

>>   You could implement virtio-net hardware if you wanted to.
>>      
> Technically you could build vbus in hardware too, I suppose, since the
> bridge is PCI compliant.  I would never advocate it, however, since many
> of our tricks do not matter if its real hardware (e.g. they are
> optimized for the costs associated with VM).
>    

No, you can't.  You won't get the cpuid in your pio writes, for one.  
And if multiple vbus cards are plugged into different PCI slots, they 
either lost inter-card interrupt coalescing, or you have to connect them 
in a side-channel.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

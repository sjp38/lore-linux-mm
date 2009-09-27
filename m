Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3887C6B0055
	for <linux-mm@kvack.org>; Sun, 27 Sep 2009 05:43:30 -0400 (EDT)
Message-ID: <4ABF33B2.4000805@redhat.com>
Date: Sun, 27 Sep 2009 11:43:14 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com> <4ABC7DCE.2000404@redhat.com> <4ABD36E3.9070503@gmail.com>
In-Reply-To: <4ABD36E3.9070503@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/26/2009 12:32 AM, Gregory Haskins wrote:
>>>
>>> I realize in retrospect that my choice of words above implies vbus _is_
>>> complete, but this is not what I was saying.  What I was trying to
>>> convey is that vbus is _more_ complete.  Yes, in either case some kind
>>> of glue needs to be written.  The difference is that vbus implements
>>> more of the glue generally, and leaves less required to be customized
>>> for each iteration.
>>>
>>>        
>>
>> No argument there.  Since you care about non-virt scenarios and virtio
>> doesn't, naturally vbus is a better fit for them as the code stands.
>>      
> Thanks for finally starting to acknowledge there's a benefit, at least.
>    

I think I've mentioned vbus' finer grained layers as helpful here, 
though I doubt the value of this.  Hypervisors are added rarely, while 
devices and drivers are added (and modified) much more often.  I don't 
buy the anything-to-anything promise.

> To be more precise, IMO virtio is designed to be a performance oriented
> ring-based driver interface that supports all types of hypervisors (e.g.
> shmem based kvm, and non-shmem based Xen).  vbus is designed to be a
> high-performance generic shared-memory interconnect (for rings or
> otherwise) framework for environments where linux is the underpinning
> "host" (physical or virtual).  They are distinctly different, but
> complementary (the former addresses the part of the front-end, and
> latter addresses the back-end, and a different part of the front-end).
>    

They're not truly complementary since they're incompatible.  A 2.6.27 
guest, or Windows guest with the existing virtio drivers, won't work 
over vbus.  Further, non-shmem virtio can't work over vbus.  Since 
virtio is guest-oriented and host-agnostic, it can't ignore 
non-shared-memory hosts (even though it's unlikely virtio will be 
adopted there).

> In addition, the kvm-connector used in AlacrityVM's design strives to
> add value and improve performance via other mechanisms, such as dynamic
>   allocation, interrupt coalescing (thus reducing exit-ratio, which is a
> serious issue in KVM)

Do you have measurements of inter-interrupt coalescing rates (excluding 
intra-interrupt coalescing).

> and priortizable/nestable signals.
>    

That doesn't belong in a bus.

> Today there is a large performance disparity between what a KVM guest
> sees and what a native linux application sees on that same host.  Just
> take a look at some of my graphs between "virtio", and "native", for
> example:
>
> http://developer.novell.com/wiki/images/b/b7/31-rc4_throughput.png
>    

That's a red herring.  The problem is not with virtio as an ABI, but 
with its implementation in userspace.  vhost-net should offer equivalent 
performance to vbus.

> A dominant vbus design principle is to try to achieve the same IO
> performance for all "linux applications" whether they be literally
> userspace applications, or things like KVM vcpus or Ira's physical
> boards.  It also aims to solve problems not previously expressible with
> current technologies (even virtio), like nested real-time.
>
> And even though you repeatedly insist otherwise, the neat thing here is
> that the two technologies mesh (at least under certain circumstances,
> like when virtio is deployed on a shared-memory friendly linux backend
> like KVM).  I hope that my stack diagram below depicts that clearly.
>    

Right, when you ignore the points where they don't fit, it's a perfect mesh.

>> But that's not a strong argument for vbus; instead of adding vbus you
>> could make virtio more friendly to non-virt
>>      
> Actually, it _is_ a strong argument then because adding vbus is what
> helps makes virtio friendly to non-virt, at least for when performance
> matters.
>    

As vhost-net shows, you can do that without vbus and without breaking 
compatibility.



>> Right.  virtio assumes that it's in a virt scenario and that the guest
>> architecture already has enumeration and hotplug mechanisms which it
>> would prefer to use.  That happens to be the case for kvm/x86.
>>      
> No, virtio doesn't assume that.  It's stack provides the "virtio-bus"
> abstraction and what it does assume is that it will be wired up to
> something underneath. Kvm/x86 conveniently has pci, so the virtio-pci
> adapter was created to reuse much of that facility.  For other things
> like lguest and s360, something new had to be created underneath to make
> up for the lack of pci-like support.
>    

Right, I was wrong there.  But it does allow you to have a 1:1 mapping 
between native devices and virtio devices.


>>> So to answer your question, the difference is that the part that has to
>>> be customized in vbus should be a fraction of what needs to be
>>> customized with vhost because it defines more of the stack.
>>>        
>> But if you want to use the native mechanisms, vbus doesn't have any
>> added value.
>>      
> First of all, thats incorrect.  If you want to use the "native"
> mechanisms (via the way the vbus-connector is implemented, for instance)
> you at least still have the benefit that the backend design is more
> broadly re-useable in more environments (like non-virt, for instance),
> because vbus does a proper job of defining the requisite
> layers/abstractions compared to vhost.  So it adds value even in that
> situation.
>    

Maybe.  If vhost-net isn't sufficient I'm sure there will be patches sent.

> Second of all, with PV there is no such thing as "native".  It's
> software so it can be whatever we want.  Sure, you could argue that the
> guest may have built-in support for something like PCI protocol.
> However, PCI protocol itself isn't suitable for high-performance PV out
> of the can.  So you will therefore invariably require new software
> layers on top anyway, even if part of the support is already included.
>    

Of course there is such a thing as native, a pci-ready guest has tons of 
support built into it that doesn't need to be retrofitted.  Since 
practically everyone (including Xen) does their paravirt drivers atop 
pci, the claim that pci isn't suitable for high performance is incorrect.


> And lastly, why would you _need_ to use the so called "native"
> mechanism?  The short answer is, "you don't".  Any given system (guest
> or bare-metal) already have a wide-range of buses (try running "tree
> /sys/bus" in Linux).  More importantly, the concept of adding new buses
> is widely supported in both the Windows and Linux driver model (and
> probably any other guest-type that matters).  Therefore, despite claims
> to the contrary, its not hard or even unusual to add a new bus to the mix.
>    

The short answer is "compatibility".


> In summary, vbus is simply one more bus of many, purpose built to
> support high-end IO in a virt-like model, giving controlled access to
> the linux-host underneath it.  You can write a high-performance layer
> below the OS bus-model (vbus), or above it (virtio-pci) but either way
> you are modifying the stack to add these capabilities, so we might as
> well try to get this right.
>
> With all due respect, you are making a big deal out of a minor issue.
>    

It's not minor to me.

>>> And, as
>>> eluded to in my diagram, both virtio-net and vhost (with some
>>> modifications to fit into the vbus framework) are potentially
>>> complementary, not competitors.
>>>
>>>        
>> Only theoretically.  The existing installed base would have to be thrown
>> away
>>      
> "Thrown away" is pure hyperbole.  The installed base, worse case, needs
> to load a new driver for a missing device.

Yes, we all know how fun this is.  Especially if the device changed is 
your boot disk.  You may not care about the pain caused to users, but I 
do, so I will continue to insist on compatibility.

>> or we'd need to support both.
>>
>>
>>      
> No matter what model we talk about, there's always going to be a "both"
> since the userspace virtio models are probably not going to go away (nor
> should they).
>    

virtio allows you to have userspace-only, kernel-only, or 
start-with-userspace-and-move-to-kernel-later, all transparent to the 
guest.  In many cases we'll stick with userspace-only.

>> All this is after kvm has decoded that vbus is addresses.  It can't work
>> without someone outside vbus deciding that.
>>      
> How the connector message is delivered is really not relevant.  Some
> architectures will simply deliver the message point-to-point (like the
> original hypercall design for KVM, or something like Ira's rig), and
> some will need additional demuxing (like pci-bridge/pio based KVM).
> It's an implementation detail of the connector.
>
> However, the real point here is that something needs to establish a
> scoped namespace mechanism, add items to that namespace, and advertise
> the presence of the items to the guest.  vbus has this facility built in
> to its stack.  vhost doesn't, so it must come from elsewhere.
>    

So we have: vbus needs a connector, vhost needs a connector.  vbus 
doesn't need userspace to program the addresses (but does need userspace 
to instantiate the devices and to program the bus address decode), vhost 
needs userspace to instantiate the devices and program the addresses.

>>> In fact, it's actually a simpler design to unify things this way because
>>> you avoid splitting the device model up. Consider how painful the vhost
>>> implementation would be if it didn't already have the userspace
>>> virtio-net to fall-back on.  This is effectively what we face for new
>>> devices going forward if that model is to persist.
>>>
>>>        
>>
>> It doesn't have just virtio-net, it has userspace-based hostplug
>>      
> vbus has hotplug too: mkdir and rmdir
>    

Does that work from nonprivileged processes?  Does it work on Windows?

> As an added bonus, its device-model is modular.  A developer can write a
> new device model, compile it, insmod it to the host kernel, hotplug it
> to the running guest with mkdir/ln, and the come back out again
> (hotunplug with rmdir, rmmod, etc).  They may do this all without taking
> the guest down, and while eating QEMU based IO solutions for breakfast
> performance wise.
>
> Afaict, qemu can't do either of those things.
>    

We've seen that herring before, and it's redder than ever.



>> Refactor instead of duplicating.
>>      
> There is no duplicating.  vbus has no equivalent today as virtio doesn't
> define these layers.
>    

So define them if they're missing.


>>>
>>>        
>>>>    Use libraries (virtio-shmem.ko, libvhost.so).
>>>>
>>>>          
>>> What do you suppose vbus is?  vbus-proxy.ko = virtio-shmem.ko, and you
>>> dont need libvhost.so per se since you can just use standard kernel
>>> interfaces (like configfs/sysfs).  I could create an .so going forward
>>> for the new ioctl-based interface, I suppose.
>>>
>>>        
>> Refactor instead of rewriting.
>>      
> There is no rewriting.  vbus has no equivalent today as virtio doesn't
> define these layers.
>
> By your own admission, you said if you wanted that capability, use a
> library.  What I think you are not understanding is vbus _is_ that
> library.  So what is the problem, exactly?
>    

It's not compatible.  If you were truly worried about code duplication 
in virtio, you'd refactor it to remove the duplication, without 
affecting existing guests.

>>>> For kvm/x86 pci definitely remains king.
>>>>
>>>>          
>>> For full virtualization, sure.  I agree.  However, we are talking about
>>> PV here.  For PV, PCI is not a requirement and is a technical dead-end
>>> IMO.
>>>
>>> KVM seems to be the only virt solution that thinks otherwise (*), but I
>>> believe that is primarily a condition of its maturity.  I aim to help
>>> advance things here.
>>>
>>> (*) citation: xen has xenbus, lguest has lguest-bus, vmware has some
>>> vmi-esq thing (I forget what its called) to name a few.  Love 'em or
>>> hate 'em, most other hypervisors do something along these lines.  I'd
>>> like to try to create one for KVM, but to unify them all (at least for
>>> the Linux-based host designs).
>>>
>>>        
>> VMware are throwing VMI away (won't be supported in their new product,
>> and they've sent a patch to rip it off from Linux);
>>      
> vmware only cares about x86 iiuc, so probably not a good example.
>    

Well, you brought it up.  Between you and me, I only care about x86 too.

>> Xen has to tunnel
>> xenbus in pci for full virtualization (which is where Windows is, and
>> where Linux will be too once people realize it's faster).  lguest is
>> meant as an example hypervisor, not an attempt to take over the world.
>>      
> So pick any other hypervisor, and the situation is often similar.
>    

The situation is often pci.

>
>> An right now you can have a guest using pci to access a mix of
>> userspace-emulated devices, userspace-emulated-but-kernel-accelerated
>> virtio devices, and real host devices.  All on one dead-end bus.  Try
>> that with vbus.
>>      
> vbus is not interested in userspace devices.  The charter is to provide
> facilities for utilizing the host linux kernel's IO capabilities in the
> most efficient, yet safe, manner possible.  Those devices that fit
> outside that charter can ride on legacy mechanisms if that suits them best.
>    

vbus isn't, but I am.  I would prefer not to have to expose 
implementation decisions (kernel vs userspace) to the guest (vbus vs pci).

>>> That won't cut it.  For one, creating an eventfd is only part of the
>>> equation.  I.e. you need to have originate/terminate somewhere
>>> interesting (and in-kernel, otherwise use tuntap).
>>>
>>>        
>> vbus needs the same thing so it cancels out.
>>      
> No, it does not.  vbus just needs a relatively simple single message
> pipe between the guest and host (think "hypercall tunnel", if you will).
>    

That's ioeventfd.  So far so similar.

>   Per queue/device addressing is handled by the same conceptual namespace
> as the one that would trigger eventfds in the model you mention.  And
> that namespace is built in to the vbus stack, and objects are registered
> automatically as they are created.
>
> Contrast that to vhost, which requires some other kernel interface to
> exist, and to be managed manually for each object that is created.  Your
> libvhostconfig would need to somehow know how to perform this
> registration operation, and there would have to be something in the
> kernel to receive it, presumably on a per platform basis.  Solving this
> problem generally would probably end up looking eerily like vbus,
> because thats what vbus does.
>    

vbus devices aren't magically instantiated.  Userspace needs to 
instantiate them too.  Sure, there's less work on the host side since 
you're using vbus instead of the native interface, but more work on the 
guest side since you're using vbus instead of the native interface.



>> Well, let's see.  Can vbus today:
>>
>> - let userspace know which features are available (so it can decide if
>> live migration is possible)
>>      
> yes, its in sysfs.
>
>    
>> - let userspace limit which features are exposed to the guest (so it can
>> make live migration possible among hosts of different capabilities)
>>      
> yes, its in sysfs.
>    

Per-device?  non-privileged-user capable?

>> - let userspace know which features were negotiated (so it can transfer
>> them to the other host during live migration)
>>      
> no, but we can easily add ->save()/->restore() to the model going
> forward, and the negotiated features are just a subcomponent if its
> serialized stream.
>
>    
>> - let userspace tell the kernel which features were negotiated (when
>> live migration completes, to avoid requiring the guest to re-negotiate)
>>      
> that would be the function of the ->restore() deserializer.
>
>    
>> - do all that from an unprivileged process
>>      
> yes, in the upcoming alacrityvm v0.3 with the ioctl based control plane.
>    

Ah, so you have two control planes.

> Bottom line: vbus isn't done, especially w.r.t. live-migration..but that
> is not an valid argument against the idea if you believe in
> release-early/release-often. kvm wasn't (isn't) done either when it was
> proposed/merged.
>
>    

kvm didn't have an existing counterpart in Linux when it was 
proposed/merged.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

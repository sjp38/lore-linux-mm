Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5659D6B0088
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:22:46 -0400 (EDT)
Message-ID: <4ABC7DCE.2000404@redhat.com>
Date: Fri, 25 Sep 2009 11:22:38 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <4ABBB46D.2000102@gmail.com>
In-Reply-To: <4ABBB46D.2000102@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/24/2009 09:03 PM, Gregory Haskins wrote:
>
>> I don't really see how vhost and vbus are different here.  vhost expects
>> signalling to happen through a couple of eventfds and requires someone
>> to supply them and implement kernel support (if needed).  vbus requires
>> someone to write a connector to provide the signalling implementation.
>> Neither will work out-of-the-box when implementing virtio-net over
>> falling dominos, for example.
>>      
> I realize in retrospect that my choice of words above implies vbus _is_
> complete, but this is not what I was saying.  What I was trying to
> convey is that vbus is _more_ complete.  Yes, in either case some kind
> of glue needs to be written.  The difference is that vbus implements
> more of the glue generally, and leaves less required to be customized
> for each iteration.
>    


No argument there.  Since you care about non-virt scenarios and virtio 
doesn't, naturally vbus is a better fit for them as the code stands.  
But that's not a strong argument for vbus; instead of adding vbus you 
could make virtio more friendly to non-virt (there's a limit how far you 
can take this, not imposed by the code, but by virtio's charter as a 
virtual device driver framework).

> Going back to our stack diagrams, you could think of a vhost solution
> like this:
>
> --------------------------
> | virtio-net
> --------------------------
> | virtio-ring
> --------------------------
> | virtio-bus
> --------------------------
> | ? undefined-1 ?
> --------------------------
> | vhost
> --------------------------
>
> and you could think of a vbus solution like this
>
> --------------------------
> | virtio-net
> --------------------------
> | virtio-ring
> --------------------------
> | virtio-bus
> --------------------------
> | bus-interface
> --------------------------
> | ? undefined-2 ?
> --------------------------
> | bus-model
> --------------------------
> | virtio-net-device (vhost ported to vbus model? :)
> --------------------------
>
>
> So the difference between vhost and vbus in this particular context is
> that you need to have "undefined-1" do device discovery/hotswap,
> config-space, address-decode/isolation, signal-path routing, memory-path
> routing, etc.  Today this function is filled by things like virtio-pci,
> pci-bus, KVM/ioeventfd, and QEMU for x86.  I am not as familiar with
> lguest, but presumably it is filled there by components like
> virtio-lguest, lguest-bus, lguest.ko, and lguest-launcher.  And to use
> more contemporary examples, we might have virtio-domino, domino-bus,
> domino.ko, and domino-launcher as well as virtio-ira, ira-bus, ira.ko,
> and ira-launcher.
>
> Contrast this to the vbus stack:  The bus-X components (when optionally
> employed by the connector designer) do device-discovery, hotswap,
> config-space, address-decode/isolation, signal-path and memory-path
> routing, etc in a general (and pv-centric) way. The "undefined-2"
> portion is the "connector", and just needs to convey messages like
> "DEVCALL" and "SHMSIGNAL".  The rest is handled in other parts of the stack.
>
>    

Right.  virtio assumes that it's in a virt scenario and that the guest 
architecture already has enumeration and hotplug mechanisms which it 
would prefer to use.  That happens to be the case for kvm/x86.

> So to answer your question, the difference is that the part that has to
> be customized in vbus should be a fraction of what needs to be
> customized with vhost because it defines more of the stack.

But if you want to use the native mechanisms, vbus doesn't have any 
added value.

> And, as
> eluded to in my diagram, both virtio-net and vhost (with some
> modifications to fit into the vbus framework) are potentially
> complementary, not competitors.
>    

Only theoretically.  The existing installed base would have to be thrown 
away, or we'd need to support both.

  


>> Without a vbus-connector-falling-dominos, vbus-venet can't do anything
>> either.
>>      
> Mostly covered above...
>
> However, I was addressing your assertion that vhost somehow magically
> accomplishes this "container/addressing" function without any specific
> kernel support.  This is incorrect.  I contend that this kernel support
> is required and present.  The difference is that its defined elsewhere
> (and typically in a transport/arch specific way).
>
> IOW: You can basically think of the programmed PIO addresses as forming
> its "container".  Only addresses explicitly added are visible, and
> everything else is inaccessible.  This whole discussion is merely a
> question of what's been generalized verses what needs to be
> re-implemented each time.
>    

Sorry, this is too abstract for me.



>> vbus doesn't do kvm guest address decoding for the fast path.  It's
>> still done by ioeventfd.
>>      
> That is not correct.  vbus does its own native address decoding in the
> fast path, such as here:
>
> http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=blob;f=kernel/vbus/client.c;h=e85b2d92d629734866496b67455dd307486e394a;hb=e6cbd4d1decca8e829db3b2b9b6ec65330b379e9#l331
>
>    

All this is after kvm has decoded that vbus is addresses.  It can't work 
without someone outside vbus deciding that.

> In fact, it's actually a simpler design to unify things this way because
> you avoid splitting the device model up. Consider how painful the vhost
> implementation would be if it didn't already have the userspace
> virtio-net to fall-back on.  This is effectively what we face for new
> devices going forward if that model is to persist.
>    


It doesn't have just virtio-net, it has userspace-based hostplug and a 
bunch of other devices impemented in userspace.  Currently qemu has 
virtio bindings for pci and syborg (whatever that is), and device models 
for baloon, block, net, and console, so it seems implementing device 
support in userspace is not as disasterous as you make it to be.

>> Invariably?
>>      
> As in "always"
>    

Refactor instead of duplicating.

>    
>>   Use libraries (virtio-shmem.ko, libvhost.so).
>>      
> What do you suppose vbus is?  vbus-proxy.ko = virtio-shmem.ko, and you
> dont need libvhost.so per se since you can just use standard kernel
> interfaces (like configfs/sysfs).  I could create an .so going forward
> for the new ioctl-based interface, I suppose.
>    

Refactor instead of rewriting.



>> For kvm/x86 pci definitely remains king.
>>      
> For full virtualization, sure.  I agree.  However, we are talking about
> PV here.  For PV, PCI is not a requirement and is a technical dead-end IMO.
>
> KVM seems to be the only virt solution that thinks otherwise (*), but I
> believe that is primarily a condition of its maturity.  I aim to help
> advance things here.
>
> (*) citation: xen has xenbus, lguest has lguest-bus, vmware has some
> vmi-esq thing (I forget what its called) to name a few.  Love 'em or
> hate 'em, most other hypervisors do something along these lines.  I'd
> like to try to create one for KVM, but to unify them all (at least for
> the Linux-based host designs).
>    

VMware are throwing VMI away (won't be supported in their new product, 
and they've sent a patch to rip it off from Linux); Xen has to tunnel 
xenbus in pci for full virtualization (which is where Windows is, and 
where Linux will be too once people realize it's faster).  lguest is 
meant as an example hypervisor, not an attempt to take over the world.

"PCI is a dead end" could not be more wrong, it's what guests support.  
An right now you can have a guest using pci to access a mix of 
userspace-emulated devices, userspace-emulated-but-kernel-accelerated 
virtio devices, and real host devices.  All on one dead-end bus.  Try 
that with vbus.


>>> I digress.  My point here isn't PCI.  The point here is the missing
>>> component for when PCI is not present.  The component that is partially
>>> satisfied by vbus's devid addressing scheme.  If you are going to use
>>> vhost, and you don't have PCI, you've gotta build something to replace
>>> it.
>>>
>>>        
>> Yes, that's why people have keyboards.  They'll write that glue code if
>> they need it.  If it turns out to be a hit an people start having virtio
>> transport module writing parties, they'll figure out a way to share code.
>>      
> Sigh...  The party has already started.  I tried to invite you months ago...
>    

I've been voting virtio since 2007.

>> On the guest side, virtio-shmem.ko can unify the ring access.  It
>> probably makes sense even today.  On the host side I eventfd is the
>> kernel interface and libvhostconfig.so can provide the configuration
>> when an existing ABI is not imposed.
>>      
> That won't cut it.  For one, creating an eventfd is only part of the
> equation.  I.e. you need to have originate/terminate somewhere
> interesting (and in-kernel, otherwise use tuntap).
>    

vbus needs the same thing so it cancels out.

>> Look at the virtio-net feature negotiation.  There's a lot more there
>> than the MAC address, and it's going to grow.
>>      
> Agreed, but note that makes my point.  That feature negotiation almost
> invariably influences the device-model, not some config-space shim.
> IOW: terminating config-space at some userspace shim is pointless.  The
> model ultimately needs the result of whatever transpires during that
> negotiation anyway.
>    

Well, let's see.  Can vbus today:

- let userspace know which features are available (so it can decide if 
live migration is possible)
- let userspace limit which features are exposed to the guest (so it can 
make live migration possible among hosts of different capabilities)
- let userspace know which features were negotiated (so it can transfer 
them to the other host during live migration)
- let userspace tell the kernel which features were negotiated (when 
live migration completes, to avoid requiring the guest to re-negotiate)
- do all that from an unprivileged process
- securely wrt other unprivileged processes

?

What are your plans here?



-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

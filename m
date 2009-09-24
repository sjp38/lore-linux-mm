Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EFC406B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 03:18:46 -0400 (EDT)
Message-ID: <4ABB1D44.5000007@redhat.com>
Date: Thu, 24 Sep 2009 10:18:28 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com>
In-Reply-To: <4ABA8FDC.5010008@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/24/2009 12:15 AM, Gregory Haskins wrote:
>
>>> There are various aspects about designing high-performance virtual
>>> devices such as providing the shortest paths possible between the
>>> physical resources and the consumers.  Conversely, we also need to
>>> ensure that we meet proper isolation/protection guarantees at the same
>>> time.  What this means is there are various aspects to any
>>> high-performance PV design that require to be placed in-kernel to
>>> maximize the performance yet properly isolate the guest.
>>>
>>> For instance, you are required to have your signal-path (interrupts and
>>> hypercalls), your memory-path (gpa translation), and
>>> addressing/isolation model in-kernel to maximize performance.
>>>
>>>        
>> Exactly.  That's what vhost puts into the kernel and nothing more.
>>      
> Actually, no.  Generally, _KVM_ puts those things into the kernel, and
> vhost consumes them.  Without KVM (or something equivalent), vhost is
> incomplete.  One of my goals with vbus is to generalize the "something
> equivalent" part here.
>    

I don't really see how vhost and vbus are different here.  vhost expects 
signalling to happen through a couple of eventfds and requires someone 
to supply them and implement kernel support (if needed).  vbus requires 
someone to write a connector to provide the signalling implementation.  
Neither will work out-of-the-box when implementing virtio-net over 
falling dominos, for example.

>>> Vbus accomplishes its in-kernel isolation model by providing a
>>> "container" concept, where objects are placed into this container by
>>> userspace.  The host kernel enforces isolation/protection by using a
>>> namespace to identify objects that is only relevant within a specific
>>> container's context (namely, a "u32 dev-id").  The guest addresses the
>>> objects by its dev-id, and the kernel ensures that the guest can't
>>> access objects outside of its dev-id namespace.
>>>
>>>        
>> vhost manages to accomplish this without any kernel support.
>>      
> No, vhost manages to accomplish this because of KVMs kernel support
> (ioeventfd, etc).   Without a KVM-like in-kernel support, vhost is a
> merely a kind of "tuntap"-like clone signalled by eventfds.
>    

Without a vbus-connector-falling-dominos, vbus-venet can't do anything 
either.  Both vhost and vbus need an interface, vhost's is just narrower 
since it doesn't do configuration or enumeration.

> This goes directly to my rebuttal of your claim that vbus places too
> much in the kernel.  I state that, one way or the other, address decode
> and isolation _must_ be in the kernel for performance.  Vbus does this
> with a devid/container scheme.  vhost+virtio-pci+kvm does it with
> pci+pio+ioeventfd.
>    

vbus doesn't do kvm guest address decoding for the fast path.  It's 
still done by ioeventfd.

>>   The guest
>> simply has not access to any vhost resources other than the guest->host
>> doorbell, which is handed to the guest outside vhost (so it's somebody
>> else's problem, in userspace).
>>      
> You mean _controlled_ by userspace, right?  Obviously, the other side of
> the kernel still needs to be programmed (ioeventfd, etc).  Otherwise,
> vhost would be pointless: e.g. just use vanilla tuntap if you don't need
> fast in-kernel decoding.
>    

Yes (though for something like level-triggered interrupts we're probably 
keeping it in userspace, enjoying the benefits of vhost data path while 
paying more for signalling).

>>> All that is required is a way to transport a message with a "devid"
>>> attribute as an address (such as DEVCALL(devid)) and the framework
>>> provides the rest of the decode+execute function.
>>>
>>>        
>> vhost avoids that.
>>      
> No, it doesn't avoid it.  It just doesn't specify how its done, and
> relies on something else to do it on its behalf.
>    

That someone else can be in userspace, apart from the actual fast path.

> Conversely, vbus specifies how its done, but not how to transport the
> verb "across the wire".  That is the role of the vbus-connector abstraction.
>    

So again, vbus does everything in the kernel (since it's so easy and 
cheap) but expects a vbus-connector.  vhost does configuration in 
userspace (since it's so clunky and fragile) but expects a couple of 
eventfds.

>>> Contrast this to vhost+virtio-pci (called simply "vhost" from here).
>>>
>>>        
>> It's the wrong name.  vhost implements only the data path.
>>      
> Understood, but vhost+virtio-pci is what I am contrasting, and I use
> "vhost" for short from that point on because I am too lazy to type the
> whole name over and over ;)
>    

If you #define A A+B+C don't expect intelligent conversation afterwards.

>>> It is not immune to requiring in-kernel addressing support either, but
>>> rather it just does it differently (and its not as you might expect via
>>> qemu).
>>>
>>> Vhost relies on QEMU to render PCI objects to the guest, which the guest
>>> assigns resources (such as BARs, interrupts, etc).
>>>        
>> vhost does not rely on qemu.  It relies on its user to handle
>> configuration.  In one important case it's qemu+pci.  It could just as
>> well be the lguest launcher.
>>      
> I meant vhost=vhost+virtio-pci here.  Sorry for the confusion.
>
> The point I am making specifically is that vhost in general relies on
> other in-kernel components to function.  I.e. It cannot function without
> having something like the PCI model to build an IO namespace.  That
> namespace (in this case, pio addresses+data tuples) are used for the
> in-kernel addressing function under KVM + virtio-pci.
>
> The case of the lguest launcher is a good one to highlight.  Yes, you
> can presumably also use lguest with vhost, if the requisite facilities
> are exposed to lguest-bus, and some eventfd based thing like ioeventfd
> is written for the host (if it doesnt exist already).
>
> And when the next virt design "foo" comes out, it can make a "foo-bus"
> model, and implement foo-eventfd on the backend, etc, etc.
>    

It's exactly the same with vbus needing additional connectors for 
additional transports.

> Ira can make ira-bus, and ira-eventfd, etc, etc.
>
> Each iteration will invariably introduce duplicated parts of the stack.
>    

Invariably?  Use libraries (virtio-shmem.ko, libvhost.so).


>> For the N+1th time, no.  vhost is perfectly usable without pci.  Can we
>> stop raising and debunking this point?
>>      
> Again, I understand vhost is decoupled from PCI, and I don't mean to
> imply anything different.  I use PCI as an example here because a) its
> the only working example of vhost today (to my knowledge), and b) you
> have stated in the past that PCI is the only "right" way here, to
> paraphrase.  Perhaps you no longer feel that way, so I apologize if you
> feel you already recanted your position on PCI and I missed it.
>    

For kvm/x86 pci definitely remains king.  I was talking about the two 
lguest users and Ira.

> I digress.  My point here isn't PCI.  The point here is the missing
> component for when PCI is not present.  The component that is partially
> satisfied by vbus's devid addressing scheme.  If you are going to use
> vhost, and you don't have PCI, you've gotta build something to replace it.
>    

Yes, that's why people have keyboards.  They'll write that glue code if 
they need it.  If it turns out to be a hit an people start having virtio 
transport module writing parties, they'll figure out a way to share code.

>>> All you really need is a simple decode+execute mechanism, and a way to
>>> program it from userspace control.  vbus tries to do just that:
>>> commoditize it so all you need is the transport of the control messages
>>> (like DEVCALL()), but the decode+execute itself is reuseable, even
>>> across various environments (like KVM or Iras rig).
>>>
>>>        
>> If you think it should be "commodotized", write libvhostconfig.so.
>>      
> I know you are probably being facetious here, but what do you propose
> for the parts that must be in-kernel?
>    

On the guest side, virtio-shmem.ko can unify the ring access.  It 
probably makes sense even today.  On the host side I eventfd is the 
kernel interface and libvhostconfig.so can provide the configuration 
when an existing ABI is not imposed.

>>> And your argument, I believe, is that vbus allows both to be implemented
>>> in the kernel (though to reiterate, its optional) and is therefore a bad
>>> design, so lets discuss that.
>>>
>>> I believe the assertion is that things like config-space are best left
>>> to userspace, and we should only relegate fast-path duties to the
>>> kernel.  The problem is that, in my experience, a good deal of
>>> config-space actually influences the fast-path and thus needs to
>>> interact with the fast-path mechanism eventually anyway.
>>> Whats left
>>> over that doesn't fall into this category may cheaply ride on existing
>>> plumbing, so its not like we created something new or unnatural just to
>>> support this subclass of config-space.
>>>
>>>        
>> Flexibility is reduced, because changing code in the kernel is more
>> expensive than in userspace, and kernel/user interfaces aren't typically
>> as wide as pure userspace interfaces.  Security is reduced, since a bug
>> in the kernel affects the host, while a bug in userspace affects just on
>> guest.
>>      
> For a mac-address attribute?  Thats all we are really talking about
> here.  These points you raise, while true of any kernel code I suppose,
> are a bit of a stretch in this context.
>    

Look at the virtio-net feature negotiation.  There's a lot more there 
than the MAC address, and it's going to grow.

>> Example: feature negotiation.  If it happens in userspace, it's easy to
>> limit what features we expose to the guest.
>>      
> Its not any harder in the kernel.  I do this today.
>
> And when you are done negotiating said features, you will generally have
> to turn around and program the feature into the backend anyway (e.g.
> ioctl() to vhost module).  Now you have to maintain some knowledge of
> that particular feature and how to program it in two places.
>    

No, you can leave it enabled unconditionally in vhost (the guest won't 
use what it doesn't know about).

> Conversely, I am eliminating the (unnecessary) middleman by letting the
> feature negotiating take place directly between the two entities that
> will consume it.
>    

The middleman is necessary, if you want to support live migration, or to 
restrict a guest to a subset of your features.

>>   If it happens in the
>> kernel, we need to add an interface to let the kernel know which
>> features it should expose to the guest.
>>      
> You need this already either way for both models anyway.  As an added
> bonus, vbus has generalized that interface using sysfs attributes, so
> all models are handled in a similar and community accepted way.
>    

vhost doesn't need it since userspace takes care of it.

>>   We also need to add an
>> interface to let userspace know which features were negotiated, if we
>> want to implement live migration.  Something fairly trivial bloats rapidly.
>>      
> Can you elaborate on the requirements for live-migration?  Wouldnt an
> opaque save/restore model work here? (e.g. why does userspace need to be
> able to interpret the in-kernel state, just pass it along as a blob to
> the new instance).
>    

A blob would work, if you commit to forward and backward compatibility 
in the kernel side (i.e. an older kernel must be able to accept a blob 
from a newer one).  I don't like blobs though, they tie you to the 
implemenetation.

>> As you can see above, userspace needs to be involved in this, and the
>> number of interfaces required is smaller if it's in userspace:
>>      
> Actually, no.  My experience has been the opposite.  Anytime I sat down
> and tried to satisfy your request to move things to the userspace,
> things got ugly and duplicative really quick.  I suspect part of the
> reason you may think its easier because you already have part of
> virtio-net in userspace and its surrounding support, but that is not the
> case moving forward for new device types.
>    

I can't comment on your experience, but we'll definitely build on 
existing code for new device types.

>> you only
>> need to know which features the kernel supports (they can be enabled
>> unconditionally, just not exposed).
>>
>> Further, some devices are perfectly happy to be implemented in
>> userspace, so we need userspace configuration support anyway.  Why
>> reimplement it in the kernel?
>>      
> Thats fine.  vbus is targetted for high-performance IO.  So if you have
> a robust userspace (like KVM+QEMU) and low-performance constraints (say,
> for a console or something), put it in userspace and vbus is not
> involved.  I don't care.
>    

So now the hypothetical non-pci hypervisor needs to support two busses.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

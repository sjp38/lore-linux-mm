Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E01A56B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 15:37:16 -0400 (EDT)
Message-ID: <4ABA78DC.7070604@redhat.com>
Date: Wed, 23 Sep 2009 22:37:00 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com>
In-Reply-To: <4ABA61D1.80703@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/23/2009 08:58 PM, Gregory Haskins wrote:
>>
>>> It also pulls parts of the device model into the host kernel.
>>>        
>> That is the point.  Most of it needs to be there for performance.
>>      
> To clarify this point:
>
> There are various aspects about designing high-performance virtual
> devices such as providing the shortest paths possible between the
> physical resources and the consumers.  Conversely, we also need to
> ensure that we meet proper isolation/protection guarantees at the same
> time.  What this means is there are various aspects to any
> high-performance PV design that require to be placed in-kernel to
> maximize the performance yet properly isolate the guest.
>
> For instance, you are required to have your signal-path (interrupts and
> hypercalls), your memory-path (gpa translation), and
> addressing/isolation model in-kernel to maximize performance.
>    

Exactly.  That's what vhost puts into the kernel and nothing more.

> Vbus accomplishes its in-kernel isolation model by providing a
> "container" concept, where objects are placed into this container by
> userspace.  The host kernel enforces isolation/protection by using a
> namespace to identify objects that is only relevant within a specific
> container's context (namely, a "u32 dev-id").  The guest addresses the
> objects by its dev-id, and the kernel ensures that the guest can't
> access objects outside of its dev-id namespace.
>    

vhost manages to accomplish this without any kernel support.  The guest 
simply has not access to any vhost resources other than the guest->host 
doorbell, which is handed to the guest outside vhost (so it's somebody 
else's problem, in userspace).

> All that is required is a way to transport a message with a "devid"
> attribute as an address (such as DEVCALL(devid)) and the framework
> provides the rest of the decode+execute function.
>    

vhost avoids that.

> Contrast this to vhost+virtio-pci (called simply "vhost" from here).
>    

It's the wrong name.  vhost implements only the data path.

> It is not immune to requiring in-kernel addressing support either, but
> rather it just does it differently (and its not as you might expect via
> qemu).
>
> Vhost relies on QEMU to render PCI objects to the guest, which the guest
> assigns resources (such as BARs, interrupts, etc).

vhost does not rely on qemu.  It relies on its user to handle 
configuration.  In one important case it's qemu+pci.  It could just as 
well be the lguest launcher.

>    A PCI-BAR in this
> example may represent a PIO address for triggering some operation in the
> device-model's fast-path.  For it to have meaning in the fast-path, KVM
> has to have in-kernel knowledge of what a PIO-exit is, and what to do
> with it (this is where pio-bus and ioeventfd come in).  The programming
> of the PIO-exit and the ioeventfd are likewise controlled by some
> userspace management entity (i.e. qemu).   The PIO address and value
> tuple form the address, and the ioeventfd framework within KVM provide
> the decode+execute function.
>    

Right.

> This idea seemingly works fine, mind you, but it rides on top of a *lot*
> of stuff including but not limited to: the guests pci stack, the qemu
> pci emulation, kvm pio support, and ioeventfd.  When you get into
> situations where you don't have PCI or even KVM underneath you (e.g. a
> userspace container, Ira's rig, etc) trying to recreate all of that PCI
> infrastructure for the sake of using PCI is, IMO, a lot of overhead for
> little gain.
>    

For the N+1th time, no.  vhost is perfectly usable without pci.  Can we 
stop raising and debunking this point?

> All you really need is a simple decode+execute mechanism, and a way to
> program it from userspace control.  vbus tries to do just that:
> commoditize it so all you need is the transport of the control messages
> (like DEVCALL()), but the decode+execute itself is reuseable, even
> across various environments (like KVM or Iras rig).
>    

If you think it should be "commodotized", write libvhostconfig.so.

> And your argument, I believe, is that vbus allows both to be implemented
> in the kernel (though to reiterate, its optional) and is therefore a bad
> design, so lets discuss that.
>
> I believe the assertion is that things like config-space are best left
> to userspace, and we should only relegate fast-path duties to the
> kernel.  The problem is that, in my experience, a good deal of
> config-space actually influences the fast-path and thus needs to
> interact with the fast-path mechanism eventually anyway.
> Whats left
> over that doesn't fall into this category may cheaply ride on existing
> plumbing, so its not like we created something new or unnatural just to
> support this subclass of config-space.
>    

Flexibility is reduced, because changing code in the kernel is more 
expensive than in userspace, and kernel/user interfaces aren't typically 
as wide as pure userspace interfaces.  Security is reduced, since a bug 
in the kernel affects the host, while a bug in userspace affects just on 
guest.

Example: feature negotiation.  If it happens in userspace, it's easy to 
limit what features we expose to the guest.  If it happens in the 
kernel, we need to add an interface to let the kernel know which 
features it should expose to the guest.  We also need to add an 
interface to let userspace know which features were negotiated, if we 
want to implement live migration.  Something fairly trivial bloats rapidly.

> For example: take an attribute like the mac-address assigned to a NIC.
> This clearly doesn't need to be in-kernel and could go either way (such
> as a PCI config-space register).
>
> As another example: consider an option bit that enables a new feature
> that affects the fast-path, like RXBUF merging.  If we use the split
> model where config space is handled by userspace and fast-path is
> in-kernel, the userspace component is only going to act as a proxy.
> I.e. it will pass the option down to the kernel eventually.  Therefore,
> there is little gain in trying to split this type of slow-path out to
> userspace.  In fact, its more work.
>    

As you can see above, userspace needs to be involved in this, and the 
number of interfaces required is smaller if it's in userspace: you only 
need to know which features the kernel supports (they can be enabled 
unconditionally, just not exposed).

Further, some devices are perfectly happy to be implemented in 
userspace, so we need userspace configuration support anyway.  Why 
reimplement it in the kernel?

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

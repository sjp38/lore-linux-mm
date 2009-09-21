Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E71916B004D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 17:43:11 -0400 (EDT)
Date: Mon, 21 Sep 2009 14:43:12 -0700
From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090921214312.GJ7182@ovro.caltech.edu>
References: <4AAFACB5.9050808@redhat.com>
 <4AAFF437.7060100@gmail.com>
 <4AB0A070.1050400@redhat.com>
 <4AB0CFA5.6040104@gmail.com>
 <4AB0E2A2.3080409@redhat.com>
 <4AB0F1EF.5050102@gmail.com>
 <4AB10B67.2050108@redhat.com>
 <4AB13B09.5040308@gmail.com>
 <4AB151D7.10402@redhat.com>
 <4AB1A8FD.2010805@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AB1A8FD.2010805@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 11:11:57PM -0400, Gregory Haskins wrote:
> Avi Kivity wrote:
> > On 09/16/2009 10:22 PM, Gregory Haskins wrote:
> >> Avi Kivity wrote:
> >>   
> >>> On 09/16/2009 05:10 PM, Gregory Haskins wrote:
> >>>     
> >>>>> If kvm can do it, others can.
> >>>>>
> >>>>>          
> >>>> The problem is that you seem to either hand-wave over details like
> >>>> this,
> >>>> or you give details that are pretty much exactly what vbus does
> >>>> already.
> >>>>    My point is that I've already sat down and thought about these
> >>>> issues
> >>>> and solved them in a freely available GPL'ed software package.
> >>>>
> >>>>        
> >>> In the kernel.  IMO that's the wrong place for it.
> >>>      
> >> 3) "in-kernel": You can do something like virtio-net to vhost to
> >> potentially meet some of the requirements, but not all.
> >>
> >> In order to fully meet (3), you would need to do some of that stuff you
> >> mentioned in the last reply with muxing device-nr/reg-nr.  In addition,
> >> we need to have a facility for mapping eventfds and establishing a
> >> signaling mechanism (like PIO+qid), etc. KVM does this with
> >> IRQFD/IOEVENTFD, but we dont have KVM in this case so it needs to be
> >> invented.
> >>    
> > 
> > irqfd/eventfd is the abstraction layer, it doesn't need to be reabstracted.
> 
> Not per se, but it needs to be interfaced.  How do I register that
> eventfd with the fastpath in Ira's rig? How do I signal the eventfd
> (x86->ppc, and ppc->x86)?
> 

Sorry to reply so late to this thread, I've been on vacation for the
past week. If you'd like to continue in another thread, please start it
and CC me.

On the PPC, I've got a hardware "doorbell" register which generates 30
distiguishable interrupts over the PCI bus. I have outbound and inbound
registers, which can be used to signal the "other side".

I assume it isn't too much code to signal an eventfd in an interrupt
handler. I haven't gotten to this point in the code yet.

> To take it to the next level, how do I organize that mechanism so that
> it works for more than one IO-stream (e.g. address the various queues
> within ethernet or a different device like the console)?  KVM has
> IOEVENTFD and IRQFD managed with MSI and PIO.  This new rig does not
> have the luxury of an established IO paradigm.
> 
> Is vbus the only way to implement a solution?  No.  But it is _a_ way,
> and its one that was specifically designed to solve this very problem
> (as well as others).
> 
> (As an aside, note that you generally will want an abstraction on top of
> irqfd/eventfd like shm-signal or virtqueues to do shared-memory based
> event mitigation, but I digress.  That is a separate topic).
> 
> > 
> >> To meet performance, this stuff has to be in kernel and there has to be
> >> a way to manage it.
> > 
> > and management belongs in userspace.
> 
> vbus does not dictate where the management must be.  Its an extensible
> framework, governed by what you plug into it (ala connectors and devices).
> 
> For instance, the vbus-kvm connector in alacrityvm chooses to put DEVADD
> and DEVDROP hotswap events into the interrupt stream, because they are
> simple and we already needed the interrupt stream anyway for fast-path.
> 
> As another example: venet chose to put ->call(MACQUERY) "config-space"
> into its call namespace because its simple, and we already need
> ->calls() for fastpath.  It therefore exports an attribute to sysfs that
> allows the management app to set it.
> 
> I could likewise have designed the connector or device-model differently
> as to keep the mac-address and hotswap-events somewhere else (QEMU/PCI
> userspace) but this seems silly to me when they are so trivial, so I didn't.
> 
> > 
> >> Since vbus was designed to do exactly that, this is
> >> what I would advocate.  You could also reinvent these concepts and put
> >> your own mux and mapping code in place, in addition to all the other
> >> stuff that vbus does.  But I am not clear why anyone would want to.
> >>    
> > 
> > Maybe they like their backward compatibility and Windows support.
> 
> This is really not relevant to this thread, since we are talking about
> Ira's hardware.  But if you must bring this up, then I will reiterate
> that you just design the connector to interface with QEMU+PCI and you
> have that too if that was important to you.
> 
> But on that topic: Since you could consider KVM a "motherboard
> manufacturer" of sorts (it just happens to be virtual hardware), I don't
> know why KVM seems to consider itself the only motherboard manufacturer
> in the world that has to make everything look legacy.  If a company like
> ASUS wants to add some cutting edge IO controller/bus, they simply do
> it.  Pretty much every product release may contain a different array of
> devices, many of which are not backwards compatible with any prior
> silicon.  The guy/gal installing Windows on that system may see a "?" in
> device-manager until they load a driver that supports the new chip, and
> subsequently it works.  It is certainly not a requirement to make said
> chip somehow work with existing drivers/facilities on bare metal, per
> se.  Why should virtual systems be different?
> 
> So, yeah, the current design of the vbus-kvm connector means I have to
> provide a driver.  This is understood, and I have no problem with that.
> 
> The only thing that I would agree has to be backwards compatible is the
> BIOS/boot function.  If you can't support running an image like the
> Windows installer, you are hosed.  If you can't use your ethernet until
> you get a chance to install a driver after the install completes, its
> just like most other systems in existence.  IOW: It's not a big deal.
> 
> For cases where the IO system is needed as part of the boot/install, you
> provide BIOS and/or an install-disk support for it.
> 
> > 
> >> So no, the kernel is not the wrong place for it.  Its the _only_ place
> >> for it.  Otherwise, just use (1) and be done with it.
> >>
> >>    
> > 
> > I'm talking about the config stuff, not the data path.
> 
> As stated above, where config stuff lives is a function of what you
> interface to vbus.  Data-path stuff must be in the kernel for
> performance reasons, and this is what I was referring to.  I think we
> are generally both in agreement, here.
> 
> What I was getting at is that you can't just hand-wave the datapath
> stuff.  We do fast path in KVM with IRQFD/IOEVENTFD+PIO, and we do
> device discovery/addressing with PCI.  Neither of those are available
> here in Ira's case yet the general concepts are needed.  Therefore, we
> have to come up with something else.
> 
> > 
> >>>   Further, if we adopt
> >>> vbus, if drop compatibility with existing guests or have to support both
> >>> vbus and virtio-pci.
> >>>      
> >> We already need to support both (at least to support Ira).  virtio-pci
> >> doesn't work here.  Something else (vbus, or vbus-like) is needed.
> >>    
> > 
> > virtio-ira.
> 
> Sure, virtio-ira and he is on his own to make a bus-model under that, or
> virtio-vbus + vbus-ira-connector to use the vbus framework.  Either
> model can work, I agree.
> 

Yes, I'm having to create my own bus model, a-la lguest, virtio-pci, and
virtio-s390. It isn't especially easy. I can steal lots of code from the
lguest bus model, but sometimes it is good to generalize, especially
after the fourth implemention or so. I think this is what GHaskins tried
to do.


Here is what I've implemented so far:

* a generic virtio-phys-guest layer (my bus model, like lguest)
	- this runs on the crate server (x86) in my system
* a generic virtio-phys-host layer (my /dev/lguest implementation)
	- this runs on the ppc boards in my system
	- this assumes that the kernel will allocate some memory and
	  expose it over PCI in a device-specific way, so the guest can
	  see it as a PCI BAR
* a virtio-phys-mpc83xx driver
	- this runs on the crate server (x86) in my system
	- this interfaces virtio-phys-guest to my mpc83xx board
	- it is a Linux PCI driver, which detects mpc83xx boards, runs
	  ioremap_pci_bar() on the correct PCI BAR, and then gives that
	  to the virtio-phys-guest layer

I think that the idea of device/driver (instead of host/guest) is a good
one. It makes my problem easier to think about.

I've given it some thought, and I think that running vhost-net (or
similar) on the ppc boards, with virtio-net on the x86 crate server will
work. The virtio-ring abstraction is almost good enough to work for this
situation, but I had to re-invent it to work with my boards.

I've exposed a 16K region of memory as PCI BAR1 from my ppc board.
Remember that this is the "host" system. I used each 4K block as a
"device descriptor" which contains:

1) the type of device, config space, etc. for virtio
2) the "desc" table (virtio memory descriptors, see virtio-ring)
3) the "avail" table (available entries in the desc table)

Parts 2 and 3 are repeated three times, to allow for a maximum of three
virtqueues per device. This is good enough for all current drivers.

The guest side (x86 in my system) allocates some device-accessible
memory, and writes the PCI address to the device descriptor. This memory
contains:

1) the "used" table (consumed entries in the desc/avail tables)

This exists three times as well, once for each virtqueue.

The rest is basically a copy of virtio-ring, with a few changes to allow
for cacheing, etc. It may not even be worth doing this from a
performance standpoint, I haven't benchmarked it yet.

For now, I'd be happy with a non-DMA memcpy only solution. I can add DMA
once things are working.

I've got the current code (subject to change at any time) available at
the address listed below. If you think another format would be better
for you, please ask, and I'll provide it.
http://www.mmarray.org/~iws/virtio-phys/

I've gotten plenty of email about this from lots of interested
developers. There are people who would like this kind of system to just
work, while having to write just some glue for their device, just like a
network driver. I hunch most people have created some proprietary mess
that basically works, and left it at that.

So, here is a desperate cry for help. I'd like to make this work, and
I'd really like to see it in mainline. I'm trying to give back to the
community from which I've taken plenty.

Ira

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

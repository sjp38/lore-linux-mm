Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 656506B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 03:50:02 -0400 (EDT)
Message-ID: <4AB1EA25.9020001@redhat.com>
Date: Thu, 17 Sep 2009 10:49:57 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com>
In-Reply-To: <4AB1A8FD.2010805@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/17/2009 06:11 AM, Gregory Haskins wrote:
>
>> irqfd/eventfd is the abstraction layer, it doesn't need to be reabstracted.
>>      
> Not per se, but it needs to be interfaced.  How do I register that
> eventfd with the fastpath in Ira's rig? How do I signal the eventfd
> (x86->ppc, and ppc->x86)?
>    

You write a userspace or kernel module to do it.  It's a few dozen lines 
of code.

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

virtio assumes that the number of transports will be limited and 
interesting growth is in the number of device classes and drivers.  So 
we have support for just three transports, but 6 device classes (9p, 
rng, balloon, console, blk, net) and 8 drivers (the preceding 6 for 
linux, plus blk/net for Windows).  It would have nice to be able to 
write a new binding in Visual Basic but it's hardly a killer feature.


>>> Since vbus was designed to do exactly that, this is
>>> what I would advocate.  You could also reinvent these concepts and put
>>> your own mux and mapping code in place, in addition to all the other
>>> stuff that vbus does.  But I am not clear why anyone would want to.
>>>
>>>        
>> Maybe they like their backward compatibility and Windows support.
>>      
> This is really not relevant to this thread, since we are talking about
> Ira's hardware.  But if you must bring this up, then I will reiterate
> that you just design the connector to interface with QEMU+PCI and you
> have that too if that was important to you.
>    

Well, for Ira the major issue is probably inclusion in the upstream kernel.

> But on that topic: Since you could consider KVM a "motherboard
> manufacturer" of sorts (it just happens to be virtual hardware), I don't
> know why KVM seems to consider itself the only motherboard manufacturer
> in the world that has to make everything look legacy.  If a company like
> ASUS wants to add some cutting edge IO controller/bus, they simply do
> it.

No, they don't.  New buses are added through industry consortiums these 
days.  No one adds a bus that is only available with their machine, not 
even Apple.

> Pretty much every product release may contain a different array of
> devices, many of which are not backwards compatible with any prior
> silicon.  The guy/gal installing Windows on that system may see a "?" in
> device-manager until they load a driver that supports the new chip, and
> subsequently it works.  It is certainly not a requirement to make said
> chip somehow work with existing drivers/facilities on bare metal, per
> se.  Why should virtual systems be different?
>    

Devices/drivers are a different matter, and if you have a virtio-net 
device you'll get the same "?" until you load the driver.  That's how 
people and the OS vendors expect things to work.

> What I was getting at is that you can't just hand-wave the datapath
> stuff.  We do fast path in KVM with IRQFD/IOEVENTFD+PIO, and we do
> device discovery/addressing with PCI.

That's not datapath stuff.

> Neither of those are available
> here in Ira's case yet the general concepts are needed.  Therefore, we
> have to come up with something else.
>    

Ira has to implement virtio's ->kick() function and come up with 
something for discovery.  It's a lot less lines of code than there are 
messages in this thread.

>> Yes.  I'm all for reusing virtio, but I'm not going switch to vbus or
>> support both for this esoteric use case.
>>      
> With all due respect, no one asked you to.  This sub-thread was
> originally about using vhost in Ira's rig.  When problems surfaced in
> that proposed model, I highlighted that I had already addressed that
> problem in vbus, and here we are.
>    

Ah, okay.  I have no interest in Ira choosing either virtio or vbus.



>> vhost-net somehow manages to work without the config stuff in the kernel.
>>      
> I was referring to data-path stuff, like signal and memory
> configuration/routing.
>    

signal and memory configuration/routing are not data-path stuff.

>> Well, virtio has a similar abstraction on the guest side.  The host side
>> abstraction is limited to signalling since all configuration is in
>> userspace.  vhost-net ought to work for lguest and s390 without change.
>>      
> But IIUC that is primarily because the revectoring work is already in
> QEMU for virtio-u and it rides on that, right?  Not knocking that, thats
> nice and a distinct advantage.  It should just be noted that its based
> on sunk-cost, and not truly free.  Its just already paid for, which is
> different.  It also means it only works in environments based on QEMU,
> which not all are (as evident by this sub-thread).
>    

No.  We expose a mix of emulated-in-userspace and emulated-in-the-kernel 
devices on one bus.  Devices emulated in userspace only lose by having 
the bus emulated in the kernel.  Devices in the kernel gain nothing from 
having the bus emulated in the kernel.  It's a complete slow path so it 
belongs in userspace where state is easy to get at, development is 
faster, and bugs are cheaper to fix.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

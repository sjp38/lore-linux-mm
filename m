Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CF0626B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 09:05:56 -0400 (EDT)
Message-ID: <4AB0E2A2.3080409@redhat.com>
Date: Wed, 16 Sep 2009 16:05:38 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com>
In-Reply-To: <4AB0CFA5.6040104@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/16/2009 02:44 PM, Gregory Haskins wrote:
> The problem isn't where to find the models...the problem is how to
> aggregate multiple models to the guest.
>    

You mean configuration?

>> You instantiate multiple vhost-nets.  Multiple ethernet NICs is a
>> supported configuration for kvm.
>>      
> But this is not KVM.
>
>    

If kvm can do it, others can.

>>> His slave boards surface themselves as PCI devices to the x86
>>> host.  So how do you use that to make multiple vhost-based devices (say
>>> two virtio-nets, and a virtio-console) communicate across the transport?
>>>
>>>        
>> I don't really see the difference between 1 and N here.
>>      
> A KVM surfaces N virtio-devices as N pci-devices to the guest.  What do
> we do in Ira's case where the entire guest represents itself as a PCI
> device to the host, and nothing the other way around?
>    

There is no guest and host in this scenario.  There's a device side 
(ppc) and a driver side (x86).  The driver side can access configuration 
information on the device side.  How to multiplex multiple devices is an 
interesting exercise for whoever writes the virtio binding for that setup.

>>> There are multiple ways to do this, but what I am saying is that
>>> whatever is conceived will start to look eerily like a vbus-connector,
>>> since this is one of its primary purposes ;)
>>>
>>>        
>> I'm not sure if you're talking about the configuration interface or data
>> path here.
>>      
> I am talking about how we would tunnel the config space for N devices
> across his transport.
>    

Sounds trivial.  Write an address containing the device number and 
register number to on location, read or write data from another.  Just 
like the PCI cf8/cfc interface.

>> They aren't in the "guest".  The best way to look at it is
>>
>> - a device side, with a dma engine: vhost-net
>> - a driver side, only accessing its own memory: virtio-net
>>
>> Given that Ira's config has the dma engine in the ppc boards, that's
>> where vhost-net would live (the ppc boards acting as NICs to the x86
>> board, essentially).
>>      
> That sounds convenient given his hardware, but it has its own set of
> problems.  For one, the configuration/inventory of these boards is now
> driven by the wrong side and has to be addressed.

Why is it the wrong side?

> Second, the role
> reversal will likely not work for many models other than ethernet (e.g.
> virtio-console or virtio-blk drivers running on the x86 board would be
> naturally consuming services from the slave boards...virtio-net is an
> exception because 802.x is generally symmetrical).
>    

There is no role reversal.  The side doing dma is the device, the side 
accessing its own memory is the driver.  Just like that other 1e12 
driver/device pairs out there.

>> I have no idea, that's for Ira to solve.
>>      
> Bingo.  Thus my statement that the vhost proposal is incomplete.  You
> have the virtio-net and vhost-net pieces covering the fast-path
> end-points, but nothing in the middle (transport, aggregation,
> config-space), and nothing on the management-side.  vbus provides most
> of the other pieces, and can even support the same virtio-net protocol
> on top.  The remaining part would be something like a udev script to
> populate the vbus with devices on board-insert events.
>    

Of course vhost is incomplete, in the same sense that Linux is 
incomplete.  Both require userspace.

>> If he could fake the PCI
>> config space as seen by the x86 board, he would just show the normal pci
>> config and use virtio-pci (multiple channels would show up as a
>> multifunction device).  Given he can't, he needs to tunnel the virtio
>> config space some other way.
>>      
> Right, and note that vbus was designed to solve this.  This tunneling
> can, of course, be done without vbus using some other design.  However,
> whatever solution is created will look incredibly close to what I've
> already done, so my point is "why reinvent it"?
>    

virtio requires binding for this tunnelling, so does vbus.  Its the same 
problem with the same solution.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

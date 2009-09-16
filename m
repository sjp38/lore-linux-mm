Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D99EF6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:59:57 -0400 (EDT)
Message-ID: <4AB10B67.2050108@redhat.com>
Date: Wed, 16 Sep 2009 18:59:35 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com>
In-Reply-To: <4AB0F1EF.5050102@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/16/2009 05:10 PM, Gregory Haskins wrote:
>
>> If kvm can do it, others can.
>>      
> The problem is that you seem to either hand-wave over details like this,
> or you give details that are pretty much exactly what vbus does already.
>   My point is that I've already sat down and thought about these issues
> and solved them in a freely available GPL'ed software package.
>    

In the kernel.  IMO that's the wrong place for it.  Further, if we adopt 
vbus, if drop compatibility with existing guests or have to support both 
vbus and virtio-pci.

> So the question is: is your position that vbus is all wrong and you wish
> to create a new bus-like thing to solve the problem?

I don't intend to create anything new, I am satisfied with virtio.  If 
it works for Ira, excellent.  If not, too bad.  I believe it will work 
without too much trouble.

> If so, how is it
> different from what Ive already done?  More importantly, what specific
> objections do you have to what Ive done, as perhaps they can be fixed
> instead of starting over?
>    

The two biggest objections are:
- the host side is in the kernel
- the guest side is a new bus instead of reusing pci (on x86/kvm), 
making Windows support more difficult

I guess these two are exactly what you think are vbus' greatest 
advantages, so we'll probably have to extend our agree-to-disagree on 
this one.

I also had issues with using just one interrupt vector to service all 
events, but that's easily fixed.

>> There is no guest and host in this scenario.  There's a device side
>> (ppc) and a driver side (x86).  The driver side can access configuration
>> information on the device side.  How to multiplex multiple devices is an
>> interesting exercise for whoever writes the virtio binding for that setup.
>>      
> Bingo.  So now its a question of do you want to write this layer from
> scratch, or re-use my framework.
>    

You will have to implement a connector or whatever for vbus as well.  
vbus has more layers so it's probably smaller for vbus.

>>>>
>>>>          
>>> I am talking about how we would tunnel the config space for N devices
>>> across his transport.
>>>
>>>        
>> Sounds trivial.
>>      
> No one said it was rocket science.  But it does need to be designed and
> implemented end-to-end, much of which Ive already done in what I hope is
> an extensible way.
>    

It was already implemented three times for virtio, so apparently that's 
extensible too.

>>   Write an address containing the device number and
>> register number to on location, read or write data from another.
>>      
> You mean like the "u64 devh", and "u32 func" fields I have here for the
> vbus-kvm connector?
>
> http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=blob;f=include/linux/vbus_pci.h;h=fe337590e644017392e4c9d9236150adb2333729;hb=ded8ce2005a85c174ba93ee26f8d67049ef11025#l64
>
>    

Probably.



>>> That sounds convenient given his hardware, but it has its own set of
>>> problems.  For one, the configuration/inventory of these boards is now
>>> driven by the wrong side and has to be addressed.
>>>        
>> Why is it the wrong side?
>>      
> "Wrong" is probably too harsh a word when looking at ethernet.  Its
> certainly "odd", and possibly inconvenient.  It would be like having
> vhost in a KVM guest, and virtio-net running on the host.  You could do
> it, but its weird and awkward.  Where it really falls apart and enters
> the "wrong" category is for non-symmetric devices, like disk-io.
>
>    


It's not odd or wrong or wierd or awkward.  An ethernet NIC is not 
symmetric, one side does DMA and issues interrupts, the other uses its 
own memory.  That's exactly the case with Ira's setup.

If the ppc boards were to emulate a disk controller, you'd run 
virtio-blk on x86 and vhost-blk on the ppc boards.

>>> Second, the role
>>> reversal will likely not work for many models other than ethernet (e.g.
>>> virtio-console or virtio-blk drivers running on the x86 board would be
>>> naturally consuming services from the slave boards...virtio-net is an
>>> exception because 802.x is generally symmetrical).
>>>
>>>        
>> There is no role reversal.
>>      
> So if I have virtio-blk driver running on the x86 and vhost-blk device
> running on the ppc board, I can use the ppc board as a block-device.
> What if I really wanted to go the other way?
>    

You mean, if the x86 board was able to access the disks and dma into the 
ppb boards memory?  You'd run vhost-blk on x86 and virtio-net on ppc.

As long as you don't use the words "guest" and "host" but keep to 
"driver" and "device", it all works out.

>> The side doing dma is the device, the side
>> accessing its own memory is the driver.  Just like that other 1e12
>> driver/device pairs out there.
>>      
> IIUC, his ppc boards really can be seen as "guests" (they are linux
> instances that are utilizing services from the x86, not the other way
> around).

They aren't guests.  Guests don't dma into their host's memory.

> vhost forces the model to have the ppc boards act as IO-hosts,
> whereas vbus would likely work in either direction due to its more
> refined abstraction layer.
>    

vhost=device=dma, virtio=driver=own-memory.

>> Of course vhost is incomplete, in the same sense that Linux is
>> incomplete.  Both require userspace.
>>      
> A vhost based solution to Iras design is missing more than userspace.
> Many of those gaps are addressed by a vbus based solution.
>    

Maybe.  Ira can fill the gaps or use vbus.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

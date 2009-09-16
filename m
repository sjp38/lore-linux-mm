Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 46A606B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 04:23:17 -0400 (EDT)
Message-ID: <4AB0A070.1050400@redhat.com>
Date: Wed, 16 Sep 2009 11:23:12 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com>
In-Reply-To: <4AAFF437.7060100@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/15/2009 11:08 PM, Gregory Haskins wrote:
>
>> There's virtio-console, virtio-blk etc.  None of these have kernel-mode
>> servers, but these could be implemented if/when needed.
>>      
> IIUC, Ira already needs at least ethernet and console capability.
>
>    

He's welcome to pick up the necessary code from qemu.

>>> b) what do you suppose this protocol to aggregate the connections would
>>> look like? (hint: this is what a vbus-connector does).
>>>
>>>        
>> You mean multilink?  You expose the device as a multiqueue.
>>      
> No, what I mean is how do you surface multiple ethernet and consoles to
> the guests?  For Ira's case, I think he needs at minimum at least one of
> each, and he mentioned possibly having two unique ethernets at one point.
>    

You instantiate multiple vhost-nets.  Multiple ethernet NICs is a 
supported configuration for kvm.

> His slave boards surface themselves as PCI devices to the x86
> host.  So how do you use that to make multiple vhost-based devices (say
> two virtio-nets, and a virtio-console) communicate across the transport?
>    

I don't really see the difference between 1 and N here.

> There are multiple ways to do this, but what I am saying is that
> whatever is conceived will start to look eerily like a vbus-connector,
> since this is one of its primary purposes ;)
>    

I'm not sure if you're talking about the configuration interface or data 
path here.

>>> c) how do you manage the configuration, especially on a per-board basis?
>>>
>>>        
>> pci (for kvm/x86).
>>      
> Ok, for kvm understood (and I would also add "qemu" to that mix).  But
> we are talking about vhost's application in a non-kvm environment here,
> right?.
>
> So if the vhost-X devices are in the "guest",

They aren't in the "guest".  The best way to look at it is

- a device side, with a dma engine: vhost-net
- a driver side, only accessing its own memory: virtio-net

Given that Ira's config has the dma engine in the ppc boards, that's 
where vhost-net would live (the ppc boards acting as NICs to the x86 
board, essentially).

> and the x86 board is just
> a slave...How do you tell each ppc board how many devices and what
> config (e.g. MACs, etc) to instantiate?  Do you assume that they should
> all be symmetric and based on positional (e.g. slot) data?  What if you
> want asymmetric configurations (if not here, perhaps in a different
> environment)?
>    

I have no idea, that's for Ira to solve.  If he could fake the PCI 
config space as seen by the x86 board, he would just show the normal pci 
config and use virtio-pci (multiple channels would show up as a 
multifunction device).  Given he can't, he needs to tunnel the virtio 
config space some other way.

>> Yes.  virtio is really virtualization oriented.
>>      
> I would say that its vhost in particular that is virtualization
> oriented.  virtio, as a concept, generally should work in physical
> systems, if perhaps with some minor modifications.  The biggest "limit"
> is having "virt" in its name ;)
>    

Let me rephrase.  The virtio developers are virtualization oriented.  If 
it works for non-virt applications, that's good, but not a design goal.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

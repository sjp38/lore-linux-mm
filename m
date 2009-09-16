Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C9A556B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 17:01:41 -0400 (EDT)
Message-ID: <4AB151D7.10402@redhat.com>
Date: Thu, 17 Sep 2009 00:00:07 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com>
In-Reply-To: <4AB13B09.5040308@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/16/2009 10:22 PM, Gregory Haskins wrote:
> Avi Kivity wrote:
>    
>> On 09/16/2009 05:10 PM, Gregory Haskins wrote:
>>      
>>>> If kvm can do it, others can.
>>>>
>>>>          
>>> The problem is that you seem to either hand-wave over details like this,
>>> or you give details that are pretty much exactly what vbus does already.
>>>    My point is that I've already sat down and thought about these issues
>>> and solved them in a freely available GPL'ed software package.
>>>
>>>        
>> In the kernel.  IMO that's the wrong place for it.
>>      
> 3) "in-kernel": You can do something like virtio-net to vhost to
> potentially meet some of the requirements, but not all.
>
> In order to fully meet (3), you would need to do some of that stuff you
> mentioned in the last reply with muxing device-nr/reg-nr.  In addition,
> we need to have a facility for mapping eventfds and establishing a
> signaling mechanism (like PIO+qid), etc. KVM does this with
> IRQFD/IOEVENTFD, but we dont have KVM in this case so it needs to be
> invented.
>    

irqfd/eventfd is the abstraction layer, it doesn't need to be reabstracted.

> To meet performance, this stuff has to be in kernel and there has to be
> a way to manage it.

and management belongs in userspace.

> Since vbus was designed to do exactly that, this is
> what I would advocate.  You could also reinvent these concepts and put
> your own mux and mapping code in place, in addition to all the other
> stuff that vbus does.  But I am not clear why anyone would want to.
>    

Maybe they like their backward compatibility and Windows support.

> So no, the kernel is not the wrong place for it.  Its the _only_ place
> for it.  Otherwise, just use (1) and be done with it.
>
>    

I'm talking about the config stuff, not the data path.

>>   Further, if we adopt
>> vbus, if drop compatibility with existing guests or have to support both
>> vbus and virtio-pci.
>>      
> We already need to support both (at least to support Ira).  virtio-pci
> doesn't work here.  Something else (vbus, or vbus-like) is needed.
>    

virtio-ira.

>>> So the question is: is your position that vbus is all wrong and you wish
>>> to create a new bus-like thing to solve the problem?
>>>        
>> I don't intend to create anything new, I am satisfied with virtio.  If
>> it works for Ira, excellent.  If not, too bad.
>>      
> I think that about sums it up, then.
>    

Yes.  I'm all for reusing virtio, but I'm not going switch to vbus or 
support both for this esoteric use case.

>>> If so, how is it
>>> different from what Ive already done?  More importantly, what specific
>>> objections do you have to what Ive done, as perhaps they can be fixed
>>> instead of starting over?
>>>
>>>        
>> The two biggest objections are:
>> - the host side is in the kernel
>>      
> As it needs to be.
>    

vhost-net somehow manages to work without the config stuff in the kernel.

> With all due respect, based on all of your comments in aggregate I
> really do not think you are truly grasping what I am actually building here.
>    

Thanks.



>>> Bingo.  So now its a question of do you want to write this layer from
>>> scratch, or re-use my framework.
>>>
>>>        
>> You will have to implement a connector or whatever for vbus as well.
>> vbus has more layers so it's probably smaller for vbus.
>>      
> Bingo!

(addictive, isn't it)

> That is precisely the point.
>
> All the stuff for how to map eventfds, handle signal mitigation, demux
> device/function pointers, isolation, etc, are built in.  All the
> connector has to do is transport the 4-6 verbs and provide a memory
> mapping/copy function, and the rest is reusable.  The device models
> would then work in all environments unmodified, and likewise the
> connectors could use all device-models unmodified.
>    

Well, virtio has a similar abstraction on the guest side.  The host side 
abstraction is limited to signalling since all configuration is in 
userspace.  vhost-net ought to work for lguest and s390 without change.

>> It was already implemented three times for virtio, so apparently that's
>> extensible too.
>>      
> And to my point, I'm trying to commoditize as much of that process as
> possible on both the front and backends (at least for cases where
> performance matters) so that you don't need to reinvent the wheel for
> each one.
>    

Since you're interested in any-to-any connectors it makes sense to you.  
I'm only interested in kvm-host-to-kvm-guest, so reducing the already 
minor effort to implement a new virtio binding has little appeal to me.

>> You mean, if the x86 board was able to access the disks and dma into the
>> ppb boards memory?  You'd run vhost-blk on x86 and virtio-net on ppc.
>>      
> But as we discussed, vhost doesn't work well if you try to run it on the
> x86 side due to its assumptions about pagable "guest" memory, right?  So
> is that even an option?  And even still, you would still need to solve
> the aggregation problem so that multiple devices can coexist.
>    

I don't know.  Maybe it can be made to work and maybe it cannot.  It 
probably can with some determined hacking.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

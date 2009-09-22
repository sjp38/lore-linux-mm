Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C04B56B00BC
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:56:55 -0400 (EDT)
Message-ID: <4AB8F3C0.7090203@redhat.com>
Date: Tue, 22 Sep 2009 18:56:48 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <20090922152520.GA9154@ovro.caltech.edu>
In-Reply-To: <20090922152520.GA9154@ovro.caltech.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/22/2009 06:25 PM, Ira W. Snyder wrote:
>
>> Yes.  vbus is more finely layered so there is less code duplication.
>>
>> The virtio layering was more or less dictated by Xen which doesn't have
>> shared memory (it uses grant references instead).  As a matter of fact
>> lguest, kvm/pci, and kvm/s390 all have shared memory, as you do, so that
>> part is duplicated.  It's probably possible to add a virtio-shmem.ko
>> library that people who do have shared memory can reuse.
>>
>>      
> Seems like a nice benefit of vbus.
>    

Yes, it is.  With some work virtio can gain that too (virtio-shmem.ko).

>>> I've given it some thought, and I think that running vhost-net (or
>>> similar) on the ppc boards, with virtio-net on the x86 crate server will
>>> work. The virtio-ring abstraction is almost good enough to work for this
>>> situation, but I had to re-invent it to work with my boards.
>>>
>>> I've exposed a 16K region of memory as PCI BAR1 from my ppc board.
>>> Remember that this is the "host" system. I used each 4K block as a
>>> "device descriptor" which contains:
>>>
>>> 1) the type of device, config space, etc. for virtio
>>> 2) the "desc" table (virtio memory descriptors, see virtio-ring)
>>> 3) the "avail" table (available entries in the desc table)
>>>
>>>        
>> Won't access from x86 be slow to this memory (on the other hand, if you
>> change it to main memory access from ppc will be slow... really depends
>> on how your system is tuned.
>>
>>      
> Writes across the bus are fast, reads across the bus are slow. These are
> just the descriptor tables for memory buffers, not the physical memory
> buffers themselves.
>
> These only need to be written by the guest (x86), and read by the host
> (ppc). The host never changes the tables, so we can cache a copy in the
> guest, for a fast detach_buf() implementation (see virtio-ring, which
> I'm copying the design from).
>
> The only accesses are writes across the PCI bus. There is never a need
> to do a read (except for slow-path configuration).
>    

Okay, sounds like what you're doing it optimal then.

> In the spirit of "post early and often", I'm making my code available,
> that's all. I'm asking anyone interested for some review, before I have
> to re-code this for about the fifth time now. I'm trying to avoid
> Haskins' situation, where he's invented and debugged a lot of new code,
> and then been told to do it completely differently.
>
> Yes, the code I posted is only compile-tested, because quite a lot of
> code (kernel and userspace) must be working before anything works at
> all. I hate to design the whole thing, then be told that something
> fundamental about it is wrong, and have to completely re-write it.
>    

Understood.  Best to get a review from Rusty then.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

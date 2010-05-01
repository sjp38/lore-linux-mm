Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CE8696B0224
	for <linux-mm@kvack.org>; Sat,  1 May 2010 04:29:03 -0400 (EDT)
Message-ID: <4BDBE643.6020302@redhat.com>
Date: Sat, 01 May 2010 11:28:51 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>> <4BD1A74A.2050003@redhat.com>> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>> <4BD3377E.6010303@redhat.com>> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>> <ce808441-fae6-4a33-8335-f7702740097a@default>> <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz 4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default> <4BDB026E.1030605@redhat.com> <4BDB18CE.2090608@goop.org> <4BDB2069.4000507@redhat.com> <4BDB2883.8070606@goop.org>
In-Reply-To: <4BDB2883.8070606@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/30/2010 09:59 PM, Jeremy Fitzhardinge wrote:
> On 04/30/2010 11:24 AM, Avi Kivity wrote:
>    
>>> I'd argue the opposite.  There's no point in having the host do swapping
>>> on behalf of guests if guests can do it themselves; it's just a
>>> duplication of functionality.
>>>        
>>
>> The problem with relying on the guest to swap is that it's voluntary.
>> The guest may not be able to do it.  When the hypervisor needs memory
>> and guests don't cooperate, it has to swap.
>>      
> Or fail whatever operation its trying to do.  You can only use
> overcommit to fake unlimited resources for so long before you need a
> government bailout.
>    

Keep your commitment below RAM+swap and you'll be fine.  We want to 
overcommit RAM, not total storage.

>>> You end up having two IO paths for each
>>> guest, and the resulting problems in trying to account for the IO,
>>> rate-limit it, etc.  If you can simply say "all guest disk IO happens
>>> via this single interface", its much easier to manage.
>>>
>>>        
>> With tmem you have to account for that memory, make sure it's
>> distributed fairly, claim it back when you need it (requiring guest
>> cooperation), live migrate and save/restore it.  It's a much larger
>> change than introducing a write-back device for swapping (which has
>> the benefit of working with unmodified guests).
>>      
> Well, with caveats.  To be useful with migration the backing store needs
> to be shared like other storage, so you can't use a specific host-local
> fast (ssd) swap device.

Live migration of local storage is possible (qemu does it).

> And because the device is backed by pagecache
> with delayed writes, it has much weaker integrity guarantees than a
> normal device, so you need to be sure that the guests are only going to
> use it for swap.  Sure, these are deployment issues rather than code
> ones, but they're still issues.
>    

You advertise it as a disk with write cache, so the guest is obliged to 
flush the cache if it wants a guarantee.  When it does, you flush your 
cache as well.  For swap, the guest will not issue any flushes.  This is 
already supported by qemu with cache=writeback.

I agree care is needed here.  You don't want to use the device for 
anything else.

>>> If frontswap has value, it's because its providing a new facility to
>>> guests that doesn't already exist and can't be easily emulated with
>>> existing interfaces.
>>>
>>> It seems to me the great strengths of the synchronous interface are:
>>>
>>>       * it matches the needs of an existing implementation (tmem in Xen)
>>>       * it is simple to understand within the context of the kernel code
>>>         it's used in
>>>
>>> Simplicity is important, because it allows the mm code to be understood
>>> and maintained without having to have a deep understanding of
>>> virtualization.
>>>        
>> If we use the existing paths, things are even simpler, and we match
>> more needs (hypervisors with dma engines, the ability to reclaim
>> memory without guest cooperation).
>>      
> Well, you still can't reclaim memory; you can write it out to storage.
> It may be cheaper/byte, but it's still a resource dedicated to the
> guest.  But that's just a consequence of allowing overcommit, and to
> what extent you're happy to allow it.
>    

In general you want to run on RAM.  To maximise your RAM, you do things 
like page sharing and ballooning.  Both can fail, increasing the demand 
for RAM.  At that time you either kill a guest or swap to disk.

Consider a frontswap/tmem on bare-metal hypervisor cluster.  Presumably 
you give most of your free memory to guests.  A node dies.  Now you need 
to start its guests on the surviving nodes, but you're at the mercy of 
your guests to give up their tmem.

With an ordinary swap approach, you first flush cache to disk, and if 
that's not sufficient you start paging out guest memory.  You take a 
performance hit but you keep your guests running.

> What kind of DMA engine do you have in mind?  Are there practical
> memory->memory DMA engines that would be useful in this context?
>    

I/OAT (driver ioatdma).

When you don't have a  lot of memory free, you can also switch from 
write cache to O_DIRECT, so you use the storage controller's dma engine 
to transfer pages to disk.

>>> Yes, that's comfortably within the "guests page themselves" model.
>>> Setting up a block device for the domain which is backed by pagecache
>>> (something we usually try hard to avoid) is pretty straightforward.  But
>>> it doesn't work well for Xen unless the blkback domain is sized so that
>>> it has all of Xen's free memory in its pagecache.
>>>
>>>        
>> Could be easily achieved with ballooning?
>>      
> It could be achieved with ballooning, but it isn't completely trivial.
> It wouldn't work terribly well with a driver domain setup, unless all
> the swap-devices turned out to be backed by the same domain (which in
> turn would need to know how to balloon in response to overall system
> demand).  The partitioning of the pagecache among the guests would be at
> the mercy of the mm subsystem rather than subject to any specific QoS or
> other per-domain policies you might want to put in place (maybe fiddling
> around with [fm]advise could get you some control over that).
>    

See Documentation/cgroups/memory.txt.

>>> That said, it does concern me that the host/hypervisor is left holding
>>> the bag on frontswapped pages.  A evil/uncooperative/lazy can just pump
>>> a whole lot of pages into the frontswap pool and leave them there.   I
>>> guess this is mitigated by the fact that the API is designed such that
>>> they can't update or read the data without also allowing the hypervisor
>>> to drop the page (updates can fail destructively, and reads are also
>>> destructive), so the guest can't use it as a clumsy extension of their
>>> normal dedicated memory.
>>>
>>>        
>> Eventually you'll have to swap frontswap pages, or kill uncooperative
>> guests.  At which point all of the simplicity is gone.
>>      
> Killing guests is pretty simple.

Migrating to a hypervisor that doesn't kill guests isn't.

> Presumably the oom killer will get kvm
> processes like anything else?
>    

Yes.  Of course, you want your management code never to allow this to 
happen.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

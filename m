Message-ID: <46933BD7.2020200@yahoo.com.au>
Date: Tue, 10 Jul 2007 17:57:11 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: zone movable patches comments
References: <4691E8D1.4030507@yahoo.com.au> <20070709110457.GB9305@skynet.ie> <469226CB.4010900@yahoo.com.au> <20070709132140.GC9305@skynet.ie>
In-Reply-To: <20070709132140.GC9305@skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On (09/07/07 22:15), Nick Piggin didst pronounce:
> 
>>Mel Gorman wrote:

>>kernelcore= has some fairly strong connotations outside the movable
>>zone functionality, however.
>>
>>If you have a 16GB highmem machine, and you want 8GB of movable zone,
>>do you say kernelcore=8GB?
> 
> 
> Yes but depending the topology of memory, the kernelcore portion may not
> be sized exactly as you request. For example, if you have many nodes of
> different sizes, kernelcore may not spread evently. Secondly, the movable
> zone can only use pages from the highest active zone.  To illustrate the
> "highest" zone problem - lets say I have a 2GB 32 bit x86 machine and I
> specify kernelcore=512MB, I'll really get a kernelcore of 896MB because
> ZONE_MOVABLE can only use HIGHMEM pages in this case.

kernelcore suggests some fundamental VM tunable, rather than just
a random shot in the dark that roughly relates to the amount of
memory you want to reserve for your movable zone.


>>Does that give you the other 8GB in kernel
>>addressable memory? :) What if some other functionality is introduced
>>that also wants to reserve a chunk of memory? How do you distinguish
>>between them?
>>
> 
> 
> Right now I wouldn't distinguish between them. So if another user
> reserved a portion of memory, it may be in kernelcore only, movable only
> or some combination thereof.

Does not seem very future proof.


>>Why not just specify in the help text that the admin should boot the
>>kernel without that parameter first to check how much memory they
>>have before using it... If they wanted to break the kernel by doing
>>something silly, then I don't see how kernelcore is really better
>>than reclaimable_mem...
>>
> 
> 
> It's simply harder to break a machine by getting kernelcore wrong than
> it is to get reclaimable_mem wrong. If the available memory to the
> machine is changed, it will not have unexpected results on the next boot
> with kernelcore and if you have a cluster with differing amounts of
> memory in each machine, it'll be easier to have one kernelcore value for
> all of them than unique reclaimable_mem ones.

No I really don't see why kernelcore=toosmall is any better than
movable_mem=toobig. And why do you think the admin knows how much
memory is enough to run the kernel, or why should that be the same
between different sized machines? If you have a huge machine, you
need much more addressable kernel memory for the mem_map array
before you even think about anything else.

Actually, it is more likely that the admin knows exactly how much
memory they need to reserve (eg. for their database's shared
memory segment or to hot unplug or whatever), and in that case
it is much better to be able to specify movable_mem= and just be
given exactly what you asked for and the kernel can be given the
rest.

If somebody is playing with this parameter, they definitely know
what they are doing and they are not just blindly throwing it out
over their cluster because it might be a good idea.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

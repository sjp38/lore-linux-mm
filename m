Message-ID: <45B19483.6010300@yahoo.com.au>
Date: Sat, 20 Jan 2007 15:03:15 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>	 <45B0DB45.4070004@linux.vnet.ibm.com>	 <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>	 <45B112B6.9060806@linux.vnet.ibm.com>	 <6d6a94c50701191804m79c70afdo1e664a072f928b9e@mail.gmail.com>	 <45B17D6D.2030004@yahoo.com.au> <6d6a94c50701191908i63fe7eebi9a97a4afb94f5df4@mail.gmail.com>
In-Reply-To: <6d6a94c50701191908i63fe7eebi9a97a4afb94f5df4@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>
List-ID: <linux-mm.kvack.org>

Aubrey Li wrote:

> So what's the right way to limit pagecache?

Probably something a lot more complicated... if you can say there
is a "right way".

>> Secondly, your patch isn't actually very good. It unconditionally
>> shrinks memory to below the given % mark each time a pagecache alloc
>> occurs, regardless of how much pagecache is in the system. Effectively
>> that seems to just reduce the amount of memory available to the system.
> 
> 
> It doesn't reduce the amount of memory available to the system. It
> just reduce the amount of memory available to the page cache. So that
> page cache is limited and the reserved memory can be allocated by the
> application.

But the patch doesn't do that, as I explained.

>> Luckily, there are actually good, robust solutions for your higher
>> order allocation problem. Do higher order allocations at boot time,
>> modifiy userspace applications, or set up otherwise-unused, or easily
>> reclaimable reserve pools for higher order allocations. I don't
>> understand why you are so resistant to all of these approaches?
>>
> 
> I think we have explained the reason too much. We are working on
> no-mmu arch and provide a platform running linux to our customer. They
> are doing very good things like mplayer, asterisk, ip camera, etc on
> our platform, some applications was migrated from mmu arch. I think
> that means in some cases no-mmu arch is somewhat better than mmu arch.
> So we are taking effort to make the migration smooth or make no-mmu
> linux stronger.
> It's no way to let our customer modify their applications, we also
> unwilling to do it. And we have not an existing mechanism to set up a
> pools for the complex applications. So I'm trying to do some coding
> hack in the kernel to satisfy these kinds of requirement.

Oh, maybe you misunderstand the reserve pools idea: that is an entirely
kernel based solution where you can preallocate a large, contiguous
pool of memory at boot time which you can use to satisfy your nommu
higher order anonymous memory allocations.

This is something that will not get fragmented by pagecache, nor will
it get fragmented by any other page allocation, slab allocation. Tt is
a pretty good solution provided that you size the pool correctly for
your application's needs.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

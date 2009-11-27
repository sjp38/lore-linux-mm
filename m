Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C8CD56B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 04:45:27 -0500 (EST)
Message-ID: <4B0F9F9E.3060604@parallels.com>
Date: Fri, 27 Nov 2009 12:45:02 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: slab control
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>	 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>	 <20091126085031.GG2970@balbir.in.ibm.com>	 <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>	 <4B0E461C.50606@parallels.com>	 <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>	 <4B0E50B1.20602@parallels.com>	 <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com>	 <4B0E7530.8050304@parallels.com> <604427e00911262315n5d520cf4p447f68e7053adc11@mail.gmail.com>
In-Reply-To: <604427e00911262315n5d520cf4p447f68e7053adc11@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ying Han wrote:
> On Thu, Nov 26, 2009 at 4:31 AM, Pavel Emelyanov <xemul@parallels.com> wrote:
>>> Aren't there patches to make the kernel track which cgroup caused
>>> which disk I/O? If so, it should be possible to charge the bios to the
>>> right cgroup.
>>>
>>> Maybe one way to decide which kernel allocations should be accounted
>>> would be to look at the calling context: If the allocation is done in
>>> user context (syscall), then it could be counted towards that user,
>>> while if the allocation is done in interrupt or kthread context, it
>>> shouldn't be accounted.
>>>
>>> Of course, this wouldn't be perfect, but it might be a good enough
>>> approximation.
>> I disagree. Bio-s are allocated in user context for all typical reads
>> (unless we requested aio) and are allocated either in pdflush context
>> or (!) in arbitrary task context for writes (e.g. via try_to_free_pages)
>> and thus such bio/buffer_head accounting will be completely random.
>>
>> One of the way to achieve the goal I can propose the following (it's
>> not perfect, but just smth to start discussion from).
>>
>> We implement support for accounting based on a bit on a kmem_cache
>> structure and mark all kmalloc caches as not-accountable. Then we grep
>> the kernel to find all kmalloc-s and think - if a kmalloc is to be
>> accounted we turn this into kmem_cache_alloc() with dedicated
>> kmem_cache and mark it as accountable.
> 
> Well it would be nice to count all kernel memory allocations
> trigger-able by user programs, the kernel
> memory includes kernel slabs as well as the pages directly allocated
> by get_free_pages(). However some
> of the allocations happen asynchronously like in kernel thread or
> interrupt context. We can not charge them
> on the random process happen to run at the time.
> 
> We can either not count those allocations, or do some special
> treatment to remember who owns those allocations.
> In our networking intensive workload, it causes us lots of trouble of
> miscounting the networking slabs for incoming
> packets. So we make changes in the networking stack which records the
> owner of the socket and then charge the
> slab later using that recorded information.

That's the same as what we do, but note, that simple accounting
is not enough for socket buffers (a.k.a. skb-s). In a perfect world
we should implement a memory management similar to what already
exists in the networking.

In particular - sockets should not report errors in case of kmem
shortage, but instead goto waiting state. Besides, TCP sockets should
adjust the TCP window according to the current kmem controller state
and this task is quite complex.

> --Ying
> 
>>> -- Suleiman
>>>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBE46B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 02:09:17 -0400 (EDT)
Message-ID: <4C6B790F.5030405@kernel.org>
Date: Wed, 18 Aug 2010 08:09:19 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [S+Q Cleanup 3/6] slub: Remove static kmem_cache_cpu array for
 boot
References: <20100817211118.958108012@linux.com> <20100817211136.091336874@linux.com> <alpine.DEB.2.00.1008171638160.31928@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1008171638160.31928@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/18/2010 01:58 AM, David Rientjes wrote:
> On Tue, 17 Aug 2010, Christoph Lameter wrote:
> 
>> Index: linux-2.6/mm/slub.c
>> ===================================================================
>> --- linux-2.6.orig/mm/slub.c	2010-08-13 10:32:45.000000000 -0500
>> +++ linux-2.6/mm/slub.c	2010-08-13 10:32:50.000000000 -0500
>> @@ -2062,23 +2062,14 @@ init_kmem_cache_node(struct kmem_cache_n
>>  #endif
>>  }
>>  
>> -static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
>> -
>>  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
>>  {
>> -	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
>> -		/*
>> -		 * Boot time creation of the kmalloc array. Use static per cpu data
>> -		 * since the per cpu allocator is not available yet.
>> -		 */
>> -		s->cpu_slab = kmalloc_percpu + (s - kmalloc_caches);
>> -	else
>> -		s->cpu_slab =  alloc_percpu(struct kmem_cache_cpu);
>> +	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
>> +			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache));
> 
> This fails with CONFIG_NODES_SHIFT=10 on x86_64, which means it will fail 
> the ia64 defconfig as well.  struct kmem_cache stores nodemask pointers up 
> to MAX_NUMNODES, which makes the conditional fail.
> 
> struct kmem_cache is 8376 bytes with that config (and CONFIG_SLUB_DEBUG), 
> so it looks like PERCPU_DYNAMIC_EARLY_SIZE will need to be at least 117264 
> for this not to fail (four orders larger than it currently is, or
> 12 << 14).  Tejun?

Heh, if it gets that high, probably the right thing to do is to define
SLUB_PERCPU_EARLY_SIZE and define PERCPU_DYNAMIC_EARLY_SIZE in terms
of it.

Thaks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

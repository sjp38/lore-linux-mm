Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 0FC806B004D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 06:30:13 -0400 (EDT)
Message-ID: <50111B83.2010105@parallels.com>
Date: Thu, 26 Jul 2012 14:27:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] consider a memcg parameter in kmem_create_cache
References: <1343227101-14217-1-git-send-email-glommer@parallels.com> <1343227101-14217-3-git-send-email-glommer@parallels.com> <20120725181018.GA4921@shutemov.name> <501110ED.9030400@parallels.com> <20120726100111.GA7447@shutemov.name>
In-Reply-To: <20120726100111.GA7447@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Frederic Weisbecker <fweisbec@gmail.com>, devel@openvz.org, cgroups@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>

On 07/26/2012 02:01 PM, Kirill A. Shutemov wrote:
> On Thu, Jul 26, 2012 at 01:42:05PM +0400, Glauber Costa wrote:
>> On 07/25/2012 10:10 PM, Kirill A. Shutemov wrote:
>>> On Wed, Jul 25, 2012 at 06:38:13PM +0400, Glauber Costa wrote:
>>>
>>> ...
>>>
>>>> @@ -337,6 +341,12 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
>>>>  	__kmalloc(size, flags)
>>>>  #endif /* DEBUG_SLAB */
>>>>  
>>>> +#ifdef CONFIG_MEMCG_KMEM
>>>> +#define MAX_KMEM_CACHE_TYPES 400
>>>> +#else
>>>> +#define MAX_KMEM_CACHE_TYPES 0
>>>> +#endif /* CONFIG_MEMCG_KMEM */
>>>> +
>>>>  #ifdef CONFIG_NUMA
>>>>  /*
>>>>   * kmalloc_node_track_caller is a special version of kmalloc_node that
>>>
>>> ...
>>>
>>>> @@ -527,6 +532,24 @@ static inline bool memcg_kmem_enabled(struct mem_cgroup *memcg)
>>>>  		memcg->kmem_accounted;
>>>>  }
>>>>  
>>>> +struct ida cache_types;
>>>> +
>>>> +void memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *cachep)
>>>> +{
>>>> +	int id = -1;
>>>> +
>>>> +	if (!memcg)
>>>> +		id = ida_simple_get(&cache_types, 0, MAX_KMEM_CACHE_TYPES,
>>>> +				    GFP_KERNEL);
>>>
>>> MAX_KMEM_CACHE_TYPES is 0 if CONFIG_MEMCG_KMEM undefined.
>>> If 'end' parameter of ida_simple_get() is 0 it will use default max value
>>> which is 0x80000000.
>>> I guess you want MAX_KMEM_CACHE_TYPES to be 1 for !CONFIG_MEMCG_KMEM.
>>>
>> ida_simple_get will not, and should never be called for !CONFIG_MEMCG_KMEM.
> 
> Okay. Is there an user for MAX_KMEM_CACHE_TYPES if !CONFIG_MEMCG_KMEM?
> 

Actually, not anymore. I will just remove it then, instead of forcing it
to 0.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

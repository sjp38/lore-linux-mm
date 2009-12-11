Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1DA6B009F
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 01:01:23 -0500 (EST)
Message-ID: <4B21E028.3030107@cs.helsinki.fi>
Date: Fri, 11 Dec 2009 08:01:12 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] tracing: Define kmem_trace_alloc_notrace unconditionally
References: <4B21DD88.7080806@cn.fujitsu.com> <4B21DF33.7010906@cs.helsinki.fi>
In-Reply-To: <4B21DF33.7010906@cs.helsinki.fi>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Li Zefan wrote:
>> Always define kmem_trace_alloc_{,node}_notrace(), otherwise
>> perf-kmem will show wrong stats ifndef CONFIG_KMEMTRACE,
>> because a kmalloc() memory allocation may be traced by
>> both trace_kmalloc() and trace_kmem_cache_alloc().
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> Did you check how much this will make kernel text bigger because of the 
> inlining happening in kmem_cache_alloc_notrace()?

Maybe use CONFIG_TRACING instead of CONFIG_KMEMTRACE here like in the 
other patch?

>> ---
>>  include/linux/slab_def.h |   24 ++----------------------
>>  include/linux/slub_def.h |   27 +++------------------------
>>  mm/slab.c                |   12 ------------
>>  mm/slub.c                |    4 ----
>>  4 files changed, 5 insertions(+), 62 deletions(-)
>>
>> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
>> index 850d057..1c9ce4b 100644
>> --- a/include/linux/slab_def.h
>> +++ b/include/linux/slab_def.h
>> @@ -109,21 +109,12 @@ extern struct cache_sizes malloc_sizes[];
>>  
>>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>>  void *__kmalloc(size_t size, gfp_t flags);
>> +void *kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags);
>>  
>> -#ifdef CONFIG_KMEMTRACE
>> -extern void *kmem_cache_alloc_notrace(struct kmem_cache *cachep, 
>> gfp_t flags);
>> -extern size_t slab_buffer_size(struct kmem_cache *cachep);
>> -#else
>> -static __always_inline void *
>> -kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags)
>> -{
>> -    return kmem_cache_alloc(cachep, flags);
>> -}
>>  static inline size_t slab_buffer_size(struct kmem_cache *cachep)
>>  {
>> -    return 0;
>> +    return cachep->buffer_size;
>>  }
>> -#endif
>>  
>>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>>  {
>> @@ -165,20 +156,9 @@ found:
>>  #ifdef CONFIG_NUMA
>>  extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
>>  extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, 
>> int node);
>> -
>> -#ifdef CONFIG_KMEMTRACE
>>  extern void *kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
>>                         gfp_t flags,
>>                         int nodeid);
>> -#else
>> -static __always_inline void *
>> -kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
>> -                  gfp_t flags,
>> -                  int nodeid)
>> -{
>> -    return kmem_cache_alloc_node(cachep, flags, nodeid);
>> -}
>> -#endif
>>  
>>  static __always_inline void *kmalloc_node(size_t size, gfp_t flags, 
>> int node)
>>  {
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index 5ad70a6..5c5ca0c 100644
>> --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -215,18 +215,9 @@ static __always_inline struct kmem_cache 
>> *kmalloc_slab(size_t size)
>>  #endif
>>  
>>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>> +void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags);
>>  void *__kmalloc(size_t size, gfp_t flags);
>>  
>> -#ifdef CONFIG_KMEMTRACE
>> -extern void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t 
>> gfpflags);
>> -#else
>> -static __always_inline void *
>> -kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
>> -{
>> -    return kmem_cache_alloc(s, gfpflags);
>> -}
>> -#endif
>> -
>>  static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
>>  {
>>      unsigned int order = get_order(size);
>> @@ -265,20 +256,8 @@ static __always_inline void *kmalloc(size_t size, 
>> gfp_t flags)
>>  #ifdef CONFIG_NUMA
>>  void *__kmalloc_node(size_t size, gfp_t flags, int node);
>>  void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
>> -
>> -#ifdef CONFIG_KMEMTRACE
>> -extern void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
>> -                       gfp_t gfpflags,
>> -                       int node);
>> -#else
>> -static __always_inline void *
>> -kmem_cache_alloc_node_notrace(struct kmem_cache *s,
>> -                  gfp_t gfpflags,
>> -                  int node)
>> -{
>> -    return kmem_cache_alloc_node(s, gfpflags, node);
>> -}
>> -#endif
>> +void *kmem_cache_alloc_node_notrace(struct kmem_cache *s, gfp_t 
>> gfpflags,
>> +                    int node);
>>  
>>  static __always_inline void *kmalloc_node(size_t size, gfp_t flags, 
>> int node)
>>  {
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 7dfa481..e556380 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -490,14 +490,6 @@ static void **dbg_userword(struct kmem_cache 
>> *cachep, void *objp)
>>  
>>  #endif
>>  
>> -#ifdef CONFIG_KMEMTRACE
>> -size_t slab_buffer_size(struct kmem_cache *cachep)
>> -{
>> -    return cachep->buffer_size;
>> -}
>> -EXPORT_SYMBOL(slab_buffer_size);
>> -#endif
>> -
>>  /*
>>   * Do not go above this order unless 0 objects fit into the slab.
>>   */
>> @@ -3558,13 +3550,11 @@ void *kmem_cache_alloc(struct kmem_cache 
>> *cachep, gfp_t flags)
>>  }
>>  EXPORT_SYMBOL(kmem_cache_alloc);
>>  
>> -#ifdef CONFIG_KMEMTRACE
>>  void *kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags)
>>  {
>>      return __cache_alloc(cachep, flags, __builtin_return_address(0));
>>  }
>>  EXPORT_SYMBOL(kmem_cache_alloc_notrace);
>> -#endif
>>  
>>  /**
>>   * kmem_ptr_validate - check if an untrusted pointer might be a slab 
>> entry.
>> @@ -3621,7 +3611,6 @@ void *kmem_cache_alloc_node(struct kmem_cache 
>> *cachep, gfp_t flags, int nodeid)
>>  }
>>  EXPORT_SYMBOL(kmem_cache_alloc_node);
>>  
>> -#ifdef CONFIG_KMEMTRACE
>>  void *kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
>>                      gfp_t flags,
>>                      int nodeid)
>> @@ -3630,7 +3619,6 @@ void *kmem_cache_alloc_node_notrace(struct 
>> kmem_cache *cachep,
>>                    __builtin_return_address(0));
>>  }
>>  EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
>> -#endif
>>  
>>  static __always_inline void *
>>  __do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 4996fc7..a1c8fe5 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1754,13 +1754,11 @@ void *kmem_cache_alloc(struct kmem_cache *s, 
>> gfp_t gfpflags)
>>  }
>>  EXPORT_SYMBOL(kmem_cache_alloc);
>>  
>> -#ifdef CONFIG_KMEMTRACE
>>  void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
>>  {
>>      return slab_alloc(s, gfpflags, -1, _RET_IP_);
>>  }
>>  EXPORT_SYMBOL(kmem_cache_alloc_notrace);
>> -#endif
>>  
>>  #ifdef CONFIG_NUMA
>>  void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int 
>> node)
>> @@ -1775,7 +1773,6 @@ void *kmem_cache_alloc_node(struct kmem_cache 
>> *s, gfp_t gfpflags, int node)
>>  EXPORT_SYMBOL(kmem_cache_alloc_node);
>>  #endif
>>  
>> -#ifdef CONFIG_KMEMTRACE
>>  void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
>>                      gfp_t gfpflags,
>>                      int node)
>> @@ -1783,7 +1780,6 @@ void *kmem_cache_alloc_node_notrace(struct 
>> kmem_cache *s,
>>      return slab_alloc(s, gfpflags, node, _RET_IP_);
>>  }
>>  EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
>> -#endif
>>  
>>  /*
>>   * Slow patch handling. This may still be called frequently since 
>> objects
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <4561DFB7.5090108@oracle.com>
Date: Mon, 20 Nov 2006 09:02:47 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH]Re: build error: sparsemem + SLOB
References: <20061119210545.9708e366.randy.dunlap@oracle.com> <20061120201955.97DB.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20061120201955.97DB.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:
>>   LD      .tmp_vmlinux1
>> mm/built-in.o: In function `sparse_index_init':
>> sparse.c:(.text.sparse_index_init+0x19): undefined reference to `slab_is_available'
>> make: *** [.tmp_vmlinux1] Error 1
>>
>>
>> mm/sparse.c: line 35 uses slab_is_available() but SLAB=n, SLOB=y.
> 
> 
> Hmm.
> To be honest, I don't know that embedded people would like to use sparsemem.
> mem_section[] array might be too big for them.
> But, they may expect reduce power consumption of memory by memory hotplug.
> 
> Anyway, this is fix.

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

> ------------
> This patch is to fix compile error when SLOB is on with sparsemem.
> 
>   LD      .tmp_vmlinux1
> mm/built-in.o: In function `sparse_index_init':
> sparse.c:(.text.sparse_index_init+0x19): undefined reference to `slab_is_available'
> make: *** [.tmp_vmlinux1] Error 1
> 
> mm/sparse.c: line 35 uses slab_is_available() but SLAB=n, SLOB=y.
> 
> This patch is for 2.6.19-rc5-mm2.
> 
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ------------
>  include/linux/slab.h |    9 +++++++++
>  mm/slob.c            |    4 ++++
>  mm/sparse.c          |    2 +-
>  3 files changed, 14 insertions(+), 1 deletion(-)
> 
> Index: 19-rc5-mm2/include/linux/slab.h
> ===================================================================
> --- 19-rc5-mm2.orig/include/linux/slab.h	2006-11-17 15:21:10.000000000 +0900
> +++ 19-rc5-mm2/include/linux/slab.h	2006-11-20 19:07:20.000000000 +0900
> @@ -210,6 +210,8 @@ static inline void *kcalloc(size_t n, si
>  	return kzalloc(n * size, flags);
>  }
>  
> +#define kmem_is_available() slab_is_available()
> +
>  extern void kfree(const void *);
>  extern unsigned int ksize(const void *);
>  extern int slab_is_available(void);
> @@ -260,6 +262,13 @@ extern void kmem_set_shrinker(kmem_cache
>  #else /* CONFIG_SLOB */
>  
>  /* SLOB allocator routines */
> +extern int slob_initialized;
> +
> +#define kmem_is_available() slob_is_available()
> +static inline int slob_is_available(void)
> +{
> +	return slob_initialized;
> +}
>  
>  void kmem_cache_init(void);
>  struct kmem_cache *kmem_cache_create(const char *c, size_t, size_t,
> Index: 19-rc5-mm2/mm/slob.c
> ===================================================================
> --- 19-rc5-mm2.orig/mm/slob.c	2006-11-17 15:20:47.000000000 +0900
> +++ 19-rc5-mm2/mm/slob.c	2006-11-20 18:37:10.000000000 +0900
> @@ -61,6 +61,8 @@ static DEFINE_SPINLOCK(block_lock);
>  
>  static void slob_free(void *b, int size);
>  
> +int slob_initialized= 0;
> +
>  static void *slob_alloc(size_t size, gfp_t gfp, int align)
>  {
>  	slob_t *prev, *cur, *aligned = 0;
> @@ -337,4 +339,6 @@ void kmem_cache_init(void)
>  		free_page((unsigned long)p);
>  
>  	mod_timer(&slob_timer, jiffies + HZ);
> +	slob_initialized = 1;
> +
>  }
> Index: 19-rc5-mm2/mm/sparse.c
> ===================================================================
> --- 19-rc5-mm2.orig/mm/sparse.c	2006-11-17 15:21:10.000000000 +0900
> +++ 19-rc5-mm2/mm/sparse.c	2006-11-20 16:20:56.000000000 +0900
> @@ -50,7 +50,7 @@ static struct mem_section *sparse_index_
>  	unsigned long array_size = SECTIONS_PER_ROOT *
>  				   sizeof(struct mem_section);
>  
> -	if (slab_is_available())
> +	if (kmem_is_available())
>  		section = kmalloc_node(array_size, GFP_KERNEL, nid);
>  	else
>  		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
> 
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

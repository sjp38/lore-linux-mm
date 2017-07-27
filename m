From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v4] mm: Add SLUB free list pointer obfuscation
Date: Thu, 27 Jul 2017 10:14:18 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707271003370.15126@nuc-kabylake>
References: <20170726041250.GA76741@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726041250.GA76741@beast>
Sender: linux-kernel-owner@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Tycho Andersen <tycho@docker.com>, Alexander Popov <alex.popov@linux.com>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com
List-Id: linux-mm.kvack.org

On Tue, 25 Jul 2017, Kees Cook wrote:

> +/*
> + * Returns freelist pointer (ptr). With hardening, this is obfuscated
> + * with an XOR of the address where the pointer is held and a per-cache
> + * random number.
> + */
> +static inline void *freelist_ptr(const struct kmem_cache *s, void *ptr,
> +				 unsigned long ptr_addr)
> +{
> +#ifdef CONFIG_SLAB_FREELIST_HARDENED
> +	return (void *)((unsigned long)ptr ^ s->random ^ ptr_addr);
> +#else
> +	return ptr;
> +#endif
> +}

Weird function. Why pass both the pointer as well as the address of the
pointer? The address of the pointer would be sufficient I think. Compiler
can optimize the refs on its own. OK ptr_addr is really the obfuscation
value. Maybe a bit confusing to call this ptr_addr and also pass this as
a long. xor_value? If it is a pointer address the it should be void ** or
so.

>  static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
>  {
> +	unsigned long freepointer_addr;
>  	void *p;
>
>  	if (!debug_pagealloc_enabled())
>  		return get_freepointer(s, object);
>
> -	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
> -	return p;
> +	freepointer_addr = (unsigned long)object + s->offset;

converts the void ** to unsigned long.... which requires another cast in
the following line.

> +	probe_kernel_read(&p, (void **)freepointer_addr, sizeof(p));
> +	return freelist_ptr(s, p, freepointer_addr);
>  }
>
>  static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
>  {
> -	*(void **)(object + s->offset) = fp;
> +	unsigned long freeptr_addr = (unsigned long)object + s->offset;
> +
> +	*(void **)freeptr_addr = freelist_ptr(s, fp, freeptr_addr);
>  }
>
>  /* Loop over all objects in a slab */
> @@ -3563,6 +3592,9 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
>  {
>  	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
>  	s->reserved = 0;
> +#ifdef CONFIG_SLAB_FREELIST_HARDENED
> +	s->random = get_random_long();
> +#endif
>
>  	if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
>  		s->reserved = sizeof(struct rcu_head);
>

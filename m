Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C5F816B0089
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 10:06:34 -0400 (EDT)
Message-ID: <1344521191.2393.3.camel@lorien2>
Subject: Re: [PATCH v2] mm: Restructure kmem_cache_create() to move debug
 cache integrity checks into a new function
From: Shuah Khan <shuah.khan@hp.com>
Reply-To: shuah.khan@hp.com
Date: Thu, 09 Aug 2012 08:06:31 -0600
In-Reply-To: <1344287631.2486.57.camel@lorien2>
References: <1342221125.17464.8.camel@lorien2>
	 <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
	 <1344224494.3053.5.camel@lorien2> <1344266096.2486.17.camel@lorien2>
	 <CAAmzW4Ne5pD90r+6zrrD-BXsjtf5OqaKdWY+2NSGOh1M_sWq4g@mail.gmail.com>
	 <1344272614.2486.40.camel@lorien2> <1344287631.2486.57.camel@lorien2>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: penberg@kernel.org, glommer@parallels.com, js1304@gmail.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, shuah.khan@hp.com

On Mon, 2012-08-06 at 15:13 -0600, Shuah Khan wrote:
> kmem_cache_create() does cache integrity checks when CONFIG_DEBUG_VM
> is defined. These checks interspersed with the regular code path has
> lead to compile time warnings when compiled without CONFIG_DEBUG_VM
> defined. Restructuring the code to move the integrity checks in to a new
> function would eliminate the current compile warning problem and also
> will allow for future changes to the debug only code to evolve without
> introducing new warnings in the regular path. This restructuring work
> is based on the discussion in the following thread:
> 
> https://lkml.org/lkml/2012/7/13/424

Comments, questions. Does this patch look good?

Thanks,
-- Shuah
> 
> Signed-off-by: Shuah Khan <shuah.khan@hp.com>
> ---
>  mm/slab_common.c |   79 +++++++++++++++++++++++++++++-------------------------
>  1 file changed, 43 insertions(+), 36 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 12637ce..67409f7 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -23,6 +23,46 @@ enum slab_state slab_state;
>  LIST_HEAD(slab_caches);
>  DEFINE_MUTEX(slab_mutex);
>  
> +#ifdef CONFIG_DEBUG_VM
> +static int kmem_cache_sanity_check(const char *name, size_t size)
> +{
> +	struct kmem_cache *s = NULL;
> +
> +	list_for_each_entry(s, &slab_caches, list) {
> +		char tmp;
> +		int res;
> +
> +		/*
> +		 * This happens when the module gets unloaded and doesn't
> +		 * destroy its slab cache and no-one else reuses the vmalloc
> +		 * area of the module.  Print a warning.
> +		 */
> +		res = probe_kernel_address(s->name, tmp);
> +		if (res) {
> +			pr_err("Slab cache with size %d has lost its name\n",
> +			       s->object_size);
> +			continue;
> +		}
> +
> +		if (!strcmp(s->name, name)) {
> +			pr_err("%s (%s): Cache name already exists.\n",
> +			       __func__, name);
> +			dump_stack();
> +			s = NULL;
> +			return -EINVAL;
> +		}
> +	}
> +
> +	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
> +	return 0;
> +}
> +#else
> +static inline int kmem_cache_sanity_check(const char *name, size_t size)
> +{
> +	return 0;
> +}
> +#endif
> +
>  /*
>   * kmem_cache_create - Create a cache.
>   * @name: A string which is used in /proc/slabinfo to identify this cache.
> @@ -53,48 +93,17 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
>  {
>  	struct kmem_cache *s = NULL;
>  
> -#ifdef CONFIG_DEBUG_VM
>  	if (!name || in_interrupt() || size < sizeof(void *) ||
>  		size > KMALLOC_MAX_SIZE) {
> -		printk(KERN_ERR "kmem_cache_create(%s) integrity check"
> -			" failed\n", name);
> +		pr_err("kmem_cache_create(%s) integrity check failed\n", name);
>  		goto out;
>  	}
> -#endif
>  
>  	get_online_cpus();
>  	mutex_lock(&slab_mutex);
>  
> -#ifdef CONFIG_DEBUG_VM
> -	list_for_each_entry(s, &slab_caches, list) {
> -		char tmp;
> -		int res;
> -
> -		/*
> -		 * This happens when the module gets unloaded and doesn't
> -		 * destroy its slab cache and no-one else reuses the vmalloc
> -		 * area of the module.  Print a warning.
> -		 */
> -		res = probe_kernel_address(s->name, tmp);
> -		if (res) {
> -			printk(KERN_ERR
> -			       "Slab cache with size %d has lost its name\n",
> -			       s->object_size);
> -			continue;
> -		}
> -
> -		if (!strcmp(s->name, name)) {
> -			printk(KERN_ERR "kmem_cache_create(%s): Cache name"
> -				" already exists.\n",
> -				name);
> -			dump_stack();
> -			s = NULL;
> -			goto oops;
> -		}
> -	}
> -
> -	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
> -#endif
> +	if (kmem_cache_sanity_check(name, size))
> +		goto oops;
>  
>  	s = __kmem_cache_create(name, size, align, flags, ctor);
>  
> @@ -102,9 +111,7 @@ oops:
>  	mutex_unlock(&slab_mutex);
>  	put_online_cpus();
>  
> -#ifdef CONFIG_DEBUG_VM
>  out:
> -#endif
>  	if (!s && (flags & SLAB_PANIC))
>  		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

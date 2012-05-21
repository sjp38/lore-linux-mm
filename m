Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 490686B0082
	for <linux-mm@kvack.org>; Mon, 21 May 2012 05:36:42 -0400 (EDT)
Message-ID: <4FBA0C2D.3000101@parallels.com>
Date: Mon, 21 May 2012 13:34:37 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for
 kmem_cache_destroy
References: <20120518161906.207356777@linux.com> <20120518161932.147485968@linux.com>
In-Reply-To: <20120518161932.147485968@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/18/2012 08:19 PM, Christoph Lameter wrote:
> -/*
> - * Close a cache and release the kmem_cache structure
> - * (must be used for caches created using kmem_cache_create)
> - */
> -void kmem_cache_destroy(struct kmem_cache *s)
> +int __kmem_cache_shutdown(struct kmem_cache *s)
>   {
> -	mutex_lock(&slab_mutex);
> -	s->refcount--;
> -	if (!s->refcount) {
> -		list_del(&s->list);
> -		mutex_unlock(&slab_mutex);
> -		if (kmem_cache_close(s)) {
> -			printk(KERN_ERR "SLUB %s: %s called for cache that "
> -				"still has objects.\n", s->name, __func__);
> -			dump_stack();
> -		}
> -		if (s->flags&  SLAB_DESTROY_BY_RCU)
> -			rcu_barrier();
> -		sysfs_slab_remove(s);
> -	} else
> -		mutex_unlock(&slab_mutex);
> +	return kmem_cache_close(s);
> +}

Something doesn't smell right here. It seems that we're now closing the 
caches right away. That wasn't the case before, nor it should be: For 
aliases, we should only decrease the refcount.

So unless I am missing something, it seems to me the correct code would be:

s->refcount--;
if (!s->refcount)
     return kmem_cache_close;
return 0;

And while we're on that, that makes the sequence list_del() -> if it 
fails -> list_add() in the common kmem_cache_destroy a bit clumsy. 
Aliases will be re-added to the list quite frequently. Not that it is a 
big problem, but still...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

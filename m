Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 64ECA6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:41:25 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Hung task when calling clone() due to netfilter/slab
References: <1326558605.19951.7.camel@lappy>
	<1326561043.5287.24.camel@edumazet-laptop>
	<1326632384.11711.3.camel@lappy>
	<1326648305.5287.78.camel@edumazet-laptop>
	<alpine.DEB.2.00.1201170910130.4800@router.home>
	<1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170927020.4800@router.home>
	<1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170942240.4800@router.home>
	<alpine.DEB.2.00.1201171620590.14697@router.home>
Date: Thu, 19 Jan 2012 13:43:40 -0800
In-Reply-To: <alpine.DEB.2.00.1201171620590.14697@router.home> (Christoph
	Lameter's message of "Tue, 17 Jan 2012 16:22:09 -0600 (CST)")
Message-ID: <m1bopz2ws3.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

Christoph Lameter <cl@linux.com> writes:

> Another version that drops the slub lock for both invocations of sysfs
> functions from kmem_cache_create. The invocation from slab_sysfs_init
> is not a problem since user space is not active at that point.
>
>
> Subject: slub: Do not take the slub lock while calling into sysfs
>
> This patch avoids holding the slub_lock during kmem_cache_create()
> when calling sysfs. It is possible because kmem_cache_create()
> allocates the kmem_cache object and therefore is the only one context
> that can access the newly created object. It is therefore possible
> to drop the slub_lock early. We defer the adding of the new kmem_cache
> to the end of processing because the new kmem_cache structure would
> be reachable otherwise via scans over slabs. This allows sysfs_slab_add()
> to run without holding any locks.
>
> The case is different if we are creating an alias instead of a new
> kmem_cache structure. In that case we can also drop the slub lock
> early because we have taken a refcount on the kmem_cache structure.
> It therefore cannot vanish from under us.
> But if the sysfs_slab_alias() call fails we can no longer simply
> decrement the refcount since the other references may have gone
> away in the meantime. Call kmem_cache_destroy() to cause the
> refcount to be decremented and the kmem_cache structure to be
> freed if all references are gone.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

I am dense.  Is the deadlock here that you are fixing slub calling sysfs
with the slub_lock held but sysfs then calling kmem_cache_zalloc?

I don't see what sysfs is doing in the creation path that would cause
a deadlock except for using slab.

> ---
>  mm/slub.c |   25 +++++++++++--------------
>  1 file changed, 11 insertions(+), 14 deletions(-)
>
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2012-01-17 09:53:26.599505365 -0600
> +++ linux-2.6/mm/slub.c	2012-01-17 09:59:57.131497273 -0600
> @@ -3912,13 +3912,14 @@ struct kmem_cache *kmem_cache_create(con
>  		s->objsize = max(s->objsize, (int)size);
>  		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
>
> +		up_write(&slub_lock);
>  		if (sysfs_slab_alias(s, name)) {
> -			s->refcount--;
> +			kmem_cache_destroy(s);
>  			goto err;
>  		}
> -		up_write(&slub_lock);
>  		return s;
>  	}
> +	up_write(&slub_lock);
>
>  	n = kstrdup(name, GFP_KERNEL);
>  	if (!n)
> @@ -3928,27 +3929,23 @@ struct kmem_cache *kmem_cache_create(con
>  	if (s) {
>  		if (kmem_cache_open(s, n,
>  				size, align, flags, ctor)) {
> -			list_add(&s->list, &slab_caches);
> -			if (sysfs_slab_add(s)) {
> -				list_del(&s->list);
> -				kfree(n);
> -				kfree(s);
> -				goto err;
> +
> +			if (sysfs_slab_add(s) == 0) {
> +				down_write(&slub_lock);
> +				list_add(&s->list, &slab_caches);
> +				up_write(&slub_lock);
> +				return s;
>  			}
> -			up_write(&slub_lock);
> -			return s;
>  		}
>  		kfree(n);
>  		kfree(s);
>  	}
>  err:
> -	up_write(&slub_lock);
>
>  	if (flags & SLAB_PANIC)
>  		panic("Cannot create slabcache %s\n", name);
> -	else
> -		s = NULL;
> -	return s;
> +
> +	return NULL;
>  }
>  EXPORT_SYMBOL(kmem_cache_create);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

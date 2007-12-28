Date: Fri, 28 Dec 2007 02:48:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB: Fix sysfs object handling
Message-Id: <20071228024851.4221ae85.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0712272313370.4412@graphe.net>
References: <Pine.LNX.4.64.0712272313370.4412@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 27 Dec 2007 23:17:13 -0800 (PST) Christoph Lameter <christoph@lameter.com> wrote:

> If CONFIG_SYSFS is set then free the kmem_cache structure when
> sysfs tells us its okay. Otherwise there is the danger (as pointed out by 
> Al Viro) that sysfs thinks the kobject still exists after 
> kmem_cache_destroy() removed it.
> 

Thanks.  I doubt if Al reads linux-mm a lot.  cc added...

> 
> ---
>  mm/slub.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2007-12-27 23:03:25.000000000 -0800
> +++ linux-2.6/mm/slub.c	2007-12-27 23:03:26.000000000 -0800
> @@ -247,7 +247,10 @@ static void sysfs_slab_remove(struct kme
>  static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
>  static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
>  							{ return 0; }
> -static inline void sysfs_slab_remove(struct kmem_cache *s) {}
> +static inline void sysfs_slab_remove(struct kmem_cache *s)
> +{
> +	kfree(s);
> +}
>  #endif
>  
>  /********************************************************************
> @@ -2322,7 +2325,6 @@ void kmem_cache_destroy(struct kmem_cach
>  		if (kmem_cache_close(s))
>  			WARN_ON(1);
>  		sysfs_slab_remove(s);
> -		kfree(s);
>  	} else
>  		up_write(&slub_lock);
>  }
> @@ -3940,6 +3942,13 @@ static ssize_t slab_attr_store(struct ko
>  	return err;
>  }
>  
> +static void kmem_cache_release(struct kobject *kobj)
> +{
> +	struct kmem_cache *s = to_slab(kobj);
> +
> +	kfree(s);
> +}
> +
>  static struct sysfs_ops slab_sysfs_ops = {
>  	.show = slab_attr_show,
>  	.store = slab_attr_store,
> @@ -3947,6 +3956,7 @@ static struct sysfs_ops slab_sysfs_ops =
>  
>  static struct kobj_type slab_ktype = {
>  	.sysfs_ops = &slab_sysfs_ops,
> +	.release = kmem_cache_release
>  };
>  
>  static int uevent_filter(struct kset *kset, struct kobject *kobj)
> @@ -4048,6 +4058,7 @@ static void sysfs_slab_remove(struct kme
>  {
>  	kobject_uevent(&s->kobj, KOBJ_REMOVE);
>  	kobject_del(&s->kobj);
> +	kobject_put(&s->kobj);
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

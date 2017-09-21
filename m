From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 01/31] usercopy: Prepare for usercopy whitelisting
Date: Thu, 21 Sep 2017 10:21:16 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709211009400.14427@nuc-kabylake>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org> <1505940337-79069-2-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505940337-79069-2-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com
List-Id: linux-mm.kvack.org

On Wed, 20 Sep 2017, Kees Cook wrote:

> diff --git a/include/linux/stddef.h b/include/linux/stddef.h
> index 9c61c7cda936..f00355086fb2 100644
> --- a/include/linux/stddef.h
> +++ b/include/linux/stddef.h
> @@ -18,6 +18,8 @@ enum {
>  #define offsetof(TYPE, MEMBER)	((size_t)&((TYPE *)0)->MEMBER)
>  #endif
>
> +#define sizeof_field(structure, field) sizeof((((structure *)0)->field))
> +
>  /**
>   * offsetofend(TYPE, MEMBER)
>   *

Hmmm.. Is that really necessary? Code knows the type of field and can
use sizeof type.

Also this is a non slab change hidden in the patchset.

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 904a83be82de..36408f5f2a34 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -272,6 +272,9 @@ int slab_unmergeable(struct kmem_cache *s)
>  	if (s->ctor)
>  		return 1;
>
> +	if (s->usersize)
> +		return 1;
> +
>  	/*
>  	 * We may have set a slab to be unmergeable during bootstrap.
>  	 */

This will ultimately make all slabs unmergeable at the end of your
patchset? Lots of space will be wasted. Is there any way to make this
feature optional?

#ifdef CONFIG_HARDENED around this?


> @@ -491,6 +509,15 @@ kmem_cache_create(const char *name, size_t size, size_t align,
>  	}
>  	return s;
>  }
> +EXPORT_SYMBOL(kmem_cache_create_usercopy);
> +
> +struct kmem_cache *
> +kmem_cache_create(const char *name, size_t size, size_t align,
> +		unsigned long flags, void (*ctor)(void *))
> +{
> +	return kmem_cache_create_usercopy(name, size, align, flags, 0, size,
> +					  ctor);
> +}
>  EXPORT_SYMBOL(kmem_cache_create);

Well this makes the slab created unmergeable.

> @@ -897,7 +927,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
>  	if (!s)
>  		panic("Out of memory when creating slab %s\n", name);
>
> -	create_boot_cache(s, name, size, flags);
> +	create_boot_cache(s, name, size, flags, 0, size);

Ok this makes the kmalloc array unmergeable.

> @@ -5081,6 +5081,12 @@ static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
>  SLAB_ATTR_RO(cache_dma);
>  #endif
>
> +static ssize_t usersize_show(struct kmem_cache *s, char *buf)
> +{
> +	return sprintf(buf, "%zu\n", s->usersize);
> +}
> +SLAB_ATTR_RO(usersize);
> +
>  static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
>  {
>  	return sprintf(buf, "%d\n", !!(s->flags & SLAB_TYPESAFE_BY_RCU));
> @@ -5455,6 +5461,7 @@ static struct attribute *slab_attrs[] = {
>  #ifdef CONFIG_FAILSLAB
>  	&failslab_attr.attr,
>  #endif
> +	&usersize_attr.attr,

So useroffset is not exposed?

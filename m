Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id F0A086B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 08:04:13 -0400 (EDT)
Message-ID: <5017C90E.7060706@parallels.com>
Date: Tue, 31 Jul 2012 16:01:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [13/20] Extract a common function for kmem_cache_destroy
References: <20120601195245.084749371@linux.com> <20120601195307.063633659@linux.com>
In-Reply-To: <20120601195307.063633659@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 06/01/2012 11:52 PM, Christoph Lameter wrote:
> kmem_cache_destroy does basically the same in all allocators.
> 
> Extract common code which is easy since we already have common mutex handling.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> 
> ---
> 
> +	return kmem_cache_close(s);
> +}
> +
> +void __kmem_cache_destroy(struct kmem_cache *s)
> +{
> +	sysfs_slab_remove(s);
> +	kfree(s);
>  }
> -EXPORT_SYMBOL(kmem_cache_destroy);
>  

Christoph,

While testing corner cases of slab memcg, I reached a bug that can be
tracked down to those patches. They are not merged yet, so please mind
them in your next submission. The problem seem to be a consequence of
more than one patch, this one included.

Problem is that you are now allocating objects from kmem_cache with
kmem_cache_alloc, but freeing it with kfree - and in multiple locations.

In particular, after the whole series is applied, you will have a call
to "kfree(s)" in sysfs_slab_remove() that is called from
kmem_cache_shutdown(), and later on kmem_cache_free(kmem_cache, s) from
the destruction common code -> a double free.

Please fix this for the next round.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A2AEA6B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 04:44:58 -0400 (EDT)
Message-ID: <5018EBDA.4090902@parallels.com>
Date: Wed, 1 Aug 2012 12:42:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [2/9] slub: Use kmem_cache for the kmem_cache structure
References: <20120731173620.432853182@linux.com> <20120731173634.744568366@linux.com>
In-Reply-To: <20120731173634.744568366@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 07/31/2012 09:36 PM, Christoph Lameter wrote:
> Do not use kmalloc() but kmem_cache_alloc() for the allocation
> of the kmem_cache structures in slub.
> 
> This is the way its supposed to be. Recent merges lost
> the freeing of the kmem_cache structure and so this is also
> fixing memory leak on kmem_cache_destroy() by adding
> the missing free action to sysfs_slab_remove().

This patch seems incomplete to say the least.

1) You are still not touching the !SYSFS version of the function,
that still reads:

static inline void sysfs_slab_remove(struct kmem_cache *s)
{
        kfree(s->name);
        kfree(s);
}

and it is then inconsistent with its SYSFS version.

2) kmem_cache_release still reads:

static void kmem_cache_release(struct kobject *kobj)
{
        struct kmem_cache *s = to_slab(kobj);

        kfree(s->name);
        kfree(s);
}

Since IIRC both kmem_cache_release and sysfs_slab_remove are called
during cache destruction, you now have a double-double-free (a quadruple
free?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C08C6B000A
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 18:58:13 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t17-v6so6056207ply.13
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 15:58:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i62-v6si9011956pfc.255.2018.06.15.15.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 15:58:12 -0700 (PDT)
Date: Fri, 15 Jun 2018 15:58:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slub: fix failure when we delete and create a slab
 cache
Message-Id: <20180615155809.77862e1f6376d5779da9d991@linux-foundation.org>
In-Reply-To: <alpine.LRH.2.02.1806151817130.6333@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1806151817130.6333@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Jun 2018 18:25:29 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:

> In the kernel 4.17 I removed some code from dm-bufio that did slab cache
> merging (21bb13276768) - both slab and slub support merging caches with
> identical attributes, so dm-bufio now just calls kmem_cache_create and
> relies on implicit merging.
> 
> This uncovered a bug in the slub subsystem - if we delete a cache and
> immediatelly create another cache with the same attributes, it fails
> because of duplicate filename in /sys/kernel/slab/. The slub subsystem
> offloads freeing the cache to a workqueue - and if we create the new cache
> before the workqueue runs, it complains because of duplicate filename in
> sysfs.

Huh.  Surprised that such an obvious blooper survived this long.  I
guess a rapid del+add is uncommon.

> This patch fixes the bug by moving the call of kobject_del from 
> sysfs_slab_remove_workfn to shutdown_cache. kobject_del must be called 
> while we hold slab_mutex - so that the sysfs entry is deleted before a 
> cache with the same attributes could be created.
> 
> 
> Running device-mapper-test-suite with:

Nice changelog, btw.

> --- linux-2.6.orig/include/linux/slub_def.h
> +++ linux-2.6/include/linux/slub_def.h
> @@ -156,8 +156,12 @@ struct kmem_cache {
>  
>  #ifdef CONFIG_SYSFS
>  #define SLAB_SUPPORTS_SYSFS
> +void sysfs_slab_unlink(struct kmem_cache *);
>  void sysfs_slab_release(struct kmem_cache *);
>  #else
> +static inline void sysfs_slab_unlink(struct kmem_cache *s)
> +{
> +}
>  static inline void sysfs_slab_release(struct kmem_cache *s)
>  {
>  }

hm, that's pretty old-school.  We could replace SLAB_SUPPORTS_SYSFS
with CONFIG_SLAB_SUPPORTS_SYSFS, move the above logic into slab.h and..

> --- linux-2.6.orig/mm/slab_common.c
> +++ linux-2.6/mm/slab_common.c
> @@ -566,10 +566,14 @@ static int shutdown_cache(struct kmem_ca
>  	list_del(&s->list);
>  
>  	if (s->flags & SLAB_TYPESAFE_BY_RCU) {
> +#ifdef SLAB_SUPPORTS_SYSFS
> +		sysfs_slab_unlink(s);
> +#endif
>  		list_add_tail(&s->list, &slab_caches_to_rcu_destroy);
>  		schedule_work(&slab_caches_to_rcu_destroy_work);
>  	} else {
>  #ifdef SLAB_SUPPORTS_SYSFS
> +		sysfs_slab_unlink(s);
>  		sysfs_slab_release(s);
>  #else
>  		slab_kmem_cache_release(s);

remove a bunch of ifdefs.  But that would be a separate thing.

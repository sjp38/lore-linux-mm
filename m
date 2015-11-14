Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 860DD6B0038
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 06:04:42 -0500 (EST)
Received: by lfs39 with SMTP id 39so65215444lfs.3
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 03:04:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c2si1625393lfe.34.2015.11.14.03.04.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 03:04:40 -0800 (PST)
Date: Sat, 14 Nov 2015 14:04:21 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V4 1/2] slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
Message-ID: <20151114110421.GE31308@esperanza>
References: <20151113105558.32536.63240.stgit@firesoul>
 <20151113105725.32536.67149.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151113105725.32536.67149.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Fri, Nov 13, 2015 at 11:57:40AM +0100, Jesper Dangaard Brouer wrote:
> The call slab_pre_alloc_hook() interacts with kmemgc and is not
> allowed to be called several times inside the bulk alloc for loop,
> due to the call to memcg_kmem_get_cache().
> 
> This would result in hitting the VM_BUG_ON in __memcg_kmem_get_cache.
> 
> As suggested by Vladimir Davydov, change slab_post_alloc_hook()
> to be able to handle an array of objects.
> 
> A subtle detail is, loop iterator "i" in slab_post_alloc_hook()
> must have same type (size_t) as size argument.  This helps the
> compiler to easier realize that it can remove the loop, when all
> debug statements inside loop evaluates to nothing.
>  Note, this is only an issue because the kernel is compiled with
> GCC option: -fno-strict-overflow
> 
> In slab_alloc_node() the compiler inlines and optimizes the invocation
> of slab_post_alloc_hook(s, flags, 1, &object) by removing the loop and
> access object directly.
> 
> Reported-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

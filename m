Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1E165828F3
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:58:45 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id c10so40554877pfc.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:58:45 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id vw1si45491228pab.74.2016.02.08.01.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 01:58:44 -0800 (PST)
Date: Mon, 8 Feb 2016 12:58:31 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCHv8] mm: slab: free kmem_cache_node after destroy sysfs file
Message-ID: <20160208095831.GB30053@esperanza>
References: <1454923907-25901-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454923907-25901-1-git-send-email-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Feb 08, 2016 at 12:31:47PM +0300, Dmitry Safonov wrote:
> With enabled slub_debug alloc_calls_show will try to track location and
> user of slab object on each online node, kmem_cache_node structure and
> cpu_cache/cpu_slub shouldn't be freed till there is the last reference
> to sysfs file.
> 
> Fixes the following panic:
> [43963.463055] BUG: unable to handle kernel
> [43963.463090] NULL pointer dereference at 0000000000000020
> [43963.463146] IP: [<ffffffff811c6959>] list_locations+0x169/0x4e0
> [43963.463185] PGD 257304067 PUD 438456067 PMD 0
> [43963.463220] Oops: 0000 [#1] SMP
> [43963.463850] CPU: 3 PID: 973074 Comm: cat ve: 0 Not tainted 3.10.0-229.7.2.ovz.9.30-00007-japdoll-dirty #2 9.30
> [43963.463913] Hardware name: DEPO Computers To Be Filled By O.E.M./H67DE3, BIOS L1.60c 07/14/2011
> [43963.463976] task: ffff88042a5dc5b0 ti: ffff88037f8d8000 task.ti: ffff88037f8d8000
> [43963.464036] RIP: 0010:[<ffffffff811c6959>]  [<ffffffff811c6959>] list_locations+0x169/0x4e0
> [43963.464725] Call Trace:
> [43963.464756]  [<ffffffff811c6d1d>] alloc_calls_show+0x1d/0x30
> [43963.464793]  [<ffffffff811c15ab>] slab_attr_show+0x1b/0x30
> [43963.464829]  [<ffffffff8125d27a>] sysfs_read_file+0x9a/0x1a0
> [43963.464865]  [<ffffffff811e3c6c>] vfs_read+0x9c/0x170
> [43963.464900]  [<ffffffff811e4798>] SyS_read+0x58/0xb0
> [43963.464936]  [<ffffffff81612d49>] system_call_fastpath+0x16/0x1b
> [43963.464970] Code: 5e 07 12 00 b9 00 04 00 00 3d 00 04 00 00 0f 4f c1 3d 00 04 00 00 89 45 b0 0f 84 c3 00 00 00 48 63 45 b0 49 8b 9c c4 f8 00 00 00 <48> 8b 43 20 48 85 c0 74 b6 48 89 df e8 46 37 44 00 48 8b 53 10
> [43963.465119] RIP  [<ffffffff811c6959>] list_locations+0x169/0x4e0
> [43963.465155]  RSP <ffff88037f8dbe28>
> [43963.465185] CR2: 0000000000000020
> 
> Separated __kmem_cache_release from __kmem_cache_shutdown which now
> called on slab_kmem_cache_release (after the last reference to sysfs
> file object has dropped).
> Reintroduced locking in free_partial as sysfs file might access cache's
> partial list after shutdowning - partiall revert of the
> commit 69cb8e6b7c2982 ("slub: free slabs without holding locks")
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>

The patch looks good to me now, thanks.

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Two minor nits below:

...
>  /*
>   * Attempt to free all partial slabs on a node.
> - * This is called from kmem_cache_close(). We must be the last thread
> - * using the cache and therefore we do not need to lock anymore.
> + * This is called from __kmem_cache_shutdown(). We must take list_lock
> + * because sysfs file might still access partial list after the shutdowning.
>   */
>  static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>  {
> +	unsigned long flags;
>  	struct page *page, *h;
>  
> +	spin_lock_irqsave(&n->list_lock, flags);

Nit: this function is never called with irqs disabled, so
spin_lock_irq() would be enough. We could add BUG_ON(irqs_disabled())
just to be sure.

>  	list_for_each_entry_safe(page, h, &n->partial, lru) {
>  		if (!page->inuse) {
>  			__remove_partial(n, page);

Nit: __remove_partial() (with leading underscores) was introduced solely
to avoid lockdep warning here (see 1e4dd9461fabf). Since we now take
list_lock, we can use remove_partial() (w/o underscores) and hence zap
__remove_partial().

Thanks,
Vladimir

>  			discard_slab(s, page);
>  		} else {
>  			list_slab_objects(s, page,
> -			"Objects remaining in %s on kmem_cache_close()");
> +			"Objects remaining in %s on __kmem_cache_shutdown()");
>  		}
>  	}
> +	spin_unlock_irqrestore(&n->list_lock, flags);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 534086B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 16:46:27 -0400 (EDT)
Date: Fri, 27 Jul 2012 15:46:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: remove one code path and reduce lock contention
 in __slab_free()
In-Reply-To: <1343420271-3825-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207271538250.25434@router.home>
References: <1343420271-3825-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 28 Jul 2012, Joonsoo Kim wrote:

> Subject and commit log are changed from v1.

That looks a bit better. But the changelog could use more cleanup and
clearer expression.

> @@ -2490,25 +2492,17 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>                  return;
>          }
>
> +	if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
> +		goto slab_empty;
> +

So we can never encounter a empty slab that was frozen before? Really?

Remote frees can decrement inuse again. All objects of a slab frozen on
one cpu could be allocated while the slab is still frozen. The
unfreezing requires slab_alloc to encounter a NULL pointer after all.

A remote processor could obtain a pointer to all these objects and free
them. The code here would cause an unfreeze action. Another alloc on the
first processor would cause a *second* unfreeze action on a page that was
freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

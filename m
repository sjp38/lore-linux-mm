Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 3E2D76B00DD
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 11:28:21 -0400 (EDT)
Date: Tue, 18 Sep 2012 15:28:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 09/16] sl[au]b: always get the cache from its page in
 kfree
In-Reply-To: <1347977530-29755-10-git-send-email-glommer@parallels.com>
Message-ID: <00000139d9fe8595-8905906d-18ed-4d41-afdb-f4c632c2d50a-000000@email.amazonses.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-10-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 18 Sep 2012, Glauber Costa wrote:

> index f2d760c..18de3f6 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3938,9 +3938,12 @@ EXPORT_SYMBOL(__kmalloc);
>   * Free an object which was previously allocated from this
>   * cache.
>   */
> -void kmem_cache_free(struct kmem_cache *cachep, void *objp)
> +void kmem_cache_free(struct kmem_cache *s, void *objp)
>  {
>  	unsigned long flags;
> +	struct kmem_cache *cachep = virt_to_cache(objp);
> +
> +	VM_BUG_ON(!slab_equal_or_parent(cachep, s));
>

This is an extremely hot path of the kernel and you are adding significant
processing. Check how the benchmarks are influenced by this change.
virt_to_cache can be a bit expensive.

> diff --git a/mm/slub.c b/mm/slub.c
> index 4778548..a045dfc 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2604,7 +2604,9 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
>
>  	page = virt_to_head_page(x);
>
> -	slab_free(s, page, x, _RET_IP_);
> +	VM_BUG_ON(!slab_equal_or_parent(page->slab, s));
> +
> +	slab_free(page->slab, page, x, _RET_IP_);
>

Less of a problem here but you are eroding one advantage that slab has had
in the past over slub in terms of freeing objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

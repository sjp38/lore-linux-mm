Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 909EA6B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:06:06 -0400 (EDT)
Date: Tue, 27 Aug 2013 16:06:04 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 07/16] slab: overloading the RCU head over the LRU for
 RCU free
Message-ID: <20130827160604.5ca4161c@lwn.net>
In-Reply-To: <1377161065-30552-8-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1377161065-30552-8-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013 17:44:16 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> With build-time size checking, we can overload the RCU head over the LRU
> of struct page to free pages of a slab in rcu context. This really help to
> implement to overload the struct slab over the struct page and this
> eventually reduce memory usage and cache footprint of the SLAB.

So I'm taking a look at this, trying to figure out what's actually in
struct page while this stuff is going on without my head exploding.  A
couple of questions come to mind.

>  static void kmem_rcu_free(struct rcu_head *head)
>  {
> -	struct slab_rcu *slab_rcu = (struct slab_rcu *)head;
> -	struct kmem_cache *cachep = slab_rcu->page->slab_cache;
> +	struct kmem_cache *cachep;
> +	struct page *page;
>  
> -	kmem_freepages(cachep, slab_rcu->page);
> +	page = container_of((struct list_head *)head, struct page, lru);
> +	cachep = page->slab_cache;
> +
> +	kmem_freepages(cachep, page);
>  }

Is there a reason why you don't add the rcu_head structure as another field
in that union alongside lru rather than playing casting games here?  This
stuff is hard enough to follow as it is without adding that into the mix.

The other question I had is: this field also overlays slab_page.  I guess
that, by the time RCU comes into play, there will be no further use of
slab_page?  It might be nice to document that somewhere if it's the case.

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

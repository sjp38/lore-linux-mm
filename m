Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id E52666B007B
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 08:52:27 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so2998619lbi.37
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 05:52:26 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pu8si36944270lbb.37.2014.06.09.05.52.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jun 2014 05:52:25 -0700 (PDT)
Date: Mon, 9 Jun 2014 16:52:13 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 5/8] slub: make slab_free non-preemptable
Message-ID: <20140609125211.GA32192@esperanza>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1406060942160.32229@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406060942160.32229@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 06, 2014 at 09:46:57AM -0500, Christoph Lameter wrote:
> On Fri, 6 Jun 2014, Vladimir Davydov wrote:
> 
> > This patch makes SLUB's implementation of kmem_cache_free
> > non-preemptable. As a result, synchronize_sched() will work as a barrier
> > against kmem_cache_free's in flight, so that issuing it before cache
> > destruction will protect us against the use-after-free.
> 
> 
> Subject: slub: reenable preemption before the freeing of slabs from slab_free
> 
> I would prefer to call the page allocator with preemption enabled if possible.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-05-29 11:45:32.065859887 -0500
> +++ linux/mm/slub.c	2014-06-06 09:45:12.822480834 -0500
> @@ -1998,6 +1998,7 @@
>  	if (n)
>  		spin_unlock(&n->list_lock);
> 
> +	preempt_enable();

The whole function (unfreeze_partials) is currently called with irqs
off, so this is effectively a no-op. I guess we can restore irqs here
though.

>  	while (discard_page) {
>  		page = discard_page;
>  		discard_page = discard_page->next;
> @@ -2006,6 +2007,7 @@
>  		discard_slab(s, page);

If we just freed the last slab of the cache and then get preempted
(suppose we restored irqs above), nothing will prevent the cache from
destruction, which may result in use-after-free below. We need to be
more cautious if we want to call for page allocator with preemption and
irqs on.

However, I still don't understand what's the point in it. We *already*
call discard_slab with irqs disabled, which is harder, and it haven't
caused any problems AFAIK. Moreover, even if we enabled preemption/irqs,
it wouldn't guarantee that discard_slab would always be called with
preemption/irqs on, because the whole function - I mean kmem_cache_free
- can be called with preemption/irqs disabled.

So my point it would only complicate the code.

Thanks.

>  		stat(s, FREE_SLAB);
>  	}
> +	preempt_disable();
>  #endif
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

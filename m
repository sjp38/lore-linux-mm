Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 836606B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:25:01 -0500 (EST)
Received: by pabur14 with SMTP id ur14so46464497pab.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:25:01 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x10si19754495pas.190.2015.12.10.03.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:25:00 -0800 (PST)
Date: Thu, 10 Dec 2015 14:24:47 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: MEMCG no longer works with SLOB
Message-ID: <20151210112447.GV11488@esperanza>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
 <2564892.qO1q7YJ6Nb@wuerfel>
 <1558902.EBTjGmY9S2@wuerfel>
 <20151209200107.GA17409@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151209200107.GA17409@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 09, 2015 at 03:01:07PM -0500, Johannes Weiner wrote:
> On Wed, Dec 09, 2015 at 05:32:39PM +0100, Arnd Bergmann wrote:
> > The change to move the kmem accounting into the normal memcg
> > code means we can no longer use memcg with slob, which lacks
> > the memcg_params member in its struct kmem_cache:
> > 
> > ../mm/slab.h: In function 'is_root_cache':
> > ../mm/slab.h:187:10: error: 'struct kmem_cache' has no member named 'memcg_params'

Argh, I completely forgot about this SLOB thing :-(

> > 
> > This enforces the new dependency in Kconfig. Alternatively,
> > we could change the slob code to allow using MEMCG.
> 
> I'm curious, was this a random config or do you actually use
> CONFIG_SLOB && CONFIG_MEMCG?
> 
> Excluding CONFIG_MEMCG completely for slob seems harsh, but I would
> prefer not littering the source with
> 
> #if defined(CONFIG_MEMCG) && (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
> 
> or
> 
> #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> 
> for such a special case. The #ifdefs are already out of hand in there.
> 
> Vladimir, what would you think of simply doing this?
> 
> diff --git a/mm/slab.h b/mm/slab.h
> index 5adec08..0b3ec4b 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -25,6 +25,9 @@ struct kmem_cache {
>  	int refcount;		/* Use counter */
>  	void (*ctor)(void *);	/* Called on object slot creation */
>  	struct list_head list;	/* List of all slab caches on the system */
> +#ifdef CONFIG_MEMCG
> +	struct memcg_cache_params memcg_params;
> +#endif
>  };
>  
>  #endif /* CONFIG_SLOB */

I don't like it. This would result in allocation of per memcg arrays for
each list_lru/kmem_cache, which would never be used. This looks
extremely ugly. I'd prefer to make CONFIG_MEMCG depend on SL[AU]B, but
I'm afraid such a change will be frowned upon - who knows who uses
MEMCG & SLOB?

I guess SLOB could be made memcg-aware, but I don't think it's worth the
trouble, although I can take a look in this direction - from a quick
glance at SLOB it shouldn't be difficult. If we decide to go this way, I
think we could use this patch as a temporary fix, which would be
reverted eventually.

Otherwise, no matter how tempting the idea to put all memcg stuff under
CONFIG_MEMCG is, I think it won't fly, so for now we should use ifdefs.
To avoid complex checks, we could define a macro in memcontrol.h, say
MEMCG_KMEM_ENABLED, and use it throughout the code. And I think we
should wrap list_lru stuff in it either :-/

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

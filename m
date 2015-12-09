Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id AF8AD6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 15:01:20 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id v187so1479538wmv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 12:01:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ix3si13492985wjb.141.2015.12.09.12.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 12:01:19 -0800 (PST)
Date: Wed, 9 Dec 2015 15:01:07 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: MEMCG no longer works with SLOB
Message-ID: <20151209200107.GA17409@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
 <2564892.qO1q7YJ6Nb@wuerfel>
 <1558902.EBTjGmY9S2@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558902.EBTjGmY9S2@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@virtuozzo.com>

On Wed, Dec 09, 2015 at 05:32:39PM +0100, Arnd Bergmann wrote:
> The change to move the kmem accounting into the normal memcg
> code means we can no longer use memcg with slob, which lacks
> the memcg_params member in its struct kmem_cache:
> 
> ../mm/slab.h: In function 'is_root_cache':
> ../mm/slab.h:187:10: error: 'struct kmem_cache' has no member named 'memcg_params'
> 
> This enforces the new dependency in Kconfig. Alternatively,
> we could change the slob code to allow using MEMCG.

I'm curious, was this a random config or do you actually use
CONFIG_SLOB && CONFIG_MEMCG?

Excluding CONFIG_MEMCG completely for slob seems harsh, but I would
prefer not littering the source with

#if defined(CONFIG_MEMCG) && (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))

or

#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)

for such a special case. The #ifdefs are already out of hand in there.

Vladimir, what would you think of simply doing this?

diff --git a/mm/slab.h b/mm/slab.h
index 5adec08..0b3ec4b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -25,6 +25,9 @@ struct kmem_cache {
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
 	struct list_head list;	/* List of all slab caches on the system */
+#ifdef CONFIG_MEMCG
+	struct memcg_cache_params memcg_params;
+#endif
 };
 
 #endif /* CONFIG_SLOB */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

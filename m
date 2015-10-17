Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 30D3A82F64
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 10:59:02 -0400 (EDT)
Received: by iofz202 with SMTP id z202so8249890iof.2
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 07:59:02 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sa1si7544746igb.99.2015.10.17.07.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Oct 2015 07:59:01 -0700 (PDT)
Date: Sat, 17 Oct 2015 17:58:44 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
Message-ID: <20151017145843.GL11309@esperanza>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
 <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
 <20151016131726.GA602@node.shutemov.name>
 <20151016135106.GJ11309@esperanza>
 <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 16, 2015 at 03:12:23PM -0700, Hugh Dickins wrote:
...
> Are you expecting to use mem_cgroup_from_kmem() from other places
> in future?  Seems possible; but at present it's called from only

Not in the near future. At least, currently I can't think of any other
use for it except list_lru_from_kmem.

> one place, and (given how memcontrol.h has somehow managed to avoid
> including mm.h all these years), I thought it would be nice to avoid
> it for just this; and fixed my build with the patch below last night.
> Whatever you all think best: just wanted to point out an alternative.

Makes sense, thanks!

I would even inline mem_cgroup_from_kmem to list_lru_from_kmem:

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 47677acb4516..2077b9bb4883 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -831,16 +831,6 @@ static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 	if (memcg_kmem_enabled())
 		__memcg_kmem_put_cache(cachep);
 }
-
-static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
-{
-	struct page *page;
-
-	if (!memcg_kmem_enabled())
-		return NULL;
-	page = virt_to_head_page(ptr);
-	return page->mem_cgroup;
-}
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -886,11 +876,6 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 }
-
-static inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
-{
-	return NULL;
-}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 28237476b055..00d0a70af70a 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -68,10 +68,10 @@ list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
 {
 	struct mem_cgroup *memcg;
 
-	if (!nlru->memcg_lrus)
+	if (!memcg_kmem_enabled() || !nlru->memcg_lrus)
 		return &nlru->lru;
 
-	memcg = mem_cgroup_from_kmem(ptr);
+	memcg = virt_to_head_page(ptr)->mem_cgroup;
 	if (!memcg)
 		return &nlru->lru;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

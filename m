Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 7A22F6B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 09:18:00 -0400 (EDT)
Message-ID: <51BB1802.8050108@yandex-team.ru>
Date: Fri, 14 Jun 2013 17:17:54 +0400
From: Roman Gushchin <klamm@yandex-team.ru>
MIME-Version: 1.0
Subject: [PATCH] slub: Avoid direct compaction if possible
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, glommer@parallels.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Slub tries to use contiguous pages to fasten allocations and to minimize
management overhead. If necessary, it can easily fall back to the minimum
order allocations.

Slub tries to allocate contiguous pages even if memory is fragmented and
there are no free contiguous pages. In this case it calls direct compaction
to allocate contiguous page. Compaction requires the taking of some heavily
contended locks (e.g. zone locks). So, running compaction (direct and using
kswapd) simultaneously on several processors can cause serious performance
issues.

It's possible to avoid such problems (or at least to make them less probable)
by avoiding direct compaction. If it's not possible to allocate a contiguous
page without compaction, slub will fall back to order 0 page(s). In this case
kswapd will be woken to perform asynchronous compaction. So, slub can return
to default order allocations as soon as memory will be de-fragmented.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
---
  include/linux/gfp.h | 4 +++-
  mm/page_alloc.c     | 3 +++
  mm/slub.c           | 3 ++-
  3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0f615eb..073a90a 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -35,6 +35,7 @@ struct vm_area_struct;
  #define ___GFP_NO_KSWAPD	0x400000u
  #define ___GFP_OTHER_NODE	0x800000u
  #define ___GFP_WRITE		0x1000000u
+#define ___GFP_NOCOMPACT	0x2000000u
  /* If the above are modified, __GFP_BITS_SHIFT may need updating */

  /*
@@ -92,6 +93,7 @@ struct vm_area_struct;
  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
  #define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
  #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
+#define __GFP_NOCOMPACT ((__force gfp_t)___GFP_NOCOMPACT) /* Avoid direct compaction */

  /*
   * This may seem redundant, but it's a way of annotating false positives vs.
@@ -99,7 +101,7 @@ struct vm_area_struct;
   */
  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)

-#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))

  /* This equals 0, but use constants in case they ever change */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3edb62..292562f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2482,6 +2482,9 @@ rebalance:
  	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
  		goto nopage;

+	if (order && (gfp_mask & __GFP_NOCOMPACT))
+		goto nopage;
+
  	/*
  	 * Try direct compaction. The first pass is asynchronous. Subsequent
  	 * attempts after direct reclaim are synchronous
diff --git a/mm/slub.c b/mm/slub.c
index 57707f0..a38733b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1287,7 +1287,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
  	 * Let the initial higher-order allocation fail under memory pressure
  	 * so we fall-back to the minimum order allocation.
  	 */
-	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
+	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NOCOMPACT) &
+		~__GFP_NOFAIL;

  	page = alloc_slab_page(alloc_gfp, node, oo);
  	if (unlikely(!page)) {
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

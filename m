Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 83A8E6B00CC
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:52:56 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 22/22] slab: Use nr_online_nodes to check for a NUMA platform
Date: Wed, 22 Apr 2009 14:53:27 +0100
Message-Id: <1240408407-21848-23-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

SLAB currently avoids checking a bitmap repeatedly by checking once and
storing a flag. When the addition of nr_online_nodes as a cheaper version
of num_online_nodes(), this check can be replaced by nr_online_nodes.

(Christoph did a patch that this is lifted almost verbatim from, hence the
first Signed-off-by. Christoph, can you confirm you're ok with that?)

Signed-off-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/slab.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 1c680e8..4d38dc2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -892,7 +892,6 @@ static void __slab_error(const char *function, struct kmem_cache *cachep,
   */
 
 static int use_alien_caches __read_mostly = 1;
-static int numa_platform __read_mostly = 1;
 static int __init noaliencache_setup(char *s)
 {
 	use_alien_caches = 0;
@@ -1453,10 +1452,8 @@ void __init kmem_cache_init(void)
 	int order;
 	int node;
 
-	if (num_possible_nodes() == 1) {
+	if (num_possible_nodes() == 1)
 		use_alien_caches = 0;
-		numa_platform = 0;
-	}
 
 	for (i = 0; i < NUM_INIT_LISTS; i++) {
 		kmem_list3_init(&initkmem_list3[i]);
@@ -3579,7 +3576,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp)
 	 * variable to skip the call, which is mostly likely to be present in
 	 * the cache.
 	 */
-	if (numa_platform && cache_free_alien(cachep, objp))
+	if (nr_online_nodes > 1 && cache_free_alien(cachep, objp))
 		return;
 
 	if (likely(ac->avail < ac->limit)) {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

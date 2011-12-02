Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 19D986B004D
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 03:24:48 -0500 (EST)
From: Alex Shi <alex.shi@intel.com>
Subject: [PATCH 2/3] slub: remove unnecessary statistics, deactivate_to_head/tail
Date: Fri,  2 Dec 2011 16:23:08 +0800
Message-Id: <1322814189-17318-2-git-send-email-alex.shi@intel.com>
In-Reply-To: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Alex Shi <alexs@intel.com>

Since the head or tail were automaticly decided in add_partial(),
we didn't need this statistics again.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 include/linux/slub_def.h |    2 --
 mm/slub.c                |   11 ++---------
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a32bcfd..509841a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -29,8 +29,6 @@ enum stat_item {
 	CPUSLAB_FLUSH,		/* Abandoning of the cpu slab */
 	DEACTIVATE_FULL,	/* Cpu slab was full when deactivated */
 	DEACTIVATE_EMPTY,	/* Cpu slab was empty when deactivated */
-	DEACTIVATE_TO_HEAD,	/* Cpu slab was moved to the head of partials */
-	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
 	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
 	DEACTIVATE_BYPASS,	/* Implicit deactivation */
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
diff --git a/mm/slub.c b/mm/slub.c
index c419e80..65d901f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1717,13 +1717,11 @@ static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 	enum slab_modes l = M_NONE, m = M_NONE;
 	void *freelist;
 	void *nextfree;
-	int tail = DEACTIVATE_TO_HEAD;
 	struct page new;
 	struct page old;
 
 	if (page->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
-		tail = DEACTIVATE_TO_TAIL;
 	}
 
 	c->tid = next_tid(c->tid);
@@ -1826,12 +1824,11 @@ redo:
 
 			remove_full(s, page);
 
-		if (m == M_PARTIAL) {
+		if (m == M_PARTIAL)
 
 			add_partial(n, page);
-			stat(s, tail);
 
-		} else if (m == M_FULL) {
+		else if (m == M_FULL) {
 
 			stat(s, DEACTIVATE_FULL);
 			add_full(s, n, page);
@@ -5023,8 +5020,6 @@ STAT_ATTR(FREE_SLAB, free_slab);
 STAT_ATTR(CPUSLAB_FLUSH, cpuslab_flush);
 STAT_ATTR(DEACTIVATE_FULL, deactivate_full);
 STAT_ATTR(DEACTIVATE_EMPTY, deactivate_empty);
-STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate_to_head);
-STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
 STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
 STAT_ATTR(DEACTIVATE_BYPASS, deactivate_bypass);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
@@ -5088,8 +5083,6 @@ static struct attribute *slab_attrs[] = {
 	&cpuslab_flush_attr.attr,
 	&deactivate_full_attr.attr,
 	&deactivate_empty_attr.attr,
-	&deactivate_to_head_attr.attr,
-	&deactivate_to_tail_attr.attr,
 	&deactivate_remote_frees_attr.attr,
 	&deactivate_bypass_attr.attr,
 	&order_fallback_attr.attr,
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

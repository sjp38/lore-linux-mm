Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 436406B0037
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 19:57:56 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 27 Jun 2013 05:20:44 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 0C1371258051
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 05:26:49 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5QNw4tc27459722
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 05:28:04 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5QNviIS013120
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 09:57:44 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm/slub: Fix slub calculate active slabs uncorrectly
Date: Thu, 27 Jun 2013 07:57:37 +0800
Message-Id: <1372291059-9880-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Enough slabs are queued in partial list to avoid pounding the page allocator
excessively. Entire free slabs are not discarded immediately if there are not
enough slabs in partial list(n->partial < s->min_partial). The number of total
slabs is composed by the number of active slabs and the number of entire free
slabs, however, the current logic of slub implementation ignore this which lead
to the number of active slabs and the number of total slabs in slabtop message
is always equal. This patch fix it by substract the number of entire free slabs
in partial list when caculate active slabs.

Before patch:
Active / Total Slabs (% used) : 59018 / 59018 (100.0%)

After patch:
Active / Total Slabs (% used) : 11086 / 11153 (99.4%)

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slub.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 57707f0..939760d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2055,15 +2055,20 @@ static int count_free(struct page *page)
 }
 
 static unsigned long count_partial(struct kmem_cache_node *n,
-					int (*get_count)(struct page *))
+	unsigned long *nr_inactive_slabs, int (*get_count)(struct page *))
 {
 	unsigned long flags;
 	unsigned long x = 0;
+	unsigned long nr_inactive = 0;
 	struct page *page;
 
 	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->partial, lru)
+	list_for_each_entry(page, &n->partial, lru) {
 		x += get_count(page);
+		if (nr_inactive_slabs && page->inuse == 0)
+			nr_inactive++;
+	}
+	*nr_inactive_slabs = nr_inactive;
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return x;
 }
@@ -2102,7 +2107,7 @@ slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 		if (!n)
 			continue;
 
-		nr_free  = count_partial(n, count_free);
+		nr_free  = count_partial(n, NULL, count_free);
 		nr_slabs = node_nr_slabs(n);
 		nr_objs  = node_nr_objs(n);
 
@@ -4304,7 +4309,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			x = atomic_long_read(&n->total_objects);
 		else if (flags & SO_OBJECTS)
 			x = atomic_long_read(&n->total_objects) -
-				count_partial(n, count_free);
+				count_partial(n, NULL, count_free);
 
 			else
 				x = atomic_long_read(&n->nr_slabs);
@@ -4319,9 +4324,9 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			struct kmem_cache_node *n = get_node(s, node);
 
 			if (flags & SO_TOTAL)
-				x = count_partial(n, count_total);
+				x = count_partial(n, NULL, count_total);
 			else if (flags & SO_OBJECTS)
-				x = count_partial(n, count_inuse);
+				x = count_partial(n, NULL, count_inuse);
 			else
 				x = n->nr_partial;
 			total += x;
@@ -5273,6 +5278,8 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 	unsigned long nr_slabs = 0;
 	unsigned long nr_objs = 0;
 	unsigned long nr_free = 0;
+	unsigned long nr_inactive = 0;
+	unsigned long nr_inactive_slabs = 0;
 	int node;
 
 	for_each_online_node(node) {
@@ -5284,12 +5291,13 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 		nr_partials += n->nr_partial;
 		nr_slabs += atomic_long_read(&n->nr_slabs);
 		nr_objs += atomic_long_read(&n->total_objects);
-		nr_free += count_partial(n, count_free);
+		nr_free += count_partial(n, &nr_inactive, count_free);
+		nr_inactive_slabs += nr_inactive;
 	}
 
 	sinfo->active_objs = nr_objs - nr_free;
 	sinfo->num_objs = nr_objs;
-	sinfo->active_slabs = nr_slabs;
+	sinfo->active_slabs = nr_slabs - nr_inactive_slabs;
 	sinfo->num_slabs = nr_slabs;
 	sinfo->objects_per_slab = oo_objects(s->oo);
 	sinfo->cache_order = oo_order(s->oo);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

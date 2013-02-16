Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 6902B6B00B6
	for <linux-mm@kvack.org>; Sat, 16 Feb 2013 11:27:52 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so1024750pbc.31
        for <linux-mm@kvack.org>; Sat, 16 Feb 2013 08:27:51 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH 2/2] mm: protect si_meminfo() and si_meminfo_node() from memory hotplug operations
Date: Sun, 17 Feb 2013 00:27:26 +0800
Message-Id: <1361032046-1725-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1361032046-1725-1-git-send-email-jiang.liu@huawei.com>
References: <1361032046-1725-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com
Cc: Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

There's typical usage of si_meminfo as below:
	si_meminfo(&si);
	threshold = si->totalram - si.totalhigh;

It may cause underflow if memory hotplug races with si_meminfo() because
there's no mechanism to protect si_meminfo() from memory hotplug
operations. And some callers expects that si_meminfo() is a lightweight
operations. So introduce a lightweight mechanism to protect si_meminfo()
from memory hotplug operations.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/page_alloc.c |   24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6884dc5..5cf03d4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2831,18 +2831,34 @@ static inline void show_node(struct zone *zone)
 void si_meminfo(struct sysinfo *val)
 {
 	int nid;
-	unsigned long present_pages = 0;
+	unsigned long present_pages;
 
+	val->sharedram = 0;
+	val->mem_unit = PAGE_SIZE;
+
+restart:
+	present_pages = 0;
 	for_each_node_state(nid, N_MEMORY)
 		present_pages += node_present_pages(nid);
 
 	val->totalram = present_pages;
-	val->sharedram = 0;
 	val->freeram = global_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
 	val->totalhigh = totalhigh_pages;
 	val->freehigh = nr_free_highpages();
-	val->mem_unit = PAGE_SIZE;
+
+	/*
+	 * si_meminfo() may generate invalid results because it isn't protected
+	 * from memory hotplug operaitons. And some callers expect that it's an
+	 * lightweigh operation. So provide minimal protections without heavy
+	 * overhead.
+	 */
+	if (val->totalram < val->freeram ||
+	    val->totalram < val->bufferram ||
+	    val->totalram < val->totalhigh ||
+	    val->totalhigh < val->freehigh ||
+	    val->freeram < val->freehigh)
+		goto restart;
 }
 
 EXPORT_SYMBOL(si_meminfo);
@@ -2854,6 +2870,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	unsigned long managed_pages = 0;
 	pg_data_t *pgdat = NODE_DATA(nid);
 
+	lock_memory_hotplug();
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 
@@ -2874,6 +2891,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	val->freehigh = 0;
 #endif
 	val->mem_unit = PAGE_SIZE;
+	unlock_memory_hotplug();
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

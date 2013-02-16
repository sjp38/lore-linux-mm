Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C223B6B00B5
	for <linux-mm@kvack.org>; Sat, 16 Feb 2013 11:27:48 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz10so2188609pad.7
        for <linux-mm@kvack.org>; Sat, 16 Feb 2013 08:27:47 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH 1/2] vm: add 'MemManaged' field to /proc/meminfo and /sys/.../nodex/meminfo
Date: Sun, 17 Feb 2013 00:27:25 +0800
Message-Id: <1361032046-1725-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com
Cc: Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

As reported by https://bugzilla.kernel.org/show_bug.cgi?id=53501,
"MemTotal" from /proc/meminfo means memory pages managed by the buddy
system (managed_pages), but "MemTotal" from /sys/.../node/nodex/meminfo
means phsical pages present (present_pages) within the NUMA node.
There's a difference between managed_pages and present_pages due to
bootmem allocator and reserved pages.

So introduce a new field "MemManaged" to /sys/.../nodex/meminfo and
/proc/meminfo, so that:
MemTotal = present_pages
MemManaged = managed_pages = present_pages - reserved_pages

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Reported-by: sworddragon2@aol.com
---
Hi Andrew and David,
	How about these draft patches? It just passes compilation. If you
are OK with them, we will conduct tests tomorrow.
	Regards!
	Gerry
---
 drivers/base/node.c |    2 ++
 fs/proc/meminfo.c   |    2 ++
 mm/page_alloc.c     |   19 ++++++++++++++++++-
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index fac124a..6508c4d 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -66,6 +66,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 	si_meminfo_node(&i, nid);
 	n = sprintf(buf,
 		       "Node %d MemTotal:       %8lu kB\n"
+		       "Node %d MemManaged:     %8lu kB\n"
 		       "Node %d MemFree:        %8lu kB\n"
 		       "Node %d MemUsed:        %8lu kB\n"
 		       "Node %d Active:         %8lu kB\n"
@@ -77,6 +78,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d Unevictable:    %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n",
 		       nid, K(i.totalram),
+		       nid, K(i.sharedram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
 		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 80e4645..5d58cbb 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -54,6 +54,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	 */
 	seq_printf(m,
 		"MemTotal:       %8lu kB\n"
+		"MemManaged:     %8lu kB\n"
 		"MemFree:        %8lu kB\n"
 		"Buffers:        %8lu kB\n"
 		"Cached:         %8lu kB\n"
@@ -106,6 +107,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 		,
 		K(i.totalram),
+		K(totalram_pages),
 		K(i.freeram),
 		K(i.bufferram),
 		K(cached),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 595e655..6884dc5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2830,7 +2830,13 @@ static inline void show_node(struct zone *zone)
 
 void si_meminfo(struct sysinfo *val)
 {
-	val->totalram = totalram_pages;
+	int nid;
+	unsigned long present_pages = 0;
+
+	for_each_node_state(nid, N_MEMORY)
+		present_pages += node_present_pages(nid);
+
+	val->totalram = present_pages;
 	val->sharedram = 0;
 	val->freeram = global_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
@@ -2844,8 +2850,19 @@ EXPORT_SYMBOL(si_meminfo);
 #ifdef CONFIG_NUMA
 void si_meminfo_node(struct sysinfo *val, int nid)
 {
+	int zone_type;
+	unsigned long managed_pages = 0;
 	pg_data_t *pgdat = NODE_DATA(nid);
 
+	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
+		managed_pages += pgdat->node_zones[zone_type].managed_pages;
+
+	/*
+	 * Ugly hack: struct sysinfo is exported to userspace and there's no
+	 * space available for a new field "managedram", so reuse field
+	 * "sharedram".
+	 */
+	val->sharedram = managed_pages;
 	val->totalram = pgdat->node_present_pages;
 	val->freeram = node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

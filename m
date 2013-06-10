Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 9D0B46B0032
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 07:16:33 -0400 (EDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MO600K7SCMYIA70@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 10 Jun 2013 20:16:31 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Subject: [PATCH] memcg: Add force_reclaim to reclaim tasks' memory in memcg.
Date: Mon, 10 Jun 2013 20:16:31 +0900
Message-id: <021801ce65cb$f5b0bc50$e11234f0$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: 'Kyungmin Park' <kyungmin.park@samsung.com>

These days, platforms tend to manage memory on low memory state
like andloid's lowmemory killer. These platforms might want to
reclaim memory from background tasks as well as kill victims
to guarantee free memory at use space level. This patch provides
an interface to reclaim a given memcg. After platform's low memory
handler moves tasks that the platform wants to reclaim to
a memcg and decides how many pages should be reclaimed, it can
reclaim the pages from the tasks by writing the number of pages
at memory.force_reclaim.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/memcontrol.c |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 010d6c1..21819c9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4980,6 +4980,28 @@ static int mem_cgroup_force_empty_write(struct cgroup
*cont, unsigned int event)
 	return ret;
 }
 
+static int mem_cgroup_force_reclaim(struct cgroup *cont, struct cftype
*cft, u64 val)
+{
+
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	unsigned long nr_to_reclaim = val;
+	unsigned long total = 0;
+	int loop;
+
+	for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
+		total += try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
false);
+
+		/*
+		 * If nothing was reclaimed after two attempts, there
+		 * may be no reclaimable pages in this hierarchy.
+		 * If more than nr_to_reclaim pages were already reclaimed,
+		 * finish force reclaim.
+		 */
+		if (loop && (!total || total > nr_to_reclaim))
+			break;
+	}
+	return total;
+}
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype
*cft)
 {
@@ -5938,6 +5960,10 @@ static struct cftype mem_cgroup_files[] = {
 		.trigger = mem_cgroup_force_empty_write,
 	},
 	{
+		.name = "force_reclaim",
+		.write_u64 = mem_cgroup_force_reclaim,
+	},
+	{
 		.name = "use_hierarchy",
 		.flags = CFTYPE_INSANE,
 		.write_u64 = mem_cgroup_hierarchy_write,
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

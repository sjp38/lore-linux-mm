Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 30B946B0055
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 20:23:52 -0500 (EST)
Date: Tue, 23 Dec 2008 01:24:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH mmotm] memcg: avoid reclaim_stat oops when disabled
Message-ID: <Pine.LNX.4.64.0812230116210.20371@blonde.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_get_reclaim_stat_from_page() oopses in page_cgroup_zoneinfo()
when you boot with cgroup_disabled=memory: it needs to check for that.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Follow memcg-add-zone_reclaim_stat-reclaim-stat-trivial-fixes.patch

 mm/memcontrol.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

--- mmotm/mm/memcontrol.c	2008-12-16 18:05:31.000000000 +0000
+++ fixed/mm/memcontrol.c	2008-12-16 19:30:02.000000000 +0000
@@ -496,9 +496,14 @@ struct zone_reclaim_stat *mem_cgroup_get
 struct zone_reclaim_stat *
 mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 {
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
+	struct page_cgroup *pc;
+	struct mem_cgroup_per_zone *mz;
 
+	if (mem_cgroup_disabled())
+		return NULL;
+
+	pc = lookup_page_cgroup(page);
+	mz = page_cgroup_zoneinfo(pc);
 	if (!mz)
 		return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

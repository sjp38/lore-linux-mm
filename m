Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 432566B0102
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:57 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:56 -0800 (PST)
Subject: [PATCH v2 21/22] mm: free lruvec in memcgroup via rcu
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:54 +0400
Message-ID: <20120220172354.22196.56006.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is required for splitting lru_lock into per-lruvec pieces.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/memcontrol.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 69763da..eb024c1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -148,6 +148,7 @@ struct mem_cgroup_per_zone {
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
+	struct rcu_head		rcu_head;
 };
 
 struct mem_cgroup_lru_info {
@@ -4657,18 +4658,27 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	return 0;
 }
 
+static void free_pn_rcu(struct rcu_head *rcu_head)
+{
+       struct mem_cgroup_per_node *pn;
+       int zone;
+
+       pn = container_of(rcu_head, struct mem_cgroup_per_node, rcu_head);
+
+       for (zone = 0; zone < MAX_NR_ZONES; zone++)
+	       wait_lruvec_unlock(&pn->zoneinfo[zone].lruvec);
+
+       kfree(pn);
+}
+
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn = memcg->info.nodeinfo[node];
-	int zone;
 
 	if (!pn)
 		return;
 
-	for (zone = 0; zone < MAX_NR_ZONES; zone++)
-		wait_lruvec_unlock(&pn->zoneinfo[zone].lruvec);
-
-	kfree(pn);
+	call_rcu(&pn->rcu_head, free_pn_rcu);
 }
 
 static struct mem_cgroup *mem_cgroup_alloc(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

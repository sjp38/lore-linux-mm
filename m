Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B0276B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 08:27:47 -0400 (EDT)
Received: by bwz10 with SMTP id 10so682891bwz.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 05:27:45 -0700 (PDT)
From: "Kirill A. Shutsemov" <kirill@shutemov.name>
Subject: [BUGFIX][PATCH] memcg: fix thresholds with use_hierarchy == 1
Date: Wed, 29 Sep 2010 15:27:25 +0300
Message-Id: <1285763245-19408-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

From: Kirill A. Shutemov <kirill@shutemov.name>

We need to check parent's thresholds if parent has use_hierarchy == 1 to
be sure that parent's threshold events will be triggered even if parent
itself is not active (no MEM_CGROUP_EVENTS).

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3eed583..196f710 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3587,9 +3587,20 @@ unlock:
 
 static void mem_cgroup_threshold(struct mem_cgroup *memcg)
 {
-	__mem_cgroup_threshold(memcg, false);
-	if (do_swap_account)
-		__mem_cgroup_threshold(memcg, true);
+	struct cgroup *parent;
+
+	while (1) {
+		__mem_cgroup_threshold(memcg, false);
+		if (do_swap_account)
+			__mem_cgroup_threshold(memcg, true);
+
+		parent = memcg->css.cgroup->parent;
+		if (!parent)
+			break;
+		memcg = mem_cgroup_from_cont(parent);
+		if (!memcg->use_hierarchy)
+			break;
+	}
 }
 
 static int compare_thresholds(const void *a, const void *b)
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

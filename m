Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5F6796B004A
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 06:16:49 -0400 (EDT)
Received: by bwz10 with SMTP id 10so1802043bwz.14
        for <linux-mm@kvack.org>; Thu, 30 Sep 2010 03:16:46 -0700 (PDT)
From: "Kirill A. Shutsemov" <kirill@shutemov.name>
Subject: [BUGFIX][PATCH v2] memcg: fix thresholds with use_hierarchy == 1
Date: Thu, 30 Sep 2010 13:16:32 +0300
Message-Id: <1285841792-23664-1-git-send-email-kirill@shutemov.name>
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
 mm/memcontrol.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3eed583..df40eaf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3587,9 +3587,13 @@ unlock:
 
 static void mem_cgroup_threshold(struct mem_cgroup *memcg)
 {
-	__mem_cgroup_threshold(memcg, false);
-	if (do_swap_account)
-		__mem_cgroup_threshold(memcg, true);
+	while (memcg) {
+		__mem_cgroup_threshold(memcg, false);
+		if (do_swap_account)
+			__mem_cgroup_threshold(memcg, true);
+
+		memcg =  parent_mem_cgroup(memcg);
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

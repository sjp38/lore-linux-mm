Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id A88286B0032
	for <linux-mm@kvack.org>; Sat,  6 Dec 2014 11:04:56 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id q107so1840320qgd.35
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 08:04:56 -0800 (PST)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id j7si18576370qaf.48.2014.12.06.08.04.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 06 Dec 2014 08:04:55 -0800 (PST)
Received: by mail-qg0-f49.google.com with SMTP id a108so1817156qge.22
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 08:04:55 -0800 (PST)
From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] mm/memcontrol.c: fix the placement of 'MAX_NUMNODES > 1' if block
Date: Sat,  6 Dec 2014 14:04:43 -0200
Message-Id: <1417881883-18324-1-git-send-email-festevam@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Fabio Estevam <fabio.estevam@freescale.com>

From: Fabio Estevam <fabio.estevam@freescale.com>

When building ARM allmodconfig we get the following build warning:

mm/memcontrol.c:1629:13: warning: 'test_mem_cgroup_node_reclaimable' defined but not used [-Wunused-function]

As test_mem_cgroup_node_reclaimable() is only used inside the
'#if MAX_NUMNODES > 1' block, we should also place its definition there as well.

Reported-by: Olof's autobuilder <build@lixom.net>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c6ac50e..d538b08 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1616,6 +1616,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			 NULL, "Memory cgroup out of memory");
 }
 
+#if MAX_NUMNODES > 1
 /**
  * test_mem_cgroup_node_reclaimable
  * @memcg: the target memcg
@@ -1638,7 +1639,6 @@ static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 	return false;
 
 }
-#if MAX_NUMNODES > 1
 
 /*
  * Always updating the nodemask is not very good - even if we have an empty
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

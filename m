Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 910156B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 17:26:09 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1516458pab.7
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 14:26:09 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id km8si49458549pdb.221.2014.12.05.14.26.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 14:26:08 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so1519812pad.13
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 14:26:07 -0800 (PST)
Message-ID: <5482316D.607@gmail.com>
Date: Sat, 06 Dec 2014 06:27:57 +0800
From: Chen Gang <gang.chen.5i5j@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: memcontrol: Skip test_mem_cgroup_node_reclaimable() when
 no MAX_NUMNODES or not more than 1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz
Cc: cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

test_mem_cgroup_node_reclaimable() is only used when "MAX_NUMNODES > 1",
so move it into related quote.

The related warning (with allmodconfig under parisc):

    CC      mm/memcontrol.o
  mm/memcontrol.c:1629:13: warning: 'test_mem_cgroup_node_reclaimable' defined but not used [-Wunused-function]
   static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
               ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
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
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

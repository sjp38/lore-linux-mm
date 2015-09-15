Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 247DD6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:06:07 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so70615152qkf.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 05:06:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d10si16622233qgd.70.2015.09.15.05.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 05:06:06 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH] mm: memcontrol: fix order calculation in try_charge()
Date: Tue, 15 Sep 2015 14:05:57 +0200
Message-Id: <1442318757-7141-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit <6539cc05386> (mm: memcontrol: fold mem_cgroup_do_charge()),
the order to pass to mem_cgroup_oom() is calculated by passing the number
of pages to get_order() instead of the expected  size in bytes. AFAICT,
it only affects the value displayed in the oom warning message.
This patch fix this.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/memcontrol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1742a2d..91bf094 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2032,7 +2032,8 @@ retry:
 
 	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
 
-	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(nr_pages));
+	mem_cgroup_oom(mem_over_limit, gfp_mask,
+		       get_order(nr_pages * PAGE_SIZE));
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

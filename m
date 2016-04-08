Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7254C6B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 18:49:15 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id f198so80273148wme.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 15:49:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u129si5066602wmd.50.2016.04.08.15.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 15:49:14 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: let v2 cgroups follow changes in system swappiness
Date: Fri,  8 Apr 2016 18:49:04 -0400
Message-Id: <1460155744-15942-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Cgroup2 currently doesn't have a per-cgroup swappiness setting. We
might want to add one later - that's a different discussion - but
until we do, the cgroups should always follow the system setting.
Otherwise it will be unchangeably set to whatever the ancestor
inherited from the system setting at the time of cgroup creation.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@vger.kernel.org # 4.5
---
 include/linux/swap.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index e58dba3..15d17c8 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -534,6 +534,10 @@ static inline swp_entry_t get_swap_page(void)
 #ifdef CONFIG_MEMCG
 static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
+	/* Cgroup2 doesn't have per-cgroup swappiness */
+	if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		return vm_swappiness;
+
 	/* root ? */
 	if (mem_cgroup_disabled() || !memcg->css.parent)
 		return vm_swappiness;
-- 
2.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

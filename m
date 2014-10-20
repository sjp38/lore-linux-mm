Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id DA2CC6B006E
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:17:47 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gf13so4601219lab.29
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:17:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id rs4si14815503lbb.12.2014.10.20.08.17.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:17:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: micro-optimize mem_cgroup_update_page_stat()
Date: Mon, 20 Oct 2014 11:17:39 -0400
Message-Id: <1413818259-10913-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Do not look up the page_cgroup when the memory controller is
runtime-disabled, but do assert that the locking protocol is followed
under DEBUG_VM regardless.  Also remove the unused flags variable.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 76892eb89d26..bea3fddb3372 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2177,13 +2177,14 @@ void mem_cgroup_update_page_stat(struct page *page,
 				 enum mem_cgroup_stat_index idx, int val)
 {
 	struct mem_cgroup *memcg;
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-	unsigned long uninitialized_var(flags);
+	struct page_cgroup *pc;
+
+	VM_BUG_ON(!rcu_read_lock_held());
 
 	if (mem_cgroup_disabled())
 		return;
 
-	VM_BUG_ON(!rcu_read_lock_held());
+	pc = lookup_page_cgroup(page);
 	memcg = pc->mem_cgroup;
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

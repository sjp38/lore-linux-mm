Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2E96B0085
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:31:47 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id b6so951740lbj.3
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:31:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dv6si2892270lbc.52.2014.10.23.07.31.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:31:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: uncharge pages on swapout fix
Date: Thu, 23 Oct 2014 10:31:40 -0400
Message-Id: <1414074700-13995-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Vladimir notes:

> > +   local_irq_disable();
> > +   mem_cgroup_charge_statistics(memcg, page, -1);
> > +   memcg_check_events(memcg, page);
> > +   local_irq_enable();
>
> AFAICT mem_cgroup_swapout() is called under mapping->tree_lock with irqs
> disabled, so we should use irq_save/restore here.

Simply remove the irq-disabling altogether and rely on the caller
holding the mapping->tree_lock for now.

Reported-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

For "mm: memcontrol: uncharge pages on swapout" in -mm.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae9b630e928b..09fece0eb9f1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5777,10 +5777,11 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
 
-	local_irq_disable();
+	/* XXX: caller holds IRQ-safe mapping->tree_lock */
+	VM_BUG_ON(!irqs_disabled());
+
 	mem_cgroup_charge_statistics(memcg, page, -1);
 	memcg_check_events(memcg, page);
-	local_irq_enable();
 }
 
 /**
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

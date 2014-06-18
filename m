Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 990836B0055
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:41:12 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so1369148wgh.4
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:41:12 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k9si4131267wia.107.2014.06.18.13.41.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:41:11 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 11/13] mm: memcontrol: do not acquire page_cgroup lock for kmem pages
Date: Wed, 18 Jun 2014 16:40:43 -0400
Message-Id: <1403124045-24361-12-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Kmem page charging and uncharging is serialized by means of exclusive
access to the page.  Do not take the page_cgroup lock and don't set
pc->flags atomically.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 199bd50359ad..5e7f8e7dc0d8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3407,12 +3407,13 @@ void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 		return;
 	}
-
+	/*
+	 * The page is freshly allocated and not visible to any
+	 * outside callers yet.  Set up pc non-atomically.
+	 */
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
 	pc->mem_cgroup = memcg;
-	SetPageCgroupUsed(pc);
-	unlock_page_cgroup(pc);
+	pc->flags = PCG_USED;
 }
 
 void __memcg_kmem_uncharge_pages(struct page *page, int order)
@@ -3422,19 +3423,11 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 
 
 	pc = lookup_page_cgroup(page);
-	/*
-	 * Fast unlocked return. Theoretically might have changed, have to
-	 * check again after locking.
-	 */
 	if (!PageCgroupUsed(pc))
 		return;
 
-	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
-		ClearPageCgroupUsed(pc);
-	}
-	unlock_page_cgroup(pc);
+	memcg = pc->mem_cgroup;
+	pc->flags = 0;
 
 	/*
 	 * We trust that only if there is a memcg associated with the page, it
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

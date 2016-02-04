Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEC24403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 15:08:44 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id r129so228629226wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 12:08:44 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ci1si19725846wjc.27.2016.02.04.12.08.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 12:08:43 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/2] mm: memcontrol: drop unnecessary lru locking from mem_cgroup_migrate()
Date: Thu,  4 Feb 2016 15:07:47 -0500
Message-Id: <1454616467-8994-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
References: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Mateusz Guzik <mguzik@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Migration accounting in the memory controller used to have to handle
both oldpage and newpage being on the LRU already; fuse's page cache
replacement used to pass a recycled newpage that had been uncharged
but not freed and removed from the LRU, and the memcg migration code
used to uncharge oldpage to "pass on" the existing charge to newpage.

Nowadays, pages are no longer uncharged when truncated from the page
cache, but rather only at free time, so if a LRU page is recycled in
page cache replacement it'll also still be charged. And we bail out of
the charge transfer altogether in that case. Tell commit_charge() that
we know newpage is not on the LRU, to avoid taking the zone->lru_lock
unnecessarily from the migration path.

But also, oldpage is no longer uncharged inside migration. We only use
oldpage for its page->mem_cgroup and page size, so we don't care about
its LRU state anymore either. Remove any mention from the kernel doc.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Suggested-by: Hugh Dickins <hughd@google.com>
---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e4199830456..42882c1e7fce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5489,7 +5489,6 @@ void mem_cgroup_uncharge_list(struct list_head *page_list)
  * be uncharged upon free.
  *
  * Both pages must be locked, @newpage->mapping must be set up.
- * Either or both pages might be on the LRU already.
  */
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 {
@@ -5524,7 +5523,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
 		page_counter_charge(&memcg->memsw, nr_pages);
 	css_get_many(&memcg->css, nr_pages);
 
-	commit_charge(newpage, memcg, true);
+	commit_charge(newpage, memcg, false);
 
 	local_irq_disable();
 	mem_cgroup_charge_statistics(memcg, newpage, compound, nr_pages);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

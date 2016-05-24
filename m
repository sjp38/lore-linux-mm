Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63F256B0265
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:49:48 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id q17so5205254lbn.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:49:48 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0115.outbound.protection.outlook.com. [104.47.1.115])
        by mx.google.com with ESMTPS id o16si22215126wme.6.2016.05.24.01.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:49:44 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RESEND 5/8] mm: memcontrol: teach uncharge_list to deal with kmem pages
Date: Tue, 24 May 2016 11:49:27 +0300
Message-ID: <18d5c09e97f80074ed25b97a7d0f32b95d875717.1464079538.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1464079537.git.vdavydov@virtuozzo.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Page table pages are batched-freed in release_pages on most
architectures. If we want to charge them to kmemcg (this is what is done
later in this series), we need to teach mem_cgroup_uncharge_list to
handle kmem pages.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 42 ++++++++++++++++++++++++------------------
 1 file changed, 24 insertions(+), 18 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 482b4a0c97e4..89a421ee4713 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5432,15 +5432,18 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 
 static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 			   unsigned long nr_anon, unsigned long nr_file,
-			   unsigned long nr_huge, struct page *dummy_page)
+			   unsigned long nr_huge, unsigned long nr_kmem,
+			   struct page *dummy_page)
 {
-	unsigned long nr_pages = nr_anon + nr_file;
+	unsigned long nr_pages = nr_anon + nr_file + nr_kmem;
 	unsigned long flags;
 
 	if (!mem_cgroup_is_root(memcg)) {
 		page_counter_uncharge(&memcg->memory, nr_pages);
 		if (do_memsw_account())
 			page_counter_uncharge(&memcg->memsw, nr_pages);
+		if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && nr_kmem)
+			page_counter_uncharge(&memcg->kmem, nr_kmem);
 		memcg_oom_recover(memcg);
 	}
 
@@ -5463,6 +5466,7 @@ static void uncharge_list(struct list_head *page_list)
 	unsigned long nr_anon = 0;
 	unsigned long nr_file = 0;
 	unsigned long nr_huge = 0;
+	unsigned long nr_kmem = 0;
 	unsigned long pgpgout = 0;
 	struct list_head *next;
 	struct page *page;
@@ -5473,8 +5477,6 @@ static void uncharge_list(struct list_head *page_list)
 	 */
 	next = page_list->next;
 	do {
-		unsigned int nr_pages = 1;
-
 		page = list_entry(next, struct page, lru);
 		next = page->lru.next;
 
@@ -5493,31 +5495,35 @@ static void uncharge_list(struct list_head *page_list)
 		if (memcg != page->mem_cgroup) {
 			if (memcg) {
 				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-					       nr_huge, page);
-				pgpgout = nr_anon = nr_file = nr_huge = 0;
+					       nr_huge, nr_kmem, page);
+				pgpgout = nr_anon = nr_file =
+					nr_huge = nr_kmem = 0;
 			}
 			memcg = page->mem_cgroup;
 		}
 
-		if (PageTransHuge(page)) {
-			nr_pages <<= compound_order(page);
-			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-			nr_huge += nr_pages;
-		}
+		if (!PageKmemcg(page)) {
+			unsigned int nr_pages = 1;
 
-		if (PageAnon(page))
-			nr_anon += nr_pages;
-		else
-			nr_file += nr_pages;
+			if (PageTransHuge(page)) {
+				nr_pages <<= compound_order(page);
+				VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+				nr_huge += nr_pages;
+			}
+			if (PageAnon(page))
+				nr_anon += nr_pages;
+			else
+				nr_file += nr_pages;
+			pgpgout++;
+		} else
+			nr_kmem += 1 << compound_order(page);
 
 		page->mem_cgroup = NULL;
-
-		pgpgout++;
 	} while (next != page_list);
 
 	if (memcg)
 		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-			       nr_huge, page);
+			       nr_huge, nr_kmem, page);
 }
 
 /**
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

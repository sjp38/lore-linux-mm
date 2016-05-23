Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6EC828E2
	for <linux-mm@kvack.org>; Mon, 23 May 2016 06:20:49 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id u5so110993735igk.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 03:20:49 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0129.outbound.protection.outlook.com. [157.56.112.129])
        by mx.google.com with ESMTPS id h204si14404434oia.212.2016.05.23.03.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 03:20:45 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 5/8] mm: memcontrol: teach uncharge_list to deal with kmem pages
Date: Mon, 23 May 2016 13:20:26 +0300
Message-ID: <fb4b8ca7fc4570579ad7e8617cda539fbb447cf3.1463997354.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1463997354.git.vdavydov@virtuozzo.com>
References: <cover.1463997354.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC726B0259
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 06:46:19 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so32194088pab.3
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 03:46:19 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rf13si11812054pac.159.2015.09.26.03.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 03:46:18 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 3/5] memcg: teach uncharge_list to uncharge kmem pages
Date: Sat, 26 Sep 2015 13:45:55 +0300
Message-ID: <3046cc6283ee35c3b8b2b77c478f9bed9ca959e4.1443262808.git.vdavydov@parallels.com>
In-Reply-To: <cover.1443262808.git.vdavydov@parallels.com>
References: <cover.1443262808.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Page table pages are batched-freed in release_pages on most
architectures. If we want to charge them to kmemcg (this is what is done
later in this series), we need to teach mem_cgroup_uncharge_list to
handle kmem pages. With PageKmem helper introduced previously this is
trivial.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c | 21 ++++++++++++++-------
 mm/swap.c       |  3 +--
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ddaeba34e09..a61fe1604f49 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5420,15 +5420,18 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
 
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
 		if (do_swap_account)
 			page_counter_uncharge(&memcg->memsw, nr_pages);
+		if (nr_kmem)
+			page_counter_uncharge(&memcg->kmem, nr_kmem);
 		memcg_oom_recover(memcg);
 	}
 
@@ -5451,6 +5454,7 @@ static void uncharge_list(struct list_head *page_list)
 	unsigned long nr_anon = 0;
 	unsigned long nr_file = 0;
 	unsigned long nr_huge = 0;
+	unsigned long nr_kmem = 0;
 	unsigned long pgpgout = 0;
 	struct list_head *next;
 	struct page *page;
@@ -5477,19 +5481,22 @@ static void uncharge_list(struct list_head *page_list)
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
+		if (!PageKmem(page) && PageTransHuge(page)) {
 			nr_pages <<= compound_order(page);
 			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			nr_huge += nr_pages;
 		}
 
-		if (PageAnon(page))
+		if (PageKmem(page))
+			nr_kmem += 1 << compound_order(page);
+		else if (PageAnon(page))
 			nr_anon += nr_pages;
 		else
 			nr_file += nr_pages;
@@ -5501,7 +5508,7 @@ static void uncharge_list(struct list_head *page_list)
 
 	if (memcg)
 		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-			       nr_huge, page);
+			       nr_huge, nr_kmem, page);
 }
 
 /**
diff --git a/mm/swap.c b/mm/swap.c
index 8d8d03118a18..983f692a47fd 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -64,8 +64,7 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
-	if (!PageKmem(page))
-		mem_cgroup_uncharge(page);
+	mem_cgroup_uncharge(page);
 }
 
 static void __put_single_page(struct page *page)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

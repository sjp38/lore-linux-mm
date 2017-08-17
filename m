Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B39E6B039F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:12 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p48so26593232qtf.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b2si1853678qkc.206.2017.08.16.17.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:06:08 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 09/19] mm/memcontrol: allow to uncharge page without using page->lru field
Date: Wed, 16 Aug 2017 20:05:38 -0400
Message-Id: <20170817000548.32038-10-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

HMM pages (private or public device pages) are ZONE_DEVICE page and
thus you can not use page->lru fields of those pages. This patch
re-arrange the uncharge to allow single page to be uncharge without
modifying the lru field of the struct page.

There is no change to memcontrol logic, it is the same as it was
before this patch.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org
---
 mm/memcontrol.c | 168 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 92 insertions(+), 76 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index df6f63ee95d6..604fb3ca8028 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5533,48 +5533,102 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 	cancel_charge(memcg, nr_pages);
 }
 
-static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
-			   unsigned long nr_anon, unsigned long nr_file,
-			   unsigned long nr_kmem, unsigned long nr_huge,
-			   unsigned long nr_shmem, struct page *dummy_page)
+struct uncharge_gather {
+	struct mem_cgroup *memcg;
+	unsigned long pgpgout;
+	unsigned long nr_anon;
+	unsigned long nr_file;
+	unsigned long nr_kmem;
+	unsigned long nr_huge;
+	unsigned long nr_shmem;
+	struct page *dummy_page;
+};
+
+static inline void uncharge_gather_clear(struct uncharge_gather *ug)
 {
-	unsigned long nr_pages = nr_anon + nr_file + nr_kmem;
+	memset(ug, 0, sizeof(*ug));
+}
+
+static void uncharge_batch(const struct uncharge_gather *ug)
+{
+	unsigned long nr_pages = ug->nr_anon + ug->nr_file + ug->nr_kmem;
 	unsigned long flags;
 
-	if (!mem_cgroup_is_root(memcg)) {
-		page_counter_uncharge(&memcg->memory, nr_pages);
+	if (!mem_cgroup_is_root(ug->memcg)) {
+		page_counter_uncharge(&ug->memcg->memory, nr_pages);
 		if (do_memsw_account())
-			page_counter_uncharge(&memcg->memsw, nr_pages);
-		if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && nr_kmem)
-			page_counter_uncharge(&memcg->kmem, nr_kmem);
-		memcg_oom_recover(memcg);
+			page_counter_uncharge(&ug->memcg->memsw, nr_pages);
+		if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && ug->nr_kmem)
+			page_counter_uncharge(&ug->memcg->kmem, ug->nr_kmem);
+		memcg_oom_recover(ug->memcg);
 	}
 
 	local_irq_save(flags);
-	__this_cpu_sub(memcg->stat->count[MEMCG_RSS], nr_anon);
-	__this_cpu_sub(memcg->stat->count[MEMCG_CACHE], nr_file);
-	__this_cpu_sub(memcg->stat->count[MEMCG_RSS_HUGE], nr_huge);
-	__this_cpu_sub(memcg->stat->count[NR_SHMEM], nr_shmem);
-	__this_cpu_add(memcg->stat->events[PGPGOUT], pgpgout);
-	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
-	memcg_check_events(memcg, dummy_page);
+	__this_cpu_sub(ug->memcg->stat->count[MEMCG_RSS], ug->nr_anon);
+	__this_cpu_sub(ug->memcg->stat->count[MEMCG_CACHE], ug->nr_file);
+	__this_cpu_sub(ug->memcg->stat->count[MEMCG_RSS_HUGE], ug->nr_huge);
+	__this_cpu_sub(ug->memcg->stat->count[NR_SHMEM], ug->nr_shmem);
+	__this_cpu_add(ug->memcg->stat->events[PGPGOUT], ug->pgpgout);
+	__this_cpu_add(ug->memcg->stat->nr_page_events, nr_pages);
+	memcg_check_events(ug->memcg, ug->dummy_page);
 	local_irq_restore(flags);
 
-	if (!mem_cgroup_is_root(memcg))
-		css_put_many(&memcg->css, nr_pages);
+	if (!mem_cgroup_is_root(ug->memcg))
+		css_put_many(&ug->memcg->css, nr_pages);
+}
+
+static void uncharge_page(struct page *page, struct uncharge_gather *ug)
+{
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
+
+	if (!page->mem_cgroup)
+		return;
+
+	/*
+	 * Nobody should be changing or seriously looking at
+	 * page->mem_cgroup at this point, we have fully
+	 * exclusive access to the page.
+	 */
+
+	if (ug->memcg != page->mem_cgroup) {
+		if (ug->memcg) {
+			uncharge_batch(ug);
+			uncharge_gather_clear(ug);
+		}
+		ug->memcg = page->mem_cgroup;
+	}
+
+	if (!PageKmemcg(page)) {
+		unsigned int nr_pages = 1;
+
+		if (PageTransHuge(page)) {
+			nr_pages <<= compound_order(page);
+			ug->nr_huge += nr_pages;
+		}
+		if (PageAnon(page))
+			ug->nr_anon += nr_pages;
+		else {
+			ug->nr_file += nr_pages;
+			if (PageSwapBacked(page))
+				ug->nr_shmem += nr_pages;
+		}
+		ug->pgpgout++;
+	} else {
+		ug->nr_kmem += 1 << compound_order(page);
+		__ClearPageKmemcg(page);
+	}
+
+	ug->dummy_page = page;
+	page->mem_cgroup = NULL;
 }
 
 static void uncharge_list(struct list_head *page_list)
 {
-	struct mem_cgroup *memcg = NULL;
-	unsigned long nr_shmem = 0;
-	unsigned long nr_anon = 0;
-	unsigned long nr_file = 0;
-	unsigned long nr_huge = 0;
-	unsigned long nr_kmem = 0;
-	unsigned long pgpgout = 0;
+	struct uncharge_gather ug;
 	struct list_head *next;
-	struct page *page;
+
+	uncharge_gather_clear(&ug);
 
 	/*
 	 * Note that the list can be a single page->lru; hence the
@@ -5582,57 +5636,16 @@ static void uncharge_list(struct list_head *page_list)
 	 */
 	next = page_list->next;
 	do {
+		struct page *page;
+
 		page = list_entry(next, struct page, lru);
 		next = page->lru.next;
 
-		VM_BUG_ON_PAGE(PageLRU(page), page);
-		VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
-
-		if (!page->mem_cgroup)
-			continue;
-
-		/*
-		 * Nobody should be changing or seriously looking at
-		 * page->mem_cgroup at this point, we have fully
-		 * exclusive access to the page.
-		 */
-
-		if (memcg != page->mem_cgroup) {
-			if (memcg) {
-				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-					       nr_kmem, nr_huge, nr_shmem, page);
-				pgpgout = nr_anon = nr_file = nr_kmem = 0;
-				nr_huge = nr_shmem = 0;
-			}
-			memcg = page->mem_cgroup;
-		}
-
-		if (!PageKmemcg(page)) {
-			unsigned int nr_pages = 1;
-
-			if (PageTransHuge(page)) {
-				nr_pages <<= compound_order(page);
-				nr_huge += nr_pages;
-			}
-			if (PageAnon(page))
-				nr_anon += nr_pages;
-			else {
-				nr_file += nr_pages;
-				if (PageSwapBacked(page))
-					nr_shmem += nr_pages;
-			}
-			pgpgout++;
-		} else {
-			nr_kmem += 1 << compound_order(page);
-			__ClearPageKmemcg(page);
-		}
-
-		page->mem_cgroup = NULL;
+		uncharge_page(page, &ug);
 	} while (next != page_list);
 
-	if (memcg)
-		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
-			       nr_kmem, nr_huge, nr_shmem, page);
+	if (ug.memcg)
+		uncharge_batch(&ug);
 }
 
 /**
@@ -5644,6 +5657,8 @@ static void uncharge_list(struct list_head *page_list)
  */
 void mem_cgroup_uncharge(struct page *page)
 {
+	struct uncharge_gather ug;
+
 	if (mem_cgroup_disabled())
 		return;
 
@@ -5651,8 +5666,9 @@ void mem_cgroup_uncharge(struct page *page)
 	if (!page->mem_cgroup)
 		return;
 
-	INIT_LIST_HEAD(&page->lru);
-	uncharge_list(&page->lru);
+	uncharge_gather_clear(&ug);
+	uncharge_page(page, &ug);
+	uncharge_batch(&ug);
 }
 
 /**
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 49B106B0259
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:50 -0500 (EST)
Received: by pfnn128 with SMTP id n128so46957072pfn.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:50 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 85si19875403pfl.178.2015.12.10.03.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:48 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 5/7] mm: vmscan: do not scan anon pages if memcg swap limit is hit
Date: Thu, 10 Dec 2015 14:39:18 +0300
Message-ID: <04c56c92f57c90a1f626546fcfade747fbfa9ec5.1449742561.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1449742560.git.vdavydov@virtuozzo.com>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We don't scan anonymous memory if we ran out of swap, neither should we
do it in case memcg swap limit is hit, because swap out is impossible
anyway.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/swap.h |  6 ++++++
 mm/memcontrol.c      | 13 +++++++++++++
 mm/vmscan.c          |  2 +-
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 66ea62cf256d..e3344d8ca2e9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -551,6 +551,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
 extern int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry);
 extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
+extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
 #else
 static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
@@ -564,6 +565,11 @@ static inline int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
 static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
 {
 }
+
+static inline long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
+{
+	return get_nr_swap_pages();
+}
 #endif
 
 #endif /* __KERNEL__*/
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9d10e2819ec4..2ee823d62f80 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5826,6 +5826,19 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 	rcu_read_unlock();
 }
 
+long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
+{
+	long nr_swap_pages = get_nr_swap_pages();
+
+	if (!do_swap_account)
+		return nr_swap_pages;
+	for (; memcg != root_mem_cgroup; memcg = parent_mem_cgroup(memcg))
+		nr_swap_pages = min_t(long, nr_swap_pages,
+				      READ_ONCE(memcg->swap.limit) -
+				      page_counter_read(&memcg->swap));
+	return nr_swap_pages;
+}
+
 /* for remember boot option*/
 #ifdef CONFIG_MEMCG_SWAP_ENABLED
 static int really_do_swap_account __initdata = 1;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b220e6cda25d..ab52d865d922 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1995,7 +1995,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		force_scan = true;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
+	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

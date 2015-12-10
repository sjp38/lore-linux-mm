Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 233EF6B0257
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:45 -0500 (EST)
Received: by pabur14 with SMTP id ur14so46639265pab.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:44 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wh2si19850092pac.170.2015.12.10.03.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:44 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 4/7] swap.h: move memcg related stuff to the end of the file
Date: Thu, 10 Dec 2015 14:39:17 +0300
Message-ID: <72ad884dba8e3a9b13935bc0f27b2e46681c53c0.1449742561.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1449742560.git.vdavydov@virtuozzo.com>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The following patches will add more functions to the memcg section of
include/linux/swap.h. Some of them will need values defined below the
current location of the section. So let's move the section to the end of
the file. No functional changes intended.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/swap.h | 68 ++++++++++++++++++++++++++++------------------------
 1 file changed, 37 insertions(+), 31 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index f4b3ccdcba91..66ea62cf256d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -350,38 +350,7 @@ extern void check_move_unevictable_pages(struct page **, int nr_pages);
 
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
-#ifdef CONFIG_MEMCG
-static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
-{
-	/* root ? */
-	if (mem_cgroup_disabled() || !memcg->css.parent)
-		return vm_swappiness;
-
-	return memcg->swappiness;
-}
 
-#else
-static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
-{
-	return vm_swappiness;
-}
-#endif
-#ifdef CONFIG_MEMCG_SWAP
-extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
-extern int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry);
-extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
-#else
-static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
-{
-}
-static inline int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
-{
-	return 0;
-}
-static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
-{
-}
-#endif
 #ifdef CONFIG_SWAP
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
@@ -560,5 +529,42 @@ static inline swp_entry_t get_swap_page(void)
 }
 
 #endif /* CONFIG_SWAP */
+
+#ifdef CONFIG_MEMCG
+static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
+{
+	/* root ? */
+	if (mem_cgroup_disabled() || !memcg->css.parent)
+		return vm_swappiness;
+
+	return memcg->swappiness;
+}
+
+#else
+static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
+{
+	return vm_swappiness;
+}
+#endif
+
+#ifdef CONFIG_MEMCG_SWAP
+extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
+extern int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry);
+extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
+#else
+static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
+{
+}
+
+static inline int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
+{
+}
+#endif
+
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

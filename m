Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id EF2B46B010E
	for <linux-mm@kvack.org>; Sat,  1 Nov 2014 23:16:06 -0400 (EDT)
Received: by mail-wg0-f54.google.com with SMTP id n12so3490154wgh.41
        for <linux-mm@kvack.org>; Sat, 01 Nov 2014 20:16:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id yu10si6523419wjc.112.2014.11.01.20.16.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Nov 2014 20:16:06 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: move page->mem_cgroup bad page handling into generic code
Date: Sat,  1 Nov 2014 23:15:56 -0400
Message-Id: <1414898156-4741-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Now that the external page_cgroup data structure and its lookup is
gone, let the generic bad_page() check for page->mem_cgroup sanity.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  4 ----
 mm/debug.c                 |  5 ++++-
 mm/memcontrol.c            | 15 ---------------
 mm/page_alloc.c            | 12 ++++++++----
 4 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index dafba59b31b4..e789551d4db0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -173,10 +173,6 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
-#ifdef CONFIG_DEBUG_VM
-bool mem_cgroup_bad_page_check(struct page *page);
-void mem_cgroup_print_bad_page(struct page *page);
-#endif
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
diff --git a/mm/debug.c b/mm/debug.c
index 5ce45c9a29b5..0e58f3211f89 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -95,7 +95,10 @@ void dump_page_badflags(struct page *page, const char *reason,
 		dump_flags(page->flags & badflags,
 				pageflag_names, ARRAY_SIZE(pageflag_names));
 	}
-	mem_cgroup_print_bad_page(page);
+#ifdef CONFIG_MEMCG
+	if (page->mem_cgroup)
+		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
+#endif
 }
 
 void dump_page(struct page *page, const char *reason)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fbb41a170eae..3645641513a1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3157,21 +3157,6 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #endif
 
-#ifdef CONFIG_DEBUG_VM
-bool mem_cgroup_bad_page_check(struct page *page)
-{
-	if (mem_cgroup_disabled())
-		return false;
-
-	return page->mem_cgroup != NULL;
-}
-
-void mem_cgroup_print_bad_page(struct page *page)
-{
-	pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
-}
-#endif
-
 static DEFINE_MUTEX(memcg_limit_mutex);
 
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6a952237a677..161da09fcda2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -653,8 +653,10 @@ static inline int free_pages_check(struct page *page)
 		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
 		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
 	}
-	if (unlikely(mem_cgroup_bad_page_check(page)))
-		bad_reason = "cgroup check failed";
+#ifdef CONFIG_MEMCG
+	if (unlikely(page->mem_cgroup))
+		bad_reason = "page still charged to cgroup";
+#endif
 	if (unlikely(bad_reason)) {
 		bad_page(page, bad_reason, bad_flags);
 		return 1;
@@ -920,8 +922,10 @@ static inline int check_new_page(struct page *page)
 		bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
 		bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
 	}
-	if (unlikely(mem_cgroup_bad_page_check(page)))
-		bad_reason = "cgroup check failed";
+#ifdef CONFIG_MEMCG
+	if (unlikely(page->mem_cgroup))
+		bad_reason = "page still charged to cgroup";
+#endif
 	if (unlikely(bad_reason)) {
 		bad_page(page, bad_reason, bad_flags);
 		return 1;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

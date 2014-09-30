Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id AF4626B0039
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:54:51 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id wo20so14112374obc.41
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 18:54:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c5si21670810obj.80.2014.09.29.18.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:54:50 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 2/5] mm: constify dump_page and friends
Date: Mon, 29 Sep 2014 21:47:16 -0400
Message-Id: <1412041639-23617-3-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>

Constify dump_page so that we could dump_page const pages, there is no
functional change here.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/memcontrol.h  | 8 ++++----
 include/linux/mm.h          | 2 +-
 include/linux/mmdebug.h     | 4 ++--
 include/linux/page_cgroup.h | 4 ++--
 mm/debug.c                  | 4 ++--
 mm/memcontrol.c             | 6 +++---
 mm/page_cgroup.c            | 4 ++--
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 19df5d8..534633f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -200,8 +200,8 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
 #ifdef CONFIG_DEBUG_VM
-bool mem_cgroup_bad_page_check(struct page *page);
-void mem_cgroup_print_bad_page(struct page *page);
+bool mem_cgroup_bad_page_check(const struct page *page);
+void mem_cgroup_print_bad_page(const struct page *page);
 #endif
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
@@ -373,13 +373,13 @@ void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 
 #if !defined(CONFIG_MEMCG) || !defined(CONFIG_DEBUG_VM)
 static inline bool
-mem_cgroup_bad_page_check(struct page *page)
+mem_cgroup_bad_page_check(const struct page *page)
 {
 	return false;
 }
 
 static inline void
-mem_cgroup_print_bad_page(struct page *page)
+mem_cgroup_print_bad_page(const struct page *page)
 {
 }
 #endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a91874b..0c13412 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -447,7 +447,7 @@ static inline void page_mapcount_reset(struct page *page)
 	atomic_set(&(page)->_mapcount, -1);
 }
 
-static inline int page_mapcount(struct page *page)
+static inline int page_mapcount(const struct page *page)
 {
 	return atomic_read(&(page)->_mapcount) + 1;
 }
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 877ef22..7d05557 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -7,8 +7,8 @@ struct page;
 struct vm_area_struct;
 struct mm_struct;
 
-extern void dump_page(struct page *page, const char *reason);
-extern void dump_page_badflags(struct page *page, const char *reason,
+extern void dump_page(const struct page *page, const char *reason);
+extern void dump_page_badflags(const struct page *page, const char *reason,
 			       unsigned long badflags);
 void dump_vma(const struct vm_area_struct *vma);
 void dump_mm(const struct mm_struct *mm);
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 5c831f1..fa30115 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -39,7 +39,7 @@ static inline void page_cgroup_init(void)
 }
 #endif
 
-struct page_cgroup *lookup_page_cgroup(struct page *page);
+struct page_cgroup *lookup_page_cgroup(const struct page *page);
 
 static inline int PageCgroupUsed(struct page_cgroup *pc)
 {
@@ -52,7 +52,7 @@ static inline void pgdat_page_cgroup_init(struct pglist_data *pgdat)
 {
 }
 
-static inline struct page_cgroup *lookup_page_cgroup(struct page *page)
+static inline struct page_cgroup *lookup_page_cgroup(const struct page *page)
 {
 	return NULL;
 }
diff --git a/mm/debug.c b/mm/debug.c
index 5ce45c9..d699471 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -80,7 +80,7 @@ static void dump_flags(unsigned long flags,
 	pr_cont(")\n");
 }
 
-void dump_page_badflags(struct page *page, const char *reason,
+void dump_page_badflags(const struct page *page, const char *reason,
 		unsigned long badflags)
 {
 	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
@@ -98,7 +98,7 @@ void dump_page_badflags(struct page *page, const char *reason,
 	mem_cgroup_print_bad_page(page);
 }
 
-void dump_page(struct page *page, const char *reason)
+void dump_page(const struct page *page, const char *reason)
 {
 	dump_page_badflags(page, reason, 0);
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 23976fd..b698778 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3546,7 +3546,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 #endif
 
 #ifdef CONFIG_DEBUG_VM
-static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
+static struct page_cgroup *lookup_page_cgroup_used(const struct page *page)
 {
 	struct page_cgroup *pc;
 
@@ -3561,7 +3561,7 @@ static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
 	return NULL;
 }
 
-bool mem_cgroup_bad_page_check(struct page *page)
+bool mem_cgroup_bad_page_check(const struct page *page)
 {
 	if (mem_cgroup_disabled())
 		return false;
@@ -3569,7 +3569,7 @@ bool mem_cgroup_bad_page_check(struct page *page)
 	return lookup_page_cgroup_used(page) != NULL;
 }
 
-void mem_cgroup_print_bad_page(struct page *page)
+void mem_cgroup_print_bad_page(const struct page *page)
 {
 	struct page_cgroup *pc;
 
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 3708264..0f14421 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -21,7 +21,7 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
 	pgdat->node_page_cgroup = NULL;
 }
 
-struct page_cgroup *lookup_page_cgroup(struct page *page)
+struct page_cgroup *lookup_page_cgroup(const struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long offset;
@@ -89,7 +89,7 @@ fail:
 
 #else /* CONFIG_FLAT_NODE_MEM_MAP */
 
-struct page_cgroup *lookup_page_cgroup(struct page *page)
+struct page_cgroup *lookup_page_cgroup(const struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 	struct mem_section *section = __pfn_to_section(pfn);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

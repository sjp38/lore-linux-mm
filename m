Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id B8C696B003C
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 21:28:56 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id w10so1322305bkz.6
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 18:28:56 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lu10si9834948bkb.38.2014.03.11.18.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 18:28:55 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/8] mm: memcg: inline mem_cgroup_charge_common()
Date: Tue, 11 Mar 2014 21:28:29 -0400
Message-Id: <1394587714-6966-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

mem_cgroup_charge_common() is used by both cache and anon pages, but
most of its body only applies to anon pages and the remainder is not
worth having in a separate function.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 40 ++++++++++++++++------------------------
 1 file changed, 16 insertions(+), 24 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5abdfab957ad..cfdb9c385d8d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3919,20 +3919,21 @@ out:
 	return ret;
 }
 
-/*
- * Charge the memory controller for page usage.
- * Return
- * 0 if the charge was successful
- * < 0 if the cgroup is over its limit
- */
-static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype)
+int mem_cgroup_newpage_charge(struct page *page,
+			      struct mm_struct *mm, gfp_t gfp_mask)
 {
 	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	bool oom = true;
 	int ret;
 
+	if (mem_cgroup_disabled())
+		return 0;
+
+	VM_BUG_ON_PAGE(page_mapped(page), page);
+	VM_BUG_ON_PAGE(page->mapping && !PageAnon(page), page);
+	VM_BUG_ON(!mm);
+
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
@@ -3946,22 +3947,11 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
 	if (ret == -ENOMEM)
 		return ret;
-	__mem_cgroup_commit_charge(memcg, page, nr_pages, ctype, false);
+	__mem_cgroup_commit_charge(memcg, page, nr_pages,
+				   MEM_CGROUP_CHARGE_TYPE_ANON, false);
 	return 0;
 }
 
-int mem_cgroup_newpage_charge(struct page *page,
-			      struct mm_struct *mm, gfp_t gfp_mask)
-{
-	if (mem_cgroup_disabled())
-		return 0;
-	VM_BUG_ON_PAGE(page_mapped(page), page);
-	VM_BUG_ON_PAGE(page->mapping && !PageAnon(page), page);
-	VM_BUG_ON(!mm);
-	return mem_cgroup_charge_common(page, mm, gfp_mask,
-					MEM_CGROUP_CHARGE_TYPE_ANON);
-}
-
 /*
  * While swap-in, try_charge -> commit or cancel, the page is locked.
  * And when try_charge() successfully returns, one refcnt to memcg without
@@ -4079,9 +4069,11 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	if (PageCompound(page))
 		return 0;
 
-	if (!PageSwapCache(page))
-		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
-	else { /* page is swapcache/shmem */
+	if (!PageSwapCache(page)) {
+		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
+		if (ret != -ENOMEM)
+			__mem_cgroup_commit_charge(memcg, page, 1, type, false);
+	} else { /* page is swapcache/shmem */
 		ret = __mem_cgroup_try_charge_swapin(mm, page,
 						     gfp_mask, &memcg);
 		if (!ret)
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

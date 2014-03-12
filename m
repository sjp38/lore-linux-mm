Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1286B00BB
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 11:20:52 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id n12so11742836wgh.24
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 08:20:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si4198317wij.24.2014.03.12.08.20.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 08:20:51 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: rename high level charging functions
Date: Wed, 12 Mar 2014 16:20:43 +0100
Message-Id: <1394637643-5613-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20140312145300.GC14688@cmpxchg.org>
References: <20140312145300.GC14688@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

mem_cgroup_newpage_charge is used only for charging anonymous memory
so it is better to rename it to mem_cgroup_charge_anon.

mem_cgroup_cache_charge is used for file backed memory so rename it
to mem_cgroup_charge_file.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/cgroups/memcg_test.txt | 4 ++--
 include/linux/memcontrol.h           | 8 ++++----
 mm/filemap.c                         | 2 +-
 mm/huge_memory.c                     | 8 ++++----
 mm/memcontrol.c                      | 4 ++--
 mm/memory.c                          | 6 +++---
 mm/shmem.c                           | 6 +++---
 7 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index ce94a83a7d9a..80ac454704b8 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -24,7 +24,7 @@ Please note that implementation details can be changed.
 
    a page/swp_entry may be charged (usage += PAGE_SIZE) at
 
-	mem_cgroup_newpage_charge()
+	mem_cgroup_charge_anon()
 	  Called at new page fault and Copy-On-Write.
 
 	mem_cgroup_try_charge_swapin()
@@ -32,7 +32,7 @@ Please note that implementation details can be changed.
 	  Followed by charge-commit-cancel protocol. (With swap accounting)
 	  At commit, a charge recorded in swap_cgroup is removed.
 
-	mem_cgroup_cache_charge()
+	mem_cgroup_charge_file()
 	  Called at add_to_page_cache()
 
 	mem_cgroup_cache_charge_swapin()
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index abd0113b6620..b4e9c196949a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -65,7 +65,7 @@ struct mem_cgroup_reclaim_cookie {
  * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
  */
 
-extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
+extern int mem_cgroup_charge_anon(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 /* for swap handling */
 extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
@@ -74,7 +74,7 @@ extern void mem_cgroup_commit_charge_swapin(struct page *page,
 					struct mem_cgroup *memcg);
 extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
 
-extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
+extern int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
@@ -234,13 +234,13 @@ void mem_cgroup_print_bad_page(struct page *page);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
-static inline int mem_cgroup_newpage_charge(struct page *page,
+static inline int mem_cgroup_charge_anon(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return 0;
 }
 
-static inline int mem_cgroup_cache_charge(struct page *page,
+static inline int mem_cgroup_charge_file(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index 2d8af8796fed..a2e7b8ed7b74 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -562,7 +562,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
 
-	error = mem_cgroup_cache_charge(page, current->mm,
+	error = mem_cgroup_charge_file(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
 		return error;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bbf3b3db8f27..335e2f59853b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -827,7 +827,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
+	if (unlikely(mem_cgroup_charge_anon(page, mm, GFP_KERNEL))) {
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -968,7 +968,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					       __GFP_OTHER_NODE,
 					       vma, address, page_to_nid(page));
 		if (unlikely(!pages[i] ||
-			     mem_cgroup_newpage_charge(pages[i], mm,
+			     mem_cgroup_charge_anon(pages[i], mm,
 						       GFP_KERNEL))) {
 			if (pages[i])
 				put_page(pages[i]);
@@ -1101,7 +1101,7 @@ alloc:
 		goto out;
 	}
 
-	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
+	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))) {
 		put_page(new_page);
 		if (page) {
 			split_huge_page(page);
@@ -2363,7 +2363,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!new_page)
 		return;
 
-	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)))
+	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL)))
 		return;
 
 	/*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 67e01b27a021..d67650a67507 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3851,7 +3851,7 @@ out:
 	return ret;
 }
 
-int mem_cgroup_newpage_charge(struct page *page,
+int mem_cgroup_charge_anon(struct page *page,
 			      struct mm_struct *mm, gfp_t gfp_mask)
 {
 	unsigned int nr_pages = 1;
@@ -3987,7 +3987,7 @@ void mem_cgroup_commit_charge_swapin(struct page *page,
 					  MEM_CGROUP_CHARGE_TYPE_ANON);
 }
 
-int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
+int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
 	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
diff --git a/mm/memory.c b/mm/memory.c
index 548d97e3df91..5c57d1bbf3cf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2803,7 +2803,7 @@ gotten:
 	}
 	__SetPageUptodate(new_page);
 
-	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
+	if (mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
 	mmun_start  = address & PAGE_MASK;
@@ -3256,7 +3256,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	__SetPageUptodate(page);
 
-	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
+	if (mem_cgroup_charge_anon(page, mm, GFP_KERNEL))
 		goto oom_free_page;
 
 	entry = mk_pte(page, vma->vm_page_prot);
@@ -3384,7 +3384,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!new_page)
 		return VM_FAULT_OOM;
 
-	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)) {
+	if (mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL)) {
 		page_cache_release(new_page);
 		return VM_FAULT_OOM;
 	}
diff --git a/mm/shmem.c b/mm/shmem.c
index 7847ea0c0d30..0f0fca94b532 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -685,7 +685,7 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 	 * the shmem_swaplist_mutex which might hold up shmem_writepage().
 	 * Charged back to the user (not to caller) when swap account is used.
 	 */
-	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
+	error = mem_cgroup_charge_file(page, current->mm, GFP_KERNEL);
 	if (error)
 		goto out;
 	/* No radix_tree_preload: swap entry keeps a place for page in tree */
@@ -1082,7 +1082,7 @@ repeat:
 				goto failed;
 		}
 
-		error = mem_cgroup_cache_charge(page, current->mm,
+		error = mem_cgroup_charge_file(page, current->mm,
 						gfp & GFP_RECLAIM_MASK);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
@@ -1136,7 +1136,7 @@ repeat:
 
 		SetPageSwapBacked(page);
 		__set_page_locked(page);
-		error = mem_cgroup_cache_charge(page, current->mm,
+		error = mem_cgroup_charge_file(page, current->mm,
 						gfp & GFP_RECLAIM_MASK);
 		if (error)
 			goto decused;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

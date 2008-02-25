Date: Mon, 25 Feb 2008 23:35:33 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 01/15] memcg: mm_match_cgroup not vm_match_cgroup
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252334190.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

vm_match_cgroup is a perverse name for a macro to match mm with cgroup:
rename it mm_match_cgroup, matching mm_init_cgroup and mm_free_cgroup.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/memcontrol.h |    4 ++--
 mm/memcontrol.c            |    2 +-
 mm/rmap.c                  |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

--- 2.6.25-rc3/include/linux/memcontrol.h	2008-02-24 22:39:48.000000000 +0000
+++ memcg01/include/linux/memcontrol.h	2008-02-25 14:05:35.000000000 +0000
@@ -48,7 +48,7 @@ extern int mem_cgroup_cache_charge(struc
 					gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
-#define vm_match_cgroup(mm, cgroup)	\
+#define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == rcu_dereference((mm)->mem_cgroup))
 
 extern int mem_cgroup_prepare_migration(struct page *page);
@@ -118,7 +118,7 @@ static inline int mem_cgroup_cache_charg
 	return 0;
 }
 
-static inline int vm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
+static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
 {
 	return 1;
 }
--- 2.6.25-rc3/mm/memcontrol.c	2008-02-24 22:39:48.000000000 +0000
+++ memcg01/mm/memcontrol.c	2008-02-25 14:05:35.000000000 +0000
@@ -399,7 +399,7 @@ int task_in_mem_cgroup(struct task_struc
 	int ret;
 
 	task_lock(task);
-	ret = task->mm && vm_match_cgroup(task->mm, mem);
+	ret = task->mm && mm_match_cgroup(task->mm, mem);
 	task_unlock(task);
 	return ret;
 }
--- 2.6.25-rc3/mm/rmap.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg01/mm/rmap.c	2008-02-25 14:05:35.000000000 +0000
@@ -321,7 +321,7 @@ static int page_referenced_anon(struct p
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !vm_match_cgroup(vma->vm_mm, mem_cont))
+		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
@@ -382,7 +382,7 @@ static int page_referenced_file(struct p
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !vm_match_cgroup(vma->vm_mm, mem_cont))
+		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
 				  == (VM_LOCKED|VM_MAYSHARE)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

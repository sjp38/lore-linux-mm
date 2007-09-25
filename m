Date: Tue, 25 Sep 2007 10:13:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 6/5] memcontrol: move mm_cgroup to header file
Message-ID: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Inline functions must preceed their use, so mm_cgroup() should be defined
in linux/memcontrol.h.

include/linux/memcontrol.h:48: warning: 'mm_cgroup' declared inline after
	being called
include/linux/memcontrol.h:48: warning: previous declaration of
	'mm_cgroup' was here

Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |    8 ++++++--
 mm/memcontrol.c            |    5 -----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -45,7 +45,11 @@ extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
-extern struct mem_cgroup *mm_cgroup(struct mm_struct *mm);
+
+static inline struct mem_cgroup *mm_cgroup(const struct mm_struct *mm)
+{
+	return rcu_dereference(mm->mem_cgroup);
+}
 
 static inline void mem_cgroup_uncharge_page(struct page *page)
 {
@@ -108,7 +112,7 @@ static inline int mem_cgroup_cache_charge(struct page *page,
 	return 0;
 }
 
-static inline struct mem_cgroup *mm_cgroup(struct mm_struct *mm)
+static inline struct mem_cgroup *mm_cgroup(const struct mm_struct *mm)
 {
 	return NULL;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -110,11 +110,6 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 				struct mem_cgroup, css);
 }
 
-inline struct mem_cgroup *mm_cgroup(struct mm_struct *mm)
-{
-	return rcu_dereference(mm->mem_cgroup);
-}
-
 void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p)
 {
 	struct mem_cgroup *mem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

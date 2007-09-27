Date: Thu, 27 Sep 2007 11:01:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/2] memcontrol: move oom task exclusion to tasklist
 scan
Message-ID: <alpine.DEB.0.9999.0709270008500.24731@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Creates a helper function to return non-zero if a task is a member of a
memory controller:

	int task_in_mem_cgroup(const struct task_struct *task,
			       const struct mem_cgroup *mem);

When the OOM killer is constrained by the memory controller, the exclusion
of tasks that are not a member of that controller was previously misplaced
and appeared in the badness scoring function.  It should be excluded
during the tasklist scan in select_bad_process() instead.

Cc: Christoph Lameter <clameter@sgi.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |   16 ++++++++++++++++
 mm/oom_kill.c              |    9 ++-------
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -56,6 +56,16 @@ static inline void mem_cgroup_uncharge_page(struct page *page)
 	mem_cgroup_uncharge(page_get_page_cgroup(page));
 }
 
+static inline int task_in_mem_cgroup(struct task_struct *task,
+				     const struct mem_cgroup *mem)
+{
+	int ret;
+	task_lock(task);
+	ret = task->mm && mm_cgroup(task->mm) == mem;
+	task_unlock(task);
+	return ret;
+}
+
 #else /* CONFIG_CGROUP_MEM_CONT */
 static inline void mm_init_cgroup(struct mm_struct *mm,
 					struct task_struct *p)
@@ -107,6 +117,12 @@ static inline struct mem_cgroup *mm_cgroup(const struct mm_struct *mm)
 	return NULL;
 }
 
+static inline int task_in_mem_cgroup(struct task_struct *task,
+				     const struct mem_cgroup *mem)
+{
+	return 1;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -65,13 +65,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime,
 		return 0;
 	}
 
-#ifdef CONFIG_CGROUP_MEM_CONT
-	if (mem != NULL && mm->mem_cgroup != mem) {
-		task_unlock(p);
-		return 0;
-	}
-#endif
-
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
@@ -224,6 +217,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		/* skip the init task */
 		if (is_global_init(p))
 			continue;
+		if (mem && !task_in_mem_cgroup(p, mem))
+			continue;
 
 		/*
 		 * This task already has access to memory reserves and is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

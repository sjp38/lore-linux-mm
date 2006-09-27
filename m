From: Paul Jackson <pj@sgi.com>
Date: Wed, 27 Sep 2006 01:36:52 -0700
Message-Id: <20060927083652.16816.90521.sendpatchset@sam.engr.sgi.com>
Subject: [RFC] fake numa node speedup - fix for non-CPUSET builds
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

My RFC patch memory_fast_zonelist_scan does not compile
in the case of NUMA enabled, CPUSET disabled, because it
tries to access "current->mems_allowed" from NUMA code.

Fix by adding yet another cpuset.h macro to access the
current tasks mems_allowed (or node_online_map for non-CPUSET
configs.)

Signed-off-by: Paul Jackson

---

 include/linux/cpuset.h |    2 ++
 mm/page_alloc.c        |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

--- 2.6.18-rc7-mm1.orig/mm/page_alloc.c	2006-09-26 18:00:23.000000000 -0700
+++ 2.6.18-rc7-mm1/mm/page_alloc.c	2006-09-26 18:01:49.000000000 -0700
@@ -956,7 +956,7 @@ static int zlf_setup(struct zonelist *zo
 		return 0;
 
 	allowednodes = !in_interrupt() && (alloc_flags & ALLOC_CPUSET) ?
-				&current->mems_allowed : &node_online_map;
+				&cpuset_current_mems_allowed : &node_online_map;
 
 	if (jiffies - zlf->last_full_zap > 1 * HZ) {
 		nodes_clear(zlf->fullnodes);
--- 2.6.18-rc7-mm1.orig/include/linux/cpuset.h	2006-09-26 18:00:23.000000000 -0700
+++ 2.6.18-rc7-mm1/include/linux/cpuset.h	2006-09-26 18:01:49.000000000 -0700
@@ -23,6 +23,7 @@ extern void cpuset_fork(struct task_stru
 extern void cpuset_exit(struct task_struct *p);
 extern cpumask_t cpuset_cpus_allowed(struct task_struct *p);
 extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
+#define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
 void cpuset_update_task_memory_state(void);
 #define cpuset_nodes_subset_current_mems_allowed(nodes) \
@@ -83,6 +84,7 @@ static inline nodemask_t cpuset_mems_all
 	return node_possible_map;
 }
 
+#define cpuset_current_mems_allowed (node_online_map)
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

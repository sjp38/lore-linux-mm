Date: Thu, 13 Sep 2007 17:36:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
In-Reply-To: <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Christoph Lameter wrote:

> > It's easier to serialize it outside of out_of_memory() instead, since it 
> > only has a single caller and we don't need to serialize for sysrq.
> > 
> > This seems like it would collapse down nicely to a global or per-cpuset 
> > serialization with an added helper function implemented partially in 
> > kernel/cpuset.c for the CONFIG_CPUSETS case.
> > 
> > Then, in __alloc_pages(), we test for either a global or per-cpuset 
> > spin_trylock() and, if we acquire it, call out_of_memory() and goto 
> > restart as we currently do.  If it's contended, we reschedule ourself and 
> > goto restart when we awaken.
> 
> Could you rephrase that in patch form? ;-)
> 

Yeah, it turned out to be a little more invasive then I thought but it 
appears to be the cleanest solution for both the general CONSTRAINT_NONE 
and the per-cpuset CONSTRAINT_CPUSET cases.

I've been trying to keep score at home, but I've lost track of what 
patches from the series we're keeping so this is against HEAD.




serialize oom killer

Serializes the OOM killer both globally and per-cpuset, depending on the
system configuration.

A new spinlock, oom_lock, is introduced for the global case.  It
serializes the OOM killer for systems that are not using cpusets.  Only
one system task may enter the OOM killer at a time to prevent
unnecessarily killing others.

A per-cpuset flag, CS_OOM, is introduced in the flags field of struct
cpuset.  It serializes the OOM killer for only for hardwall allocations
targeted for that cpuset.  Only one task for each cpuset may enter the
OOM killer at a time to prevent unnecessarily killing others.  When a
per-cpuset OOM killing is taking place, the global spinlock is also
locked since we'll be alleviating that condition at the same time.

Regardless of the synchronization primitive used, if a task cannot
acquire the OOM lock, it is put to sleep before retrying the triggering
allocation so that the OOM killer may finish and free some memory.

We acquire either lock before attempting one last try at 
get_pages_from_freelist() with a very high watermark, otherwise we could 
invoke the OOM killer needlessly if another thread reschedules between 
this allocation attempt and trying to take the OOM lock.

Also converts the CONSTAINT_{NONE,CPUSET,MEMORY_POLICY} defines to an
enum and moves them to include/linux/swap.h.  We're going to need an
include/linux/oom_kill.h soon, probably.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/char/sysrq.c   |    3 +-
 include/linux/cpuset.h |   13 ++++++++++-
 include/linux/swap.h   |   14 ++++++++++-
 kernel/cpuset.c        |   16 +++++++++++++
 mm/oom_kill.c          |   58 ++++++++++++++++++++++++++++++++++++-----------
 mm/page_alloc.c        |   42 +++++++++++++++++++++++-----------
 6 files changed, 114 insertions(+), 32 deletions(-)

diff --git a/drivers/char/sysrq.c b/drivers/char/sysrq.c
--- a/drivers/char/sysrq.c
+++ b/drivers/char/sysrq.c
@@ -270,8 +270,7 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(&NODE_DATA(0)->node_zonelists[ZONE_NORMAL],
-			GFP_KERNEL, 0);
+	out_of_memory(GFP_KERNEL, 0, CONSTRAINT_NONE);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -60,7 +60,8 @@ extern char *cpuset_task_status_allowed(struct task_struct *task, char *buffer);
 
 extern void cpuset_lock(void);
 extern void cpuset_unlock(void);
-
+extern int cpuset_oom_test_and_set_lock(void);
+extern int cpuset_oom_unlock(void);
 extern int cpuset_mem_spread_node(void);
 
 static inline int cpuset_do_page_mem_spread(void)
@@ -129,6 +130,16 @@ static inline char *cpuset_task_status_allowed(struct task_struct *task,
 static inline void cpuset_lock(void) {}
 static inline void cpuset_unlock(void) {}
 
+static inline int cpuset_oom_test_and_set_lock(void)
+{
+	return -1;
+}
+
+static inline int cpuset_oom_unlock(void)
+{
+	return 0;
+}
+
 static inline int cpuset_mem_spread_node(void)
 {
 	return 0;
diff --git a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -159,9 +159,21 @@ struct swap_list_t {
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
 /* linux/mm/oom_kill.c */
-extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
+/*
+ * Types of limitations to the nodes from which allocations may occur
+ */
+enum oom_constraint {
+	CONSTRAINT_NONE,
+	CONSTRAINT_CPUSET,
+	CONSTRAINT_MEMORY_POLICY,
+};
+extern void out_of_memory(gfp_t gfp_mask, int order,
+			  enum oom_constraint constraint);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
+extern int oom_test_and_set_lock(struct zonelist *zonelist, gfp_t gfp_mask,
+				 enum oom_constraint *constraint);
+extern void oom_unlock(enum oom_constraint constraint);
 
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -109,6 +109,7 @@ typedef enum {
 	CS_NOTIFY_ON_RELEASE,
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
+	CS_IS_OOM,
 } cpuset_flagbits_t;
 
 /* convenient tests for these bits */
@@ -147,6 +148,11 @@ static inline int is_spread_slab(const struct cpuset *cs)
 	return test_bit(CS_SPREAD_SLAB, &cs->flags);
 }
 
+static inline int is_oom(const struct cpuset *cs)
+{
+	return test_bit(CS_IS_OOM, &cs->flags);
+}
+
 /*
  * Increment this integer everytime any cpuset changes its
  * mems_allowed value.  Users of cpusets can track this generation
@@ -2527,6 +2533,16 @@ void cpuset_unlock(void)
 	mutex_unlock(&callback_mutex);
 }
 
+int cpuset_oom_test_and_set_lock(void)
+{
+	return test_and_set_bit(CS_IS_OOM, &current->cpuset->flags);
+}
+
+int cpuset_oom_unlock(void)
+{
+	return test_and_clear_bit(CS_IS_OOM, &current->cpuset->flags);
+}
+
 /**
  * cpuset_mem_spread_node() - On which node to begin search for a page
  *
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -27,6 +27,7 @@
 #include <linux/notifier.h>
 
 int sysctl_panic_on_oom;
+static DEFINE_SPINLOCK(oom_lock);
 /* #define DEBUG */
 
 /**
@@ -164,13 +165,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 }
 
 /*
- * Types of limitations to the nodes from which allocations may occur
- */
-#define CONSTRAINT_NONE 1
-#define CONSTRAINT_MEMORY_POLICY 2
-#define CONSTRAINT_CPUSET 3
-
-/*
  * Determine the type of allocation constraint.
  */
 static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
@@ -387,6 +381,48 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+/*
+ * If using cpusets, try to lock task's per-cpuset OOM lock; otherwise, try to
+ * lock the global OOM spinlock.  Returns non-zero if the lock is contended or
+ * zero if acquired.
+ */
+int oom_test_and_set_lock(struct zonelist *zonelist, gfp_t gfp_mask,
+			  enum oom_constraint *constraint)
+{
+	int ret;
+
+	*constraint = constrained_alloc(zonelist, gfp_mask);
+	switch (*constraint) {
+	case CONSTRAINT_CPUSET:
+		ret = cpuset_oom_test_and_set_lock();
+		if (!ret)
+			spin_trylock(&oom_lock);
+		break;
+	default:
+		ret = spin_trylock(&oom_lock);
+		break;
+	}
+	return ret;
+}
+
+/*
+ * If using cpusets, unlock task's per-cpuset OOM lock; otherwise, unlock the
+ * global OOM spinlock.
+ */
+void oom_unlock(enum oom_constraint constraint)
+{
+	switch (constraint) {
+	case CONSTRAINT_CPUSET:
+		if (likely(spin_is_locked(&oom_lock)))
+			spin_unlock(&oom_lock);
+		cpuset_oom_unlock();
+		break;
+	default:
+		spin_unlock(&oom_lock);
+		break;
+	}
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  *
@@ -395,12 +431,11 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
+void out_of_memory(gfp_t gfp_mask, int order, enum oom_constraint constraint)
 {
 	struct task_struct *p;
 	unsigned long points = 0;
 	unsigned long freed = 0;
-	int constraint;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
@@ -418,11 +453,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 	if (sysctl_panic_on_oom == 2)
 		panic("out of memory. Compulsory panic_on_oom is selected.\n");
 
-	/*
-	 * Check if there were limitations on the allocation (only relevant for
-	 * NUMA) that may require different handling.
-	 */
-	constraint = constrained_alloc(zonelist, gfp_mask);
 	cpuset_lock();
 	read_lock(&tasklist_lock);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1352,22 +1352,36 @@ nofail_alloc:
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
-		/*
-		 * Go through the zonelist yet one more time, keep
-		 * very high watermark here, this is only to catch
-		 * a parallel oom killing, we must fail if we're still
-		 * under heavy pressure.
-		 */
-		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-				zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
-		if (page)
-			goto got_pg;
+		enum oom_constraint constraint = CONSTRAINT_NONE;
 
-		/* The OOM killer will not help higher order allocs so fail */
-		if (order > PAGE_ALLOC_COSTLY_ORDER)
-			goto nopage;
+		if (!oom_test_and_set_lock(zonelist, gfp_mask, &constraint)) {
+			/*
+			 * Go through the zonelist yet one more time, keep
+			 * very high watermark here, this is only to catch
+			 * a previous oom killing, we must fail if we're still
+			 * under heavy pressure.
+			 */
+			page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL,
+					order, zonelist,
+					ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+			if (page) {
+				oom_unlock(constraint);
+				goto got_pg;
+			}
+
+			/*
+			 * The OOM killer will not help higher order allocs so
+			 * fail
+			 */
+			if (order > PAGE_ALLOC_COSTLY_ORDER) {
+				oom_unlock(constraint);
+				goto nopage;
+			}
 
-		out_of_memory(zonelist, gfp_mask, order);
+			out_of_memory(gfp_mask, order, constraint);
+			oom_unlock(constraint);
+		} else
+			schedule_timeout_uninterruptible(1);
 		goto restart;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

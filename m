Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A279A900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 23:15:50 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so85642888pdb.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 20:15:50 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id b9si29369130pas.133.2015.06.02.20.15.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 20:15:49 -0700 (PDT)
Received: by pdbnf5 with SMTP id nf5so85642523pdb.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 20:15:48 -0700 (PDT)
Date: Wed, 3 Jun 2015 12:15:44 +0900
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH RFC] memcg: close the race window between OOM detection and
 killing
Message-ID: <20150603031544.GC7579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

Hello,

This patch closes the race window by introducing OOM victim generation
number to detect whether any exited between OOM detection and killing;
however, this isn't the prettiest thing in the world and is nasty in
that memcg OOM mechanism deviates from system-wide OOM killer.

The only reason memcg OOM killer behaves asynchronously (unwinding
stack and then handling) is memcg userland OOM handling, which may end
up blocking for userland actions while still holding whatever locks
that it was holding at the time it was invoking try_charge() leading
to a deadlock.

However, given that userland OOMs are retriable, this doesn't have to
be this complicated.  Waiting with timeout in try_charge()
synchronously should be enough - in the unlikely cases where forward
progress can't be made, the OOM killing can simply abort waiting and
continue on.  If it is an OOM deadlock which requires death of more
victims, OOM condition will trigger again and kill more.

IOW, it'd be cleaner to do everything synchronously while holding
oom_lock with timeout to get out of rare deadlocks.

What do you think?

Thanks.
----- 8< -----
Memcg OOM killings are done at the end of page fault apart from OOM
detection.  This allows the following race condition.

	Task A				Task B

	OOM detection
					OOM detection
	OOM kill
	victim exits
					OOM kill

Task B has no way of knowing that another task has already killed an
OOM victim which proceeded to exit and release memory and will
unnecessarily pick another victim.  In highly contended cases, this
can lead to multiple unnecessary chained killings.

This patch closes this race window by adding per-memcg OOM victim exit
generation number.  Each task snapshots it when trying to charge.  If
OOM condition is triggered, the kill path compares the remembered
generation against the current value.  If they differ, it indicates
that some victims have exited between the charge attempt and OOM kill
path and the task shouldn't pick another victim.

The condition can be reliably triggered with multiple allocating
processes by modifying mem_cgroup_oom_trylock() to retry several times
with a short delay.  With the patch applied, memcg OOM correctly
detects the race condition and skips OOM killing to retry the
allocation.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |    9 ++++++-
 include/linux/sched.h      |    3 +-
 mm/memcontrol.c            |   52 +++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c              |    5 ++++
 4 files changed, 66 insertions(+), 3 deletions(-)

--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -126,8 +126,8 @@ bool mem_cgroup_lruvec_online(struct lru
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
 void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
-extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
-					struct task_struct *p);
+void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p);
+void mem_cgroup_exit_oom_victim(void);
 
 static inline void mem_cgroup_oom_enable(void)
 {
@@ -321,6 +321,11 @@ mem_cgroup_print_oom_info(struct mem_cgr
 {
 }
 
+static inline void
+mem_cgroup_exit_oom_victim(void)
+{
+}
+
 static inline struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page)
 {
 	return NULL;
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1770,7 +1770,8 @@ struct task_struct {
 		struct mem_cgroup *memcg;
 		gfp_t gfp_mask;
 		int order;
-		unsigned int may_oom:1;
+		u16 oom_exit_gen;
+		u16 may_oom:1;
 	} memcg_oom;
 #endif
 #ifdef CONFIG_UPROBES
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -285,6 +285,21 @@ struct mem_cgroup {
 	 */
 	bool use_hierarchy;
 
+	/*
+	 * Because memcg OOM detection and killing aren't in the same
+	 * critical section, OOM victims might exit between the detection
+	 * and killing steps of another OOMing task leading to unnecessary
+	 * consecutive OOM killings.  The following counter, bumped
+	 * whenever an OOM victim exits, is used to detect such race
+	 * conditions by testing whether it has changed between detection
+	 * and killing.
+	 *
+	 * Use u16 to avoid bloating task->memcg_oom_info.  While u16 can
+	 * wrap inbetween, it's highly unlikely and we can afford rare
+	 * inaccuracies.  Protected by oom_lock.
+	 */
+	u16		oom_exit_gen;
+
 	/* protected by memcg_oom_lock */
 	bool		oom_lock;
 	int		under_oom;
@@ -1490,6 +1505,28 @@ void mem_cgroup_print_oom_info(struct me
 	mutex_unlock(&oom_info_lock);
 }
 
+/**
+ * mem_cgroup_exit_oom_victim - note the exit of an OOM victim
+ *
+ * Called from exit_oom_victm() with oom_lock held.  This is used to bump
+ * memcg->oom_exit_gen which is used to avoid unnecessary chained OOM
+ * killings.
+ */
+void mem_cgroup_exit_oom_victim(void)
+{
+	struct mem_cgroup *memcg;
+
+	lockdep_assert_held(&oom_lock);
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+
+	/* paired with load_acquire in try_charge() */
+	smp_store_release(&memcg->oom_exit_gen, memcg->oom_exit_gen + 1);
+
+	rcu_read_unlock();
+ }
+
 /*
  * This function returns the number of memcg under hierarchy tree. Returns
  * 1(self count) if no children.
@@ -1533,6 +1570,13 @@ static void mem_cgroup_out_of_memory(str
 	mutex_lock(&oom_lock);
 
 	/*
+	 * If we raced OOM victim exits between our charge attempt and
+	 * here, there's no reason to kill more.  Bail and retry.
+	 */
+	if (current->memcg_oom.oom_exit_gen != memcg->oom_exit_gen)
+		goto unlock;
+
+	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
@@ -2245,6 +2289,14 @@ static int try_charge(struct mem_cgroup
 	if (mem_cgroup_is_root(memcg))
 		goto done;
 retry:
+	/*
+	 * Snapshot the current OOM exit generation number.  The generation
+	 * number has to be updated after memory is released and read
+	 * before charging is attempted.  Use load_acquire paired with
+	 * store_release in mem_cgroup_exit_oom_victim() for ordering.
+	 */
+	current->memcg_oom.oom_exit_gen = smp_load_acquire(&memcg->oom_exit_gen);
+
 	if (consume_stock(memcg, nr_pages))
 		goto done;
 
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -435,10 +435,15 @@ void mark_oom_victim(struct task_struct
  */
 void exit_oom_victim(void)
 {
+	mutex_lock(&oom_lock);
+
+	mem_cgroup_exit_oom_victim();
 	clear_thread_flag(TIF_MEMDIE);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
+
+	mutex_unlock(&oom_lock);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

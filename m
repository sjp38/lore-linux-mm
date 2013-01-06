Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8B8896B004D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 15:02:34 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so10232052pad.25
        for <linux-mm@kvack.org>; Sun, 06 Jan 2013 12:02:33 -0800 (PST)
Date: Sun, 6 Jan 2013 12:02:26 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
In-Reply-To: <CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1301061135400.29149@eggly.anvils>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456367-14660-1-git-send-email-handai.szj@taobao.com> <20130102104421.GC22160@dhcp22.suse.cz> <CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

On Sat, 5 Jan 2013, Sha Zhengju wrote:
> On Wed, Jan 2, 2013 at 6:44 PM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > Maybe I have missed some other locking which would prevent this from
> > happening but the locking relations are really complicated in this area
> > so if mem_cgroup_{begin,end}_update_page_stat might be called
> > recursively then we need a fat comment which justifies that.
> >
> 
> Ohhh...good catching!  I didn't notice there is a recursive call of
> mem_cgroup_{begin,end}_update_page_stat in page_remove_rmap().
> The mem_cgroup_{begin,end}_update_page_stat() design has depressed
> me a lot recently as the lock granularity is a little bigger than I thought.
> Not only the resource but also some code logic is in the range of locking
> which may be deadlock prone. The problem still exists if we are trying to
> add stat account of other memcg page later, may I make bold to suggest
> that we dig into the lock again...

Forgive me, I must confess I'm no more than skimming this thread,
and don't like dumping unsigned-off patches on people; but thought
that on balance it might be more helpful than not if I offer you a
patch I worked on around 3.6-rc2 (but have updated to 3.8-rc2 below).

I too was getting depressed by the constraints imposed by
mem_cgroup_{begin,end}_update_page_stat (good job though Kamezawa-san
did to minimize them), and wanted to replace by something freer, more
RCU-like.  In the end it seemed more effort than it was worth to go
as far as I wanted, but I do think that this is some improvement over
what we currently have, and should deal with your recursion issue.

But if this does appear useful to memcg people, then we really ought
to get it checked over by locking/barrier experts before going further.
I think myself that I've over-barriered it, and could use a little
lighter; but they (Paul McKenney, Peter Zijlstra, Oleg Nesterov come
to mind) will see more clearly, and may just hate the whole thing,
as yet another peculiar lockdep-avoiding hand-crafted locking scheme.
I've not wanted to waste their time on reviewing it, if it's not even
going to be useful to memcg people.

It may be easier to understand if you just apply the patch and look
at the result in mm/memcontrol.c, where I tried to gather the pieces
together in one place and describe them ("These functions mediate...").

Hugh

 include/linux/memcontrol.h |   39 +--
 mm/memcontrol.c            |  375 +++++++++++++++++++++--------------
 mm/rmap.c                  |   20 -
 3 files changed, 257 insertions(+), 177 deletions(-)

--- 3.8-rc2/include/linux/memcontrol.h	2012-12-22 09:43:27.172015571 -0800
+++ linux/include/linux/memcontrol.h	2013-01-02 14:47:47.960394878 -0800
@@ -136,32 +136,28 @@ static inline bool mem_cgroup_disabled(v
 	return false;
 }
 
-void __mem_cgroup_begin_update_page_stat(struct page *page, bool *locked,
-					 unsigned long *flags);
-
+void __mem_cgroup_begin_update_page_stat(struct page *page);
+void __mem_cgroup_end_update_page_stat(void);
 extern atomic_t memcg_moving;
 
 static inline void mem_cgroup_begin_update_page_stat(struct page *page,
-					bool *locked, unsigned long *flags)
+						     bool *clamped)
 {
-	if (mem_cgroup_disabled())
-		return;
-	rcu_read_lock();
-	*locked = false;
-	if (atomic_read(&memcg_moving))
-		__mem_cgroup_begin_update_page_stat(page, locked, flags);
+	preempt_disable();
+	*clamped = false;
+	if (unlikely(atomic_read(&memcg_moving))) {
+		__mem_cgroup_begin_update_page_stat(page);
+		*clamped = true;
+	}
 }
 
-void __mem_cgroup_end_update_page_stat(struct page *page,
-				unsigned long *flags);
 static inline void mem_cgroup_end_update_page_stat(struct page *page,
-					bool *locked, unsigned long *flags)
+						   bool *clamped)
 {
-	if (mem_cgroup_disabled())
-		return;
-	if (*locked)
-		__mem_cgroup_end_update_page_stat(page, flags);
-	rcu_read_unlock();
+	/* We don't currently use the page arg, but keep it for symmetry */
+	if (unlikely(*clamped))
+		__mem_cgroup_end_update_page_stat();
+	preempt_enable();
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
@@ -345,13 +341,16 @@ mem_cgroup_print_oom_info(struct mem_cgr
 }
 
 static inline void mem_cgroup_begin_update_page_stat(struct page *page,
-					bool *locked, unsigned long *flags)
+						     bool *clamped)
 {
+	/* It may be helpful to our callers if the stub behaves the same way */
+	preempt_disable();
 }
 
 static inline void mem_cgroup_end_update_page_stat(struct page *page,
-					bool *locked, unsigned long *flags)
+						   bool *clamped)
 {
+	preempt_enable();
 }
 
 static inline void mem_cgroup_inc_page_stat(struct page *page,
--- 3.8-rc2/mm/memcontrol.c	2012-12-22 09:43:27.628015582 -0800
+++ linux/mm/memcontrol.c	2013-01-02 14:55:36.268406008 -0800
@@ -321,12 +321,7 @@ struct mem_cgroup {
 	 * mem_cgroup ? And what type of charges should we move ?
 	 */
 	unsigned long 	move_charge_at_immigrate;
-	/*
-	 * set > 0 if pages under this cgroup are moving to other cgroup.
-	 */
-	atomic_t	moving_account;
-	/* taken only while moving_account > 0 */
-	spinlock_t	move_lock;
+
 	/*
 	 * percpu counter.
 	 */
@@ -1414,60 +1409,10 @@ int mem_cgroup_swappiness(struct mem_cgr
 }
 
 /*
- * memcg->moving_account is used for checking possibility that some thread is
- * calling move_account(). When a thread on CPU-A starts moving pages under
- * a memcg, other threads should check memcg->moving_account under
- * rcu_read_lock(), like this:
- *
- *         CPU-A                                    CPU-B
- *                                              rcu_read_lock()
- *         memcg->moving_account+1              if (memcg->mocing_account)
- *                                                   take heavy locks.
- *         synchronize_rcu()                    update something.
- *                                              rcu_read_unlock()
- *         start move here.
- */
-
-/* for quick checking without looking up memcg */
-atomic_t memcg_moving __read_mostly;
-
-static void mem_cgroup_start_move(struct mem_cgroup *memcg)
-{
-	atomic_inc(&memcg_moving);
-	atomic_inc(&memcg->moving_account);
-	synchronize_rcu();
-}
-
-static void mem_cgroup_end_move(struct mem_cgroup *memcg)
-{
-	/*
-	 * Now, mem_cgroup_clear_mc() may call this function with NULL.
-	 * We check NULL in callee rather than caller.
-	 */
-	if (memcg) {
-		atomic_dec(&memcg_moving);
-		atomic_dec(&memcg->moving_account);
-	}
-}
-
-/*
- * 2 routines for checking "mem" is under move_account() or not.
- *
- * mem_cgroup_stolen() -  checking whether a cgroup is mc.from or not. This
- *			  is used for avoiding races in accounting.  If true,
- *			  pc->mem_cgroup may be overwritten.
- *
  * mem_cgroup_under_move() - checking a cgroup is mc.from or mc.to or
  *			  under hierarchy of moving cgroups. This is for
- *			  waiting at hith-memory prressure caused by "move".
+ *			  waiting at high memory pressure caused by "move".
  */
-
-static bool mem_cgroup_stolen(struct mem_cgroup *memcg)
-{
-	VM_BUG_ON(!rcu_read_lock_held());
-	return atomic_read(&memcg->moving_account) > 0;
-}
-
 static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *from;
@@ -1506,24 +1451,6 @@ static bool mem_cgroup_wait_acct_move(st
 	return false;
 }
 
-/*
- * Take this lock when
- * - a code tries to modify page's memcg while it's USED.
- * - a code tries to modify page state accounting in a memcg.
- * see mem_cgroup_stolen(), too.
- */
-static void move_lock_mem_cgroup(struct mem_cgroup *memcg,
-				  unsigned long *flags)
-{
-	spin_lock_irqsave(&memcg->move_lock, *flags);
-}
-
-static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
-				unsigned long *flags)
-{
-	spin_unlock_irqrestore(&memcg->move_lock, *flags);
-}
-
 /**
  * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
  * @memcg: The memory cgroup that went over limit
@@ -2096,75 +2023,215 @@ static bool mem_cgroup_handle_oom(struct
 }
 
 /*
- * Currently used to update mapped file statistics, but the routine can be
- * generalized to update other statistics as well.
- *
- * Notes: Race condition
- *
- * We usually use page_cgroup_lock() for accessing page_cgroup member but
- * it tends to be costly. But considering some conditions, we doesn't need
- * to do so _always_.
- *
- * Considering "charge", lock_page_cgroup() is not required because all
- * file-stat operations happen after a page is attached to radix-tree. There
- * are no race with "charge".
- *
- * Considering "uncharge", we know that memcg doesn't clear pc->mem_cgroup
- * at "uncharge" intentionally. So, we always see valid pc->mem_cgroup even
- * if there are race with "uncharge". Statistics itself is properly handled
- * by flags.
+ * These functions mediate between the common case of updating memcg stats
+ * when a page transitions from one state to another, and the rare case of
+ * moving a page from one memcg to another.
+ *
+ * A simple example of the updater would be:
+ *	mem_cgroup_begin_update_page_stat(page);
+ *	if (TestClearPageFlag(page))
+ *		mem_cgroup_dec_page_stat(page, NR_FLAG_PAGES);
+ *	mem_cgroup_end_update_page_stat(page);
+ *
+ * An over-simplified example of the mover would be:
+ *	mem_cgroup_begin_move();
+ *	for each page chosen from old_memcg {
+ *		pc = lookup_page_cgroup(page);
+ *		lock_page_cgroup(pc);
+ *		if (trylock_memcg_move(page)) {
+ *			if (PageFlag(page)) {
+ *				mem_cgroup_dec_page_stat(page, NR_FLAG_PAGES);
+ *				pc->mem_cgroup = new_memcg;
+ *				mem_cgroup_inc_page_stat(page, NR_FLAG_PAGES);
+ *			}
+ *			unlock_memcg_move();
+ *			unlock_page_cgroup(pc);
+ *		}
+ *		cond_resched();
+ *	}
+ *	mem_cgroup_end_move();
+ *
+ * Without some kind of serialization between updater and mover, the mover
+ * cannot know whether or not to move one count from old to new memcg stats;
+ * but the serialization must be as lightweight as possible for the updater.
+ *
+ * At present we use two layers of lock avoidance, then spinlock on memcg;
+ * but that already got into (easily avoided) lock hierarchy violation with
+ * the page_cgroup lock; and as dirty writeback stats are added, it gets
+ * into further difficulty with the page cache radix tree lock (and on s390
+ * architecture, page_remove_rmap calls set_page_dirty within its critical
+ * section: perhaps that can be reordered, but if not, it requires nesting).
+ *
+ * We need a mechanism more like rcu_read_lock() for the updater, who then
+ * does not have to worry about lock ordering.  The scheme below is not quite
+ * as light as that: rarely, the updater does have to spin waiting on a mover;
+ * and it is still best for updater to avoid taking page_cgroup lock in its
+ * critical section (though mover drops and retries if necessary, so there is
+ * no actual deadlock).  Testing on 4-way suggests 5% heavier for the mover.
+ */
+
+/*
+ * memcg_moving count is written in advance by movers,
+ * and read by updaters to see if they need to worry further.
+ */
+atomic_t memcg_moving __read_mostly;
+
+/*
+ * Keep it simple: allow only one page to move at a time.  cgroup_mutex
+ * already serializes move_charge_at_immigrate movements, but not writes
+ * to memory.force_empty, nor move-pages-to-parent phase of cgroup rmdir.
  *
- * Considering "move", this is an only case we see a race. To make the race
- * small, we check mm->moving_account and detect there are possibility of race
- * If there is, we take a lock.
+ * memcg_moving_lock guards writes by movers to memcg_moving_page,
+ * which is read by updaters to see if they need to worry about their page.
+ */
+static DEFINE_SPINLOCK(memcg_moving_lock);
+static struct page *memcg_moving_page;
+
+/*
+ * updating_page_stat is written per-cpu by updaters,
+ * and all cpus read by mover to check when safe to proceed with the move.
  */
+static DEFINE_PER_CPU(int, updating_page_stat) = 0;
 
-void __mem_cgroup_begin_update_page_stat(struct page *page,
-				bool *locked, unsigned long *flags)
+/*
+ * Mover calls mem_cgroup_begin_move() before starting on its pages; its
+ * synchronize_rcu() ensures that all updaters will see memcg_moving in time.
+ */
+static void mem_cgroup_begin_move(void)
 {
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc;
+	get_online_cpus();
+	atomic_inc(&memcg_moving);
+	synchronize_rcu();
+}
+
+static void mem_cgroup_end_move(void)
+{
+	atomic_dec(&memcg_moving);
+	put_online_cpus();
+}
+
+/*
+ * Mover calls trylock_memcg_move(page) before moving stats and changing
+ * ownership of page.  If it fails, mover should drop page_cgroup lock and
+ * any other spinlocks held, cond_resched then try the page again.  This
+ * lets updaters take those locks if unavoidable, though preferably not.
+ */
+static bool trylock_memcg_move(struct page *page)
+{
+	static struct cpumask updating;
+	int try;
+
+	cpumask_copy(&updating, cpu_online_mask);
+	spin_lock(&memcg_moving_lock);
+	memcg_moving_page = page;
 
-	pc = lookup_page_cgroup(page);
-again:
-	memcg = pc->mem_cgroup;
-	if (unlikely(!memcg || !PageCgroupUsed(pc)))
-		return;
 	/*
-	 * If this memory cgroup is not under account moving, we don't
-	 * need to take move_lock_mem_cgroup(). Because we already hold
-	 * rcu_read_lock(), any calls to move_account will be delayed until
-	 * rcu_read_unlock() if mem_cgroup_stolen() == true.
+	 * Make sure that __mem_cgroup_begin_update_page_stat(page) can see
+	 * our memcg_moving_page before it commits to updating_page_stat.
 	 */
-	if (!mem_cgroup_stolen(memcg))
-		return;
+	smp_mb();
 
-	move_lock_mem_cgroup(memcg, flags);
-	if (memcg != pc->mem_cgroup || !PageCgroupUsed(pc)) {
-		move_unlock_mem_cgroup(memcg, flags);
-		goto again;
+	for (try = 0; try < 64; try++) {
+		int updaters = 0;
+		int cpu;
+
+		for_each_cpu(cpu, &updating) {
+			if (ACCESS_ONCE(per_cpu(updating_page_stat, cpu)))
+				updaters++;
+			else
+				cpumask_clear_cpu(cpu, &updating);
+		}
+		if (!updaters)
+			return true;
 	}
-	*locked = true;
+
+	memcg_moving_page = NULL;
+	spin_unlock(&memcg_moving_lock);
+	return false;
 }
 
-void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
+static void unlock_memcg_move(void)
 {
-	struct page_cgroup *pc = lookup_page_cgroup(page);
+	memcg_moving_page = NULL;
+	spin_unlock(&memcg_moving_lock);
+}
 
-	/*
-	 * It's guaranteed that pc->mem_cgroup never changes while
-	 * lock is held because a routine modifies pc->mem_cgroup
-	 * should take move_lock_mem_cgroup().
-	 */
-	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
+/*
+ * If memcg_moving, updater calls __mem_cgroup_begin_update_page_stat(page)
+ * (with preemption disabled) to indicate to the next mover that this cpu is
+ * updating a page, or to wait on the mover if it's already moving this page.
+ */
+void __mem_cgroup_begin_update_page_stat(struct page *page)
+{
+	static const int probing = 0x10000;
+	int updating;
+
+	__this_cpu_add(updating_page_stat, probing);
+
+	for (;;) {
+		/*
+		 * Make sure that trylock_memcg_move(page) can see our
+		 * updating_page_stat before we check memcg_moving_page.
+		 *
+		 * We use the special probing value at first so move sees it,
+		 * but nesting and interrupts on this cpu can distinguish it.
+		 */
+		smp_mb();
+
+		if (likely(page != ACCESS_ONCE(memcg_moving_page)))
+			break;
+
+		/*
+		 * We may be nested, we may be serving an interrupt: do not
+		 * hang here if the outer level already went beyond probing.
+		 */
+		updating = __this_cpu_read(updating_page_stat);
+		if (updating & (probing - 1))
+			break;
+
+		__this_cpu_write(updating_page_stat, 0);
+		while (page == ACCESS_ONCE(memcg_moving_page))
+			cpu_relax();
+		__this_cpu_write(updating_page_stat, updating);
+	}
+
+	/* Add one to count and remove temporary probing value */
+	__this_cpu_sub(updating_page_stat, probing - 1);
+}
+
+void __mem_cgroup_end_update_page_stat(void)
+{
+	__this_cpu_dec(updating_page_stat);
+}
+
+/*
+ * Static inline interfaces to the above in include/linux/memcontrol.h:
+ *
+static inline void mem_cgroup_begin_update_page_stat(struct page *page,
+						     bool *clamped)
+{
+	preempt_disable();
+	*clamped = false;
+	if (unlikely(atomic_read(&memcg_moving))) {
+		__mem_cgroup_begin_update_page_stat(page);
+		*clamped = true;
+	}
 }
 
+static inline void mem_cgroup_end_update_page_stat(struct page *page,
+						   bool *clamped)
+{
+	if (unlikely(*clamped))
+		__mem_cgroup_end_update_page_stat();
+	preempt_enable();
+}
+ */
+
 void mem_cgroup_update_page_stat(struct page *page,
 				 enum mem_cgroup_page_stat_item idx, int val)
 {
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-	unsigned long uninitialized_var(flags);
 
 	if (mem_cgroup_disabled())
 		return;
@@ -2181,7 +2248,8 @@ void mem_cgroup_update_page_stat(struct
 		BUG();
 	}
 
-	this_cpu_add(memcg->stat->count[idx], val);
+	/* mem_cgroup_begin_update_page_stat() disabled preemption */
+	__this_cpu_add(memcg->stat->count[idx], val);
 }
 
 /*
@@ -3580,7 +3648,6 @@ static int mem_cgroup_move_account(struc
 				   struct mem_cgroup *from,
 				   struct mem_cgroup *to)
 {
-	unsigned long flags;
 	int ret;
 	bool anon = PageAnon(page);
 
@@ -3602,21 +3669,21 @@ static int mem_cgroup_move_account(struc
 	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
 		goto unlock;
 
-	move_lock_mem_cgroup(from, &flags);
+	ret = -EAGAIN;
+	if (!trylock_memcg_move(page))
+		goto unlock;
 
 	if (!anon && page_mapped(page)) {
 		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
 		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, anon, nr_pages);
-	move_unlock_mem_cgroup(from, &flags);
+	unlock_memcg_move();
 	ret = 0;
 unlock:
 	unlock_page_cgroup(pc);
@@ -3675,19 +3742,25 @@ static int mem_cgroup_move_parent(struct
 	 */
 	if (!parent)
 		parent = root_mem_cgroup;
-
+retry:
 	if (nr_pages > 1) {
 		VM_BUG_ON(!PageTransHuge(page));
 		flags = compound_lock_irqsave(page);
 	}
 
-	ret = mem_cgroup_move_account(page, nr_pages,
-				pc, child, parent);
-	if (!ret)
-		__mem_cgroup_cancel_local_charge(child, nr_pages);
+	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent);
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
+
+	if (ret == -EAGAIN) {
+		cond_resched();
+		goto retry;
+	}
+
+	if (!ret)
+		__mem_cgroup_cancel_local_charge(child, nr_pages);
+
 	putback_lru_page(page);
 put:
 	put_page(page);
@@ -4685,7 +4758,7 @@ static void mem_cgroup_reparent_charges(
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		drain_all_stock_sync(memcg);
-		mem_cgroup_start_move(memcg);
+		mem_cgroup_begin_move();
 		for_each_node_state(node, N_MEMORY) {
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				enum lru_list lru;
@@ -4695,7 +4768,7 @@ static void mem_cgroup_reparent_charges(
 				}
 			}
 		}
-		mem_cgroup_end_move(memcg);
+		mem_cgroup_end_move();
 		memcg_oom_recover(memcg);
 		cond_resched();
 
@@ -6128,7 +6201,6 @@ mem_cgroup_css_alloc(struct cgroup *cont
 	atomic_set(&memcg->refcnt, 1);
 	memcg->move_charge_at_immigrate = 0;
 	mutex_init(&memcg->thresholds_lock);
-	spin_lock_init(&memcg->move_lock);
 
 	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
 	if (error) {
@@ -6521,7 +6593,8 @@ static void mem_cgroup_clear_mc(void)
 	mc.from = NULL;
 	mc.to = NULL;
 	spin_unlock(&mc.lock);
-	mem_cgroup_end_move(from);
+	if (from)
+		mem_cgroup_end_move();
 }
 
 static int mem_cgroup_can_attach(struct cgroup *cgroup,
@@ -6547,7 +6620,7 @@ static int mem_cgroup_can_attach(struct
 			VM_BUG_ON(mc.precharge);
 			VM_BUG_ON(mc.moved_charge);
 			VM_BUG_ON(mc.moved_swap);
-			mem_cgroup_start_move(from);
+			mem_cgroup_begin_move();
 			spin_lock(&mc.lock);
 			mc.from = from;
 			mc.to = memcg;
@@ -6573,7 +6646,7 @@ static int mem_cgroup_move_charge_pte_ra
 				unsigned long addr, unsigned long end,
 				struct mm_walk *walk)
 {
-	int ret = 0;
+	int ret;
 	struct vm_area_struct *vma = walk->private;
 	pte_t *pte;
 	spinlock_t *ptl;
@@ -6592,6 +6665,8 @@ static int mem_cgroup_move_charge_pte_ra
 	 *    to be unlocked in __split_huge_page_splitting(), where the main
 	 *    part of thp split is not executed yet.
 	 */
+retry:
+	ret = 0;
 	if (pmd_trans_huge_lock(pmd, vma) == 1) {
 		if (mc.precharge < HPAGE_PMD_NR) {
 			spin_unlock(&vma->vm_mm->page_table_lock);
@@ -6602,8 +6677,9 @@ static int mem_cgroup_move_charge_pte_ra
 			page = target.page;
 			if (!isolate_lru_page(page)) {
 				pc = lookup_page_cgroup(page);
-				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
-							pc, mc.from, mc.to)) {
+				ret = mem_cgroup_move_account(page,
+					    HPAGE_PMD_NR, pc, mc.from, mc.to);
+				if (!ret) {
 					mc.precharge -= HPAGE_PMD_NR;
 					mc.moved_charge += HPAGE_PMD_NR;
 				}
@@ -6612,12 +6688,14 @@ static int mem_cgroup_move_charge_pte_ra
 			put_page(page);
 		}
 		spin_unlock(&vma->vm_mm->page_table_lock);
+		if (ret == -EAGAIN)
+			goto retry;
 		return 0;
 	}
 
 	if (pmd_trans_unstable(pmd))
 		return 0;
-retry:
+
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);
@@ -6632,8 +6710,9 @@ retry:
 			if (isolate_lru_page(page))
 				goto put;
 			pc = lookup_page_cgroup(page);
-			if (!mem_cgroup_move_account(page, 1, pc,
-						     mc.from, mc.to)) {
+			ret = mem_cgroup_move_account(page, 1, pc,
+						      mc.from, mc.to);
+			if (!ret) {
 				mc.precharge--;
 				/* we uncharge from mc.from later. */
 				mc.moved_charge++;
@@ -6653,11 +6732,15 @@ put:			/* get_mctgt_type() gets the page
 		default:
 			break;
 		}
+		if (ret == -EAGAIN)
+			break;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
 
 	if (addr != end) {
+		if (ret == -EAGAIN)
+			goto retry;
 		/*
 		 * We have consumed all precharges we got in can_attach().
 		 * We try charge one by one, but don't do any additional
--- 3.8-rc2/mm/rmap.c	2012-12-22 09:43:27.656015582 -0800
+++ linux/mm/rmap.c	2013-01-02 15:03:46.100417650 -0800
@@ -1107,15 +1107,14 @@ void page_add_new_anon_rmap(struct page
  */
 void page_add_file_rmap(struct page *page)
 {
-	bool locked;
-	unsigned long flags;
+	bool clamped;
 
-	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+	mem_cgroup_begin_update_page_stat(page, &clamped);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
 	}
-	mem_cgroup_end_update_page_stat(page, &locked, &flags);
+	mem_cgroup_end_update_page_stat(page, &clamped);
 }
 
 /**
@@ -1128,16 +1127,15 @@ void page_remove_rmap(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	bool anon = PageAnon(page);
-	bool locked;
-	unsigned long flags;
+	bool uninitialized_var(clamped);
 
 	/*
 	 * The anon case has no mem_cgroup page_stat to update; but may
-	 * uncharge_page() below, where the lock ordering can deadlock if
-	 * we hold the lock against page_stat move: so avoid it on anon.
+	 * uncharge_page() below, when holding page_cgroup lock might force
+	 * a page_stat move to back off temporarily: so avoid it on anon.
 	 */
 	if (!anon)
-		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+		mem_cgroup_begin_update_page_stat(page, &clamped);
 
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
@@ -1182,7 +1180,7 @@ void page_remove_rmap(struct page *page)
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+		mem_cgroup_end_update_page_stat(page, &clamped);
 	}
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
@@ -1198,7 +1196,7 @@ void page_remove_rmap(struct page *page)
 	return;
 out:
 	if (!anon)
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+		mem_cgroup_end_update_page_stat(page, &clamped);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id D73B26B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 03:36:31 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so3474785yha.35
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 00:36:31 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id z48si11965636yha.56.2013.12.16.00.36.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 00:36:30 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id kx10so2607988pab.8
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 00:36:29 -0800 (PST)
Date: Mon, 16 Dec 2013 00:36:05 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: 3.13-rc breaks MEMCG_SWAP
Message-ID: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

CONFIG_MEMCG_SWAP is broken in 3.13-rc.  Try something like this:

mkdir -p /tmp/tmpfs /tmp/memcg
mount -t tmpfs -o size=1G tmpfs /tmp/tmpfs
mount -t cgroup -o memory memcg /tmp/memcg
mkdir /tmp/memcg/old
echo 512M >/tmp/memcg/old/memory.limit_in_bytes
echo $$ >/tmp/memcg/old/tasks
cp /dev/zero /tmp/tmpfs/zero 2>/dev/null
echo $$ >/tmp/memcg/tasks
rmdir /tmp/memcg/old
sleep 1	# let rmdir work complete
mkdir /tmp/memcg/new
umount /tmp/tmpfs
dmesg | grep WARNING
rmdir /tmp/memcg/new
umount /tmp/memcg

Shows lots of WARNING: CPU: 1 PID: 1006 at kernel/res_counter.c:91
                           res_counter_uncharge_locked+0x1f/0x2f()

Breakage comes from 34c00c319ce7 ("memcg: convert to use cgroup id").

The lifetime of a cgroup id is different from the lifetime of the
css id it replaced: memsw's css_get()s do nothing to hold on to the
old cgroup id, it soon gets recycled to a new cgroup, which then
mysteriously inherits the old's swap, without any charge for it.
(I thought memsw's particular need had been discussed and was
well understood when 34c00c319ce7 went in, but apparently not.)

The right thing to do at this stage would be to revert that and its
associated commits; but I imagine to do so would be unwelcome to
the cgroup guys, going against their general direction; and I've
no idea how embedded that css_id removal has become by now.

Perhaps some creative refcounting can rescue memsw while still
using cgroup id?

But if not, I've looked up and updated a patch I prepared eighteen
months ago (when I too misunderstood how that memsw refcounting
worked, and mistakenly thought something like this necessary):
to scan the swap_cgroup arrays reassigning id when reparented.
This works fine in the testing I've done on it.

I've not given enough thought to the races around mem_cgroup_lookup():
maybe it's okay as I have it, maybe it needs more (perhaps restoring
the extra css_gets and css_puts that I removed, though that would be
a little sad).  And I've made almost no attempt to optimize the scan
of all swap areas, beyond not doing it if the memcg is using no swap.

I've kept in the various things that patch was doing, and not thought
through what their interdependencies are: it should probably be split
up e.g. some swap_cgroup locking changes in page_cgroup.c, to make the
locking easier or more efficient when reassigning.  But I'll certainly
not spend time on that if you decide to rescue memsw by some other way.

Hugh
---

 include/linux/page_cgroup.h |    1 
 mm/memcontrol.c             |   74 ++++++++++++++-------------
 mm/page_cgroup.c            |   90 +++++++++++++++++++++++-----------
 3 files changed, 101 insertions(+), 64 deletions(-)

--- 3.13-rc4/include/linux/page_cgroup.h	2012-09-30 16:47:46.000000000 -0700
+++ linux/include/linux/page_cgroup.h	2013-12-15 14:34:36.304485959 -0800
@@ -111,6 +111,7 @@ extern unsigned short swap_cgroup_cmpxch
 					unsigned short old, unsigned short new);
 extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
 extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
+extern long swap_cgroup_reassign(unsigned short old, unsigned short new);
 extern int swap_cgroup_swapon(int type, unsigned long max_pages);
 extern void swap_cgroup_swapoff(int type);
 #else
--- 3.13-rc4/mm/memcontrol.c	2013-12-15 13:15:41.634280121 -0800
+++ linux/mm/memcontrol.c	2013-12-15 14:34:36.308485960 -0800
@@ -873,10 +873,8 @@ static long mem_cgroup_read_stat(struct
 	return val;
 }
 
-static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
-					 bool charge)
+static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg, long val)
 {
-	int val = (charge) ? 1 : -1;
 	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
 }
 
@@ -2871,8 +2869,8 @@ struct mem_cgroup *try_get_mem_cgroup_fr
 			memcg = NULL;
 	} else if (PageSwapCache(page)) {
 		ent.val = page_private(page);
-		id = lookup_swap_cgroup_id(ent);
 		rcu_read_lock();
+		id = lookup_swap_cgroup_id(ent);
 		memcg = mem_cgroup_lookup(id);
 		if (memcg && !css_tryget(&memcg->css))
 			memcg = NULL;
@@ -4238,15 +4236,11 @@ __mem_cgroup_uncharge_common(struct page
 	 */
 
 	unlock_page_cgroup(pc);
-	/*
-	 * even after unlock, we have memcg->res.usage here and this memcg
-	 * will never be freed, so it's safe to call css_get().
-	 */
+
 	memcg_check_events(memcg, page);
-	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
-		mem_cgroup_swap_statistics(memcg, true);
-		css_get(&memcg->css);
-	}
+	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
+		mem_cgroup_swap_statistics(memcg, 1);
+
 	/*
 	 * Migration does not charge the res_counter for the
 	 * replacement page, so leave it alone when phasing out the
@@ -4356,8 +4350,7 @@ mem_cgroup_uncharge_swapcache(struct pag
 	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
 
 	/*
-	 * record memcg information,  if swapout && memcg != NULL,
-	 * css_get() was called in uncharge().
+	 * record memcg information
 	 */
 	if (do_swap_account && swapout && memcg)
 		swap_cgroup_record(ent, mem_cgroup_id(memcg));
@@ -4377,8 +4370,8 @@ void mem_cgroup_uncharge_swap(swp_entry_
 	if (!do_swap_account)
 		return;
 
-	id = swap_cgroup_record(ent, 0);
 	rcu_read_lock();
+	id = swap_cgroup_record(ent, 0);
 	memcg = mem_cgroup_lookup(id);
 	if (memcg) {
 		/*
@@ -4387,8 +4380,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 		 */
 		if (!mem_cgroup_is_root(memcg))
 			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
-		mem_cgroup_swap_statistics(memcg, false);
-		css_put(&memcg->css);
+		mem_cgroup_swap_statistics(memcg, -1);
 	}
 	rcu_read_unlock();
 }
@@ -4415,31 +4407,40 @@ static int mem_cgroup_move_swap_account(
 	old_id = mem_cgroup_id(from);
 	new_id = mem_cgroup_id(to);
 
-	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		mem_cgroup_swap_statistics(from, false);
-		mem_cgroup_swap_statistics(to, true);
-		/*
-		 * This function is only called from task migration context now.
-		 * It postpones res_counter and refcount handling till the end
-		 * of task migration(mem_cgroup_clear_mc()) for performance
-		 * improvement. But we cannot postpone css_get(to)  because if
-		 * the process that has been moved to @to does swap-in, the
-		 * refcount of @to might be decreased to 0.
-		 *
-		 * We are in attach() phase, so the cgroup is guaranteed to be
-		 * alive, so we can just call css_get().
-		 */
-		css_get(&to->css);
+	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id)
 		return 0;
-	}
+
 	return -EINVAL;
 }
+
+static void mem_cgroup_reparent_swap(struct mem_cgroup *memcg)
+{
+	if (do_swap_account &&
+	    res_counter_read_u64(&memcg->memsw, RES_USAGE) >
+	    res_counter_read_u64(&memcg->kmem, RES_USAGE)) {
+		struct mem_cgroup *parent;
+		long reassigned;
+
+		parent = parent_mem_cgroup(memcg);
+		if (!parent)
+			parent = root_mem_cgroup;
+		reassigned = swap_cgroup_reassign(mem_cgroup_id(memcg),
+						  mem_cgroup_id(parent));
+
+		mem_cgroup_swap_statistics(memcg, -reassigned);
+		mem_cgroup_swap_statistics(parent, reassigned);
+	}
+}
 #else
 static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 				struct mem_cgroup *from, struct mem_cgroup *to)
 {
 	return -EINVAL;
 }
+
+static inline void mem_cgroup_reparent_swap(struct mem_cgroup *memcg)
+{
+}
 #endif
 
 /*
@@ -5017,6 +5018,7 @@ static int mem_cgroup_force_empty(struct
 	}
 	lru_add_drain();
 	mem_cgroup_reparent_charges(memcg);
+	/* but mem_cgroup_force_empty does not mem_cgroup_reparent_swap */
 
 	return 0;
 }
@@ -6348,6 +6350,7 @@ static void mem_cgroup_css_offline(struc
 
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
+	mem_cgroup_reparent_swap(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
@@ -6702,7 +6705,6 @@ static void __mem_cgroup_clear_mc(void)
 {
 	struct mem_cgroup *from = mc.from;
 	struct mem_cgroup *to = mc.to;
-	int i;
 
 	/* we must uncharge all the leftover precharges from mc.to */
 	if (mc.precharge) {
@@ -6724,8 +6726,8 @@ static void __mem_cgroup_clear_mc(void)
 			res_counter_uncharge(&mc.from->memsw,
 						PAGE_SIZE * mc.moved_swap);
 
-		for (i = 0; i < mc.moved_swap; i++)
-			css_put(&mc.from->css);
+		mem_cgroup_swap_statistics(from, -mc.moved_swap);
+		mem_cgroup_swap_statistics(to, mc.moved_swap);
 
 		if (!mem_cgroup_is_root(mc.to)) {
 			/*
--- 3.13-rc4/mm/page_cgroup.c	2013-02-18 15:58:34.000000000 -0800
+++ linux/mm/page_cgroup.c	2013-12-15 14:34:36.312485960 -0800
@@ -322,7 +322,8 @@ void __meminit pgdat_page_cgroup_init(st
 
 #ifdef CONFIG_MEMCG_SWAP
 
-static DEFINE_MUTEX(swap_cgroup_mutex);
+static DEFINE_SPINLOCK(swap_cgroup_lock);
+
 struct swap_cgroup_ctrl {
 	struct page **map;
 	unsigned long length;
@@ -353,14 +354,11 @@ struct swap_cgroup {
 /*
  * allocate buffer for swap_cgroup.
  */
-static int swap_cgroup_prepare(int type)
+static int swap_cgroup_prepare(struct swap_cgroup_ctrl *ctrl)
 {
 	struct page *page;
-	struct swap_cgroup_ctrl *ctrl;
 	unsigned long idx, max;
 
-	ctrl = &swap_cgroup_ctrl[type];
-
 	for (idx = 0; idx < ctrl->length; idx++) {
 		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 		if (!page)
@@ -407,18 +405,17 @@ unsigned short swap_cgroup_cmpxchg(swp_e
 {
 	struct swap_cgroup_ctrl *ctrl;
 	struct swap_cgroup *sc;
-	unsigned long flags;
 	unsigned short retval;
 
 	sc = lookup_swap_cgroup(ent, &ctrl);
 
-	spin_lock_irqsave(&ctrl->lock, flags);
+	spin_lock(&ctrl->lock);
 	retval = sc->id;
 	if (retval == old)
 		sc->id = new;
 	else
 		retval = 0;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
+	spin_unlock(&ctrl->lock);
 	return retval;
 }
 
@@ -435,14 +432,13 @@ unsigned short swap_cgroup_record(swp_en
 	struct swap_cgroup_ctrl *ctrl;
 	struct swap_cgroup *sc;
 	unsigned short old;
-	unsigned long flags;
 
 	sc = lookup_swap_cgroup(ent, &ctrl);
 
-	spin_lock_irqsave(&ctrl->lock, flags);
+	spin_lock(&ctrl->lock);
 	old = sc->id;
 	sc->id = id;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
+	spin_unlock(&ctrl->lock);
 
 	return old;
 }
@@ -451,19 +447,60 @@ unsigned short swap_cgroup_record(swp_en
  * lookup_swap_cgroup_id - lookup mem_cgroup id tied to swap entry
  * @ent: swap entry to be looked up.
  *
- * Returns CSS ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
+ * Returns ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
  */
 unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
 {
 	return lookup_swap_cgroup(ent, NULL)->id;
 }
 
+/**
+ * swap_cgroup_reassign - assign all old entries to new (before old is freed).
+ * @old: id of emptied memcg whose entries are now to be reassigned
+ * @new: id of parent memcg to which those entries are to be assigned
+ *
+ * Returns number of entries reassigned, for debugging or for statistics.
+ */
+long swap_cgroup_reassign(unsigned short old, unsigned short new)
+{
+	long reassigned = 0;
+	int type;
+
+	for (type = 0; type < MAX_SWAPFILES; type++) {
+		struct swap_cgroup_ctrl *ctrl = &swap_cgroup_ctrl[type];
+		unsigned long idx;
+
+		for (idx = 0; idx < ACCESS_ONCE(ctrl->length); idx++) {
+			struct swap_cgroup *sc, *scend;
+
+			spin_lock(&swap_cgroup_lock);
+			if (idx >= ACCESS_ONCE(ctrl->length))
+				goto unlock;
+			sc = page_address(ctrl->map[idx]);
+			for (scend = sc + SC_PER_PAGE; sc < scend; sc++) {
+				if (sc->id != old)
+					continue;
+				spin_lock(&ctrl->lock);
+				if (sc->id == old) {
+					sc->id = new;
+					reassigned++;
+				}
+				spin_unlock(&ctrl->lock);
+			}
+unlock:
+			spin_unlock(&swap_cgroup_lock);
+			cond_resched();
+		}
+	}
+	return reassigned;
+}
+
 int swap_cgroup_swapon(int type, unsigned long max_pages)
 {
 	void *array;
 	unsigned long array_size;
 	unsigned long length;
-	struct swap_cgroup_ctrl *ctrl;
+	struct swap_cgroup_ctrl ctrl;
 
 	if (!do_swap_account)
 		return 0;
@@ -475,23 +512,20 @@ int swap_cgroup_swapon(int type, unsigne
 	if (!array)
 		goto nomem;
 
-	ctrl = &swap_cgroup_ctrl[type];
-	mutex_lock(&swap_cgroup_mutex);
-	ctrl->length = length;
-	ctrl->map = array;
-	spin_lock_init(&ctrl->lock);
-	if (swap_cgroup_prepare(type)) {
-		/* memory shortage */
-		ctrl->map = NULL;
-		ctrl->length = 0;
-		mutex_unlock(&swap_cgroup_mutex);
-		vfree(array);
+	ctrl.length = length;
+	ctrl.map = array;
+	spin_lock_init(&ctrl.lock);
+
+	if (swap_cgroup_prepare(&ctrl))
 		goto nomem;
-	}
-	mutex_unlock(&swap_cgroup_mutex);
+
+	spin_lock(&swap_cgroup_lock);
+	swap_cgroup_ctrl[type] = ctrl;
+	spin_unlock(&swap_cgroup_lock);
 
 	return 0;
 nomem:
+	vfree(array);
 	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
 	printk(KERN_INFO
 		"swap_cgroup can be disabled by swapaccount=0 boot option\n");
@@ -507,13 +541,13 @@ void swap_cgroup_swapoff(int type)
 	if (!do_swap_account)
 		return;
 
-	mutex_lock(&swap_cgroup_mutex);
+	spin_lock(&swap_cgroup_lock);
 	ctrl = &swap_cgroup_ctrl[type];
 	map = ctrl->map;
 	length = ctrl->length;
 	ctrl->map = NULL;
 	ctrl->length = 0;
-	mutex_unlock(&swap_cgroup_mutex);
+	spin_unlock(&swap_cgroup_lock);
 
 	if (map) {
 		for (i = 0; i < length; i++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

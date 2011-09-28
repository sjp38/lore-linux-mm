Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 90FB09000C7
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:49:39 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p8S0nb5e030107
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:37 -0700
Received: from iadx2 (iadx2.prod.google.com [10.12.150.2])
	by wpaz1.hot.corp.google.com with ESMTP id p8S0nT8j010367
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:36 -0700
Received: by iadx2 with SMTP id x2so7477679iad.20
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:36 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 4/9] kstaled: minimalistic implementation.
Date: Tue, 27 Sep 2011 17:49:02 -0700
Message-Id: <1317170947-17074-5-git-send-email-walken@google.com>
In-Reply-To: <1317170947-17074-1-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

Introduce minimal kstaled implementation. The scan rate is controlled by
/sys/kernel/mm/kstaled/scan_seconds and per-cgroup statistics are output
into /dev/cgroup/*/memory.idle_page_stats.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memcontrol.c |  297 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 297 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e013b8e..e55056f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,8 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/kthread.h>
+#include <linux/rmap.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -283,6 +285,16 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
+
+#ifdef CONFIG_KSTALED
+	seqcount_t idle_page_stats_lock;
+	struct idle_page_stats {
+		unsigned long idle_clean;
+		unsigned long idle_dirty_file;
+		unsigned long idle_dirty_swap;
+	} idle_page_stats, idle_scan_stats;
+	unsigned long idle_page_scans;
+#endif
 };
 
 /* Stuffs for move charges at task migration. */
@@ -4668,6 +4680,30 @@ static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
 }
 #endif /* CONFIG_NUMA */
 
+#ifdef CONFIG_KSTALED
+static int mem_cgroup_idle_page_stats_read(struct cgroup *cgrp,
+	struct cftype *cft,  struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	unsigned int seqcount;
+	struct idle_page_stats stats;
+	unsigned long scans;
+
+	do {
+		seqcount = read_seqcount_begin(&memcg->idle_page_stats_lock);
+		stats = memcg->idle_page_stats;
+		scans = memcg->idle_page_scans;
+	} while (read_seqcount_retry(&memcg->idle_page_stats_lock, seqcount));
+
+	cb->fill(cb, "idle_clean", stats.idle_clean * PAGE_SIZE);
+	cb->fill(cb, "idle_dirty_file", stats.idle_dirty_file * PAGE_SIZE);
+	cb->fill(cb, "idle_dirty_swap", stats.idle_dirty_swap * PAGE_SIZE);
+	cb->fill(cb, "scans", scans);
+
+	return 0;
+}
+#endif /* CONFIG_KSTALED */
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4738,6 +4774,12 @@ static struct cftype mem_cgroup_files[] = {
 		.mode = S_IRUGO,
 	},
 #endif
+#ifdef CONFIG_KSTALED
+	{
+		.name = "idle_page_stats",
+		.read_map = mem_cgroup_idle_page_stats_read,
+	},
+#endif
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -5001,6 +5043,9 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
+#ifdef CONFIG_KSTALED
+	seqcount_init(&mem->idle_page_stats_lock);
+#endif
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
@@ -5568,3 +5613,255 @@ static int __init enable_swap_account(char *s)
 __setup("swapaccount=", enable_swap_account);
 
 #endif
+
+#ifdef CONFIG_KSTALED
+
+static unsigned int kstaled_scan_seconds;
+static DECLARE_WAIT_QUEUE_HEAD(kstaled_wait);
+
+static unsigned kstaled_scan_page(struct page *page)
+{
+	bool is_locked = false;
+	bool is_file;
+	struct page_referenced_info info;
+	struct page_cgroup *pc;
+	struct idle_page_stats *stats;
+	unsigned nr_pages;
+
+	/*
+	 * Before taking the page reference, check if the page is
+	 * a user page which is not obviously unreclaimable
+	 * (we will do more complete checks later).
+	 */
+	if (!PageLRU(page) ||
+	    (!PageCompound(page) &&
+	     (PageMlocked(page) ||
+	      (page->mapping == NULL && !PageSwapCache(page)))))
+		return 1;
+
+	if (!get_page_unless_zero(page))
+		return 1;
+
+	/* Recheck now that we have the page reference. */
+	if (unlikely(!PageLRU(page)))
+		goto out;
+	nr_pages = 1 << compound_trans_order(page);
+	if (PageMlocked(page))
+		goto out;
+
+	/*
+	 * Anon and SwapCache pages can be identified without locking.
+	 * For all other cases, we need the page locked in order to
+	 * dereference page->mapping.
+	 */
+	if (PageAnon(page) || PageSwapCache(page))
+		is_file = false;
+	else if (!trylock_page(page)) {
+		/*
+		 * We need to lock the page to dereference the mapping.
+		 * But don't risk sleeping by calling lock_page().
+		 * We don't want to stall kstaled, so we conservatively
+		 * count locked pages as unreclaimable.
+		 */
+		goto out;
+	} else {
+		struct address_space *mapping = page->mapping;
+
+		is_locked = true;
+
+		/*
+		 * The page is still anon - it has been continuously referenced
+		 * since the prior check.
+		 */
+		VM_BUG_ON(PageAnon(page) || mapping != page_rmapping(page));
+
+		/*
+		 * Check the mapping under protection of the page lock.
+		 * 1. If the page is not swap cache and has no mapping,
+		 *    shrink_page_list can't do anything with it.
+		 * 2. If the mapping is unevictable (as in SHM_LOCK segments),
+		 *    shrink_page_list can't do anything with it.
+		 * 3. If the page is swap cache or the mapping is swap backed
+		 *    (as in shmem), consider it a swappable page.
+		 * 4. If the backing dev has indicated that it does not want
+		 *    its pages sync'd to disk (as in ramfs), take this as
+		 *    a hint that its pages are not reclaimable.
+		 * 5. Otherwise, consider this as a file page reclaimable
+		 *    through standard pageout.
+		 */
+		if (!mapping && !PageSwapCache(page))
+			goto out;
+		else if (mapping_unevictable(mapping))
+			goto out;
+		else if (PageSwapCache(page) ||
+			 mapping_cap_swap_backed(mapping))
+			is_file = false;
+		else if (!mapping_cap_writeback_dirty(mapping))
+			goto out;
+		else
+			is_file = true;
+	}
+
+	/* Find out if the page is idle. Also test for pending mlock. */
+	page_referenced_kstaled(page, is_locked, &info);
+	if ((info.pr_flags & PR_REFERENCED) || (info.vm_flags & VM_LOCKED))
+		goto out;
+
+	/* Locate kstaled stats for the page's cgroup. */
+	pc = lookup_page_cgroup(page);
+	if (!pc)
+		goto out;
+	lock_page_cgroup(pc);
+	if (!PageCgroupUsed(pc))
+		goto unlock_page_cgroup_out;
+	stats = &pc->mem_cgroup->idle_scan_stats;
+
+	/* Finally increment the correct statistic for this page. */
+	if (!(info.pr_flags & PR_DIRTY) &&
+	    !PageDirty(page) && !PageWriteback(page))
+		stats->idle_clean += nr_pages;
+	else if (is_file)
+		stats->idle_dirty_file += nr_pages;
+	else
+		stats->idle_dirty_swap += nr_pages;
+
+ unlock_page_cgroup_out:
+	unlock_page_cgroup(pc);
+
+ out:
+	if (is_locked)
+		unlock_page(page);
+	put_page(page);
+
+	return nr_pages;
+}
+
+static void kstaled_scan_node(pg_data_t *pgdat)
+{
+	unsigned long flags;
+	unsigned long pfn, end;
+
+	pgdat_resize_lock(pgdat, &flags);
+
+	pfn = pgdat->node_start_pfn;
+	end = pfn + pgdat->node_spanned_pages;
+
+	while (pfn < end) {
+		if (need_resched()) {
+			pgdat_resize_unlock(pgdat, &flags);
+			cond_resched();
+			pgdat_resize_lock(pgdat, &flags);
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+			/* abort if the node got resized */
+			if (pfn < pgdat->node_start_pfn ||
+			    end > (pgdat->node_start_pfn +
+				   pgdat->node_spanned_pages))
+				goto abort;
+#endif
+		}
+
+		pfn += pfn_valid(pfn) ?
+			kstaled_scan_page(pfn_to_page(pfn)) : 1;
+	}
+
+abort:
+	pgdat_resize_unlock(pgdat, &flags);
+}
+
+static int kstaled(void *dummy)
+{
+	while (1) {
+		int scan_seconds;
+		int nid;
+		struct mem_cgroup *memcg;
+
+		wait_event_interruptible(kstaled_wait,
+				 (scan_seconds = kstaled_scan_seconds) > 0);
+		/*
+		 * We use interruptible wait_event so as not to contribute
+		 * to the machine load average while we're sleeping.
+		 * However, we don't actually expect to receive a signal
+		 * since we run as a kernel thread, so the condition we were
+		 * waiting for should be true once we get here.
+		 */
+		BUG_ON(scan_seconds <= 0);
+
+		for_each_mem_cgroup_all(memcg)
+			memset(&memcg->idle_scan_stats, 0,
+			       sizeof(memcg->idle_scan_stats));
+
+		for_each_node_state(nid, N_HIGH_MEMORY)
+			kstaled_scan_node(NODE_DATA(nid));
+
+		for_each_mem_cgroup_all(memcg) {
+			write_seqcount_begin(&memcg->idle_page_stats_lock);
+			memcg->idle_page_stats = memcg->idle_scan_stats;
+			memcg->idle_page_scans++;
+			write_seqcount_end(&memcg->idle_page_stats_lock);
+		}
+
+		schedule_timeout_interruptible(scan_seconds * HZ);
+	}
+
+	BUG();
+	return 0;	/* NOT REACHED */
+}
+
+static ssize_t kstaled_scan_seconds_show(struct kobject *kobj,
+					 struct kobj_attribute *attr,
+					 char *buf)
+{
+	return sprintf(buf, "%u\n", kstaled_scan_seconds);
+}
+
+static ssize_t kstaled_scan_seconds_store(struct kobject *kobj,
+					  struct kobj_attribute *attr,
+					  const char *buf, size_t count)
+{
+	int err;
+	unsigned long input;
+
+	err = kstrtoul(buf, 10, &input);
+	if (err)
+		return -EINVAL;
+	kstaled_scan_seconds = input;
+	wake_up_interruptible(&kstaled_wait);
+	return count;
+}
+
+static struct kobj_attribute kstaled_scan_seconds_attr = __ATTR(
+	scan_seconds, 0644,
+	kstaled_scan_seconds_show, kstaled_scan_seconds_store);
+
+static struct attribute *kstaled_attrs[] = {
+	&kstaled_scan_seconds_attr.attr,
+	NULL
+};
+static struct attribute_group kstaled_attr_group = {
+	.name = "kstaled",
+	.attrs = kstaled_attrs,
+};
+
+static int __init kstaled_init(void)
+{
+	int error;
+	struct task_struct *thread;
+
+	error = sysfs_create_group(mm_kobj, &kstaled_attr_group);
+	if (error) {
+		pr_err("Failed to create kstaled sysfs node\n");
+		return error;
+	}
+
+	thread = kthread_run(kstaled, NULL, "kstaled");
+	if (IS_ERR(thread)) {
+		pr_err("Failed to start kstaled\n");
+		return PTR_ERR(thread);
+	}
+
+	return 0;
+}
+module_init(kstaled_init);
+
+#endif /* CONFIG_KSTALED */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

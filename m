Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A09B98D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 04:44:27 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p2P8iPH0008871
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:25 -0700
Received: from iye7 (iye7.prod.google.com [10.241.50.7])
	by wpaz17.hot.corp.google.com with ESMTP id p2P8iObN005167
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:24 -0700
Received: by iye7 with SMTP id 7so350050iye.34
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:24 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/5] kstaled: minimalistic implementation.
Date: Fri, 25 Mar 2011 01:43:53 -0700
Message-Id: <1301042635-11180-4-git-send-email-walken@google.com>
In-Reply-To: <1301042635-11180-1-git-send-email-walken@google.com>
References: <1301042635-11180-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Introduce minimal kstaled implementation. The scan rate is controlled by
/sys/kernel/mm/kstaled/scan_seconds and per-cgroup statistics are output
into /dev/cgroup/*/memory.idle_page_stats

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memcontrol.c |  279 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 279 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index da53a25..042e266 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -48,6 +48,8 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/kthread.h>
+#include <linux/rmap.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -270,6 +272,14 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
+
+	seqcount_t idle_page_stats_lock;
+	struct idle_page_stats {
+		unsigned long idle_clean;
+		unsigned long idle_dirty_file;
+		unsigned long idle_dirty_swap;
+	} idle_page_stats, idle_scan_stats;
+	unsigned long idle_page_scans;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -4168,6 +4178,28 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	return 0;
 }
 
+static int mem_cgroup_idle_page_stats_read(struct cgroup *cgrp,
+	struct cftype *cft,  struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	unsigned int seqcount;
+	struct idle_page_stats stats;
+	unsigned long scans;
+
+	do {
+		seqcount = read_seqcount_begin(&mem->idle_page_stats_lock);
+		stats = mem->idle_page_stats;
+		scans = mem->idle_page_scans;
+	} while (read_seqcount_retry(&mem->idle_page_stats_lock, seqcount));
+
+	cb->fill(cb, "idle_clean", stats.idle_clean * PAGE_SIZE);
+	cb->fill(cb, "idle_dirty_file", stats.idle_dirty_file * PAGE_SIZE);
+	cb->fill(cb, "idle_dirty_swap", stats.idle_dirty_swap * PAGE_SIZE);
+	cb->fill(cb, "scans", scans);
+
+	return 0;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4231,6 +4263,10 @@ static struct cftype mem_cgroup_files[] = {
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "idle_page_stats",
+		.read_map = mem_cgroup_idle_page_stats_read,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -4494,6 +4530,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
+	seqcount_init(&mem->idle_page_stats_lock);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
@@ -5076,3 +5113,245 @@ static int __init disable_swap_account(char *s)
 }
 __setup("noswapaccount", disable_swap_account);
 #endif
+
+static unsigned int kstaled_scan_seconds;
+static DECLARE_WAIT_QUEUE_HEAD(kstaled_wait);
+
+static inline void kstaled_scan_page(struct page *page)
+{
+	bool is_locked = false;
+	bool is_file;
+	struct pr_info info;
+	struct page_cgroup *pc;
+	struct idle_page_stats *stats;
+
+	/*
+	 * Before taking the page reference, check if the page is
+	 * a user page which is not obviously unreclaimable
+	 * (we will do more complete checks later).
+	 */
+	if (!PageLRU(page) || PageMlocked(page) ||
+	    (page->mapping == NULL && !PageSwapCache(page)))
+		return;
+
+	if (!get_page_unless_zero(page))
+		return;
+
+	/* Recheck now that we have the page reference. */
+	if (unlikely(!PageLRU(page) || PageMlocked(page)))
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
+		else if (mapping && mapping_unevictable(mapping))
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
+	/*
+	 * Unlock early to avoid depending on lock ordering
+	 * between page and page_cgroup
+	 */
+	if (is_locked) {
+		unlock_page(page);
+		is_locked = false;
+	}
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
+		stats->idle_clean++;
+	else if (is_file)
+		stats->idle_dirty_file++;
+	else
+		stats->idle_dirty_swap++;
+
+ unlock_page_cgroup_out:
+	unlock_page_cgroup(pc);
+
+ out:
+	if (is_locked)
+		unlock_page(page);
+	put_page(page);
+}
+
+static void kstaled_scan_node(pg_data_t *pgdat)
+{
+	unsigned long flags;
+	unsigned long start, end, pfn;
+
+	pgdat_resize_lock(pgdat, &flags);
+
+	start = pgdat->node_start_pfn;
+	end = start + pgdat->node_spanned_pages;
+
+	for (pfn = start; pfn < end; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+
+		kstaled_scan_page(pfn_to_page(pfn));
+	}
+
+	pgdat_resize_unlock(pgdat, &flags);
+}
+
+static int kstaled(void *dummy)
+{
+	while (1) {
+		int scan_seconds;
+		int nid;
+		struct mem_cgroup *mem;
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
+		for_each_mem_cgroup_all(mem)
+			memset(&mem->idle_scan_stats, 0,
+			       sizeof(mem->idle_scan_stats));
+
+		for_each_node_state(nid, N_HIGH_MEMORY) {
+			const struct cpumask *cpumask = cpumask_of_node(nid);
+
+			if (!cpumask_empty(cpumask))
+				set_cpus_allowed_ptr(current, cpumask);
+
+			kstaled_scan_node(NODE_DATA(nid));
+		}
+
+		for_each_mem_cgroup_all(mem) {
+			write_seqcount_begin(&mem->idle_page_stats_lock);
+			mem->idle_page_stats = mem->idle_scan_stats;
+			mem->idle_page_scans++;
+			write_seqcount_end(&mem->idle_page_stats_lock);
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
+	err = strict_strtoul(buf, 10, &input);
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
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

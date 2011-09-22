Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 970729000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 19:15:06 -0400 (EDT)
Date: Thu, 22 Sep 2011 16:14:48 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [PATCH 4/8] kstaled: minimalistic implementation.
Message-Id: <20110922161448.91a2e2b2.akpm@google.com>
In-Reply-To: <1316230753-8693-5-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-5-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 16 Sep 2011 20:39:09 -0700
Michel Lespinasse <walken@google.com> wrote:

> Introduce minimal kstaled implementation. The scan rate is controlled by
> /sys/kernel/mm/kstaled/scan_seconds and per-cgroup statistics are output
> into /dev/cgroup/*/memory.idle_page_stats.
> 
>
> ...
>
> @@ -4668,6 +4680,30 @@ static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
>  }
>  #endif /* CONFIG_NUMA */
>  
> +#ifdef CONFIG_KSTALED
> +static int mem_cgroup_idle_page_stats_read(struct cgroup *cgrp,
> +	struct cftype *cft,  struct cgroup_map_cb *cb)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);

nit: please prefer to use identifier "memcg" when referring to a mem_cgroup.

> +	unsigned int seqcount;
> +	struct idle_page_stats stats;
> +	unsigned long scans;
> +
> +	do {
> +		seqcount = read_seqcount_begin(&mem->idle_page_stats_lock);
> +		stats = mem->idle_page_stats;
> +		scans = mem->idle_page_scans;
> +	} while (read_seqcount_retry(&mem->idle_page_stats_lock, seqcount));
> +
> +	cb->fill(cb, "idle_clean", stats.idle_clean * PAGE_SIZE);
> +	cb->fill(cb, "idle_dirty_file", stats.idle_dirty_file * PAGE_SIZE);
> +	cb->fill(cb, "idle_dirty_swap", stats.idle_dirty_swap * PAGE_SIZE);

So the user interface has units of bytes.  Was that documented
somewhere?  Is it worth bothering with?  getpagesize() exists...

(Actually, do we have a documentation update for the entire feature?)

> +	cb->fill(cb, "scans", scans);
> +
> +	return 0;
> +}
> +#endif /* CONFIG_KSTALED */
> +
>  static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
>
> ...
>
> @@ -5568,3 +5613,249 @@ static int __init enable_swap_account(char *s)
>  __setup("swapaccount=", enable_swap_account);
>  
>  #endif
> +
> +#ifdef CONFIG_KSTALED
> +
> +static unsigned int kstaled_scan_seconds;
> +static DECLARE_WAIT_QUEUE_HEAD(kstaled_wait);
> +
> +static inline void kstaled_scan_page(struct page *page)

uninline this.  You may find that the compiler already uninlined it. 
Or it might inline it for you even if it wasn't declared inline.  gcc
does a decent job of optimizing this stuff for us and hints are often
unneeded.

> +{
> +	bool is_locked = false;
> +	bool is_file;
> +	struct pr_info info;
> +	struct page_cgroup *pc;
> +	struct idle_page_stats *stats;
> +
> +	/*
> +	 * Before taking the page reference, check if the page is
> +	 * a user page which is not obviously unreclaimable
> +	 * (we will do more complete checks later).
> +	 */
> +	if (!PageLRU(page) || PageMlocked(page) ||
> +	    (page->mapping == NULL && !PageSwapCache(page)))
> +		return;
> +
> +	if (!get_page_unless_zero(page))
> +		return;
> +
> +	/* Recheck now that we have the page reference. */
> +	if (unlikely(!PageLRU(page) || PageMlocked(page)))
> +		goto out;
> +
> +	/*
> +	 * Anon and SwapCache pages can be identified without locking.
> +	 * For all other cases, we need the page locked in order to
> +	 * dereference page->mapping.
> +	 */
> +	if (PageAnon(page) || PageSwapCache(page))
> +		is_file = false;
> +	else if (!trylock_page(page)) {
> +		/*
> +		 * We need to lock the page to dereference the mapping.
> +		 * But don't risk sleeping by calling lock_page().
> +		 * We don't want to stall kstaled, so we conservatively
> +		 * count locked pages as unreclaimable.
> +		 */

hm.  Pages are rarely locked for very long.  They aren't locked during
writeback.   I question the need for this?

> +		goto out;
> +	} else {
> +		struct address_space *mapping = page->mapping;
> +
> +		is_locked = true;
> +
> +		/*
> +		 * The page is still anon - it has been continuously referenced
> +		 * since the prior check.
> +		 */
> +		VM_BUG_ON(PageAnon(page) || mapping != page_rmapping(page));

Really?  Are you sure that an elevated refcount is sufficient to
stabilise both of these?

> +		/*
> +		 * Check the mapping under protection of the page lock.
> +		 * 1. If the page is not swap cache and has no mapping,
> +		 *    shrink_page_list can't do anything with it.
> +		 * 2. If the mapping is unevictable (as in SHM_LOCK segments),
> +		 *    shrink_page_list can't do anything with it.
> +		 * 3. If the page is swap cache or the mapping is swap backed
> +		 *    (as in shmem), consider it a swappable page.
> +		 * 4. If the backing dev has indicated that it does not want
> +		 *    its pages sync'd to disk (as in ramfs), take this as
> +		 *    a hint that its pages are not reclaimable.
> +		 * 5. Otherwise, consider this as a file page reclaimable
> +		 *    through standard pageout.
> +		 */
> +		if (!mapping && !PageSwapCache(page))
> +			goto out;
> +		else if (mapping_unevictable(mapping))
> +			goto out;
> +		else if (PageSwapCache(page) ||
> +			 mapping_cap_swap_backed(mapping))
> +			is_file = false;
> +		else if (!mapping_cap_writeback_dirty(mapping))
> +			goto out;
> +		else
> +			is_file = true;
> +	}
> +
> +	/* Find out if the page is idle. Also test for pending mlock. */
> +	page_referenced_kstaled(page, is_locked, &info);
> +	if ((info.pr_flags & PR_REFERENCED) || (info.vm_flags & VM_LOCKED))
> +		goto out;
> +
> +	/* Locate kstaled stats for the page's cgroup. */
> +	pc = lookup_page_cgroup(page);
> +	if (!pc)
> +		goto out;
> +	lock_page_cgroup(pc);
> +	if (!PageCgroupUsed(pc))
> +		goto unlock_page_cgroup_out;
> +	stats = &pc->mem_cgroup->idle_scan_stats;
> +
> +	/* Finally increment the correct statistic for this page. */
> +	if (!(info.pr_flags & PR_DIRTY) &&
> +	    !PageDirty(page) && !PageWriteback(page))
> +		stats->idle_clean++;
> +	else if (is_file)
> +		stats->idle_dirty_file++;
> +	else
> +		stats->idle_dirty_swap++;
> +
> + unlock_page_cgroup_out:
> +	unlock_page_cgroup(pc);
> +
> + out:
> +	if (is_locked)
> +		unlock_page(page);
> +	put_page(page);
> +}
> +
> +static void kstaled_scan_node(pg_data_t *pgdat)
> +{
> +	unsigned long flags;
> +	unsigned long start, end, pfn;
> +
> +	pgdat_resize_lock(pgdat, &flags);
> +
> +	start = pgdat->node_start_pfn;
> +	end = start + pgdat->node_spanned_pages;
> +
> +	for (pfn = start; pfn < end; pfn++) {
> +		if (need_resched()) {
> +			pgdat_resize_unlock(pgdat, &flags);
> +			cond_resched();
> +			pgdat_resize_lock(pgdat, &flags);
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +			/* abort if the node got resized */
> +			if (pfn < pgdat->node_start_pfn ||
> +			    end > (pgdat->node_start_pfn +
> +				   pgdat->node_spanned_pages))
> +				goto abort;
> +#endif
> +		}
> +
> +		if (!pfn_valid(pfn))
> +			continue;
> +
> +		kstaled_scan_page(pfn_to_page(pfn));
> +	}
> +
> +abort:
> +	pgdat_resize_unlock(pgdat, &flags);
> +}
> +
> +static int kstaled(void *dummy)
> +{
> +	while (1) {
> +		int scan_seconds;
> +		int nid;
> +		struct mem_cgroup *mem;
> +
> +		wait_event_interruptible(kstaled_wait,
> +				 (scan_seconds = kstaled_scan_seconds) > 0);
> +		/*
> +		 * We use interruptible wait_event so as not to contribute
> +		 * to the machine load average while we're sleeping.
> +		 * However, we don't actually expect to receive a signal
> +		 * since we run as a kernel thread, so the condition we were
> +		 * waiting for should be true once we get here.
> +		 */
> +		BUG_ON(scan_seconds <= 0);
> +
> +		for_each_mem_cgroup_all(mem)
> +			memset(&mem->idle_scan_stats, 0,
> +			       sizeof(mem->idle_scan_stats));
> +
> +		for_each_node_state(nid, N_HIGH_MEMORY)
> +			kstaled_scan_node(NODE_DATA(nid));
> +
> +		for_each_mem_cgroup_all(mem) {
> +			write_seqcount_begin(&mem->idle_page_stats_lock);
> +			mem->idle_page_stats = mem->idle_scan_stats;
> +			mem->idle_page_scans++;
> +			write_seqcount_end(&mem->idle_page_stats_lock);
> +		}
> +
> +		schedule_timeout_interruptible(scan_seconds * HZ);
> +	}
> +
> +	BUG();
> +	return 0;	/* NOT REACHED */
> +}

OK, I'm really confused.

Take a minimal machine with a single node which contains one zone.

AFAICT this code will measure the number of idle pages in that zone and
then will attribute that number into *every* cgroup in the system. 
With no discrimination between them.  So it really provided no useful
information at all.

I was quite surprised to see a physical page scan!  I'd have expected
kstaled to be doing pte tree walks.


> +static ssize_t kstaled_scan_seconds_show(struct kobject *kobj,
> +					 struct kobj_attribute *attr,
> +					 char *buf)
> +{
> +	return sprintf(buf, "%u\n", kstaled_scan_seconds);
> +}
> +
> +static ssize_t kstaled_scan_seconds_store(struct kobject *kobj,
> +					  struct kobj_attribute *attr,
> +					  const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long input;
> +
> +	err = strict_strtoul(buf, 10, &input);

Please use the new kstrto*() interfaces when merging up to mainline.

> +	if (err)
> +		return -EINVAL;
> +	kstaled_scan_seconds = input;
> +	wake_up_interruptible(&kstaled_wait);
> +	return count;
> +}
> +
>
> ...
>
> +static int __init kstaled_init(void)
> +{
> +	int error;
> +	struct task_struct *thread;
> +
> +	error = sysfs_create_group(mm_kobj, &kstaled_attr_group);
> +	if (error) {
> +		pr_err("Failed to create kstaled sysfs node\n");
> +		return error;
> +	}
> +
> +	thread = kthread_run(kstaled, NULL, "kstaled");
> +	if (IS_ERR(thread)) {
> +		pr_err("Failed to start kstaled\n");
> +		return PTR_ERR(thread);
> +	}
> +
> +	return 0;
> +}

I wonder if one thread machine-wide will be sufficient.  We might end
up with per-nice threads, for example.  Like kswapd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

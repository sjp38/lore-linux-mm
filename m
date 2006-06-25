Date: Sat, 24 Jun 2006 17:49:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Light weight event counters V5
Message-ID: <Pine.LNX.4.64.0606241746540.16238@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(This touches some arch specific code but its getting rid of a lot of 
interrupt enable/disable in the VM. Contains Andrew's fixes for various 
arches. Not VM critical and this hopefully concludes the counter rework.)

[PATCH] Light weight event counters V5

The remaining counters in page_state after the zoned VM counter patches have
been applied are all just for show in /proc/vmstat. They have no essential
function for the VM.

We use a simple increment of per cpu variables. In order to avoid the
most severe races we disable preempt. Preempt does not prevent the race
between an increment and an interrupt handler incrementing the same
statistics counter. However, that race is exceedingly rare, we may
only loose one increment or so and there is no requirement (at least
not in kernel) that the vm event counters have to be accurate.

In the non preempt case this results in a simple increment for
each counter. For many architectures this will be reduced by the
compiler to a single instruction. This single instruction is atomic for
i386 and x86_64.  And therefore even the rare race condition in an
interrupt is avoided for both architectures in most cases.

The patchset also adds an off switch for embedded systems that allows a
building of linux kernels without these counters.

The implementation of these counters is through inline code that hopefully
results in only a single instruction increment instruction being emitted
(i386, x86_64) or in the increment being hidden though instruction
concurrency (EPIC architectures such as ia64 can get that done).

Benefits:
- VM event counter operations usually reduce to a single inline instruction
  on i386 and x86_64.
- No interrupt disable, only preempt disable for the preempt case.
  Preempt disable can also be avoided by moving the counter into a spinlock.
- Handling is similar to zoned VM counters.
- Simple and easily extendable.
- Can be omitted to reduce memory use for embedded use.

References:

RFC http://marc.theaimsgroup.com/?l=linux-kernel&m=113512330605497&w=2
RFC http://marc.theaimsgroup.com/?l=linux-kernel&m=114988082814934&w=2
local_t http://marc.theaimsgroup.com/?l=linux-kernel&m=114991748606690&w=2
V2 http://marc.theaimsgroup.com/?t=115014808400007&r=1&w=2
V3 http://marc.theaimsgroup.com/?l=linux-kernel&m=115024767022346&w=2
V4 http://marc.theaimsgroup.com/?l=linux-kernel&m=115047968808926&w=2

Changelog
========
V1->V2:
- Attempt to use local_t
- Include all the arch fixes in 2.6.17-rc6-mm2
- Based on ZVC patchset V3.

V2->V3:
- Restore the distinction between vm counter updates in
  interrupt  disable / non prempt state where we do not need
  to disable preempt and counter updates without any locks
  held.
- Obey the prior distinctions made for __inc_page_state etc.
  Howver, since we now only require preemption to be off.
  We switch a couple of uses over to use the  __ function.
- Do not use local_t since it currently also requires preempt.
- Applied on to top of the ZVC patchset V4.

V3->V4
- Remove unused functions from vmstat.h
- Switch a couple of more cases to __ by moving
  them into spinlocks, moving spinlocks etc.
- Still applies on top of ZVC patchset V4.

V4->V5
- Fix up for 2.6.17-mm2
- remove inclusion of local.h in vmstat.h
- The zone order was inverted for /proc/vmstat.

Tested on IA64 NUMA and x86_64 single processor.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-mm2/init/Kconfig
===================================================================
--- linux-2.6.17-mm2.orig/init/Kconfig	2006-06-24 15:53:01.205586534 -0700
+++ linux-2.6.17-mm2/init/Kconfig	2006-06-24 17:25:22.325406036 -0700
@@ -441,6 +441,15 @@ config SLAB
 	  SLOB is more space efficient but does not scale well and is
 	  more susceptible to fragmentation.
 
+config VM_EVENT_COUNTERS
+	default y
+	bool "Enable VM event counters for /proc/vmstat" if EMBEDDED
+	help
+	  VM event counters are only needed to for event counts to be
+	  shown. They have no function for the kernel itself. This
+	  option allows the disabling of the VM event counters.
+	  /proc/vmstat will only show page counts.
+
 endmenu		# General setup
 
 config TINY_SHMEM
Index: linux-2.6.17-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/page_alloc.c	2006-06-24 16:06:38.219500034 -0700
+++ linux-2.6.17-mm2/mm/page_alloc.c	2006-06-24 17:25:22.326382538 -0700
@@ -455,7 +455,7 @@ static void __free_pages_ok(struct page 
 
 	kernel_map_pages(page, 1 << order, 0);
 	local_irq_save(flags);
-	__mod_page_state(pgfree, 1 << order);
+	__count_vm_events(PGFREE, 1 << order);
 	free_one_page(page_zone(page), page, order);
 	local_irq_restore(flags);
 }
@@ -728,7 +728,7 @@ static void fastcall free_hot_cold_page(
 
 	pcp = &zone_pcp(zone, get_cpu())->pcp[cold];
 	local_irq_save(flags);
-	__inc_page_state(pgfree);
+	__count_vm_event(PGFREE);
 	list_add(&page->lru, &pcp->list);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
@@ -804,7 +804,7 @@ again:
 			goto failed;
 	}
 
-	__mod_page_state_zone(zone, pgalloc, 1 << order);
+	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(zonelist, zone);
 	local_irq_restore(flags);
 	put_cpu();
@@ -2125,24 +2125,11 @@ static int page_alloc_cpu_notify(struct 
 				 unsigned long action, void *hcpu)
 {
 	int cpu = (unsigned long)hcpu;
-	unsigned long *src, *dest;
 
 	if (action == CPU_DEAD) {
-		int i;
-
 		local_irq_disable();
 		__drain_pages(cpu);
-
-		/* Add dead cpu's page_states to our own. */
-		dest = (unsigned long *)&__get_cpu_var(page_states);
-		src = (unsigned long *)&per_cpu(page_states, cpu);
-
-		for (i = 0; i < sizeof(struct page_state)/sizeof(unsigned long);
-				i++) {
-			dest[i] += src[i];
-			src[i] = 0;
-		}
-
+		vm_events_fold_cpu(cpu);
 		local_irq_enable();
 		refresh_cpu_vm_stats(cpu);
 	}
Index: linux-2.6.17-mm2/block/ll_rw_blk.c
===================================================================
--- linux-2.6.17-mm2.orig/block/ll_rw_blk.c	2006-06-24 15:52:53.521491568 -0700
+++ linux-2.6.17-mm2/block/ll_rw_blk.c	2006-06-24 17:25:22.329312044 -0700
@@ -3169,9 +3169,9 @@ void submit_bio(int rw, struct bio *bio)
 	BIO_BUG_ON(!bio->bi_io_vec);
 	bio->bi_rw |= rw;
 	if (rw & WRITE)
-		mod_page_state(pgpgout, count);
+		count_vm_events(PGPGOUT, count);
 	else
-		mod_page_state(pgpgin, count);
+		count_vm_events(PGPGIN, count);
 
 	if (unlikely(block_dump)) {
 		char b[BDEVNAME_SIZE];
Index: linux-2.6.17-mm2/drivers/parisc/led.c
===================================================================
--- linux-2.6.17-mm2.orig/drivers/parisc/led.c	2006-06-24 15:52:55.646360121 -0700
+++ linux-2.6.17-mm2/drivers/parisc/led.c	2006-06-24 17:25:22.330288546 -0700
@@ -411,16 +411,17 @@ static __inline__ int led_get_net_activi
 static __inline__ int led_get_diskio_activity(void)
 {	
 	static unsigned long last_pgpgin, last_pgpgout;
-	struct page_state pgstat;
+	unsigned long events[NR_VM_EVENT_ITEMS];
 	int changed;
 
-	get_full_page_state(&pgstat); /* get no of sectors in & out */
+	all_vm_events(events);
 
 	/* Just use a very simple calculation here. Do not care about overflow,
 	   since we only want to know if there was activity or not. */
-	changed = (pgstat.pgpgin != last_pgpgin) || (pgstat.pgpgout != last_pgpgout);
-	last_pgpgin  = pgstat.pgpgin;
-	last_pgpgout = pgstat.pgpgout;
+	changed = (events[PGPGIN] != last_pgpgin) ||
+		  (events[PGPGOUT] != last_pgpgout);
+	last_pgpgin  = events[PGPGIN];
+	last_pgpgout = events[PGPGOUT];
 
 	return (changed ? LED_DISK_IO : 0);
 }
Index: linux-2.6.17-mm2/fs/inode.c
===================================================================
--- linux-2.6.17-mm2.orig/fs/inode.c	2006-06-24 15:52:57.406993394 -0700
+++ linux-2.6.17-mm2/fs/inode.c	2006-06-24 17:25:22.331265048 -0700
@@ -452,15 +452,14 @@ static void prune_icache(int nr_to_scan)
 		nr_pruned++;
 	}
 	inodes_stat.nr_unused -= nr_pruned;
+	if (current_is_kswapd())
+		__count_vm_events(KSWAPD_INODESTEAL, reap);
+	else
+		__count_vm_events(PGINODESTEAL, reap);
 	spin_unlock(&inode_lock);
 
 	dispose_list(&freeable);
 	mutex_unlock(&iprune_mutex);
-
-	if (current_is_kswapd())
-		mod_page_state(kswapd_inodesteal, reap);
-	else
-		mod_page_state(pginodesteal, reap);
 }
 
 /*
Index: linux-2.6.17-mm2/fs/ncpfs/mmap.c
===================================================================
--- linux-2.6.17-mm2.orig/fs/ncpfs/mmap.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm2/fs/ncpfs/mmap.c	2006-06-24 17:25:22.331265048 -0700
@@ -93,7 +93,7 @@ static struct page* ncp_file_mmap_nopage
 	 */
 	if (type)
 		*type = VM_FAULT_MAJOR;
-	inc_page_state(pgmajfault);
+	count_vm_event(PGMAJFAULT);
 	return page;
 }
 
Index: linux-2.6.17-mm2/mm/filemap.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/filemap.c	2006-06-24 15:53:01.383309915 -0700
+++ linux-2.6.17-mm2/mm/filemap.c	2006-06-24 17:25:22.333218052 -0700
@@ -1502,7 +1502,7 @@ retry_find:
 		 */
 		if (!did_readaround) {
 			majmin = VM_FAULT_MAJOR;
-			inc_page_state(pgmajfault);
+			count_vm_event(PGMAJFAULT);
 		}
 		did_readaround = 1;
 		ra_pages = max_sane_readahead(file->f_ra.ra_pages);
@@ -1585,7 +1585,7 @@ no_cached_page:
 page_not_uptodate:
 	if (!did_readaround) {
 		majmin = VM_FAULT_MAJOR;
-		inc_page_state(pgmajfault);
+		count_vm_event(PGMAJFAULT);
 	}
 	lock_page(page);
 
Index: linux-2.6.17-mm2/mm/memory.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/memory.c	2006-06-24 15:53:01.392098434 -0700
+++ linux-2.6.17-mm2/mm/memory.c	2006-06-24 17:25:22.334194554 -0700
@@ -1954,7 +1954,7 @@ static int do_swap_page(struct mm_struct
 
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
-		inc_page_state(pgmajfault);
+		count_vm_event(PGMAJFAULT);
 		grab_swap_token();
 	}
 
@@ -2328,7 +2328,7 @@ int __handle_mm_fault(struct mm_struct *
 
 	__set_current_state(TASK_RUNNING);
 
-	inc_page_state(pgfault);
+	count_vm_event(PGFAULT);
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, write_access);
Index: linux-2.6.17-mm2/mm/page_io.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/page_io.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm2/mm/page_io.c	2006-06-24 17:25:22.335171056 -0700
@@ -101,7 +101,7 @@ int swap_writepage(struct page *page, st
 	}
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		rw |= (1 << BIO_RW_SYNC);
-	inc_page_state(pswpout);
+	count_vm_event(PSWPOUT);
 	set_page_writeback(page);
 	unlock_page(page);
 	submit_bio(rw, bio);
@@ -123,7 +123,7 @@ int swap_readpage(struct file *file, str
 		ret = -ENOMEM;
 		goto out;
 	}
-	inc_page_state(pswpin);
+	count_vm_event(PSWPIN);
 	submit_bio(READ, bio);
 out:
 	return ret;
Index: linux-2.6.17-mm2/mm/shmem.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/shmem.c	2006-06-24 15:53:01.441900040 -0700
+++ linux-2.6.17-mm2/mm/shmem.c	2006-06-24 17:25:22.336147558 -0700
@@ -1046,12 +1046,12 @@ repeat:
 		swappage = lookup_swap_cache(swap);
 		if (!swappage) {
 			shmem_swp_unmap(entry);
-			spin_unlock(&info->lock);
 			/* here we actually do the io */
 			if (type && *type == VM_FAULT_MINOR) {
-				inc_page_state(pgmajfault);
+				__count_vm_event(PGMAJFAULT);
 				*type = VM_FAULT_MAJOR;
 			}
+			spin_unlock(&info->lock);
 			swappage = shmem_swapin(info, swap, idx);
 			if (!swappage) {
 				spin_lock(&info->lock);
Index: linux-2.6.17-mm2/mm/swap.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/swap.c	2006-06-24 15:53:01.447759053 -0700
+++ linux-2.6.17-mm2/mm/swap.c	2006-06-24 17:25:22.337124061 -0700
@@ -88,7 +88,7 @@ int rotate_reclaimable_page(struct page 
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (PageLRU(page) && !PageActive(page)) {
 		list_move_tail(&page->lru, &zone->inactive_list);
-		inc_page_state(pgrotated);
+		__count_vm_event(PGROTATED);
 	}
 	if (!test_clear_page_writeback(page))
 		BUG();
@@ -108,7 +108,7 @@ void fastcall activate_page(struct page 
 		del_page_from_inactive_list(zone, page);
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
-		inc_page_state(pgactivate);
+		__count_vm_event(PGACTIVATE);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
Index: linux-2.6.17-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/vmscan.c	2006-06-24 15:53:01.480960124 -0700
+++ linux-2.6.17-mm2/mm/vmscan.c	2006-06-24 17:25:22.338100563 -0700
@@ -216,7 +216,7 @@ unsigned long shrink_slab(unsigned long 
 				break;
 			if (shrink_ret < nr_before)
 				ret += nr_before - shrink_ret;
-			mod_page_state(slabs_scanned, this_scan);
+			count_vm_events(SLABS_SCANNED, this_scan);
 			total_scan -= this_scan;
 
 			cond_resched();
@@ -574,7 +574,7 @@ keep:
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
-	mod_page_state(pgactivate, pgactivate);
+	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
 
@@ -665,11 +665,11 @@ static unsigned long shrink_inactive_lis
 		nr_reclaimed += nr_freed;
 		local_irq_disable();
 		if (current_is_kswapd()) {
-			__mod_page_state_zone(zone, pgscan_kswapd, nr_scan);
-			__mod_page_state(kswapd_steal, nr_freed);
+			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scan);
+			__count_vm_events(KSWAPD_STEAL, nr_freed);
 		} else
-			__mod_page_state_zone(zone, pgscan_direct, nr_scan);
-		__mod_page_state_zone(zone, pgsteal, nr_freed);
+			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scan);
+		__count_vm_events(PGACTIVATE, nr_freed);
 
 		if (nr_taken == 0)
 			goto done;
@@ -847,11 +847,10 @@ static void shrink_active_list(unsigned 
 		}
 	}
 	zone->nr_active += pgmoved;
-	spin_unlock(&zone->lru_lock);
 
-	__mod_page_state_zone(zone, pgrefill, pgscanned);
-	__mod_page_state(pgdeactivate, pgdeactivate);
-	local_irq_enable();
+	__count_zone_vm_events(PGREFILL, zone, pgscanned);
+	__count_vm_events(PGDEACTIVATE, pgdeactivate);
+	spin_unlock_irq(&zone->lru_lock);
 
 	pagevec_release(&pvec);
 }
@@ -984,7 +983,7 @@ unsigned long try_to_free_pages(struct z
 	};
 
 	delay_swap_prefetch();
-	inc_page_state(allocstall);
+	count_vm_event(ALLOCSTALL);
 
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
@@ -1081,7 +1080,7 @@ loop_again:
 	total_scanned = 0;
 	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
-	inc_page_state(pageoutrun);
+	count_vm_event(PAGEOUTRUN);
 
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
Index: linux-2.6.17-mm2/arch/s390/appldata/appldata_mem.c
===================================================================
--- linux-2.6.17-mm2.orig/arch/s390/appldata/appldata_mem.c	2006-06-24 15:52:53.291037074 -0700
+++ linux-2.6.17-mm2/arch/s390/appldata/appldata_mem.c	2006-06-24 17:25:22.339077065 -0700
@@ -107,21 +107,21 @@ static void appldata_get_mem_data(void *
 	 * serialized through the appldata_ops_lock and can use static
 	 */
 	static struct sysinfo val;
-	static struct page_state ps;
+	unsigned long ev[NR_VM_EVENT_ITEMS];
 	struct appldata_mem_data *mem_data;
 
 	mem_data = data;
 	mem_data->sync_count_1++;
 
-	get_full_page_state(&ps);
-	mem_data->pgpgin     = ps.pgpgin >> 1;
-	mem_data->pgpgout    = ps.pgpgout >> 1;
-	mem_data->pswpin     = ps.pswpin;
-	mem_data->pswpout    = ps.pswpout;
-	mem_data->pgalloc    = ps.pgalloc_high + ps.pgalloc_normal +
-			       ps.pgalloc_dma;
-	mem_data->pgfault    = ps.pgfault;
-	mem_data->pgmajfault = ps.pgmajfault;
+	all_vm_events(ev);
+	mem_data->pgpgin     = ev[PGPGIN] >> 1;
+	mem_data->pgpgout    = ev[PGPGOUT] >> 1;
+	mem_data->pswpin     = ev[PSWPIN];
+	mem_data->pswpout    = ev[PSWPOUT];
+	mem_data->pgalloc    = ev[PGALLOC_HIGH] + ev[PGALLOC_NORMAL] +
+			       ev[PGALLOC_DMA];
+	mem_data->pgfault    = ev[PGFAULT];
+	mem_data->pgmajfault = ev[PGMAJFAULT];
 
 	si_meminfo(&val);
 	mem_data->sharedram = val.sharedram;
Index: linux-2.6.17-mm2/arch/s390/appldata/appldata_base.c
===================================================================
--- linux-2.6.17-mm2.orig/arch/s390/appldata/appldata_base.c	2006-06-24 15:52:53.290060572 -0700
+++ linux-2.6.17-mm2/arch/s390/appldata/appldata_base.c	2006-06-24 17:25:22.340053567 -0700
@@ -767,7 +767,6 @@ unsigned long nr_iowait(void)
 EXPORT_SYMBOL_GPL(si_swapinfo);
 EXPORT_SYMBOL_GPL(nr_threads);
 EXPORT_SYMBOL_GPL(avenrun);
-EXPORT_SYMBOL_GPL(get_full_page_state);
 EXPORT_SYMBOL_GPL(nr_running);
 EXPORT_SYMBOL_GPL(nr_iowait);
 //EXPORT_SYMBOL_GPL(nr_context_switches);
Index: linux-2.6.17-mm2/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/vmstat.c	2006-06-24 16:06:38.218523532 -0700
+++ linux-2.6.17-mm2/mm/vmstat.c	2006-06-24 17:25:22.341030069 -0700
@@ -13,66 +13,6 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 
-/*
- * Accumulate the page_state information across all CPUs.
- * The result is unavoidably approximate - it can change
- * during and after execution of this function.
- */
-DEFINE_PER_CPU(struct page_state, page_states) = {0};
-
-static void __get_page_state(struct page_state *ret, int nr, cpumask_t *cpumask)
-{
-	unsigned cpu;
-
-	memset(ret, 0, nr * sizeof(unsigned long));
-	cpus_and(*cpumask, *cpumask, cpu_online_map);
-
-	for_each_cpu_mask(cpu, *cpumask) {
-		unsigned long *in;
-		unsigned long *out;
-		unsigned off;
-		unsigned next_cpu;
-
-		in = (unsigned long *)&per_cpu(page_states, cpu);
-
-		next_cpu = next_cpu(cpu, *cpumask);
-		if (likely(next_cpu < NR_CPUS))
-			prefetch(&per_cpu(page_states, next_cpu));
-
-		out = (unsigned long *)ret;
-		for (off = 0; off < nr; off++)
-			*out++ += *in++;
-	}
-}
-
-void get_full_page_state(struct page_state *ret)
-{
-	cpumask_t mask = CPU_MASK_ALL;
-
-	__get_page_state(ret, sizeof(*ret) / sizeof(unsigned long), &mask);
-}
-
-void __mod_page_state_offset(unsigned long offset, unsigned long delta)
-{
-	void *ptr;
-
-	ptr = &__get_cpu_var(page_states);
-	*(unsigned long *)(ptr + offset) += delta;
-}
-EXPORT_SYMBOL(__mod_page_state_offset);
-
-void mod_page_state_offset(unsigned long offset, unsigned long delta)
-{
-	unsigned long flags;
-	void *ptr;
-
-	local_irq_save(flags);
-	ptr = &__get_cpu_var(page_states);
-	*(unsigned long *)(ptr + offset) += delta;
-	local_irq_restore(flags);
-}
-EXPORT_SYMBOL(mod_page_state_offset);
-
 void __get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free, struct pglist_data *pgdat)
 {
@@ -106,6 +46,63 @@ void get_zone_counts(unsigned long *acti
 	}
 }
 
+#ifdef CONFIG_VM_EVENT_COUNTERS
+DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
+EXPORT_PER_CPU_SYMBOL(vm_event_states);
+
+static void sum_vm_events(unsigned long *ret, cpumask_t *cpumask)
+{
+	int cpu = 0;
+	int i;
+
+	memset(ret, 0, NR_VM_EVENT_ITEMS * sizeof(unsigned long));
+
+	cpu = first_cpu(*cpumask);
+	while (cpu < NR_CPUS) {
+		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
+
+		cpu = next_cpu(cpu, *cpumask);
+
+		if (cpu < NR_CPUS)
+			prefetch(&per_cpu(vm_event_states, cpu));
+
+
+		for (i=0; i< NR_VM_EVENT_ITEMS; i++)
+			ret[i] += this->event[i];
+	}
+}
+
+/*
+ * Accumulate the vm event counters across all CPUs.
+ * The result is unavoidably approximate - it can change
+ * during and after execution of this function.
+*/
+void all_vm_events(unsigned long *ret)
+{
+	sum_vm_events(ret, &cpu_online_map);
+}
+
+#ifdef CONFIG_HOTPLUG
+/*
+ * Fold the foreign cpu events into our own.
+ *
+ * This is adding to the events on one processor
+ * but keeps the global counts constant.
+ */
+void vm_events_fold_cpu(int cpu)
+{
+	struct vm_event_state *fold_state = &per_cpu(vm_event_states, cpu);
+	int i;
+
+	for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
+		count_vm_events(i, fold_state->event[i]);
+		fold_state->event[i] = 0;
+	}
+}
+#endif /* CONFIG_HOTPLUG */
+
+#endif /* CONFIG_VM_EVENT_COUNTERS */
+
 /*
  * Manage combined zone based / global counters
  *
@@ -467,16 +464,16 @@ static char *vmstat_text[] = {
 	"numa_other",
 #endif
 
-	/* Event counters */
+#ifdef CONFIG_VM_EVENT_COUNTERS
 	"pgpgin",
 	"pgpgout",
 	"pswpin",
 	"pswpout",
 
-	"pgalloc_high",
-	"pgalloc_normal",
-	"pgalloc_dma32",
 	"pgalloc_dma",
+	"pgalloc_dma32",
+	"pgalloc_normal",
+	"pgalloc_high",
 
 	"pgfree",
 	"pgactivate",
@@ -485,25 +482,25 @@ static char *vmstat_text[] = {
 	"pgfault",
 	"pgmajfault",
 
-	"pgrefill_high",
-	"pgrefill_normal",
-	"pgrefill_dma32",
 	"pgrefill_dma",
+	"pgrefill_dma32",
+	"pgrefill_normal",
+	"pgrefill_high",
 
-	"pgsteal_high",
-	"pgsteal_normal",
-	"pgsteal_dma32",
 	"pgsteal_dma",
+	"pgsteal_dma32",
+	"pgsteal_normal",
+	"pgsteal_high",
 
-	"pgscan_kswapd_high",
-	"pgscan_kswapd_normal",
-	"pgscan_kswapd_dma32",
 	"pgscan_kswapd_dma",
+	"pgscan_kswapd_dma32",
+	"pgscan_kswapd_normal",
+	"pgscan_kswapd_high",
 
-	"pgscan_direct_high",
-	"pgscan_direct_normal",
-	"pgscan_direct_dma32",
 	"pgscan_direct_dma",
+	"pgscan_direct_dma32",
+	"pgscan_direct_normal",
+	"pgscan_direct_high",
 
 	"pginodesteal",
 	"slabs_scanned",
@@ -513,6 +510,7 @@ static char *vmstat_text[] = {
 	"allocstall",
 
 	"pgrotated",
+#endif
 };
 
 /*
@@ -615,23 +613,32 @@ struct seq_operations zoneinfo_op = {
 static void *vmstat_start(struct seq_file *m, loff_t *pos)
 {
 	unsigned long *v;
-	struct page_state *ps;
+#ifdef CONFIG_VM_EVENT_COUNTERS
+	unsigned long *e;
+#endif
 	int i;
 
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
 
+#ifdef CONFIG_VM_EVENT_COUNTERS
 	v = kmalloc(NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long)
-			+ sizeof(*ps), GFP_KERNEL);
+			+ sizeof(struct vm_event_state), GFP_KERNEL);
+#else
+	v = kmalloc(NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long),
+			GFP_KERNEL);
+#endif
 	m->private = v;
 	if (!v)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		v[i] = global_page_state(i);
-	ps = (struct page_state *)(v + NR_VM_ZONE_STAT_ITEMS);
-	get_full_page_state(ps);
-	ps->pgpgin /= 2;		/* sectors -> kbytes */
-	ps->pgpgout /= 2;
+#ifdef CONFIG_VM_EVENT_COUNTERS
+	e = v + NR_VM_ZONE_STAT_ITEMS;
+	all_vm_events(e);
+	e[PGPGIN] /= 2;		/* sectors -> kbytes */
+	e[PGPGOUT] /= 2;
+#endif
 	return v + *pos;
 }
 
Index: linux-2.6.17-mm2/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm2.orig/include/linux/vmstat.h	2006-06-24 16:06:38.223406043 -0700
+++ linux-2.6.17-mm2/include/linux/vmstat.h	2006-06-24 17:25:22.342006571 -0700
@@ -6,116 +6,78 @@
 #include <linux/config.h>
 #include <linux/mmzone.h>
 #include <asm/atomic.h>
-
+ 
+#ifdef CONFIG_VM_EVENT_COUNTERS
 /*
- * Global page accounting.  One instance per CPU.  Only unsigned longs are
- * allowed.
+ * Light weight per cpu counter implementation.
+ *
+ * Counters should only be incremented and no critical kernel component
+ * should rely on the counter values.
  *
- * - Fields can be modified with xxx_page_state and xxx_page_state_zone at
- * any time safely (which protects the instance from modification by
- * interrupt.
- * - The __xxx_page_state variants can be used safely when interrupts are
- * disabled.
- * - The __xxx_page_state variants can be used if the field is only
- * modified from process context and protected from preemption, or only
- * modified from interrupt context.  In this case, the field should be
- * commented here.
+ * Counters are handled completely inline. On many platforms the code
+ * generated will simply be the increment of a global address.
  */
-struct page_state {
-	unsigned long pgpgin;		/* Disk reads */
-	unsigned long pgpgout;		/* Disk writes */
-	unsigned long pswpin;		/* swap reads */
-	unsigned long pswpout;		/* swap writes */
-
-	unsigned long pgalloc_high;	/* page allocations */
-	unsigned long pgalloc_normal;
-	unsigned long pgalloc_dma32;
-	unsigned long pgalloc_dma;
-
-	unsigned long pgfree;		/* page freeings */
-	unsigned long pgactivate;	/* pages moved inactive->active */
-	unsigned long pgdeactivate;	/* pages moved active->inactive */
-
-	unsigned long pgfault;		/* faults (major+minor) */
-	unsigned long pgmajfault;	/* faults (major only) */
-
-	unsigned long pgrefill_high;	/* inspected in refill_inactive_zone */
-	unsigned long pgrefill_normal;
-	unsigned long pgrefill_dma32;
-	unsigned long pgrefill_dma;
-
-	unsigned long pgsteal_high;	/* total highmem pages reclaimed */
-	unsigned long pgsteal_normal;
-	unsigned long pgsteal_dma32;
-	unsigned long pgsteal_dma;
-
-	unsigned long pgscan_kswapd_high;/* total highmem pages scanned */
-	unsigned long pgscan_kswapd_normal;
-	unsigned long pgscan_kswapd_dma32;
-	unsigned long pgscan_kswapd_dma;
-
-	unsigned long pgscan_direct_high;/* total highmem pages scanned */
-	unsigned long pgscan_direct_normal;
-	unsigned long pgscan_direct_dma32;
-	unsigned long pgscan_direct_dma;
-
-	unsigned long pginodesteal;	/* pages reclaimed via inode freeing */
-	unsigned long slabs_scanned;	/* slab objects scanned */
-	unsigned long kswapd_steal;	/* pages reclaimed by kswapd */
-	unsigned long kswapd_inodesteal;/* reclaimed via kswapd inode freeing */
-	unsigned long pageoutrun;	/* kswapd's calls to page reclaim */
-	unsigned long allocstall;	/* direct reclaim calls */
 
-	unsigned long pgrotated;	/* pages rotated to tail of the LRU */
+#define FOR_ALL_ZONES(x) x##_DMA, x##_DMA32, x##_NORMAL, x##_HIGH
+
+enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
+		FOR_ALL_ZONES(PGALLOC),
+		PGFREE, PGACTIVATE, PGDEACTIVATE,
+		PGFAULT, PGMAJFAULT,
+		FOR_ALL_ZONES(PGREFILL),
+		FOR_ALL_ZONES(PGSTEAL),
+		FOR_ALL_ZONES(PGSCAN_KSWAPD),
+		FOR_ALL_ZONES(PGSCAN_DIRECT),
+		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
+		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		NR_VM_EVENT_ITEMS
 };
 
-extern void get_full_page_state(struct page_state *ret);
-extern void mod_page_state_offset(unsigned long offset, unsigned long delta);
-extern void __mod_page_state_offset(unsigned long offset, unsigned long delta);
-
-#define mod_page_state(member, delta)	\
-	mod_page_state_offset(offsetof(struct page_state, member), (delta))
-
-#define __mod_page_state(member, delta)	\
-	__mod_page_state_offset(offsetof(struct page_state, member), (delta))
-
-#define inc_page_state(member)		mod_page_state(member, 1UL)
-#define dec_page_state(member)		mod_page_state(member, 0UL - 1)
-#define add_page_state(member,delta)	mod_page_state(member, (delta))
-#define sub_page_state(member,delta)	mod_page_state(member, 0UL - (delta))
-
-#define __inc_page_state(member)	__mod_page_state(member, 1UL)
-#define __dec_page_state(member)	__mod_page_state(member, 0UL - 1)
-#define __add_page_state(member,delta)	__mod_page_state(member, (delta))
-#define __sub_page_state(member,delta)	__mod_page_state(member, 0UL - (delta))
-
-#define page_state(member) (*__page_state(offsetof(struct page_state, member)))
-
-#define state_zone_offset(zone, member)					\
-({									\
-	unsigned offset;						\
-	if (is_highmem(zone))						\
-		offset = offsetof(struct page_state, member##_high);	\
-	else if (is_normal(zone))					\
-		offset = offsetof(struct page_state, member##_normal);	\
-	else if (is_dma32(zone))					\
-		offset = offsetof(struct page_state, member##_dma32);	\
-	else								\
-		offset = offsetof(struct page_state, member##_dma);	\
-	offset;								\
-})
-
-#define __mod_page_state_zone(zone, member, delta)			\
- do {									\
-	__mod_page_state_offset(state_zone_offset(zone, member), (delta)); \
- } while (0)
-
-#define mod_page_state_zone(zone, member, delta)			\
- do {									\
-	mod_page_state_offset(state_zone_offset(zone, member), (delta)); \
- } while (0)
+struct vm_event_state {
+	unsigned long event[NR_VM_EVENT_ITEMS];
+};
+
+DECLARE_PER_CPU(struct vm_event_state, vm_event_states);
+
+static inline void __count_vm_event(enum vm_event_item item)
+{
+	__get_cpu_var(vm_event_states.event[item])++;
+}
+
+static inline void count_vm_event(enum vm_event_item item)
+{
+	get_cpu_var(vm_event_states.event[item])++;
+	put_cpu();
+}
+
+static inline void __count_vm_events(enum vm_event_item item, long delta)
+{
+	__get_cpu_var(vm_event_states.event[item]) += delta;
+}
+
+static inline void count_vm_events(enum vm_event_item item, long delta)
+{
+	get_cpu_var(vm_event_states.event[item])++;
+	put_cpu();
+}
+
+extern void all_vm_events(unsigned long *);
+extern void vm_events_fold_cpu(int cpu);
+
+#else
+
+/* Disable counters */
+#define get_cpu_vm_events(e)	0L
+#define count_vm_event(e)	do { } while (0)
+#define count_vm_events(e,d)	do { } while (0)
+#define __count_vm_event(e)	do { } while (0)
+#define __count_vm_events(e,d)	do { } while (0)
+#define vm_events_fold_cpu(x)	do { } while (0)
+
+#endif /* CONFIG_VM_EVENT_COUNTERS */
 
-DECLARE_PER_CPU(struct page_state, page_states);
+#define __count_zone_vm_events(item, zone, delta) \
+			__count_vm_events(item##_DMA + zone_idx(zone), delta)
 
 /*
  * Zone based page accounting with per cpu differentials.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

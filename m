Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2E912828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 18:26:26 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id l127so45019705iof.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 15:26:26 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0252.hostedemail.com. [216.40.44.252])
        by mx.google.com with ESMTPS id j5si1231877ioe.201.2016.03.03.15.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 15:26:25 -0800 (PST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] mm: Convert printk(KERN_<LEVEL> to pr_<level>
Date: Thu,  3 Mar 2016 15:25:33 -0800
Message-Id: <c12953a0177b3fd04945b042cb10495130c08bec.1457047399.git.joe@perches.com>
In-Reply-To: <cover.1457047399.git.joe@perches.com>
References: <cover.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Most of the mm subsystem uses pr_<level> so make it consistent.

Miscellanea:

o Realign arguments
o Add missing newline to format
o kmemleak-test.c has a "kmemleak: " prefix added to the
  "Kmemleak testing" logging message via pr_fmt

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/backing-dev.c    |  4 ++--
 mm/bootmem.c        |  7 +++----
 mm/dmapool.c        | 12 +++++------
 mm/internal.h       |  2 +-
 mm/kmemcheck.c      |  2 +-
 mm/kmemleak-test.c  |  2 +-
 mm/memory-failure.c | 52 +++++++++++++++++++---------------------------
 mm/memory.c         | 17 +++++++--------
 mm/memory_hotplug.c | 11 +++++-----
 mm/mm_init.c        |  7 +++----
 mm/nobootmem.c      |  4 ++--
 mm/page_alloc.c     | 24 ++++++++--------------
 mm/page_io.c        | 22 ++++++++++----------
 mm/page_poison.c    |  4 ++--
 mm/percpu-km.c      |  6 +++---
 mm/percpu.c         | 12 +++++------
 mm/shmem.c          | 14 ++++++-------
 mm/slab.c           | 59 ++++++++++++++++++++++++-----------------------------
 mm/slab_common.c    |  2 +-
 mm/sparse-vmemmap.c |  6 +++---
 mm/sparse.c         | 17 +++++++--------
 mm/swap_cgroup.c    |  5 ++---
 22 files changed, 128 insertions(+), 163 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 46d19a6a..08e3a58 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -1012,8 +1012,8 @@ int pdflush_proc_obsolete(struct ctl_table *table, int write,
 
 	if (copy_to_user(buffer, kbuf, sizeof(kbuf)))
 		return -EFAULT;
-	printk_once(KERN_WARNING "%s exported in /proc is scheduled for removal\n",
-			table->procname);
+	pr_warn_once("%s exported in /proc is scheduled for removal\n",
+		     table->procname);
 
 	*lenp = 2;
 	*ppos += *lenp;
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 91e32bc..0aa7dda 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -50,8 +50,7 @@ early_param("bootmem_debug", bootmem_debug_setup);
 
 #define bdebug(fmt, args...) ({				\
 	if (unlikely(bootmem_debug))			\
-		printk(KERN_INFO			\
-			"bootmem::%s " fmt,		\
+		pr_info("bootmem::%s " fmt,		\
 			__func__, ## args);		\
 })
 
@@ -680,7 +679,7 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
 	 */
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
 	panic("Out of memory");
 	return NULL;
 }
@@ -755,7 +754,7 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 	if (ptr)
 		return ptr;
 
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
 	panic("Out of memory");
 	return NULL;
 }
diff --git a/mm/dmapool.c b/mm/dmapool.c
index 2821500..abcbfe8 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -294,8 +294,7 @@ void dma_pool_destroy(struct dma_pool *pool)
 					"dma_pool_destroy %s, %p busy\n",
 					pool->name, page->vaddr);
 			else
-				printk(KERN_ERR
-				       "dma_pool_destroy %s, %p busy\n",
+				pr_err("dma_pool_destroy %s, %p busy\n",
 				       pool->name, page->vaddr);
 			/* leak the still-in-use consistent memory */
 			list_del(&page->page_list);
@@ -424,7 +423,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 				"dma_pool_free %s, %p/%lx (bad dma)\n",
 				pool->name, vaddr, (unsigned long)dma);
 		else
-			printk(KERN_ERR "dma_pool_free %s, %p/%lx (bad dma)\n",
+			pr_err("dma_pool_free %s, %p/%lx (bad dma)\n",
 			       pool->name, vaddr, (unsigned long)dma);
 		return;
 	}
@@ -438,8 +437,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 				"dma_pool_free %s, %p (bad vaddr)/%Lx\n",
 				pool->name, vaddr, (unsigned long long)dma);
 		else
-			printk(KERN_ERR
-			       "dma_pool_free %s, %p (bad vaddr)/%Lx\n",
+			pr_err("dma_pool_free %s, %p (bad vaddr)/%Lx\n",
 			       pool->name, vaddr, (unsigned long long)dma);
 		return;
 	}
@@ -455,8 +453,8 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 				dev_err(pool->dev, "dma_pool_free %s, dma %Lx already free\n",
 					pool->name, (unsigned long long)dma);
 			else
-				printk(KERN_ERR "dma_pool_free %s, dma %Lx already free\n",
-					pool->name, (unsigned long long)dma);
+				pr_err("dma_pool_free %s, dma %Lx already free\n",
+				       pool->name, (unsigned long long)dma);
 			return;
 		}
 	}
diff --git a/mm/internal.h b/mm/internal.h
index 72bbce3..c984cea 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -395,7 +395,7 @@ extern int mminit_loglevel;
 do { \
 	if (level < mminit_loglevel) { \
 		if (level <= MMINIT_WARNING) \
-			printk(KERN_WARNING "mminit::" prefix " " fmt, ##arg); \
+			pr_warn("mminit::" prefix " " fmt, ##arg);	\
 		else \
 			printk(KERN_DEBUG "mminit::" prefix " " fmt, ##arg); \
 	} \
diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index e5f8333..5bf1917 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -20,7 +20,7 @@ void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
 	shadow = alloc_pages_node(node, flags | __GFP_NOTRACK, order);
 	if (!shadow) {
 		if (printk_ratelimit())
-			printk(KERN_ERR "kmemcheck: failed to allocate shadow bitmap\n");
+			pr_err("kmemcheck: failed to allocate shadow bitmap\n");
 		return;
 	}
 
diff --git a/mm/kmemleak-test.c b/mm/kmemleak-test.c
index dcdcadb..dd3c23a 100644
--- a/mm/kmemleak-test.c
+++ b/mm/kmemleak-test.c
@@ -49,7 +49,7 @@ static int __init kmemleak_test_init(void)
 	struct test_node *elem;
 	int i;
 
-	printk(KERN_INFO "Kmemleak testing\n");
+	pr_info("Kmemleak testing\n");
 
 	/* make some orphan objects */
 	pr_info("kmalloc(32) = %p\n", kmalloc(32, GFP_KERNEL));
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 67c30eb..5a544c6 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -184,9 +184,8 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
 	struct siginfo si;
 	int ret;
 
-	printk(KERN_ERR
-		"MCE %#lx: Killing %s:%d due to hardware memory corruption\n",
-		pfn, t->comm, t->pid);
+	pr_err("MCE %#lx: Killing %s:%d due to hardware memory corruption\n",
+	       pfn, t->comm, t->pid);
 	si.si_signo = SIGBUS;
 	si.si_errno = 0;
 	si.si_addr = (void *)addr;
@@ -209,8 +208,8 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
 		ret = send_sig_info(SIGBUS, &si, t);  /* synchronous? */
 	}
 	if (ret < 0)
-		printk(KERN_INFO "MCE: Error sending signal to %s:%d: %d\n",
-		       t->comm, t->pid, ret);
+		pr_info("MCE: Error sending signal to %s:%d: %d\n",
+			t->comm, t->pid, ret);
 	return ret;
 }
 
@@ -290,8 +289,7 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 	} else {
 		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
 		if (!tk) {
-			printk(KERN_ERR
-		"MCE: Out of memory while machine check handling\n");
+			pr_err("MCE: Out of memory while machine check handling\n");
 			return;
 		}
 	}
@@ -336,9 +334,8 @@ static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
 			 * signal and then access the memory. Just kill it.
 			 */
 			if (fail || tk->addr_valid == 0) {
-				printk(KERN_ERR
-		"MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
-					pfn, tk->tsk->comm, tk->tsk->pid);
+				pr_err("MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
+				       pfn, tk->tsk->comm, tk->tsk->pid);
 				force_sig(SIGKILL, tk->tsk);
 			}
 
@@ -350,9 +347,8 @@ static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
 			 */
 			else if (kill_proc(tk->tsk, tk->addr, trapno,
 					      pfn, page, flags) < 0)
-				printk(KERN_ERR
-		"MCE %#lx: Cannot send advisory machine check signal to %s:%d\n",
-					pfn, tk->tsk->comm, tk->tsk->pid);
+				pr_err("MCE %#lx: Cannot send advisory machine check signal to %s:%d\n",
+				       pfn, tk->tsk->comm, tk->tsk->pid);
 		}
 		put_task_struct(tk->tsk);
 		kfree(tk);
@@ -563,7 +559,7 @@ static int me_kernel(struct page *p, unsigned long pfn)
  */
 static int me_unknown(struct page *p, unsigned long pfn)
 {
-	printk(KERN_ERR "MCE %#lx: Unknown page state\n", pfn);
+	pr_err("MCE %#lx: Unknown page state\n", pfn);
 	return MF_FAILED;
 }
 
@@ -608,8 +604,8 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 	if (mapping->a_ops->error_remove_page) {
 		err = mapping->a_ops->error_remove_page(mapping, p);
 		if (err != 0) {
-			printk(KERN_INFO "MCE %#lx: Failed to punch page: %d\n",
-					pfn, err);
+			pr_info("MCE %#lx: Failed to punch page: %d\n",
+				pfn, err);
 		} else if (page_has_private(p) &&
 				!try_to_release_page(p, GFP_NOIO)) {
 			pr_info("MCE %#lx: failed to release buffers\n", pfn);
@@ -624,8 +620,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 		if (invalidate_inode_page(p))
 			ret = MF_RECOVERED;
 		else
-			printk(KERN_INFO "MCE %#lx: Failed to invalidate\n",
-				pfn);
+			pr_info("MCE %#lx: Failed to invalidate\n", pfn);
 	}
 	return ret;
 }
@@ -854,8 +849,7 @@ static int page_action(struct page_state *ps, struct page *p,
 	if (ps->action == me_swapcache_dirty && result == MF_DELAYED)
 		count--;
 	if (count != 0) {
-		printk(KERN_ERR
-		       "MCE %#lx: %s still referenced by %d users\n",
+		pr_err("MCE %#lx: %s still referenced by %d users\n",
 		       pfn, action_page_types[ps->type], count);
 		result = MF_FAILED;
 	}
@@ -934,8 +928,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	}
 
 	if (PageSwapCache(p)) {
-		printk(KERN_ERR
-		       "MCE %#lx: keeping poisoned page in swap cache\n", pfn);
+		pr_err("MCE %#lx: keeping poisoned page in swap cache\n", pfn);
 		ttu |= TTU_IGNORE_HWPOISON;
 	}
 
@@ -953,8 +946,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 		} else {
 			kill = 0;
 			ttu |= TTU_IGNORE_HWPOISON;
-			printk(KERN_INFO
-	"MCE %#lx: corrupted page was clean: dropped without side effects\n",
+			pr_info("MCE %#lx: corrupted page was clean: dropped without side effects\n",
 				pfn);
 		}
 	}
@@ -972,8 +964,8 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 
 	ret = try_to_unmap(hpage, ttu);
 	if (ret != SWAP_SUCCESS)
-		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=%d)\n",
-				pfn, page_mapcount(hpage));
+		pr_err("MCE %#lx: failed to unmap page (mapcount=%d)\n",
+		       pfn, page_mapcount(hpage));
 
 	/*
 	 * Now that the dirty bit has been propagated to the
@@ -1040,16 +1032,14 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		panic("Memory failure from trap %d on page %lx", trapno, pfn);
 
 	if (!pfn_valid(pfn)) {
-		printk(KERN_ERR
-		       "MCE %#lx: memory outside kernel control\n",
-		       pfn);
+		pr_err("MCE %#lx: memory outside kernel control\n", pfn);
 		return -ENXIO;
 	}
 
 	p = pfn_to_page(pfn);
 	orig_head = hpage = compound_head(p);
 	if (TestSetPageHWPoison(p)) {
-		printk(KERN_ERR "MCE %#lx: already hardware poisoned\n", pfn);
+		pr_err("MCE %#lx: already hardware poisoned\n", pfn);
 		return 0;
 	}
 
@@ -1180,7 +1170,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 * unpoison always clear PG_hwpoison inside page lock
 	 */
 	if (!PageHWPoison(p)) {
-		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
+		pr_err("MCE %#lx: just unpoisoned\n", pfn);
 		num_poisoned_pages_sub(nr_pages);
 		unlock_page(hpage);
 		put_hwpoison_page(hpage);
diff --git a/mm/memory.c b/mm/memory.c
index e07a75f..288a508 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -661,9 +661,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 			return;
 		}
 		if (nr_unshown) {
-			printk(KERN_ALERT
-				"BUG: Bad page map: %lu messages suppressed\n",
-				nr_unshown);
+			pr_alert("BUG: Bad page map: %lu messages suppressed\n",
+				 nr_unshown);
 			nr_unshown = 0;
 		}
 		nr_shown = 0;
@@ -674,15 +673,13 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	mapping = vma->vm_file ? vma->vm_file->f_mapping : NULL;
 	index = linear_page_index(vma, addr);
 
-	printk(KERN_ALERT
-		"BUG: Bad page map in process %s  pte:%08llx pmd:%08llx\n",
-		current->comm,
-		(long long)pte_val(pte), (long long)pmd_val(*pmd));
+	pr_alert("BUG: Bad page map in process %s  pte:%08llx pmd:%08llx\n",
+		 current->comm,
+		 (long long)pte_val(pte), (long long)pmd_val(*pmd));
 	if (page)
 		dump_page(page, "bad pte");
-	printk(KERN_ALERT
-		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
-		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
+	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
+		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
 	/*
 	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
 	 */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7249497..188ed63 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1529,8 +1529,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 
 		} else {
 #ifdef CONFIG_DEBUG_VM
-			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
-			       pfn);
+			pr_alert("removing pfn %lx from LRU failed\n", pfn);
 			dump_page(page, "failed to remove from LRU");
 #endif
 			put_page(page);
@@ -1858,7 +1857,7 @@ repeat:
 		ret = -EBUSY;
 		goto failed_removal;
 	}
-	printk(KERN_INFO "Offlined Pages %ld\n", offlined_pages);
+	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
@@ -1895,9 +1894,9 @@ repeat:
 	return 0;
 
 failed_removal:
-	printk(KERN_INFO "memory offlining [mem %#010llx-%#010llx] failed\n",
-	       (unsigned long long) start_pfn << PAGE_SHIFT,
-	       ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
+	pr_info("memory offlining [mem %#010llx-%#010llx] failed\n",
+		(unsigned long long)start_pfn << PAGE_SHIFT,
+		((unsigned long long)end_pfn << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
diff --git a/mm/mm_init.c b/mm/mm_init.c
index fdadf91..5b72266 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -55,13 +55,12 @@ void __init mminit_verify_zonelist(void)
 			/* Iterate the zonelist */
 			for_each_zone_zonelist(zone, z, zonelist, zoneid) {
 #ifdef CONFIG_NUMA
-				printk(KERN_CONT "%d:%s ",
-					zone->node, zone->name);
+				pr_cont("%d:%s ", zone->node, zone->name);
 #else
-				printk(KERN_CONT "0:%s ", zone->name);
+				pr_cont("0:%s ", zone->name);
 #endif /* CONFIG_NUMA */
 			}
-			printk(KERN_CONT "\n");
+			pr_cont("\n");
 		}
 	}
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 99feb2b..bd05a70 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -288,7 +288,7 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
 	 */
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
 	panic("Out of memory");
 	return NULL;
 }
@@ -360,7 +360,7 @@ static void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 	if (ptr)
 		return ptr;
 
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
 	panic("Out of memory");
 	return NULL;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e85becb..fd888fe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -544,11 +544,11 @@ static int __init debug_guardpage_minorder_setup(char *buf)
 	unsigned long res;
 
 	if (kstrtoul(buf, 10, &res) < 0 ||  res > MAX_ORDER / 2) {
-		printk(KERN_ERR "Bad debug_guardpage_minorder value\n");
+		pr_err("Bad debug_guardpage_minorder value\n");
 		return 0;
 	}
 	_debug_guardpage_minorder = res;
-	printk(KERN_INFO "Setting debug_guardpage_minorder to %lu\n", res);
+	pr_info("Setting debug_guardpage_minorder to %lu\n", res);
 	return 0;
 }
 __setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
@@ -4194,8 +4194,7 @@ static int __parse_numa_zonelist_order(char *s)
 	} else if (*s == 'z' || *s == 'Z') {
 		user_zonelist_order = ZONELIST_ORDER_ZONE;
 	} else {
-		printk(KERN_WARNING
-		       "Ignoring invalid numa_zonelist_order value:  %s\n", s);
+		pr_warn("Ignoring invalid numa_zonelist_order value:  %s\n", s);
 		return -EINVAL;
 	}
 	return 0;
@@ -5579,8 +5578,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 					       "  %s zone: %lu pages used for memmap\n",
 					       zone_names[j], memmap_pages);
 			} else
-				printk(KERN_WARNING
-					"  %s zone: %lu pages exceeds freesize %lu\n",
+				pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
 					zone_names[j], memmap_pages, freesize);
 		}
 
@@ -5788,8 +5786,7 @@ static unsigned long __init find_min_pfn_for_node(int nid)
 		min_pfn = min(min_pfn, start_pfn);
 
 	if (min_pfn == ULONG_MAX) {
-		printk(KERN_WARNING
-			"Could not find start_pfn for node %d\n", nid);
+		pr_warn("Could not find start_pfn for node %d\n", nid);
 		return 0;
 	}
 
@@ -6807,11 +6804,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 	if (!table)
 		panic("Failed to allocate %s hash table\n", tablename);
 
-	printk(KERN_INFO "%s hash table entries: %ld (order: %d, %lu bytes)\n",
-	       tablename,
-	       (1UL << log2qty),
-	       ilog2(size) - PAGE_SHIFT,
-	       size);
+	pr_info("%s hash table entries: %ld (order: %d, %lu bytes)\n",
+		tablename, 1UL << log2qty, ilog2(size) - PAGE_SHIFT, size);
 
 	if (_hash_shift)
 		*_hash_shift = log2qty;
@@ -7312,8 +7306,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
 #ifdef CONFIG_DEBUG_VM
-		printk(KERN_INFO "remove from free list %lx %d %lx\n",
-		       pfn, 1 << order, end_pfn);
+		pr_info("remove from free list %lx %d %lx\n",
+			pfn, 1 << order, end_pfn);
 #endif
 		list_del(&page->lru);
 		rmv_page_order(page);
diff --git a/mm/page_io.c b/mm/page_io.c
index b995a5b..ff74e51 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -56,10 +56,10 @@ void end_swap_bio_write(struct bio *bio)
 		 * Also clear PG_reclaim to avoid rotate_reclaimable_page()
 		 */
 		set_page_dirty(page);
-		printk(KERN_ALERT "Write-error on swap-device (%u:%u:%Lu)\n",
-				imajor(bio->bi_bdev->bd_inode),
-				iminor(bio->bi_bdev->bd_inode),
-				(unsigned long long)bio->bi_iter.bi_sector);
+		pr_alert("Write-error on swap-device (%u:%u:%llu)\n",
+			 imajor(bio->bi_bdev->bd_inode),
+			 iminor(bio->bi_bdev->bd_inode),
+			 (unsigned long long)bio->bi_iter.bi_sector);
 		ClearPageReclaim(page);
 	}
 	end_page_writeback(page);
@@ -73,10 +73,10 @@ static void end_swap_bio_read(struct bio *bio)
 	if (bio->bi_error) {
 		SetPageError(page);
 		ClearPageUptodate(page);
-		printk(KERN_ALERT "Read-error on swap-device (%u:%u:%Lu)\n",
-				imajor(bio->bi_bdev->bd_inode),
-				iminor(bio->bi_bdev->bd_inode),
-				(unsigned long long)bio->bi_iter.bi_sector);
+		pr_alert("Read-error on swap-device (%u:%u:%llu)\n",
+			 imajor(bio->bi_bdev->bd_inode),
+			 iminor(bio->bi_bdev->bd_inode),
+			 (unsigned long long)bio->bi_iter.bi_sector);
 		goto out;
 	}
 
@@ -216,7 +216,7 @@ reprobe:
 out:
 	return ret;
 bad_bmap:
-	printk(KERN_ERR "swapon: swapfile has holes\n");
+	pr_err("swapon: swapfile has holes\n");
 	ret = -EINVAL;
 	goto out;
 }
@@ -290,8 +290,8 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 			 */
 			set_page_dirty(page);
 			ClearPageReclaim(page);
-			pr_err_ratelimited("Write error on dio swapfile (%Lu)\n",
-				page_file_offset(page));
+			pr_err_ratelimited("Write error on dio swapfile (%llu)\n",
+					   page_file_offset(page));
 		}
 		end_page_writeback(page);
 		return ret;
diff --git a/mm/page_poison.c b/mm/page_poison.c
index 312b131..7aacdbd 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -116,9 +116,9 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
 	if (!__ratelimit(&ratelimit))
 		return;
 	else if (start == end && single_bit_flip(*start, PAGE_POISON))
-		printk(KERN_ERR "pagealloc: single bit error\n");
+		pr_err("pagealloc: single bit error\n");
 	else
-		printk(KERN_ERR "pagealloc: memory corruption\n");
+		pr_err("pagealloc: memory corruption\n");
 
 	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
 			end - start + 1, 1);
diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 10e3d0b..0db94b7 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -95,7 +95,7 @@ static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai)
 
 	/* all units must be in a single group */
 	if (ai->nr_groups != 1) {
-		printk(KERN_CRIT "percpu: can't handle more than one groups\n");
+		pr_crit("percpu: can't handle more than one groups\n");
 		return -EINVAL;
 	}
 
@@ -103,8 +103,8 @@ static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai)
 	alloc_pages = roundup_pow_of_two(nr_pages);
 
 	if (alloc_pages > nr_pages)
-		printk(KERN_WARNING "percpu: wasting %zu pages per chunk\n",
-		       alloc_pages - nr_pages);
+		pr_warn("percpu: wasting %zu pages per chunk\n",
+			alloc_pages - nr_pages);
 
 	return 0;
 }
diff --git a/mm/percpu.c b/mm/percpu.c
index 1571547..c987fd4 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1449,20 +1449,20 @@ static void pcpu_dump_alloc_info(const char *lvl,
 		for (alloc_end += gi->nr_units / upa;
 		     alloc < alloc_end; alloc++) {
 			if (!(alloc % apl)) {
-				printk(KERN_CONT "\n");
+				pr_cont("\n");
 				printk("%spcpu-alloc: ", lvl);
 			}
-			printk(KERN_CONT "[%0*d] ", group_width, group);
+			pr_cont("[%0*d] ", group_width, group);
 
 			for (unit_end += upa; unit < unit_end; unit++)
 				if (gi->cpu_map[unit] != NR_CPUS)
-					printk(KERN_CONT "%0*d ", cpu_width,
-					       gi->cpu_map[unit]);
+					pr_cont("%0*d ",
+						cpu_width, gi->cpu_map[unit]);
 				else
-					printk(KERN_CONT "%s ", empty_str);
+					pr_cont("%s ", empty_str);
 		}
 	}
-	printk(KERN_CONT "\n");
+	pr_cont("\n");
 }
 
 /**
diff --git a/mm/shmem.c b/mm/shmem.c
index b8e8369..9428c51 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2818,9 +2818,8 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 		if ((value = strchr(this_char,'=')) != NULL) {
 			*value++ = 0;
 		} else {
-			printk(KERN_ERR
-			    "tmpfs: No value for mount option '%s'\n",
-			    this_char);
+			pr_err("tmpfs: No value for mount option '%s'\n",
+			       this_char);
 			goto error;
 		}
 
@@ -2875,8 +2874,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			if (mpol_parse_str(value, &mpol))
 				goto bad_val;
 		} else {
-			printk(KERN_ERR "tmpfs: Bad mount option %s\n",
-			       this_char);
+			pr_err("tmpfs: Bad mount option %s\n", this_char);
 			goto error;
 		}
 	}
@@ -2884,7 +2882,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 	return 0;
 
 bad_val:
-	printk(KERN_ERR "tmpfs: Bad value '%s' for mount option '%s'\n",
+	pr_err("tmpfs: Bad value '%s' for mount option '%s'\n",
 	       value, this_char);
 error:
 	mpol_put(mpol);
@@ -3281,14 +3279,14 @@ int __init shmem_init(void)
 
 	error = register_filesystem(&shmem_fs_type);
 	if (error) {
-		printk(KERN_ERR "Could not register tmpfs\n");
+		pr_err("Could not register tmpfs\n");
 		goto out2;
 	}
 
 	shm_mnt = kern_mount(&shmem_fs_type);
 	if (IS_ERR(shm_mnt)) {
 		error = PTR_ERR(shm_mnt);
-		printk(KERN_ERR "Could not kern_mount tmpfs\n");
+		pr_err("Could not kern_mount tmpfs\n");
 		goto out1;
 	}
 	return 0;
diff --git a/mm/slab.c b/mm/slab.c
index 7ee9532..7f22c9f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -471,7 +471,7 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 static void __slab_error(const char *function, struct kmem_cache *cachep,
 			char *msg)
 {
-	printk(KERN_ERR "slab error in %s(): cache `%s': %s\n",
+	pr_err("slab error in %s(): cache `%s': %s\n",
 	       function, cachep->name, msg);
 	dump_stack();
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
@@ -1347,10 +1347,9 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 	if ((gfpflags & __GFP_NOWARN) || !__ratelimit(&slab_oom_rs))
 		return;
 
-	printk(KERN_WARNING
-		"SLAB: Unable to allocate memory on node %d (gfp=0x%x)\n",
+	pr_warn("SLAB: Unable to allocate memory on node %d (gfp=0x%x)\n",
 		nodeid, gfpflags);
-	printk(KERN_WARNING "  cache: %s, object size: %d, order: %d\n",
+	pr_warn("  cache: %s, object size: %d, order: %d\n",
 		cachep->name, cachep->size, cachep->gfporder);
 
 	for_each_kmem_cache_node(cachep, node, n) {
@@ -1374,8 +1373,7 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 
 		num_slabs += active_slabs;
 		num_objs = num_slabs * cachep->num;
-		printk(KERN_WARNING
-			"  node %d: slabs: %ld/%ld, objs: %ld/%ld, free: %ld\n",
+		pr_warn("  node %d: slabs: %ld/%ld, objs: %ld/%ld, free: %ld\n",
 			node, active_slabs, num_slabs, active_objs, num_objs,
 			free_objects);
 	}
@@ -1552,7 +1550,7 @@ static void dump_line(char *data, int offset, int limit)
 	unsigned char error = 0;
 	int bad_count = 0;
 
-	printk(KERN_ERR "%03x: ", offset);
+	pr_err("%03x: ", offset);
 	for (i = 0; i < limit; i++) {
 		if (data[offset + i] != POISON_FREE) {
 			error = data[offset + i];
@@ -1565,11 +1563,11 @@ static void dump_line(char *data, int offset, int limit)
 	if (bad_count == 1) {
 		error ^= POISON_FREE;
 		if (!(error & (error - 1))) {
-			printk(KERN_ERR "Single bit error detected. Probably bad RAM.\n");
+			pr_err("Single bit error detected. Probably bad RAM.\n");
 #ifdef CONFIG_X86
-			printk(KERN_ERR "Run memtest86+ or a similar memory test tool.\n");
+			pr_err("Run memtest86+ or a similar memory test tool.\n");
 #else
-			printk(KERN_ERR "Run a memory test tool.\n");
+			pr_err("Run a memory test tool.\n");
 #endif
 		}
 	}
@@ -1584,13 +1582,13 @@ static void print_objinfo(struct kmem_cache *cachep, void *objp, int lines)
 	char *realobj;
 
 	if (cachep->flags & SLAB_RED_ZONE) {
-		printk(KERN_ERR "Redzone: 0x%llx/0x%llx.\n",
-			*dbg_redzone1(cachep, objp),
-			*dbg_redzone2(cachep, objp));
+		pr_err("Redzone: 0x%llx/0x%llx\n",
+		       *dbg_redzone1(cachep, objp),
+		       *dbg_redzone2(cachep, objp));
 	}
 
 	if (cachep->flags & SLAB_STORE_USER) {
-		printk(KERN_ERR "Last user: [<%p>](%pSR)\n",
+		pr_err("Last user: [<%p>](%pSR)\n",
 		       *dbg_userword(cachep, objp),
 		       *dbg_userword(cachep, objp));
 	}
@@ -1626,9 +1624,9 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 			/* Mismatch ! */
 			/* Print header */
 			if (lines == 0) {
-				printk(KERN_ERR
-					"Slab corruption (%s): %s start=%p, len=%d\n",
-					print_tainted(), cachep->name, realobj, size);
+				pr_err("Slab corruption (%s): %s start=%p, len=%d\n",
+				       print_tainted(), cachep->name,
+				       realobj, size);
 				print_objinfo(cachep, objp, 0);
 			}
 			/* Hexdump the affected line */
@@ -1655,15 +1653,13 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 		if (objnr) {
 			objp = index_to_obj(cachep, page, objnr - 1);
 			realobj = (char *)objp + obj_offset(cachep);
-			printk(KERN_ERR "Prev obj: start=%p, len=%d\n",
-			       realobj, size);
+			pr_err("Prev obj: start=%p, len=%d\n", realobj, size);
 			print_objinfo(cachep, objp, 2);
 		}
 		if (objnr + 1 < cachep->num) {
 			objp = index_to_obj(cachep, page, objnr + 1);
 			realobj = (char *)objp + obj_offset(cachep);
-			printk(KERN_ERR "Next obj: start=%p, len=%d\n",
-			       realobj, size);
+			pr_err("Next obj: start=%p, len=%d\n", realobj, size);
 			print_objinfo(cachep, objp, 2);
 		}
 	}
@@ -2462,7 +2458,7 @@ static void slab_put_obj(struct kmem_cache *cachep,
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
 		if (get_free_obj(page, i) == objnr) {
-			printk(KERN_ERR "slab: double free detected in cache '%s', objp %p\n",
+			pr_err("slab: double free detected in cache '%s', objp %p\n",
 			       cachep->name, objp);
 			BUG();
 		}
@@ -2582,7 +2578,7 @@ failed:
 static void kfree_debugcheck(const void *objp)
 {
 	if (!virt_addr_valid(objp)) {
-		printk(KERN_ERR "kfree_debugcheck: out of range ptr %lxh.\n",
+		pr_err("kfree_debugcheck: out of range ptr %lxh\n",
 		       (unsigned long)objp);
 		BUG();
 	}
@@ -2606,8 +2602,8 @@ static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 	else
 		slab_error(cache, "memory outside object was overwritten");
 
-	printk(KERN_ERR "%p: redzone 1:0x%llx, redzone 2:0x%llx.\n",
-			obj, redzone1, redzone2);
+	pr_err("%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
+	       obj, redzone1, redzone2);
 }
 
 static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
@@ -2895,10 +2891,9 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		if (*dbg_redzone1(cachep, objp) != RED_INACTIVE ||
 				*dbg_redzone2(cachep, objp) != RED_INACTIVE) {
 			slab_error(cachep, "double free, or memory outside object was overwritten");
-			printk(KERN_ERR
-				"%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
-				objp, *dbg_redzone1(cachep, objp),
-				*dbg_redzone2(cachep, objp));
+			pr_err("%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
+			       objp, *dbg_redzone1(cachep, objp),
+			       *dbg_redzone2(cachep, objp));
 		}
 		*dbg_redzone1(cachep, objp) = RED_ACTIVE;
 		*dbg_redzone2(cachep, objp) = RED_ACTIVE;
@@ -2909,7 +2904,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		cachep->ctor(objp);
 	if (ARCH_SLAB_MINALIGN &&
 	    ((unsigned long)objp & (ARCH_SLAB_MINALIGN-1))) {
-		printk(KERN_ERR "0x%p: not aligned to ARCH_SLAB_MINALIGN=%d\n",
+		pr_err("0x%p: not aligned to ARCH_SLAB_MINALIGN=%d\n",
 		       objp, (int)ARCH_SLAB_MINALIGN);
 	}
 	return objp;
@@ -3836,7 +3831,7 @@ static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 skip_setup:
 	err = do_tune_cpucache(cachep, limit, batchcount, shared, gfp);
 	if (err)
-		printk(KERN_ERR "enable_cpucache failed for %s, error %d.\n",
+		pr_err("enable_cpucache failed for %s, error %d\n",
 		       cachep->name, -err);
 	return err;
 }
@@ -3992,7 +3987,7 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 
 	name = cachep->name;
 	if (error)
-		printk(KERN_ERR "slab: cache %s error: %s\n", name, error);
+		pr_err("slab: cache %s error: %s\n", name, error);
 
 	sinfo->active_objs = active_objs;
 	sinfo->num_objs = num_objs;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index e885e11..b2e3796 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -442,7 +442,7 @@ out_unlock:
 			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
 				name, err);
 		else {
-			printk(KERN_WARNING "kmem_cache_create(%s) failed with error %d",
+			pr_warn("kmem_cache_create(%s) failed with error %d\n",
 				name, err);
 			dump_stack();
 		}
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index d3511f9..68885dc 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -166,8 +166,8 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 	int actual_node = early_pfn_to_nid(pfn);
 
 	if (node_distance(actual_node, node) > LOCAL_DISTANCE)
-		printk(KERN_WARNING "[%lx-%lx] potential offnode page_structs\n",
-		       start, end - 1);
+		pr_warn("[%lx-%lx] potential offnode page_structs\n",
+			start, end - 1);
 }
 
 pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
@@ -292,7 +292,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
-		printk(KERN_ERR "%s: sparsemem memory map backing failed some memory will not be available.\n",
+		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
 		ms->section_mem_map = 0;
 	}
diff --git a/mm/sparse.c b/mm/sparse.c
index 7cdb27d..5d0cf45 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -313,9 +313,8 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 
 	usemap_nid = sparse_early_nid(__nr_to_section(usemap_snr));
 	if (usemap_nid != nid) {
-		printk(KERN_INFO
-		       "node %d must be removed before remove section %ld\n",
-		       nid, usemap_snr);
+		pr_info("node %d must be removed before remove section %ld\n",
+			nid, usemap_snr);
 		return;
 	}
 	/*
@@ -324,10 +323,8 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 	 * gather other removable sections for dynamic partitioning.
 	 * Just notify un-removable section's number here.
 	 */
-	printk(KERN_INFO "Section %ld and %ld (node %d)", usemap_snr,
-	       pgdat_snr, nid);
-	printk(KERN_CONT
-	       " have a circular dependency on usemap and pgdat allocations\n");
+	pr_info("Section %ld and %ld (node %d) have a circular dependency on usemap and pgdat allocations\n",
+		usemap_snr, pgdat_snr, nid);
 }
 #else
 static unsigned long * __init
@@ -355,7 +352,7 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
 							  size * usemap_count);
 	if (!usemap) {
-		printk(KERN_WARNING "%s: allocation failed\n", __func__);
+		pr_warn("%s: allocation failed\n", __func__);
 		return;
 	}
 
@@ -428,7 +425,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 		if (map_map[pnum])
 			continue;
 		ms = __nr_to_section(pnum);
-		printk(KERN_ERR "%s: sparsemem memory map backing failed some memory will not be available.\n",
+		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 		       __func__);
 		ms->section_mem_map = 0;
 	}
@@ -456,7 +453,7 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 	if (map)
 		return map;
 
-	printk(KERN_ERR "%s: sparsemem memory map backing failed some memory will not be available.\n",
+	pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
 	       __func__);
 	ms->section_mem_map = 0;
 	return NULL;
diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index b5f7f24..310ac0b 100644
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -174,9 +174,8 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 
 	return 0;
 nomem:
-	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
-	printk(KERN_INFO
-		"swap_cgroup can be disabled by swapaccount=0 boot option\n");
+	pr_info("couldn't allocate enough memory for swap_cgroup\n");
+	pr_info("swap_cgroup can be disabled by swapaccount=0 boot option\n");
 	return -ENOMEM;
 }
 
-- 
2.6.3.368.gf34be46

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

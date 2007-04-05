Message-Id: <20070405174320.129577639@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
Date: Thu, 05 Apr 2007 19:42:19 +0200
From: root@programming.kicks-ass.net
Subject: [PATCH 10/12] mm: page_alloc_wait
Content-Disposition: inline; filename=page_alloc_wait.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

Introduce a mechanism to wait on free memory.

Currently congestion_wait() is abused to do this.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/i386/lib/usercopy.c |    2 +-
 fs/xfs/linux-2.6/kmem.c  |    4 ++--
 include/linux/mm.h       |    3 +++
 mm/page_alloc.c          |   25 +++++++++++++++++++++++--
 mm/shmem.c               |    2 +-
 mm/vmscan.c              |    1 +
 6 files changed, 31 insertions(+), 6 deletions(-)

Index: linux-2.6-mm/arch/i386/lib/usercopy.c
===================================================================
--- linux-2.6-mm.orig/arch/i386/lib/usercopy.c	2007-04-05 16:24:15.000000000 +0200
+++ linux-2.6-mm/arch/i386/lib/usercopy.c	2007-04-05 16:29:49.000000000 +0200
@@ -751,7 +751,7 @@ survive:
 
 			if (retval == -ENOMEM && is_init(current)) {
 				up_read(&current->mm->mmap_sem);
-				congestion_wait(WRITE, HZ/50);
+				page_alloc_wait(HZ/50);
 				goto survive;
 			}
 
Index: linux-2.6-mm/fs/xfs/linux-2.6/kmem.c
===================================================================
--- linux-2.6-mm.orig/fs/xfs/linux-2.6/kmem.c	2007-04-05 16:24:15.000000000 +0200
+++ linux-2.6-mm/fs/xfs/linux-2.6/kmem.c	2007-04-05 16:29:49.000000000 +0200
@@ -53,7 +53,7 @@ kmem_alloc(size_t size, unsigned int __n
 			printk(KERN_ERR "XFS: possible memory allocation "
 					"deadlock in %s (mode:0x%x)\n",
 					__FUNCTION__, lflags);
-		congestion_wait(WRITE, HZ/50);
+		page_alloc_wait(HZ/50);
 	} while (1);
 }
 
@@ -131,7 +131,7 @@ kmem_zone_alloc(kmem_zone_t *zone, unsig
 			printk(KERN_ERR "XFS: possible memory allocation "
 					"deadlock in %s (mode:0x%x)\n",
 					__FUNCTION__, lflags);
-		congestion_wait(WRITE, HZ/50);
+		page_alloc_wait(HZ/50);
 	} while (1);
 }
 
Index: linux-2.6-mm/include/linux/mm.h
===================================================================
--- linux-2.6-mm.orig/include/linux/mm.h	2007-04-05 16:24:15.000000000 +0200
+++ linux-2.6-mm/include/linux/mm.h	2007-04-05 16:29:49.000000000 +0200
@@ -1028,6 +1028,9 @@ extern void setup_per_cpu_pageset(void);
 static inline void setup_per_cpu_pageset(void) {}
 #endif
 
+void page_alloc_ok(void);
+long page_alloc_wait(long timeout);
+
 /* prio_tree.c */
 void vma_prio_tree_add(struct vm_area_struct *, struct vm_area_struct *old);
 void vma_prio_tree_insert(struct vm_area_struct *, struct prio_tree_root *);
Index: linux-2.6-mm/mm/page_alloc.c
===================================================================
--- linux-2.6-mm.orig/mm/page_alloc.c	2007-04-05 16:24:15.000000000 +0200
+++ linux-2.6-mm/mm/page_alloc.c	2007-04-05 16:35:04.000000000 +0200
@@ -107,6 +107,9 @@ unsigned long __meminitdata nr_kernel_pa
 unsigned long __meminitdata nr_all_pages;
 static unsigned long __initdata dma_reserve;
 
+static wait_queue_head_t page_alloc_wqh =
+	__WAIT_QUEUE_HEAD_INITIALIZER(page_alloc_wqh);
+
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
   /*
    * MAX_ACTIVE_REGIONS determines the maxmimum number of distinct
@@ -1698,7 +1701,7 @@ nofail_alloc:
 			if (page)
 				goto got_pg;
 			if (gfp_mask & __GFP_NOFAIL) {
-				congestion_wait(WRITE, HZ/50);
+				page_alloc_wait(HZ/50);
 				goto nofail_alloc;
 			}
 		}
@@ -1763,7 +1766,7 @@ nofail_alloc:
 			do_retry = 1;
 	}
 	if (do_retry) {
-		congestion_wait(WRITE, HZ/50);
+		page_alloc_wait(HZ/50);
 		goto rebalance;
 	}
 
@@ -4217,3 +4220,21 @@ void set_pageblock_flags_group(struct pa
 		else
 			__clear_bit(bitidx + start_bitidx, bitmap);
 }
+
+void page_alloc_ok(void)
+{
+	if (waitqueue_active(&page_alloc_wqh))
+		wake_up(&page_alloc_wqh);
+}
+
+long page_alloc_wait(long timeout)
+{
+	long ret;
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(&page_alloc_wqh, &wait, TASK_UNINTERRUPTIBLE);
+	ret = schedule_timeout(timeout);
+	finish_wait(&page_alloc_wqh, &wait);
+	return ret;
+}
+EXPORT_SYMBOL(page_alloc_wait);
Index: linux-2.6-mm/mm/shmem.c
===================================================================
--- linux-2.6-mm.orig/mm/shmem.c	2007-04-05 16:24:15.000000000 +0200
+++ linux-2.6-mm/mm/shmem.c	2007-04-05 16:30:31.000000000 +0200
@@ -1216,7 +1216,7 @@ repeat:
 			page_cache_release(swappage);
 			if (error == -ENOMEM) {
 				/* let kswapd refresh zone for GFP_ATOMICs */
-				congestion_wait(WRITE, HZ/50);
+				page_alloc_wait(HZ/50);
 			}
 			goto repeat;
 		}
Index: linux-2.6-mm/mm/vmscan.c
===================================================================
--- linux-2.6-mm.orig/mm/vmscan.c	2007-04-05 16:29:46.000000000 +0200
+++ linux-2.6-mm/mm/vmscan.c	2007-04-05 16:29:49.000000000 +0200
@@ -1436,6 +1436,7 @@ static int kswapd(void *p)
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
 		balance_pgdat(pgdat, order);
+		page_alloc_ok();
 	}
 	return 0;
 }

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

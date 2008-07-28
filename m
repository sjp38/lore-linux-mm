Date: Mon, 28 Jul 2008 15:05:59 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - GRU Driver V3 fixes to resolve code review comments
Message-ID: <20080728200559.GA26689@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, npiggin@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fixes problems identified in a code review:
	- add comment with high level dscription of the GRU
	- prepend "gru_" to all global names
	- delete unused function
	- couple of trivial bug fixes

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 drivers/misc/sgi-gru/gru_instructions.h |   10 ----
 drivers/misc/sgi-gru/grufile.c          |    8 ++-
 drivers/misc/sgi-gru/grukservices.c     |    6 +-
 drivers/misc/sgi-gru/grumain.c          |   16 ++++--
 drivers/misc/sgi-gru/gruprocfs.c        |    4 -
 drivers/misc/sgi-gru/grutables.h        |   74 +++++++++++++++++++++++++++++---
 drivers/misc/sgi-gru/grutlbpurge.c      |    4 +
 7 files changed, 93 insertions(+), 29 deletions(-)

Index: linux/drivers/misc/sgi-gru/gru_instructions.h
===================================================================
--- linux.orig/drivers/misc/sgi-gru/gru_instructions.h	2008-07-28 14:52:26.000000000 -0500
+++ linux/drivers/misc/sgi-gru/gru_instructions.h	2008-07-28 14:52:54.000000000 -0500
@@ -285,16 +285,6 @@ __opword(unsigned char opcode, unsigned 
 }
 
 /*
- * Prefetch a cacheline. Fetch is unconditional. Must page fault if
- * no valid TLB entry is found.
- * 	??? should I use actual "load" or hardware prefetch???
- */
-static inline void gru_prefetch(void *p)
-{
-	*(volatile char *)p;
-}
-
-/*
  * Architecture specific intrinsics
  */
 static inline void gru_flush_cache(void *p)
Index: linux/drivers/misc/sgi-gru/grufile.c
===================================================================
--- linux.orig/drivers/misc/sgi-gru/grufile.c	2008-07-28 14:52:26.000000000 -0500
+++ linux/drivers/misc/sgi-gru/grufile.c	2008-07-28 14:52:54.000000000 -0500
@@ -112,6 +112,10 @@ static int gru_file_mmap(struct file *fi
 	if ((vma->vm_flags & (VM_SHARED | VM_WRITE)) != (VM_SHARED | VM_WRITE))
 		return -EPERM;
 
+	if (vma->vm_start & (GRU_GSEG_PAGESIZE - 1) ||
+	    			vma->vm_end & (GRU_GSEG_PAGESIZE - 1))
+		return -EINVAL;
+
 	vma->vm_flags |=
 	    (VM_IO | VM_DONTCOPY | VM_LOCKED | VM_DONTEXPAND | VM_PFNMAP |
 			VM_RESERVED);
@@ -471,8 +475,8 @@ struct vm_operations_struct gru_vm_ops =
 module_init(gru_init);
 module_exit(gru_exit);
 
-module_param(options, ulong, 0644);
-MODULE_PARM_DESC(options, "Various debug options");
+module_param(gru_options, ulong, 0644);
+MODULE_PARM_DESC(gru_options, "Various debug options");
 
 MODULE_AUTHOR("Silicon Graphics, Inc.");
 MODULE_LICENSE("GPL");
Index: linux/drivers/misc/sgi-gru/grukservices.c
===================================================================
--- linux.orig/drivers/misc/sgi-gru/grukservices.c	2008-07-28 14:52:26.000000000 -0500
+++ linux/drivers/misc/sgi-gru/grukservices.c	2008-07-28 14:52:54.000000000 -0500
@@ -638,11 +638,11 @@ int gru_kservices_init(struct gru_state 
 	cpus_possible = uv_blade_nr_possible_cpus(gru->gs_blade_id);
 
 	num = GRU_NUM_KERNEL_CBR * cpus_possible;
-	cbr_map = reserve_gru_cb_resources(gru, GRU_CB_COUNT_TO_AU(num), NULL);
+	cbr_map = gru_reserve_cb_resources(gru, GRU_CB_COUNT_TO_AU(num), NULL);
 	gru->gs_reserved_cbrs += num;
 
 	num = GRU_NUM_KERNEL_DSR_BYTES * cpus_possible;
-	dsr_map = reserve_gru_ds_resources(gru, GRU_DS_BYTES_TO_AU(num), NULL);
+	dsr_map = gru_reserve_ds_resources(gru, GRU_DS_BYTES_TO_AU(num), NULL);
 	gru->gs_reserved_dsr_bytes += num;
 
 	gru->gs_active_contexts++;
@@ -673,7 +673,7 @@ int gru_kservices_init(struct gru_state 
 	}
 	unlock_cch_handle(cch);
 
-	if (options & GRU_QUICKLOOK)
+	if (gru_options & GRU_QUICKLOOK)
 		quicktest(gru);
 	return 0;
 }
Index: linux/drivers/misc/sgi-gru/grumain.c
===================================================================
--- linux.orig/drivers/misc/sgi-gru/grumain.c	2008-07-28 14:52:26.000000000 -0500
+++ linux/drivers/misc/sgi-gru/grumain.c	2008-07-28 14:52:54.000000000 -0500
@@ -22,7 +22,7 @@
 #include "grutables.h"
 #include "gruhandles.h"
 
-unsigned long options __read_mostly;
+unsigned long gru_options __read_mostly;
 
 static struct device_driver gru_driver = {
 	.name = "gru"
@@ -163,14 +163,14 @@ static unsigned long reserve_resources(u
 	return bits;
 }
 
-unsigned long reserve_gru_cb_resources(struct gru_state *gru, int cbr_au_count,
+unsigned long gru_reserve_cb_resources(struct gru_state *gru, int cbr_au_count,
 				       char *cbmap)
 {
 	return reserve_resources(&gru->gs_cbr_map, cbr_au_count, GRU_CBR_AU,
 				 cbmap);
 }
 
-unsigned long reserve_gru_ds_resources(struct gru_state *gru, int dsr_au_count,
+unsigned long gru_reserve_ds_resources(struct gru_state *gru, int dsr_au_count,
 				       char *dsmap)
 {
 	return reserve_resources(&gru->gs_dsr_map, dsr_au_count, GRU_DSR_AU,
@@ -182,10 +182,10 @@ static void reserve_gru_resources(struct
 {
 	gru->gs_active_contexts++;
 	gts->ts_cbr_map =
-	    reserve_gru_cb_resources(gru, gts->ts_cbr_au_count,
+	    gru_reserve_cb_resources(gru, gts->ts_cbr_au_count,
 				     gts->ts_cbr_idx);
 	gts->ts_dsr_map =
-	    reserve_gru_ds_resources(gru, gts->ts_dsr_au_count, NULL);
+	    gru_reserve_ds_resources(gru, gts->ts_dsr_au_count, NULL);
 }
 
 static void free_gru_resources(struct gru_state *gru,
@@ -416,6 +416,7 @@ static void gru_free_gru_context(struct 
 
 /*
  * Prefetching cachelines help hardware performance.
+ * (Strictly a performance enhancement. Not functionally required).
  */
 static void prefetch_data(void *p, int num, int stride)
 {
@@ -746,6 +747,8 @@ again:
  * gru_nopage
  *
  * Map the user's GRU segment
+ *
+ * 	Note: gru segments alway mmaped on GRU_GSEG_PAGESIZE boundaries.
  */
 int gru_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
@@ -757,6 +760,7 @@ int gru_fault(struct vm_area_struct *vma
 		vma, vaddr, GSEG_BASE(vaddr));
 	STAT(nopfn);
 
+	/* The following check ensures vaddr is a valid address in the VMA */
 	gts = gru_find_thread_state(vma, TSID(vaddr, vma));
 	if (!gts)
 		return VM_FAULT_SIGBUS;
@@ -775,7 +779,7 @@ again:
 	}
 
 	if (!gts->ts_gru) {
-		while (!gru_assign_gru_context(gts)) {
+		if (!gru_assign_gru_context(gts)) {
 			mutex_unlock(&gts->ts_ctxlock);
 			preempt_enable();
 			schedule_timeout(GRU_ASSIGN_DELAY);  /* true hack ZZZ */
Index: linux/drivers/misc/sgi-gru/gruprocfs.c
===================================================================
--- linux.orig/drivers/misc/sgi-gru/gruprocfs.c	2008-07-28 14:52:26.000000000 -0500
+++ linux/drivers/misc/sgi-gru/gruprocfs.c	2008-07-28 14:52:54.000000000 -0500
@@ -122,7 +122,7 @@ static ssize_t statistics_write(struct f
 
 static int options_show(struct seq_file *s, void *p)
 {
-	seq_printf(s, "0x%lx\n", options);
+	seq_printf(s, "0x%lx\n", gru_options);
 	return 0;
 }
 
@@ -136,7 +136,7 @@ static ssize_t options_write(struct file
 	    (buf, userbuf, count < sizeof(buf) ? count : sizeof(buf)))
 		return -EFAULT;
 	if (!strict_strtoul(buf, 10, &val))
-		options = val;
+		gru_options = val;
 
 	return count;
 }
Index: linux/drivers/misc/sgi-gru/grutables.h
===================================================================
--- linux.orig/drivers/misc/sgi-gru/grutables.h	2008-07-28 14:52:26.000000000 -0500
+++ linux/drivers/misc/sgi-gru/grutables.h	2008-07-28 14:52:54.000000000 -0500
@@ -24,6 +24,70 @@
 #define __GRUTABLES_H__
 
 /*
+ * GRU Chiplet:
+ *   The GRU is a user addressible memory accelerator. It provides
+ *   several forms of load, store, memset, bcopy instructions. In addition, it
+ *   contains special instructions for AMOs, sending messages to message
+ *   queues, etc.
+ *
+ *   The GRU is an integral part of the node controller. It connects
+ *   directly to the cpu socket. In its current implementation, there are 2
+ *   GRU chiplets in the node controller on each blade (~node).
+ *
+ *   The entire GRU memory space is fully coherent and cacheable by the cpus.
+ *
+ *   Each GRU chiplet has a physical memory map that looks like the following:
+ *
+ *   	+-----------------+
+ *   	|/////////////////|
+ *   	|/////////////////|
+ *   	|/////////////////|
+ *   	|/////////////////|
+ *   	|/////////////////|
+ *   	|/////////////////|
+ *   	|/////////////////|
+ *   	|/////////////////|
+ *   	+-----------------+
+ *   	|  system control |
+ *   	+-----------------+        _______ +-------------+
+ *   	|/////////////////|       /        |             |
+ *   	|/////////////////|      /         |             |
+ *   	|/////////////////|     /          | instructions|
+ *   	|/////////////////|    /           |             |
+ *   	|/////////////////|   /            |             |
+ *   	|/////////////////|  /             |-------------|
+ *   	|/////////////////| /              |             |
+ *   	+-----------------+                |             |
+ *   	|   context 15    |                |  data       |
+ *   	+-----------------+                |             |
+ *   	|    ......       | \              |             |
+ *   	+-----------------+  \____________ +-------------+
+ *   	|   context 1     |
+ *   	+-----------------+
+ *   	|   context 0     |
+ *   	+-----------------+
+ *
+ *   Each of the "contexts" is a chunk of memory that can be mmaped into user
+ *   space. The context consists of 2 parts:
+ *
+ *  	- an instruction space that can be directly accessed by the user
+ *  	  to issue GRU instructions and to check instruction status.
+ *
+ *  	- a data area that acts as normal RAM.
+ *
+ *   User instructions contain virtual addresses of data to be accessed by the
+ *   GRU. The GRU contains a TLB that is used to convert these user virtual
+ *   addresses to physical addresses.
+ *
+ *   The "system control" area of the GRU chiplet is used by the kernel driver
+ *   to manage user contexts and to perform functions such as TLB dropin and
+ *   purging.
+ *
+ *   One context may be reserved for the kernel and used for cross-partition
+ *   communication. The GRU will also be used to asynchronously zero out
+ *   large blocks of memory (not currently implemented).
+ *
+ *
  * Tables:
  *
  * 	VDATA-VMA Data		- Holds a few parameters. Head of linked list of
@@ -190,14 +254,14 @@ struct gru_stats_s {
 #define GRU_STEAL_DELAY		((HZ * 200) / 1000)
 
 #define STAT(id)	do {						\
-				if (options & OPT_STATS)		\
+				if (gru_options & OPT_STATS)		\
 					atomic_long_inc(&gru_stats.id);	\
 			} while (0)
 
 #ifdef CONFIG_SGI_GRU_DEBUG
 #define gru_dbg(dev, fmt, x...)						\
 	do {								\
-		if (options & OPT_DPRINT)				\
+		if (gru_options & OPT_DPRINT)				\
 			dev_dbg(dev, "%s: " fmt, __func__, x);		\
 	} while (0)
 #else
@@ -529,9 +593,9 @@ extern void gru_flush_all_tlb(struct gru
 extern int gru_proc_init(void);
 extern void gru_proc_exit(void);
 
-extern unsigned long reserve_gru_cb_resources(struct gru_state *gru,
+extern unsigned long gru_reserve_cb_resources(struct gru_state *gru,
 		int cbr_au_count, char *cbmap);
-extern unsigned long reserve_gru_ds_resources(struct gru_state *gru,
+extern unsigned long gru_reserve_ds_resources(struct gru_state *gru,
 		int dsr_au_count, char *dsmap);
 extern int gru_fault(struct vm_area_struct *, struct vm_fault *vmf);
 extern struct gru_mm_struct *gru_register_mmu_notifier(void);
@@ -540,6 +604,6 @@ extern void gru_drop_mmu_notifier(struct
 extern void gru_flush_tlb_range(struct gru_mm_struct *gms, unsigned long start,
 					unsigned long len);
 
-extern unsigned long options;
+extern unsigned long gru_options;
 
 #endif /* __GRUTABLES_H__ */
Index: linux/drivers/misc/sgi-gru/grutlbpurge.c
===================================================================
--- linux.orig/drivers/misc/sgi-gru/grutlbpurge.c	2008-07-28 14:52:26.000000000 -0500
+++ linux/drivers/misc/sgi-gru/grutlbpurge.c	2008-07-28 14:52:54.000000000 -0500
@@ -242,7 +242,9 @@ static void gru_invalidate_range_end(str
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
 
-	atomic_dec(&gms->ms_range_active);
+	/* ..._and_test() provides needed barrier */
+	(void)atomic_dec_and_test(&gms->ms_range_active);
+
 	wake_up_all(&gms->ms_wait_queue);
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

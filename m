Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1196B0072
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:45:12 -0500 (EST)
Received: by paceu11 with SMTP id eu11so37977882pac.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:45:12 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id rf8si2334902pab.79.2015.02.24.10.45.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Feb 2015 10:45:11 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKA00HAAHLZCV50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Feb 2015 18:49:11 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH v3 3/4] mm: cma: add list of currently allocated CMA buffers to
 debugfs
Date: Tue, 24 Feb 2015 21:44:34 +0300
Message-id: 
 <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

When CONFIG_CMA_BUFFER_LIST is configured a file is added to debugfs:
/sys/kernel/debug/cma/cma-<N>/buffers contains a list of currently allocated
CMA buffers for each CMA region (N stands for number of CMA region).

Format is:
<base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID> (<comm>)

When CONFIG_CMA_ALLOC_STACKTRACE is configured then stack traces are saved when
the allocations are made. The stack traces are added to cma/cma-<N>/buffers
for each buffer list entry.

Example:

root@debian:/sys/kernel/debug/cma# cat cma-0/buffers
0x2f400000 - 0x2f417000 (92 kB), allocated by pid 1 (swapper/0)
 [<c1142c4b>] cma_alloc+0x1bb/0x200
 [<c143d28a>] dma_alloc_from_contiguous+0x3a/0x40
 [<c10079d9>] dma_generic_alloc_coherent+0x89/0x160
 [<c14456ce>] dmam_alloc_coherent+0xbe/0x100
 [<c1487312>] ahci_port_start+0xe2/0x210
 [<c146e0e0>] ata_host_start.part.28+0xc0/0x1a0
 [<c1473650>] ata_host_activate+0xd0/0x110
 [<c14881bf>] ahci_host_activate+0x3f/0x170
 [<c14854e4>] ahci_init_one+0x764/0xab0
 [<c12e415f>] pci_device_probe+0x6f/0xd0
 [<c14378a8>] driver_probe_device+0x68/0x210
 [<c1437b09>] __driver_attach+0x79/0x80
 [<c1435eef>] bus_for_each_dev+0x4f/0x80
 [<c143749e>] driver_attach+0x1e/0x20
 [<c1437197>] bus_add_driver+0x157/0x200
 [<c14381bd>] driver_register+0x5d/0xf0
<...>

Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
---
 mm/Kconfig     |  17 +++++++
 mm/cma.c       |   9 +++-
 mm/cma.h       |  26 ++++++++++
 mm/cma_debug.c | 156 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 207 insertions(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 390214d..5ee2388 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -523,6 +523,23 @@ config CMA_DEBUGFS
 	help
 	  Turns on the DebugFS interface for CMA.
 
+config CMA_BUFFER_LIST
+	bool "List of currently allocated CMA buffers in debugfs"
+	depends on CMA_DEBUGFS
+	help
+	  /sys/kernel/debug/cma/cma-<N>/buffers contains a list of currently
+	  allocated CMA buffers for each CMA region (N stands for number of
+	  CMA region).
+	  Format is:
+	  <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID> (<comm>)
+
+config CMA_ALLOC_STACKTRACE
+	bool "Add stack trace to CMA buffer list"
+	depends on CMA_BUFFER_LIST && STACKTRACE
+	help
+	  Add stack traces saved at the moment of allocation for each buffer
+	  listed in /sys/kernel/debug/cma/cma-<N>/buffers.
+
 config CMA_AREAS
 	int "Maximum count of the CMA areas"
 	depends on CMA
diff --git a/mm/cma.c b/mm/cma.c
index 111bf62..e97c0ad 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -128,6 +128,10 @@ static int __init cma_activate_area(struct cma *cma)
 	INIT_HLIST_HEAD(&cma->mem_head);
 	spin_lock_init(&cma->mem_head_lock);
 #endif
+#ifdef CONFIG_CMA_BUFFER_LIST
+	INIT_LIST_HEAD(&cma->buffer_list);
+	mutex_init(&cma->list_lock);
+#endif
 
 	return 0;
 
@@ -410,8 +414,10 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
-	if (page)
+	if (page) {
 		trace_cma_alloc(cma, pfn, count);
+		cma_buffer_list_add(cma, pfn, count);
+	}
 
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
@@ -446,6 +452,7 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
 	free_contig_range(pfn, count);
 	cma_clear_bitmap(cma, pfn, count);
 	trace_cma_release(cma, pfn, count);
+	cma_buffer_list_del(cma, pfn, count);
 
 	return true;
 }
diff --git a/mm/cma.h b/mm/cma.h
index 1132d73..6e7a488 100644
--- a/mm/cma.h
+++ b/mm/cma.h
@@ -1,6 +1,8 @@
 #ifndef __MM_CMA_H__
 #define __MM_CMA_H__
 
+#include <linux/sched.h>
+
 struct cma {
 	unsigned long   base_pfn;
 	unsigned long   count;
@@ -11,8 +13,32 @@ struct cma {
 	struct hlist_head mem_head;
 	spinlock_t mem_head_lock;
 #endif
+#ifdef CONFIG_CMA_BUFFER_LIST
+	struct list_head buffer_list;
+	struct mutex	list_lock;
+#endif
 };
 
+#ifdef CONFIG_CMA_BUFFER_LIST
+struct cma_buffer {
+	unsigned long pfn;
+	unsigned long count;
+	pid_t pid;
+	char comm[TASK_COMM_LEN];
+#ifdef CONFIG_CMA_ALLOC_STACKTRACE
+	unsigned long trace_entries[16];
+	unsigned int nr_entries;
+#endif
+	struct list_head list;
+};
+
+extern int cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count);
+extern void cma_buffer_list_del(struct cma *cma, unsigned long pfn, int count);
+#else
+#define cma_buffer_list_add(cma, pfn, count) { }
+#define cma_buffer_list_del(cma, pfn, count) { }
+#endif /* CONFIG_CMA_BUFFER_LIST */
+
 extern struct cma cma_areas[MAX_CMA_AREAS];
 extern unsigned cma_area_count;
 
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 6f0b976..cb74a0c 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -2,6 +2,7 @@
  * CMA DebugFS Interface
  *
  * Copyright (c) 2015 Sasha Levin <sasha.levin@oracle.com>
+ * Copyright (c) 2015 Stefan Strogin <stefan.strogin@gmail.com>
  */
  
 
@@ -10,6 +11,9 @@
 #include <linux/list.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/stacktrace.h>
+#include <linux/vmalloc.h>
 
 #include "cma.h"
 
@@ -21,6 +25,103 @@ struct cma_mem {
 
 static struct dentry *cma_debugfs_root;
 
+#ifdef CONFIG_CMA_BUFFER_LIST
+/* Must be called under cma->list_lock */
+static int __cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count)
+{
+	struct cma_buffer *cmabuf;
+#ifdef CONFIG_CMA_ALLOC_STACKTRACE
+	struct stack_trace trace;
+#endif
+
+	cmabuf = kmalloc(sizeof(*cmabuf), GFP_KERNEL);
+	if (!cmabuf) {
+		pr_warn("%s(page %p, count %d): failed to allocate buffer list entry\n",
+			__func__, pfn_to_page(pfn), count);
+		return -ENOMEM;
+	}
+
+#ifdef CONFIG_CMA_ALLOC_STACKTRACE
+	trace.nr_entries = 0;
+	trace.max_entries = ARRAY_SIZE(cmabuf->trace_entries);
+	trace.entries = &cmabuf->trace_entries[0];
+	trace.skip = 2;
+	save_stack_trace(&trace);
+	cmabuf->nr_entries = trace.nr_entries;
+#endif
+	cmabuf->pfn = pfn;
+	cmabuf->count = count;
+	cmabuf->pid = task_pid_nr(current);
+	get_task_comm(cmabuf->comm, current);
+
+	list_add_tail(&cmabuf->list, &cma->buffer_list);
+
+	return 0;
+}
+
+/**
+ * cma_buffer_list_add() - add a new entry to a list of allocated buffers
+ * @cma:     Contiguous memory region for which the allocation is performed.
+ * @pfn:     Base PFN of the allocated buffer.
+ * @count:   Number of allocated pages.
+ *
+ * This function adds a new entry to the list of allocated contiguous memory
+ * buffers in a CMA region.
+ */
+int cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count)
+{
+	int ret;
+
+	mutex_lock(&cma->list_lock);
+	ret = __cma_buffer_list_add(cma, pfn, count);
+	mutex_unlock(&cma->list_lock);
+
+	return ret;
+}
+
+/**
+ * cma_buffer_list_del() - delete an entry from a list of allocated buffers
+ * @cma:   Contiguous memory region for which the allocation was performed.
+ * @pfn:   Base PFN of the released buffer.
+ * @count: Number of pages.
+ *
+ * This function deletes a list entry added by cma_buffer_list_add().
+ */
+void cma_buffer_list_del(struct cma *cma, unsigned long pfn, int count)
+{
+	struct cma_buffer *cmabuf, *tmp;
+	int found = 0;
+	unsigned long buf_end_pfn, free_end_pfn = pfn + count;
+
+	mutex_lock(&cma->list_lock);
+	list_for_each_entry_safe(cmabuf, tmp, &cma->buffer_list, list) {
+
+		buf_end_pfn = cmabuf->pfn + cmabuf->count;
+		if (pfn <= cmabuf->pfn && free_end_pfn >= buf_end_pfn) {
+			list_del(&cmabuf->list);
+			kfree(cmabuf);
+			found = 1;
+		} else if (pfn <= cmabuf->pfn && free_end_pfn < buf_end_pfn) {
+			cmabuf->count -= free_end_pfn - cmabuf->pfn;
+			cmabuf->pfn = free_end_pfn;
+			found = 1;
+		} else if (pfn > cmabuf->pfn && pfn < buf_end_pfn) {
+			if (free_end_pfn < buf_end_pfn)
+				__cma_buffer_list_add(cma, free_end_pfn,
+						buf_end_pfn - free_end_pfn);
+			cmabuf->count = pfn - cmabuf->pfn;
+			found = 1;
+		}
+	}
+	mutex_unlock(&cma->list_lock);
+
+	if (!found)
+		pr_err("%s(page %p, count %d): couldn't find buffer list entry\n",
+		       __func__, pfn_to_page(pfn), count);
+
+}
+#endif /* CONFIG_CMA_BUFFER_LIST */
+
 static int cma_debugfs_get(void *data, u64 *val)
 {
 	unsigned long *p = data;
@@ -126,6 +227,57 @@ static int cma_alloc_write(void *data, u64 val)
 
 DEFINE_SIMPLE_ATTRIBUTE(cma_alloc_fops, NULL, cma_alloc_write, "%llu\n");
 
+#ifdef CONFIG_CMA_BUFFER_LIST
+static ssize_t cma_buffer_list_read(struct file *file, char __user *userbuf,
+				    size_t count, loff_t *ppos)
+{
+	struct cma *cma = file->private_data;
+	struct cma_buffer *cmabuf;
+	char *buf;
+	int ret, n = 0;
+#ifdef CONFIG_CMA_ALLOC_STACKTRACE
+	struct stack_trace trace;
+#endif
+
+	if (*ppos < 0 || !count)
+		return -EINVAL;
+
+	buf = vmalloc(count);
+	if (!buf)
+		return -ENOMEM;
+
+	mutex_lock(&cma->list_lock);
+	list_for_each_entry(cmabuf, &cma->buffer_list, list) {
+		n += snprintf(buf + n, count - n,
+			      "0x%llx - 0x%llx (%lu kB), allocated by pid %u (%s)\n",
+			      (unsigned long long)PFN_PHYS(cmabuf->pfn),
+			      (unsigned long long)PFN_PHYS(cmabuf->pfn +
+				      cmabuf->count),
+			      (cmabuf->count * PAGE_SIZE) >> 10, cmabuf->pid,
+			      cmabuf->comm);
+
+#ifdef CONFIG_CMA_ALLOC_STACKTRACE
+		trace.nr_entries = cmabuf->nr_entries;
+		trace.entries = &cmabuf->trace_entries[0];
+		n += snprint_stack_trace(buf + n, count - n, &trace, 0);
+		n += snprintf(buf + n, count - n, "\n");
+#endif
+	}
+	mutex_unlock(&cma->list_lock);
+
+	ret = simple_read_from_buffer(userbuf, count, ppos, buf, n);
+	vfree(buf);
+
+	return ret;
+}
+
+static const struct file_operations cma_buffer_list_fops = {
+	.open = simple_open,
+	.read = cma_buffer_list_read,
+	.llseek = default_llseek,
+};
+#endif /* CONFIG_CMA_BUFFER_LIST */
+
 static void cma_debugfs_add_one(struct cma *cma, int idx)
 {       
 	struct dentry *tmp;
@@ -148,6 +300,10 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 				&cma->count, &cma_debugfs_fops);
 	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
 				&cma->order_per_bit, &cma_debugfs_fops);
+#ifdef CONFIG_CMA_BUFFER_LIST
+	debugfs_create_file("buffers", S_IRUGO, tmp, cma,
+				&cma_buffer_list_fops);
+#endif
 
 	u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
 	debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id BC8866B0071
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 09:40:31 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id w10so13193162pde.39
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 06:40:31 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ql8si3300536pac.165.2014.12.26.06.40.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 26 Dec 2014 06:40:30 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NH700COV2A5NSA0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 26 Dec 2014 14:44:29 +0000 (GMT)
From: "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Subject: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
Date: Fri, 26 Dec 2014 17:39:03 +0300
Message-id: 
 <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1419602920.git.s.strogin@partner.samsung.com>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1419602920.git.s.strogin@partner.samsung.com>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Stefan I. Strogin" <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

/proc/cmainfo contains a list of currently allocated CMA buffers for every
CMA area when CONFIG_CMA_DEBUG is enabled.

Format is:

<base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID>\
		(<command name>), latency <allocation latency> us
 <stack backtrace when the buffer had been allocated>

Signed-off-by: Stefan I. Strogin <s.strogin@partner.samsung.com>
---
 mm/cma.c | 202 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 202 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index a85ae28..ffaea26 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -34,6 +34,10 @@
 #include <linux/cma.h>
 #include <linux/highmem.h>
 #include <linux/io.h>
+#include <linux/list.h>
+#include <linux/proc_fs.h>
+#include <linux/uaccess.h>
+#include <linux/time.h>
 
 struct cma {
 	unsigned long	base_pfn;
@@ -41,8 +45,25 @@ struct cma {
 	unsigned long	*bitmap;
 	unsigned int order_per_bit; /* Order of pages represented by one bit */
 	struct mutex	lock;
+#ifdef CONFIG_CMA_DEBUG
+	struct list_head buffers_list;
+	struct mutex	list_lock;
+#endif
 };
 
+#ifdef CONFIG_CMA_DEBUG
+struct cma_buffer {
+	unsigned long pfn;
+	unsigned long count;
+	pid_t pid;
+	char comm[TASK_COMM_LEN];
+	unsigned int latency;
+	unsigned long trace_entries[16];
+	unsigned int nr_entries;
+	struct list_head list;
+};
+#endif
+
 static struct cma cma_areas[MAX_CMA_AREAS];
 static unsigned cma_area_count;
 static DEFINE_MUTEX(cma_mutex);
@@ -132,6 +153,10 @@ static int __init cma_activate_area(struct cma *cma)
 	} while (--i);
 
 	mutex_init(&cma->lock);
+#ifdef CONFIG_CMA_DEBUG
+	INIT_LIST_HEAD(&cma->buffers_list);
+	mutex_init(&cma->list_lock);
+#endif
 	return 0;
 
 err:
@@ -347,6 +372,86 @@ err:
 	return ret;
 }
 
+#ifdef CONFIG_CMA_DEBUG
+/**
+ * cma_buffer_list_add() - add a new entry to a list of allocated buffers
+ * @cma:     Contiguous memory region for which the allocation is performed.
+ * @pfn:     Base PFN of the allocated buffer.
+ * @count:   Number of allocated pages.
+ * @latency: Nanoseconds spent to allocate the buffer.
+ *
+ * This function adds a new entry to the list of allocated contiguous memory
+ * buffers in a CMA area. It uses the CMA area specificated by the device
+ * if available or the default global one otherwise.
+ */
+static int cma_buffer_list_add(struct cma *cma, unsigned long pfn,
+			       int count, s64 latency)
+{
+	struct cma_buffer *cmabuf;
+	struct stack_trace trace;
+
+	cmabuf = kmalloc(sizeof(struct cma_buffer), GFP_KERNEL);
+	if (!cmabuf)
+		return -ENOMEM;
+
+	trace.nr_entries = 0;
+	trace.max_entries = ARRAY_SIZE(cmabuf->trace_entries);
+	trace.entries = &cmabuf->trace_entries[0];
+	trace.skip = 2;
+	save_stack_trace(&trace);
+
+	cmabuf->pfn = pfn;
+	cmabuf->count = count;
+	cmabuf->pid = task_pid_nr(current);
+	cmabuf->nr_entries = trace.nr_entries;
+	get_task_comm(cmabuf->comm, current);
+	cmabuf->latency = (unsigned int) div_s64(latency, NSEC_PER_USEC);
+
+	mutex_lock(&cma->list_lock);
+	list_add_tail(&cmabuf->list, &cma->buffers_list);
+	mutex_unlock(&cma->list_lock);
+
+	return 0;
+}
+
+/**
+ * cma_buffer_list_del() - delete an entry from a list of allocated buffers
+ * @cma:   Contiguous memory region for which the allocation was performed.
+ * @pfn:   Base PFN of the released buffer.
+ *
+ * This function deletes a list entry added by cma_buffer_list_add().
+ */
+static void cma_buffer_list_del(struct cma *cma, unsigned long pfn)
+{
+	struct cma_buffer *cmabuf;
+
+	mutex_lock(&cma->list_lock);
+
+	list_for_each_entry(cmabuf, &cma->buffers_list, list)
+		if (cmabuf->pfn == pfn) {
+			list_del(&cmabuf->list);
+			kfree(cmabuf);
+			goto out;
+		}
+
+	pr_err("%s(pfn %lu): couldn't find buffers list entry\n",
+	       __func__, pfn);
+
+out:
+	mutex_unlock(&cma->list_lock);
+}
+#else
+static int cma_buffer_list_add(struct cma *cma, unsigned long pfn,
+			       int count, s64 latency)
+{
+	return 0;
+}
+
+static void cma_buffer_list_del(struct cma *cma, unsigned long pfn)
+{
+}
+#endif /* CONFIG_CMA_DEBUG */
+
 /**
  * cma_alloc() - allocate pages from contiguous area
  * @cma:   Contiguous memory region for which the allocation is performed.
@@ -361,11 +466,15 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 	unsigned long mask, offset, pfn, start = 0;
 	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
 	struct page *page = NULL;
+	struct timespec ts1, ts2;
+	s64 latency;
 	int ret;
 
 	if (!cma || !cma->count)
 		return NULL;
 
+	getnstimeofday(&ts1);
+
 	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
 		 count, align);
 
@@ -413,6 +522,19 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
+	getnstimeofday(&ts2);
+	latency = timespec_to_ns(&ts2) - timespec_to_ns(&ts1);
+
+	if (page) {
+		ret = cma_buffer_list_add(cma, pfn, count, latency);
+		if (ret) {
+			pr_warn("%s(): cma_buffer_list_add() returned %d\n",
+				__func__, ret);
+			cma_release(cma, page, count);
+			page = NULL;
+		}
+	}
+
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
 }
@@ -445,6 +567,86 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
 
 	free_contig_range(pfn, count);
 	cma_clear_bitmap(cma, pfn, count);
+	cma_buffer_list_del(cma, pfn);
 
 	return true;
 }
+
+#ifdef CONFIG_CMA_DEBUG
+static void *s_start(struct seq_file *m, loff_t *pos)
+{
+	struct cma *cma = 0;
+
+	if (*pos == 0 && cma_area_count > 0)
+		cma = &cma_areas[0];
+	else
+		*pos = 0;
+
+	return cma;
+}
+
+static int s_show(struct seq_file *m, void *p)
+{
+	struct cma *cma = p;
+	struct cma_buffer *cmabuf;
+	struct stack_trace trace;
+
+	mutex_lock(&cma->list_lock);
+
+	list_for_each_entry(cmabuf, &cma->buffers_list, list) {
+		seq_printf(m, "0x%llx - 0x%llx (%lu kB), allocated by pid %u (%s), latency %u us\n",
+			   (unsigned long long)PFN_PHYS(cmabuf->pfn),
+			   (unsigned long long)PFN_PHYS(cmabuf->pfn +
+							cmabuf->count),
+			   (cmabuf->count * PAGE_SIZE) >> 10, cmabuf->pid,
+			   cmabuf->comm, cmabuf->latency);
+
+		trace.nr_entries = cmabuf->nr_entries;
+		trace.entries = &cmabuf->trace_entries[0];
+
+		seq_print_stack_trace(m, &trace, 0);
+		seq_putc(m, '\n');
+	}
+
+	mutex_unlock(&cma->list_lock);
+	return 0;
+}
+
+static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	struct cma *cma = (struct cma *)p + 1;
+
+	return (cma < &cma_areas[cma_area_count]) ? cma : 0;
+}
+
+static void s_stop(struct seq_file *m, void *p)
+{
+}
+
+static const struct seq_operations cmainfo_op = {
+	.start = s_start,
+	.show = s_show,
+	.next = s_next,
+	.stop = s_stop,
+};
+
+static int cmainfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &cmainfo_op);
+}
+
+static const struct file_operations proc_cmainfo_operations = {
+	.open = cmainfo_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release_private,
+};
+
+static int __init proc_cmainfo_init(void)
+{
+	proc_create("cmainfo", S_IRUSR, NULL, &proc_cmainfo_operations);
+	return 0;
+}
+
+module_init(proc_cmainfo_init);
+#endif /* CONFIG_CMA_DEBUG */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

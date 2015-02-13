Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 35D216B0032
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 09:16:37 -0500 (EST)
Received: by pdjy10 with SMTP id y10so19601898pdj.13
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 06:16:36 -0800 (PST)
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com. [209.85.192.181])
        by mx.google.com with ESMTPS id j2si321678pbw.169.2015.02.13.06.16.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 06:16:36 -0800 (PST)
Received: by pdbfl12 with SMTP id fl12so19680491pdb.2
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 06:16:36 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Fri, 13 Feb 2015 23:18:46 +0900 (KST)
Subject: Re: [PATCH 1/4] mm: cma: add currently allocated CMA buffers list
 to debugfs
In-Reply-To: <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
Message-ID: <alpine.DEB.2.10.1502132313010.23105@hxeon>
References: <cover.1423777850.git.s.strogin@partner.samsung.com> <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hello, Stefan.

On Fri, 13 Feb 2015, Stefan Strogin wrote:

> /sys/kernel/debug/cma/cma-<N>/buffers contains a list of currently allocated
> CMA buffers for CMA region N when CONFIG_CMA_DEBUGFS is enabled.
>
> Format is:
>
> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID> (<comm>)
> <stack backtrace when the buffer had been allocated>
>
> Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
> ---
> include/linux/cma.h |   9 ++++
> mm/cma.c            |   9 ++++
> mm/cma.h            |  16 ++++++
> mm/cma_debug.c      | 145 +++++++++++++++++++++++++++++++++++++++++++++++++++-
> 4 files changed, 178 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 9384ba6..4c2c83c 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -28,4 +28,13 @@ extern int cma_init_reserved_mem(phys_addr_t base,
> 					struct cma **res_cma);
> extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
> extern bool cma_release(struct cma *cma, struct page *pages, int count);
> +
> +#ifdef CONFIG_CMA_DEBUGFS
> +extern int cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count);
> +extern void cma_buffer_list_del(struct cma *cma, unsigned long pfn, int count);
> +#else
> +#define cma_buffer_list_add(cma, pfn, count) { }
> +#define cma_buffer_list_del(cma, pfn, count) { }
> +#endif
> +
> #endif
> diff --git a/mm/cma.c b/mm/cma.c
> index 2609e20..ed269b0 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -34,6 +34,9 @@
> #include <linux/cma.h>
> #include <linux/highmem.h>
> #include <linux/io.h>
> +#include <linux/list.h>
> +#include <linux/proc_fs.h>
> +#include <linux/time.h>

Looks like `proc_fs.h` and `time.h` are not necessary.

>
> #include "cma.h"
>
> @@ -125,6 +128,8 @@ static int __init cma_activate_area(struct cma *cma)
> #ifdef CONFIG_CMA_DEBUGFS
> 	INIT_HLIST_HEAD(&cma->mem_head);
> 	spin_lock_init(&cma->mem_head_lock);
> +	INIT_LIST_HEAD(&cma->buffers_list);
> +	mutex_init(&cma->list_lock);
> #endif
>
> 	return 0;
> @@ -408,6 +413,9 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
> 		start = bitmap_no + mask + 1;
> 	}
>
> +	if (page)
> +		cma_buffer_list_add(cma, pfn, count);
> +
> 	pr_debug("%s(): returned %p\n", __func__, page);
> 	return page;
> }
> @@ -440,6 +448,7 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
>
> 	free_contig_range(pfn, count);
> 	cma_clear_bitmap(cma, pfn, count);
> +	cma_buffer_list_del(cma, pfn, count);
>
> 	return true;
> }
> diff --git a/mm/cma.h b/mm/cma.h
> index 1132d73..98e5f79 100644
> --- a/mm/cma.h
> +++ b/mm/cma.h
> @@ -1,6 +1,8 @@
> #ifndef __MM_CMA_H__
> #define __MM_CMA_H__
>
> +#include <linux/sched.h>
> +
> struct cma {
> 	unsigned long   base_pfn;
> 	unsigned long   count;
> @@ -10,9 +12,23 @@ struct cma {
> #ifdef CONFIG_CMA_DEBUGFS
> 	struct hlist_head mem_head;
> 	spinlock_t mem_head_lock;
> +	struct list_head buffers_list;
> +	struct mutex	list_lock;
> #endif
> };
>
> +#ifdef CONFIG_CMA_DEBUGFS
> +struct cma_buffer {
> +	unsigned long pfn;
> +	unsigned long count;
> +	pid_t pid;
> +	char comm[TASK_COMM_LEN];
> +	unsigned long trace_entries[16];
> +	unsigned int nr_entries;
> +	struct list_head list;
> +};
> +#endif
> +
> extern struct cma cma_areas[MAX_CMA_AREAS];
> extern unsigned cma_area_count;
>
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 7e1d325..5acd937 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -2,6 +2,7 @@
>  * CMA DebugFS Interface
>  *
>  * Copyright (c) 2015 Sasha Levin <sasha.levin@oracle.com>
> + * Copyright (c) 2015 Stefan Strogin <stefan.strogin@gmail.com>
>  */
>
>
> @@ -10,6 +11,8 @@
> #include <linux/list.h>
> #include <linux/kernel.h>
> #include <linux/slab.h>
> +#include <linux/mm_types.h>
> +#include <linux/stacktrace.h>
>
> #include "cma.h"
>
> @@ -21,6 +24,99 @@ struct cma_mem {
>
> static struct dentry *cma_debugfs_root;
>
> +/* Must be called under cma->list_lock */
> +static int __cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count)
> +{
> +	struct cma_buffer *cmabuf;
> +	struct stack_trace trace;
> +
> +	cmabuf = kmalloc(sizeof(*cmabuf), GFP_KERNEL);
> +	if (!cmabuf) {
> +		pr_warn("%s(page %p, count %d): failed to allocate buffer list entry\n",
> +			__func__, pfn_to_page(pfn), count);

pfn_to_page() would cause build failure on x86_64. Why don't you include 
appropriate header file?


Thanks,
SeongJae Park

> +		return -ENOMEM;
> +	}
> +
> +	trace.nr_entries = 0;
> +	trace.max_entries = ARRAY_SIZE(cmabuf->trace_entries);
> +	trace.entries = &cmabuf->trace_entries[0];
> +	trace.skip = 2;
> +	save_stack_trace(&trace);
> +
> +	cmabuf->pfn = pfn;
> +	cmabuf->count = count;
> +	cmabuf->pid = task_pid_nr(current);
> +	cmabuf->nr_entries = trace.nr_entries;
> +	get_task_comm(cmabuf->comm, current);
> +
> +	list_add_tail(&cmabuf->list, &cma->buffers_list);
> +
> +	return 0;
> +}
> +
> +/**
> + * cma_buffer_list_add() - add a new entry to a list of allocated buffers
> + * @cma:     Contiguous memory region for which the allocation is performed.
> + * @pfn:     Base PFN of the allocated buffer.
> + * @count:   Number of allocated pages.
> + *
> + * This function adds a new entry to the list of allocated contiguous memory
> + * buffers in a CMA area. It uses the CMA area specificated by the device
> + * if available or the default global one otherwise.
> + */
> +int cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count)
> +{
> +	int ret;
> +
> +	mutex_lock(&cma->list_lock);
> +	ret = __cma_buffer_list_add(cma, pfn, count);
> +	mutex_unlock(&cma->list_lock);
> +
> +	return ret;
> +}
> +
> +/**
> + * cma_buffer_list_del() - delete an entry from a list of allocated buffers
> + * @cma:   Contiguous memory region for which the allocation was performed.
> + * @pfn:   Base PFN of the released buffer.
> + * @count: Number of pages.
> + *
> + * This function deletes a list entry added by cma_buffer_list_add().
> + */
> +void cma_buffer_list_del(struct cma *cma, unsigned long pfn, int count)
> +{
> +	struct cma_buffer *cmabuf, *tmp;
> +	int found = 0;
> +	unsigned long buf_end_pfn, free_end_pfn = pfn + count;
> +
> +	mutex_lock(&cma->list_lock);
> +	list_for_each_entry_safe(cmabuf, tmp, &cma->buffers_list, list) {
> +
> +		buf_end_pfn = cmabuf->pfn + cmabuf->count;
> +		if (pfn <= cmabuf->pfn && free_end_pfn >= buf_end_pfn) {
> +			list_del(&cmabuf->list);
> +			kfree(cmabuf);
> +			found = 1;
> +		} else if (pfn <= cmabuf->pfn && free_end_pfn < buf_end_pfn) {
> +			cmabuf->count -= free_end_pfn - cmabuf->pfn;
> +			cmabuf->pfn = free_end_pfn;
> +			found = 1;
> +		} else if (pfn > cmabuf->pfn && pfn < buf_end_pfn) {
> +			if (free_end_pfn < buf_end_pfn)
> +				__cma_buffer_list_add(cma, free_end_pfn,
> +						buf_end_pfn - free_end_pfn);
> +			cmabuf->count = pfn - cmabuf->pfn;
> +			found = 1;
> +		}
> +	}
> +	mutex_unlock(&cma->list_lock);
> +
> +	if (!found)
> +		pr_err("%s(page %p, count %d): couldn't find buffer list entry\n",
> +		       __func__, pfn_to_page(pfn), count);
> +
> +}
> +
> static int cma_debugfs_get(void *data, u64 *val)
> {
> 	unsigned long *p = data;
> @@ -125,6 +221,52 @@ static int cma_alloc_write(void *data, u64 val)
>
> DEFINE_SIMPLE_ATTRIBUTE(cma_alloc_fops, NULL, cma_alloc_write, "%llu\n");
>
> +static int cma_buffers_read(struct file *file, char __user *userbuf,
> +				size_t count, loff_t *ppos)
> +{
> +	struct cma *cma = file->private_data;
> +	struct cma_buffer *cmabuf;
> +	struct stack_trace trace;
> +	char *buf;
> +	int ret, n = 0;
> +
> +	if (*ppos < 0 || !count)
> +		return -EINVAL;
> +
> +	buf = kmalloc(count, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	mutex_lock(&cma->list_lock);
> +	list_for_each_entry(cmabuf, &cma->buffers_list, list) {
> +		n += snprintf(buf + n, count - n,
> +			      "0x%llx - 0x%llx (%lu kB), allocated by pid %u (%s)\n",
> +			      (unsigned long long)PFN_PHYS(cmabuf->pfn),
> +			      (unsigned long long)PFN_PHYS(cmabuf->pfn +
> +				      cmabuf->count),
> +			      (cmabuf->count * PAGE_SIZE) >> 10, cmabuf->pid,
> +			      cmabuf->comm);
> +
> +		trace.nr_entries = cmabuf->nr_entries;
> +		trace.entries = &cmabuf->trace_entries[0];
> +
> +		n += snprint_stack_trace(buf + n, count - n, &trace, 0);
> +		n += snprintf(buf + n, count - n, "\n");
> +	}
> +	mutex_unlock(&cma->list_lock);
> +
> +	ret = simple_read_from_buffer(userbuf, count, ppos, buf, n);
> +	kfree(buf);
> +
> +	return ret;
> +}
> +
> +static const struct file_operations cma_buffers_fops = {
> +	.open = simple_open,
> +	.read = cma_buffers_read,
> +	.llseek = default_llseek,
> +};
> +
> static void cma_debugfs_add_one(struct cma *cma, int idx)
> {
> 	struct dentry *tmp;
> @@ -148,6 +290,8 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
> 	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
> 				&cma->order_per_bit, &cma_debugfs_fops);
>
> +	debugfs_create_file("buffers", S_IRUGO, tmp, cma, &cma_buffers_fops);
> +
> 	u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
> 	debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
> }
> @@ -166,4 +310,3 @@ static int __init cma_debugfs_init(void)
> 	return 0;
> }
> late_initcall(cma_debugfs_init);
> -
> -- 
> 2.1.0
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

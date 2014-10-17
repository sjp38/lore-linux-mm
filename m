Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A69016B006C
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 05:30:33 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so474743pdb.25
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 02:30:33 -0700 (PDT)
Received: from manager.mioffice.cn ([42.62.48.242])
        by mx.google.com with ESMTP id ra2si599374pbb.207.2014.10.17.02.30.16
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 02:30:32 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH v2 3/4] (CMA_AGGRESSIVE) Update reserve custom contiguous area code
Date: Fri, 17 Oct 2014 17:30:05 +0800
Message-ID: <1413538205-15915-1-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1413430551-22392-4-git-send-email-zhuhui@xiaomi.com>
References: <1413430551-22392-4-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, minchan@kernel.org, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, lauraa@codeaurora.org, vbabka@suse.cz, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com
Cc: linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>

Update this patch according to the comments from Rafael.

Add cma_alloc_counter, cma_aggressive_switch, cma_aggressive_free_min and
cma_aggressive_shrink_switch.

cma_aggressive_switch is the swith for all CMA_AGGRESSIVE function.  It can be
controlled by sysctl vm.cma-aggressive-switch.

cma_aggressive_free_min can be controlled by sysctl
"vm.cma-aggressive-free-min".  If the number of CMA free pages is small than
this sysctl value, CMA_AGGRESSIVE will not work in page alloc code.

cma_aggressive_shrink_switch can be controlled by sysctl
"vm.cma-aggressive-shrink-switch".  If sysctl "vm.cma-aggressive-shrink-switch"
is true and free normal memory's size is smaller than the size that it want to
allocate, do memory shrink with function git commit -a --amend before driver
allocate pages from CMA.

When Linux kernel try to reserve custom contiguous area, increase the value of
cma_alloc_counter.  CMA_AGGRESSIVE will not work in page alloc code.
After reserve custom contiguous area function return, decreases the value of
cma_alloc_counter.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/cma.h |  7 +++++++
 kernel/sysctl.c     | 27 +++++++++++++++++++++++++++
 mm/cma.c            | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 88 insertions(+)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 0430ed0..df96abf 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -15,6 +15,13 @@
 
 struct cma;
 
+#ifdef CONFIG_CMA_AGGRESSIVE
+extern atomic_t cma_alloc_counter;
+extern int cma_aggressive_switch;
+extern unsigned long cma_aggressive_free_min;
+extern int cma_aggressive_shrink_switch;
+#endif
+
 extern phys_addr_t cma_get_base(struct cma *cma);
 extern unsigned long cma_get_size(struct cma *cma);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4aada6d..646929e2 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -92,6 +92,10 @@
 #include <linux/nmi.h>
 #endif
 
+#ifdef CONFIG_CMA_AGGRESSIVE
+#include <linux/cma.h>
+#endif
+
 
 #if defined(CONFIG_SYSCTL)
 
@@ -1485,6 +1489,29 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+#ifdef CONFIG_CMA_AGGRESSIVE
+	{
+		.procname	= "cma-aggressive-switch",
+		.data		= &cma_aggressive_switch,
+		.maxlen		= sizeof(int),
+		.mode		= 0600,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "cma-aggressive-free-min",
+		.data		= &cma_aggressive_free_min,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0600,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
+	{
+		.procname	= "cma-aggressive-shrink-switch",
+		.data		= &cma_aggressive_shrink_switch,
+		.maxlen		= sizeof(int),
+		.mode		= 0600,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/cma.c b/mm/cma.c
index 963bc4a..1cf341c 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -33,6 +33,7 @@
 #include <linux/log2.h>
 #include <linux/cma.h>
 #include <linux/highmem.h>
+#include <linux/swap.h>
 
 struct cma {
 	unsigned long	base_pfn;
@@ -127,6 +128,27 @@ err:
 	return -EINVAL;
 }
 
+#ifdef CONFIG_CMA_AGGRESSIVE
+/* The counter for the dma_alloc_from_contiguous and
+   dma_release_from_contiguous.  */
+atomic_t cma_alloc_counter = ATOMIC_INIT(0);
+
+/* Swich of CMA_AGGRESSIVE.  */
+int cma_aggressive_switch __read_mostly;
+
+/* If the number of CMA free pages is small than this value, CMA_AGGRESSIVE will
+   not work. */
+#ifdef CONFIG_CMA_AGGRESSIVE_FREE_MIN
+unsigned long cma_aggressive_free_min __read_mostly =
+					CONFIG_CMA_AGGRESSIVE_FREE_MIN;
+#else
+unsigned long cma_aggressive_free_min __read_mostly = 500;
+#endif
+
+/* Swich of CMA_AGGRESSIVE shink.  */
+int cma_aggressive_shrink_switch __read_mostly;
+#endif
+
 static int __init cma_init_reserved_areas(void)
 {
 	int i;
@@ -138,6 +160,22 @@ static int __init cma_init_reserved_areas(void)
 			return ret;
 	}
 
+#ifdef CONFIG_CMA_AGGRESSIVE
+	cma_aggressive_switch = 0;
+#ifdef CONFIG_CMA_AGGRESSIVE_PHY_MAX
+	if (memblock_phys_mem_size() <= CONFIG_CMA_AGGRESSIVE_PHY_MAX)
+#else
+	if (memblock_phys_mem_size() <= 0x40000000)
+#endif
+		cma_aggressive_switch = 1;
+
+	cma_aggressive_shrink_switch = 0;
+#ifdef CONFIG_CMA_AGGRESSIVE_SHRINK
+	if (cma_aggressive_switch)
+		cma_aggressive_shrink_switch = 1;
+#endif
+#endif
+
 	return 0;
 }
 core_initcall(cma_init_reserved_areas);
@@ -312,6 +350,11 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
 	struct page *page = NULL;
 	int ret;
+#ifdef CONFIG_CMA_AGGRESSIVE
+	int free = global_page_state(NR_FREE_PAGES)
+			- global_page_state(NR_FREE_CMA_PAGES)
+			- totalreserve_pages;
+#endif
 
 	if (!cma || !cma->count)
 		return NULL;
@@ -326,6 +369,13 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 	bitmap_maxno = cma_bitmap_maxno(cma);
 	bitmap_count = cma_bitmap_pages_to_bits(cma, count);
 
+#ifdef CONFIG_CMA_AGGRESSIVE
+	atomic_inc(&cma_alloc_counter);
+	if (cma_aggressive_switch && cma_aggressive_shrink_switch
+	    && free < count)
+		shrink_all_memory_for_cma(count - free);
+#endif
+
 	for (;;) {
 		mutex_lock(&cma->lock);
 		bitmap_no = bitmap_find_next_zero_area(cma->bitmap,
@@ -361,6 +411,10 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
+#ifdef CONFIG_CMA_AGGRESSIVE
+	atomic_dec(&cma_alloc_counter);
+#endif
+
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

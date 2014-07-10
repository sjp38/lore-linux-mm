Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1182C6B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 00:26:27 -0400 (EDT)
Received: by mail-vc0-f177.google.com with SMTP id ij19so9300375vcb.22
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 21:26:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jp10si4921024vdb.9.2014.07.09.21.26.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 21:26:25 -0700 (PDT)
From: WANG Chao <chaowang@redhat.com>
Subject: [PATCH v2] mm/vmalloc.c: clean up map_vm_area third argument
Date: Thu, 10 Jul 2014 12:26:07 +0800
Message-Id: <1404966367-7599-1-git-send-email-chaowang@redhat.com>
In-Reply-To: <1404721943-6506-1-git-send-email-chaowang@redhat.com>
References: <1404721943-6506-1-git-send-email-chaowang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Rusty Russell <rusty@rustcorp.com.au>, Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently map_vm_area() takes (struct page *** pages) as third argument,
and after mapping, it moves (*pages) to point to (*pages + nr_mappped_pages).

It looks like this kind of increment is useless to its caller these
days. The callers don't care about the increments and actually they're
trying to avoid this by passing another copy to map_vm_area().

The caller can always guarantee all the pages can be mapped into
vm_area as specified in first argument and the caller only cares about
whether map_vm_area() fails or not.

This patch cleans up the pointer movement in map_vm_area() and updates
its callers accordingly.

v2: Fix arch/tile/kernel/module.c::module_alloc().

Signed-off-by: WANG Chao <chaowang@redhat.com>
---
 arch/tile/kernel/module.c        |  2 +-
 drivers/lguest/core.c            |  7 ++-----
 drivers/staging/android/binder.c |  4 +---
 include/linux/vmalloc.h          |  2 +-
 mm/vmalloc.c                     | 14 +++++---------
 mm/zsmalloc.c                    |  2 +-
 6 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/arch/tile/kernel/module.c b/arch/tile/kernel/module.c
index 4918d91..d19b13e 100644
--- a/arch/tile/kernel/module.c
+++ b/arch/tile/kernel/module.c
@@ -58,7 +58,7 @@ void *module_alloc(unsigned long size)
 	area->nr_pages = npages;
 	area->pages = pages;
 
-	if (map_vm_area(area, prot_rwx, &pages)) {
+	if (map_vm_area(area, prot_rwx, pages)) {
 		vunmap(area->addr);
 		goto error;
 	}
diff --git a/drivers/lguest/core.c b/drivers/lguest/core.c
index 0bf1e4e..6590558 100644
--- a/drivers/lguest/core.c
+++ b/drivers/lguest/core.c
@@ -42,7 +42,6 @@ DEFINE_MUTEX(lguest_lock);
 static __init int map_switcher(void)
 {
 	int i, err;
-	struct page **pagep;
 
 	/*
 	 * Map the Switcher in to high memory.
@@ -110,11 +109,9 @@ static __init int map_switcher(void)
 	 * This code actually sets up the pages we've allocated to appear at
 	 * switcher_addr.  map_vm_area() takes the vma we allocated above, the
 	 * kind of pages we're mapping (kernel pages), and a pointer to our
-	 * array of struct pages.  It increments that pointer, but we don't
-	 * care.
+	 * array of struct pages.
 	 */
-	pagep = lg_switcher_pages;
-	err = map_vm_area(switcher_vma, PAGE_KERNEL_EXEC, &pagep);
+	err = map_vm_area(switcher_vma, PAGE_KERNEL_EXEC, lg_switcher_pages);
 	if (err) {
 		printk("lguest: map_vm_area failed: %i\n", err);
 		goto free_vma;
diff --git a/drivers/staging/android/binder.c b/drivers/staging/android/binder.c
index a741da7..0ca9785 100644
--- a/drivers/staging/android/binder.c
+++ b/drivers/staging/android/binder.c
@@ -586,7 +586,6 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 
 	for (page_addr = start; page_addr < end; page_addr += PAGE_SIZE) {
 		int ret;
-		struct page **page_array_ptr;
 
 		page = &proc->pages[(page_addr - proc->buffer) / PAGE_SIZE];
 
@@ -599,8 +598,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 		}
 		tmp_area.addr = page_addr;
 		tmp_area.size = PAGE_SIZE + PAGE_SIZE /* guard page? */;
-		page_array_ptr = page;
-		ret = map_vm_area(&tmp_area, PAGE_KERNEL, &page_array_ptr);
+		ret = map_vm_area(&tmp_area, PAGE_KERNEL, page);
 		if (ret) {
 			pr_err("%d: binder_alloc_buf failed to map page at %p in kernel\n",
 			       proc->pid, page_addr);
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 4b8a891..b87696f 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -113,7 +113,7 @@ extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
-			struct page ***pages);
+			struct page **pages);
 #ifdef CONFIG_MMU
 extern int map_kernel_range_noflush(unsigned long start, unsigned long size,
 				    pgprot_t prot, struct page **pages);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f64632b..c36547f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1270,19 +1270,15 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 }
 EXPORT_SYMBOL_GPL(unmap_kernel_range);
 
-int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page **pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
 	unsigned long end = addr + get_vm_area_size(area);
 	int err;
 
-	err = vmap_page_range(addr, end, prot, *pages);
-	if (err > 0) {
-		*pages += err;
-		err = 0;
-	}
+	err = vmap_page_range(addr, end, prot, pages);
 
-	return err;
+	return err > 0 ? 0 : err;
 }
 EXPORT_SYMBOL_GPL(map_vm_area);
 
@@ -1548,7 +1544,7 @@ void *vmap(struct page **pages, unsigned int count,
 	if (!area)
 		return NULL;
 
-	if (map_vm_area(area, prot, &pages)) {
+	if (map_vm_area(area, prot, pages)) {
 		vunmap(area->addr);
 		return NULL;
 	}
@@ -1604,7 +1600,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		area->pages[i] = page;
 	}
 
-	if (map_vm_area(area, prot, &pages))
+	if (map_vm_area(area, prot, pages))
 		goto fail;
 	return area->addr;
 
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index fe78189..bb62a4a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -690,7 +690,7 @@ static inline void __zs_cpu_down(struct mapping_area *area)
 static inline void *__zs_map_object(struct mapping_area *area,
 				struct page *pages[2], int off, int size)
 {
-	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));
+	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, pages));
 	area->vm_addr = area->vm->addr;
 	return area->vm_addr + off;
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 42F896B0031
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 21:37:03 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so14665376pbb.23
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 18:37:02 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id if4si13113659pbc.196.2014.02.16.18.36.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Feb 2014 18:37:01 -0800 (PST)
Message-ID: <53017544.90908@huawei.com>
Date: Mon, 17 Feb 2014 10:34:44 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] mm: add a new command-line kmemcheck value
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vegard
 Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

If we want to debug the kernel memory, we should turn on CONFIG_KMEMCHECK 
and rebuild the kernel. This always takes a long time and sometimes 
impossible, e.g. users don't have the kernel source code or the code 
is different from "www.kernel.org" (private features may be added to the 
kernel, and usually users can not get the whole code). 

This patch adds a new command-line "kmemcheck=3", then the kernel will run
as the same as CONFIG_KMEMCHECK=off even CONFIG_KMEMCHECK is turn on. 
"kmemcheck=0/1/2" is the same as originally. This means we can always turn
on CONFIG_KMEMCHECK, and use "kmemcheck=3" to control it on/off with out
rebuild the kernel.

In another word, "kmemcheck=3" is equivalent:
1) turn off CONFIG_KMEMCHECK
2) rebuild the kernel
3) reboot

The different between kmemcheck=0 and 3 is the used memory and nr_cpus.
Also kmemcheck=0 can used in runtime, and kmemcheck=3 is only used in boot.
boottime: kmemcheck=0/1/2/3 (command-line)
runtime: kmemcheck=0/1/2 (/proc/sys/kernel/kmemcheck)


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 arch/x86/mm/init.c                |   11 ++++++
 arch/x86/mm/kmemcheck/kmemcheck.c |   62 ++++++++++++++++++++++++++-----------
 arch/x86/mm/kmemcheck/shadow.c    |   13 +++++---
 include/linux/kmemcheck.h         |    2 +
 mm/kmemcheck.c                    |   12 +++++--
 mm/page_alloc.c                   |    2 +
 6 files changed, 76 insertions(+), 26 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index f971306..cd7d75f 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -135,6 +135,15 @@ static void __init probe_page_size_mask(void)
 		page_size_mask |= 1 << PG_LEVEL_2M;
 #endif
 
+#if defined(CONFIG_KMEMCHECK)
+	if (!kmemcheck_on) {
+		if (direct_gbpages)
+			page_size_mask |= 1 << PG_LEVEL_1G;
+		if (cpu_has_pse)
+			page_size_mask |= 1 << PG_LEVEL_2M;
+	}
+#endif
+
 	/* Enable PSE if available */
 	if (cpu_has_pse)
 		set_in_cr4(X86_CR4_PSE);
@@ -331,6 +340,8 @@ bool pfn_range_is_mapped(unsigned long start_pfn, unsigned long end_pfn)
 	return false;
 }
 
+extern int kmemcheck_on;
+
 /*
  * Setup the direct mapping of the physical memory at PAGE_OFFSET.
  * This runs before bootmem is initialized and gets pages directly from
diff --git a/arch/x86/mm/kmemcheck/kmemcheck.c b/arch/x86/mm/kmemcheck/kmemcheck.c
index d87dd6d..d686ee0 100644
--- a/arch/x86/mm/kmemcheck/kmemcheck.c
+++ b/arch/x86/mm/kmemcheck/kmemcheck.c
@@ -44,30 +44,35 @@
 #ifdef CONFIG_KMEMCHECK_ONESHOT_BY_DEFAULT
 #  define KMEMCHECK_ENABLED 2
 #endif
+#define KMEMCHECK_CLOSED 3
 
-int kmemcheck_enabled = KMEMCHECK_ENABLED;
+int kmemcheck_enabled = KMEMCHECK_CLOSED;
+int kmemcheck_on = 0;
 
 int __init kmemcheck_init(void)
 {
+	if (kmemcheck_on) {
 #ifdef CONFIG_SMP
-	/*
-	 * Limit SMP to use a single CPU. We rely on the fact that this code
-	 * runs before SMP is set up.
-	 */
-	if (setup_max_cpus > 1) {
-		printk(KERN_INFO
-			"kmemcheck: Limiting number of CPUs to 1.\n");
-		setup_max_cpus = 1;
-	}
+		/*
+		 * Limit SMP to use a single CPU. We rely on the fact that this code
+		 * runs before SMP is set up.
+		 */
+		if (setup_max_cpus > 1) {
+			printk(KERN_INFO
+				"kmemcheck: Limiting number of CPUs to 1.\n");
+			setup_max_cpus = 1;
+		}
 #endif
 
-	if (!kmemcheck_selftest()) {
-		printk(KERN_INFO "kmemcheck: self-tests failed; disabling\n");
-		kmemcheck_enabled = 0;
-		return -EINVAL;
+		if (!kmemcheck_selftest()) {
+			printk(KERN_INFO "kmemcheck: self-tests failed; disabling\n");
+			kmemcheck_enabled = 0;
+			return -EINVAL;
+		}
+
+		printk(KERN_INFO "kmemcheck: Initialized\n");
 	}
 
-	printk(KERN_INFO "kmemcheck: Initialized\n");
 	return 0;
 }
 
@@ -82,6 +87,12 @@ static int __init param_kmemcheck(char *str)
 		return -EINVAL;
 
 	sscanf(str, "%d", &kmemcheck_enabled);
+
+	if ((kmemcheck_enabled >= KMEMCHECK_CLOSED) || (kmemcheck_enabled < 0))
+		kmemcheck_on = 0;
+	else
+		kmemcheck_on = 1;
+
 	return 0;
 }
 
@@ -134,9 +145,12 @@ static DEFINE_PER_CPU(struct kmemcheck_context, kmemcheck_context);
 
 bool kmemcheck_active(struct pt_regs *regs)
 {
-	struct kmemcheck_context *data = &__get_cpu_var(kmemcheck_context);
+	if (kmemcheck_on) {
+		struct kmemcheck_context *data = &__get_cpu_var(kmemcheck_context);
+		return data->balance > 0;
+	}
 
-	return data->balance > 0;
+	return false;
 }
 
 /* Save an address that needs to be shown/hidden */
@@ -223,6 +237,9 @@ void kmemcheck_hide(struct pt_regs *regs)
 	struct kmemcheck_context *data = &__get_cpu_var(kmemcheck_context);
 	int n;
 
+	if (!kmemcheck_on)
+		return;
+
 	BUG_ON(!irqs_disabled());
 
 	if (unlikely(data->balance != 1)) {
@@ -278,6 +295,9 @@ void kmemcheck_show_pages(struct page *p, unsigned int n)
 
 bool kmemcheck_page_is_tracked(struct page *p)
 {
+	if (!kmemcheck_on)
+		return false;
+
 	/* This will also check the "hidden" flag of the PTE. */
 	return kmemcheck_pte_lookup((unsigned long) page_address(p));
 }
@@ -333,6 +353,9 @@ bool kmemcheck_is_obj_initialized(unsigned long addr, size_t size)
 	enum kmemcheck_shadow status;
 	void *shadow;
 
+	if (!kmemcheck_on)
+		return true;
+
 	shadow = kmemcheck_shadow_lookup(addr);
 	if (!shadow)
 		return true;
@@ -616,6 +639,9 @@ bool kmemcheck_fault(struct pt_regs *regs, unsigned long address,
 {
 	pte_t *pte;
 
+	if (!kmemcheck_on)
+		return false;
+
 	/*
 	 * XXX: Is it safe to assume that memory accesses from virtual 86
 	 * mode or non-kernel code segments will _never_ access kernel
@@ -644,7 +670,7 @@ bool kmemcheck_fault(struct pt_regs *regs, unsigned long address,
 
 bool kmemcheck_trap(struct pt_regs *regs)
 {
-	if (!kmemcheck_active(regs))
+	if (!kmemcheck_on || !kmemcheck_active(regs))
 		return false;
 
 	/* We're done. */
diff --git a/arch/x86/mm/kmemcheck/shadow.c b/arch/x86/mm/kmemcheck/shadow.c
index aec1242..26e461d 100644
--- a/arch/x86/mm/kmemcheck/shadow.c
+++ b/arch/x86/mm/kmemcheck/shadow.c
@@ -90,7 +90,8 @@ void kmemcheck_mark_uninitialized(void *address, unsigned int n)
  */
 void kmemcheck_mark_initialized(void *address, unsigned int n)
 {
-	mark_shadow(address, n, KMEMCHECK_SHADOW_INITIALIZED);
+	if (kmemcheck_on)
+		mark_shadow(address, n, KMEMCHECK_SHADOW_INITIALIZED);
 }
 EXPORT_SYMBOL_GPL(kmemcheck_mark_initialized);
 
@@ -103,16 +104,18 @@ void kmemcheck_mark_unallocated_pages(struct page *p, unsigned int n)
 {
 	unsigned int i;
 
-	for (i = 0; i < n; ++i)
-		kmemcheck_mark_unallocated(page_address(&p[i]), PAGE_SIZE);
+	if (kmemcheck_on)
+		for (i = 0; i < n; ++i)
+			kmemcheck_mark_unallocated(page_address(&p[i]), PAGE_SIZE);
 }
 
 void kmemcheck_mark_uninitialized_pages(struct page *p, unsigned int n)
 {
 	unsigned int i;
 
-	for (i = 0; i < n; ++i)
-		kmemcheck_mark_uninitialized(page_address(&p[i]), PAGE_SIZE);
+	if (kmemcheck_on)
+		for (i = 0; i < n; ++i)
+			kmemcheck_mark_uninitialized(page_address(&p[i]), PAGE_SIZE);
 }
 
 void kmemcheck_mark_initialized_pages(struct page *p, unsigned int n)
diff --git a/include/linux/kmemcheck.h b/include/linux/kmemcheck.h
index 39f8453..13d15e1 100644
--- a/include/linux/kmemcheck.h
+++ b/include/linux/kmemcheck.h
@@ -6,6 +6,7 @@
 
 #ifdef CONFIG_KMEMCHECK
 extern int kmemcheck_enabled;
+extern int kmemcheck_on;
 
 /* The slab-related functions. */
 void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node);
@@ -88,6 +89,7 @@ bool kmemcheck_is_obj_initialized(unsigned long addr, size_t size);
 
 #else
 #define kmemcheck_enabled 0
+#define kmemcheck_on 0
 
 static inline void
 kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index fd814fd..fd89146 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -10,6 +10,9 @@ void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
 	int pages;
 	int i;
 
+	if (!kmemcheck_on)
+		return;
+
 	pages = 1 << order;
 
 	/*
@@ -41,6 +44,9 @@ void kmemcheck_free_shadow(struct page *page, int order)
 	int pages;
 	int i;
 
+	if (!kmemcheck_on)
+		return;
+
 	if (!kmemcheck_page_is_tracked(page))
 		return;
 
@@ -63,7 +69,7 @@ void kmemcheck_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, void *object,
 	 * Has already been memset(), which initializes the shadow for us
 	 * as well.
 	 */
-	if (gfpflags & __GFP_ZERO)
+	if (!kmemcheck_on || gfpflags & __GFP_ZERO)
 		return;
 
 	/* No need to initialize the shadow of a non-tracked slab. */
@@ -92,7 +98,7 @@ void kmemcheck_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, void *object,
 void kmemcheck_slab_free(struct kmem_cache *s, void *object, size_t size)
 {
 	/* TODO: RCU freeing is unsupported for now; hide false positives. */
-	if (!s->ctor && !(s->flags & SLAB_DESTROY_BY_RCU))
+	if (kmemcheck_on && !s->ctor && !(s->flags & SLAB_DESTROY_BY_RCU))
 		kmemcheck_mark_freed(object, size);
 }
 
@@ -101,7 +107,7 @@ void kmemcheck_pagealloc_alloc(struct page *page, unsigned int order,
 {
 	int pages;
 
-	if (gfpflags & (__GFP_HIGHMEM | __GFP_NOTRACK))
+	if (!kmemcheck_on || (gfpflags & (__GFP_HIGHMEM | __GFP_NOTRACK)))
 		return;
 
 	pages = 1 << order;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f861d02..0b2bbf2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2716,6 +2716,8 @@ retry_cpuset:
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
 			preferred_zone, migratetype);
+	if (kmemcheck_on && kmemcheck_enabled && page)
+		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
-- 
1.7.1 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

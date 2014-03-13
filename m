Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DE5966B0037
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 02:48:34 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so678362pad.21
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 23:48:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id bo2si1228229pbc.231.2014.03.12.23.48.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 23:48:33 -0700 (PDT)
Message-ID: <532154B9.5000502@huawei.com>
Date: Thu, 13 Mar 2014 14:48:25 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] kmemleak: change some global variables to int
References: <53215492.40701@huawei.com>
In-Reply-To: <53215492.40701@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

They don't have to be atomic_t, because they are simple boolean
toggles.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/kmemleak.c | 80 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 40 insertions(+), 40 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 9e102ce..6740bb7 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -192,15 +192,15 @@ static struct kmem_cache *object_cache;
 static struct kmem_cache *scan_area_cache;
 
 /* set if tracing memory operations is enabled */
-static atomic_t kmemleak_enabled = ATOMIC_INIT(0);
+static int kmemleak_enabled;
 /* set in the late_initcall if there were no errors */
-static atomic_t kmemleak_initialized = ATOMIC_INIT(0);
+static int kmemleak_initialized;
 /* enables or disables early logging of the memory operations */
-static atomic_t kmemleak_early_log = ATOMIC_INIT(1);
+static int kmemleak_early_log = 1;
 /* set if a kmemleak warning was issued */
-static atomic_t kmemleak_warning = ATOMIC_INIT(0);
+static int kmemleak_warning;
 /* set if a fatal kmemleak error has occurred */
-static atomic_t kmemleak_error = ATOMIC_INIT(0);
+static int kmemleak_error;
 
 /* minimum and maximum address that may be valid pointers */
 static unsigned long min_addr = ULONG_MAX;
@@ -267,7 +267,7 @@ static void kmemleak_disable(void);
 #define kmemleak_warn(x...)	do {		\
 	pr_warning(x);				\
 	dump_stack();				\
-	atomic_set(&kmemleak_warning, 1);	\
+	kmemleak_warning = 1;			\
 } while (0)
 
 /*
@@ -805,7 +805,7 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
 	unsigned long flags;
 	struct early_log *log;
 
-	if (atomic_read(&kmemleak_error)) {
+	if (kmemleak_error) {
 		/* kmemleak stopped recording, just count the requests */
 		crt_early_log++;
 		return;
@@ -840,7 +840,7 @@ static void early_alloc(struct early_log *log)
 	unsigned long flags;
 	int i;
 
-	if (!atomic_read(&kmemleak_enabled) || !log->ptr || IS_ERR(log->ptr))
+	if (!kmemleak_enabled || !log->ptr || IS_ERR(log->ptr))
 		return;
 
 	/*
@@ -893,9 +893,9 @@ void __ref kmemleak_alloc(const void *ptr, size_t size, int min_count,
 {
 	pr_debug("%s(0x%p, %zu, %d)\n", __func__, ptr, size, min_count);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		create_object((unsigned long)ptr, size, min_count, gfp);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_ALLOC, ptr, size, min_count);
 }
 EXPORT_SYMBOL_GPL(kmemleak_alloc);
@@ -919,11 +919,11 @@ void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size)
 	 * Percpu allocations are only scanned and not reported as leaks
 	 * (min_count is set to 0).
 	 */
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		for_each_possible_cpu(cpu)
 			create_object((unsigned long)per_cpu_ptr(ptr, cpu),
 				      size, 0, GFP_KERNEL);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_ALLOC_PERCPU, ptr, size, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_alloc_percpu);
@@ -939,9 +939,9 @@ void __ref kmemleak_free(const void *ptr)
 {
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		delete_object_full((unsigned long)ptr);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_FREE, ptr, 0, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_free);
@@ -959,9 +959,9 @@ void __ref kmemleak_free_part(const void *ptr, size_t size)
 {
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		delete_object_part((unsigned long)ptr, size);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_FREE_PART, ptr, size, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_free_part);
@@ -979,11 +979,11 @@ void __ref kmemleak_free_percpu(const void __percpu *ptr)
 
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		for_each_possible_cpu(cpu)
 			delete_object_full((unsigned long)per_cpu_ptr(ptr,
 								      cpu));
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_FREE_PERCPU, ptr, 0, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_free_percpu);
@@ -999,9 +999,9 @@ void __ref kmemleak_not_leak(const void *ptr)
 {
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		make_gray_object((unsigned long)ptr);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_NOT_LEAK, ptr, 0, 0);
 }
 EXPORT_SYMBOL(kmemleak_not_leak);
@@ -1019,9 +1019,9 @@ void __ref kmemleak_ignore(const void *ptr)
 {
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		make_black_object((unsigned long)ptr);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_IGNORE, ptr, 0, 0);
 }
 EXPORT_SYMBOL(kmemleak_ignore);
@@ -1041,9 +1041,9 @@ void __ref kmemleak_scan_area(const void *ptr, size_t size, gfp_t gfp)
 {
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && size && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && size && !IS_ERR(ptr))
 		add_scan_area((unsigned long)ptr, size, gfp);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_SCAN_AREA, ptr, size, 0);
 }
 EXPORT_SYMBOL(kmemleak_scan_area);
@@ -1061,9 +1061,9 @@ void __ref kmemleak_no_scan(const void *ptr)
 {
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		object_no_scan((unsigned long)ptr);
-	else if (atomic_read(&kmemleak_early_log))
+	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_NO_SCAN, ptr, 0, 0);
 }
 EXPORT_SYMBOL(kmemleak_no_scan);
@@ -1088,7 +1088,7 @@ static bool update_checksum(struct kmemleak_object *object)
  */
 static int scan_should_stop(void)
 {
-	if (!atomic_read(&kmemleak_enabled))
+	if (!kmemleak_enabled)
 		return 1;
 
 	/*
@@ -1624,14 +1624,14 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 		return ret;
 
 	if (strncmp(buf, "clear", 5) == 0) {
-		if (atomic_read(&kmemleak_enabled))
+		if (kmemleak_enabled)
 			kmemleak_clear();
 		else
 			__kmemleak_do_cleanup();
 		goto out;
 	}
 
-	if (!atomic_read(&kmemleak_enabled)) {
+	if (!kmemleak_enabled) {
 		ret = -EBUSY;
 		goto out;
 	}
@@ -1721,14 +1721,14 @@ static DECLARE_WORK(cleanup_work, kmemleak_do_cleanup);
 static void kmemleak_disable(void)
 {
 	/* atomically check whether it was already invoked */
-	if (atomic_cmpxchg(&kmemleak_error, 0, 1))
+	if (cmpxchg(&kmemleak_error, 0, 1))
 		return;
 
 	/* stop any memory operation tracing */
-	atomic_set(&kmemleak_enabled, 0);
+	kmemleak_enabled = 0;
 
 	/* check whether it is too early for a kernel thread */
-	if (atomic_read(&kmemleak_initialized))
+	if (kmemleak_initialized)
 		schedule_work(&cleanup_work);
 
 	pr_info("Kernel memory leak detector disabled\n");
@@ -1770,9 +1770,10 @@ void __init kmemleak_init(void)
 	int i;
 	unsigned long flags;
 
+	kmemleak_early_log = 0;
+
 #ifdef CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF
 	if (!kmemleak_skip_disable) {
-		atomic_set(&kmemleak_early_log, 0);
 		kmemleak_disable();
 		return;
 	}
@@ -1790,12 +1791,11 @@ void __init kmemleak_init(void)
 
 	/* the kernel is still in UP mode, so disabling the IRQs is enough */
 	local_irq_save(flags);
-	atomic_set(&kmemleak_early_log, 0);
-	if (atomic_read(&kmemleak_error)) {
+	if (kmemleak_error) {
 		local_irq_restore(flags);
 		return;
 	} else
-		atomic_set(&kmemleak_enabled, 1);
+		kmemleak_enabled = 1;
 	local_irq_restore(flags);
 
 	/*
@@ -1839,9 +1839,9 @@ void __init kmemleak_init(void)
 				      log->op_type);
 		}
 
-		if (atomic_read(&kmemleak_warning)) {
+		if (kmemleak_warning) {
 			print_log_trace(log);
-			atomic_set(&kmemleak_warning, 0);
+			kmemleak_warning = 0;
 		}
 	}
 }
@@ -1853,9 +1853,9 @@ static int __init kmemleak_late_init(void)
 {
 	struct dentry *dentry;
 
-	atomic_set(&kmemleak_initialized, 1);
+	kmemleak_initialized = 1;
 
-	if (atomic_read(&kmemleak_error)) {
+	if (kmemleak_error) {
 		/*
 		 * Some error occurred and kmemleak was disabled. There is a
 		 * small chance that kmemleak_disable() was called immediately
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

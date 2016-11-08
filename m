Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9BF86B0260
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 14:38:17 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y16so88573897wmd.6
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:38:17 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id 5si18234157wmv.79.2016.11.08.11.38.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 11:38:16 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id f82so201601371wmf.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:38:16 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 2/2] kasan: improve error reports
Date: Tue,  8 Nov 2016 20:37:50 +0100
Message-Id: <12f35b740fd59901898c72c837600f5f4e1c2d56.1478632698.git.andreyknvl@google.com>
In-Reply-To: <cover.1478632698.git.andreyknvl@google.com>
References: <cover.1478632698.git.andreyknvl@google.com>
In-Reply-To: <cover.1478632698.git.andreyknvl@google.com>
References: <cover.1478632698.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

1. Change header format.
2. Unify header format between different kinds of bad accesses.
3. Add empty lines between parts of the report to improve readability.
4. Improve slab object description.
5. Improve mm/kasan/report.c readability.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 246 ++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 165 insertions(+), 81 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 24c1211..a2ebea0 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -48,7 +48,7 @@ static const void *find_first_bad_addr(const void *addr, size_t size)
 	return first_bad_addr;
 }
 
-static void print_error_description(struct kasan_access_info *info)
+static const char *get_shadow_bug_type(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
 	u8 *shadow_addr;
@@ -92,53 +92,82 @@ static void print_error_description(struct kasan_access_info *info)
 		break;
 	}
 
-	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
-		bug_type, (void *)info->ip,
-		info->access_addr);
-	pr_err("%s of size %zu by task %s/%d\n",
-		info->is_write ? "Write" : "Read",
-		info->access_size, current->comm, task_pid_nr(current));
+	return bug_type;
 }
 
-static inline bool kernel_or_module_addr(const void *addr)
+static const char *get_wild_bug_type(struct kasan_access_info *info)
 {
-	if (addr >= (void *)_stext && addr < (void *)_end)
-		return true;
-	if (is_module_address((unsigned long)addr))
-		return true;
-	return false;
+	const char *bug_type;
+
+	if ((unsigned long)info->access_addr < PAGE_SIZE)
+		bug_type = "null-ptr-deref";
+	else if ((unsigned long)info->access_addr < TASK_SIZE)
+		bug_type = "user-memory-access";
+	else
+		bug_type = "wild-memory-access";
+
+	return bug_type;
 }
 
-static inline bool init_task_stack_addr(const void *addr)
+static bool addr_has_shadow(struct kasan_access_info *info)
 {
-	return addr >= (void *)&init_thread_union.stack &&
-		(addr <= (void *)&init_thread_union.stack +
-			sizeof(init_thread_union.stack));
+	return (info->access_addr >=
+		 kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
 }
 
-static DEFINE_SPINLOCK(report_lock);
+static const char *get_bug_type(struct kasan_access_info *info)
+{
+	if (addr_has_shadow(info))
+		return get_shadow_bug_type(info);
+	return get_wild_bug_type(info);
+}
 
-static void kasan_start_report(unsigned long *flags)
+static void print_report_header(struct kasan_access_info *info)
 {
-	/*
-	 * Make sure we don't end up in loop.
-	 */
-	kasan_disable_current();
-	spin_lock_irqsave(&report_lock, *flags);
-	pr_err("==================================================================\n");
+	const char *bug_type = get_bug_type(info);
+
+	pr_err("BUG: KASAN: %s in %pS\n",
+		bug_type, (void *)info->ip);
+	pr_err("%s of size %zu at addr %p by task %s/%d\n",
+		info->is_write ? "Write" : "Read", info->access_size,
+		info->access_addr, current->comm, task_pid_nr(current));
 }
 
-static void kasan_end_report(unsigned long *flags)
+static void describe_object_addr(struct kmem_cache *cache, void *object,
+				const void *addr)
 {
-	pr_err("==================================================================\n");
-	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
-	spin_unlock_irqrestore(&report_lock, *flags);
-	kasan_enable_current();
+	unsigned long access_addr = (unsigned long)addr;
+	unsigned long object_addr = (unsigned long)object;
+	const char *rel_type;
+	int rel_bytes;
+
+	pr_err("The buggy address belongs to the object at %p\n"
+	       " which belongs to the cache %s of size %d\n",
+		object, cache->name, cache->object_size);
+
+	if (!addr)
+		return;
+
+	if (access_addr < object_addr) {
+		rel_type = "to the left";
+		rel_bytes = object_addr - access_addr;
+	} else if (access_addr >= object_addr + cache->object_size) {
+		rel_type = "to the right";
+		rel_bytes = access_addr - (object_addr + cache->object_size);
+	} else {
+		rel_type = "inside";
+		rel_bytes = access_addr - object_addr;
+	}
+
+	pr_err("The buggy address %p is located %d bytes %s\n"
+	       " of %d-byte region [%p, %p)\n", addr,
+		rel_bytes, rel_type, cache->object_size, (void *)object_addr,
+		(void *)(object_addr + cache->object_size));
 }
 
-static void print_track(struct kasan_track *track)
+static void print_track(struct kasan_track *track, const char *prefix)
 {
-	pr_err("PID = %u\n", track->pid);
+	pr_err("%s by task %u:\n", prefix, track->pid);
 	if (track->stack) {
 		struct stack_trace trace;
 
@@ -149,39 +178,28 @@ static void print_track(struct kasan_track *track)
 	}
 }
 
-static void kasan_object_err(struct kmem_cache *cache, void *object)
+static void describe_object(struct kmem_cache *cache, void *object,
+				const void *addr)
 {
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 
-	dump_stack();
-	pr_err("Object at %p, in cache %s size: %d\n", object, cache->name,
-		cache->object_size);
+	describe_object_addr(cache, object, addr);
+	pr_err("\n");
 
 	if (!(cache->flags & SLAB_KASAN))
 		return;
 
-	pr_err("Allocated:\n");
-	print_track(&alloc_info->alloc_track);
-	pr_err("Freed:\n");
-	print_track(&alloc_info->free_track);
-}
-
-void kasan_report_double_free(struct kmem_cache *cache, void *object,
-			s8 shadow)
-{
-	unsigned long flags;
+	if (alloc_info->free_track.stack) {
+		print_track(&alloc_info->free_track, "Freed");
+		pr_err("\n");
+	}
 
-	kasan_start_report(&flags);
-	pr_err("BUG: Double free or freeing an invalid pointer\n");
-	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
-	kasan_object_err(cache, object);
-	kasan_end_report(&flags);
+	print_track(&alloc_info->alloc_track, "Allocated");
+	pr_err("\n");
 }
 
-static void print_address_description(struct kasan_access_info *info)
+static bool try_describe_object(const void *addr)
 {
-	const void *addr = info->access_addr;
-
 	if ((addr >= (void *)PAGE_OFFSET) &&
 		(addr < high_memory)) {
 		struct page *page = virt_to_head_page(addr);
@@ -189,19 +207,62 @@ static void print_address_description(struct kasan_access_info *info)
 		if (PageSlab(page)) {
 			void *object;
 			struct kmem_cache *cache = page->slab_cache;
-			object = nearest_obj(cache, page,
-						(void *)info->access_addr);
-			kasan_object_err(cache, object);
-			return;
+			object = nearest_obj(cache, page, (void *)addr);
+			describe_object(cache, object, addr);
+			return true;
 		}
+	}
+
+	return false;
+}
+
+static void try_describe_page(const void *addr)
+{
+	if ((addr >= (void *)PAGE_OFFSET) &&
+		(addr < high_memory)) {
+		struct page *page = virt_to_head_page(addr);
 		dump_page(page, "kasan: bad access detected");
+		pr_err("\n");
 	}
+}
+
+static inline bool kernel_or_module_addr(const void *addr)
+{
+	if (addr >= (void *)_stext && addr < (void *)_end)
+		return true;
+	if (is_module_address((unsigned long)addr))
+		return true;
+	return false;
+}
+
+static inline bool init_task_stack_addr(const void *addr)
+{
+	return addr >= (void *)&init_thread_union.stack &&
+		(addr <= (void *)&init_thread_union.stack +
+			sizeof(init_thread_union.stack));
+}
 
+static void try_describe_variable(const void *addr)
+{
 	if (kernel_or_module_addr(addr)) {
 		if (!init_task_stack_addr(addr))
-			pr_err("Address belongs to variable %pS\n", addr);
+			pr_err("The buggy address %p belongs to\n"
+			       " the variable %pS\n", addr, addr);
+			pr_err("\n");
 	}
+}
+
+static void describe_address(const void *addr)
+{
+	try_describe_page(addr);
+
 	dump_stack();
+	pr_err("\n");
+
+	if (try_describe_object(addr))
+		return;
+
+	try_describe_variable(addr);
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
@@ -256,35 +317,58 @@ static void print_shadow_for_address(const void *addr)
 	}
 }
 
+static DEFINE_SPINLOCK(report_lock);
+
+static void start_report(unsigned long *flags)
+{
+	/*
+	 * Make sure we don't end up in loop.
+	 */
+	kasan_disable_current();
+	spin_lock_irqsave(&report_lock, *flags);
+	pr_err("==================================================================\n");
+}
+
+static void end_report(unsigned long *flags)
+{
+	pr_err("==================================================================\n");
+	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
+	spin_unlock_irqrestore(&report_lock, *flags);
+	kasan_enable_current();
+}
+
+void kasan_report_double_free(struct kmem_cache *cache, void *object,
+			s8 shadow)
+{
+	unsigned long flags;
+
+	start_report(&flags);
+	pr_err("BUG: double-free or invalid-free\n");
+	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
+	pr_err("\n");
+	dump_stack();
+	pr_err("\n");
+	describe_object(cache, object, NULL);
+	end_report(&flags);
+}
+
 static void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
-	const char *bug_type;
 
-	kasan_start_report(&flags);
-
-	if (info->access_addr <
-			kasan_shadow_to_mem((void *)KASAN_SHADOW_START)) {
-		if ((unsigned long)info->access_addr < PAGE_SIZE)
-			bug_type = "null-ptr-deref";
-		else if ((unsigned long)info->access_addr < TASK_SIZE)
-			bug_type = "user-memory-access";
-		else
-			bug_type = "wild-memory-access";
-		pr_err("BUG: KASAN: %s on address %p\n",
-			bug_type, info->access_addr);
-		pr_err("%s of size %zu by task %s/%d\n",
-			info->is_write ? "Write" : "Read",
-			info->access_size, current->comm,
-			task_pid_nr(current));
-		dump_stack();
-	} else {
-		print_error_description(info);
-		print_address_description(info);
+	start_report(&flags);
+
+	print_report_header(info);
+	pr_err("\n");
+
+	if (addr_has_shadow(info)) {
+		describe_address(info->access_addr);
 		print_shadow_for_address(info->first_bad_addr);
+	} else {
+		dump_stack();
 	}
 
-	kasan_end_report(&flags);
+	end_report(&flags);
 }
 
 void kasan_report(unsigned long addr, size_t size,
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

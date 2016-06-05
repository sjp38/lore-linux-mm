Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE346B0005
	for <linux-mm@kvack.org>; Sun,  5 Jun 2016 07:12:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s73so183940653pfs.0
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 04:12:03 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id zk7si19115906pac.15.2016.06.05.04.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jun 2016 04:12:02 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id di3so9611494pab.0
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 04:12:02 -0700 (PDT)
From: "seokhoon.yoon" <iamyooon@gmail.com>
Subject: [PATCH 1/1] mm/kasan: use {READ,WRITE}_MODE not true,false
Date: Sun,  5 Jun 2016 20:11:43 +0900
Message-Id: <1465125103-26764-1-git-send-email-iamyooon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, iamyooon@gmail.com, sh.yoon@lge.com

When Kasan tell memory access is write or not, use true or false.
This expression is simple and convenient.

But I think it is possible to more readable. and so change it.

Signed-off-by: seokhoon.yoon <iamyooon@gmail.com>
---
 mm/kasan/kasan.c  | 32 ++++++++++++++++----------------
 mm/kasan/kasan.h  | 12 ++++++++++--
 mm/kasan/report.c | 16 ++++++++--------
 3 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 18b6a2b..642d936 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -274,7 +274,7 @@ static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
 }
 
 static __always_inline void check_memory_region_inline(unsigned long addr,
-						size_t size, bool write,
+						size_t size, enum acc_type type,
 						unsigned long ret_ip)
 {
 	if (unlikely(size == 0))
@@ -282,39 +282,39 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 
 	if (unlikely((void *)addr <
 		kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
-		kasan_report(addr, size, write, ret_ip);
+		kasan_report(addr, size, type, ret_ip);
 		return;
 	}
 
 	if (likely(!memory_is_poisoned(addr, size)))
 		return;
 
-	kasan_report(addr, size, write, ret_ip);
+	kasan_report(addr, size, type, ret_ip);
 }
 
 static void check_memory_region(unsigned long addr,
-				size_t size, bool write,
+				size_t size, enum acc_type type,
 				unsigned long ret_ip)
 {
-	check_memory_region_inline(addr, size, write, ret_ip);
+	check_memory_region_inline(addr, size, type, ret_ip);
 }
 
 void kasan_check_read(const void *p, unsigned int size)
 {
-	check_memory_region((unsigned long)p, size, false, _RET_IP_);
+	check_memory_region((unsigned long)p, size, READ_MODE, _RET_IP_);
 }
 EXPORT_SYMBOL(kasan_check_read);
 
 void kasan_check_write(const void *p, unsigned int size)
 {
-	check_memory_region((unsigned long)p, size, true, _RET_IP_);
+	check_memory_region((unsigned long)p, size, WRITE_MODE, _RET_IP_);
 }
 EXPORT_SYMBOL(kasan_check_write);
 
 #undef memset
 void *memset(void *addr, int c, size_t len)
 {
-	check_memory_region((unsigned long)addr, len, true, _RET_IP_);
+	check_memory_region((unsigned long)addr, len, WRITE_MODE, _RET_IP_);
 
 	return __memset(addr, c, len);
 }
@@ -322,8 +322,8 @@ void *memset(void *addr, int c, size_t len)
 #undef memmove
 void *memmove(void *dest, const void *src, size_t len)
 {
-	check_memory_region((unsigned long)src, len, false, _RET_IP_);
-	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+	check_memory_region((unsigned long)src, len, READ_MODE, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, WRITE_MODE, _RET_IP_);
 
 	return __memmove(dest, src, len);
 }
@@ -331,8 +331,8 @@ void *memmove(void *dest, const void *src, size_t len)
 #undef memcpy
 void *memcpy(void *dest, const void *src, size_t len)
 {
-	check_memory_region((unsigned long)src, len, false, _RET_IP_);
-	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+	check_memory_region((unsigned long)src, len, READ_MODE, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, WRITE_MODE, _RET_IP_);
 
 	return __memcpy(dest, src, len);
 }
@@ -709,7 +709,7 @@ EXPORT_SYMBOL(__asan_unregister_globals);
 #define DEFINE_ASAN_LOAD_STORE(size)					\
 	void __asan_load##size(unsigned long addr)			\
 	{								\
-		check_memory_region_inline(addr, size, false, _RET_IP_);\
+		check_memory_region_inline(addr, size, READ_MODE, _RET_IP_);\
 	}								\
 	EXPORT_SYMBOL(__asan_load##size);				\
 	__alias(__asan_load##size)					\
@@ -717,7 +717,7 @@ EXPORT_SYMBOL(__asan_unregister_globals);
 	EXPORT_SYMBOL(__asan_load##size##_noabort);			\
 	void __asan_store##size(unsigned long addr)			\
 	{								\
-		check_memory_region_inline(addr, size, true, _RET_IP_);	\
+		check_memory_region_inline(addr, size, WRITE_MODE, _RET_IP_);\
 	}								\
 	EXPORT_SYMBOL(__asan_store##size);				\
 	__alias(__asan_store##size)					\
@@ -732,7 +732,7 @@ DEFINE_ASAN_LOAD_STORE(16);
 
 void __asan_loadN(unsigned long addr, size_t size)
 {
-	check_memory_region(addr, size, false, _RET_IP_);
+	check_memory_region(addr, size, READ_MODE, _RET_IP_);
 }
 EXPORT_SYMBOL(__asan_loadN);
 
@@ -742,7 +742,7 @@ EXPORT_SYMBOL(__asan_loadN_noabort);
 
 void __asan_storeN(unsigned long addr, size_t size)
 {
-	check_memory_region(addr, size, true, _RET_IP_);
+	check_memory_region(addr, size, WRITE_MODE, _RET_IP_);
 }
 EXPORT_SYMBOL(__asan_storeN);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7f7ac51..47cb58c 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -27,11 +27,19 @@
 #define KASAN_ABI_VERSION 1
 #endif
 
+/*
+ * Distinguish memory access
+ */
+enum acc_type {
+	READ_MODE,
+	WRITE_MODE
+};
+
 struct kasan_access_info {
 	const void *access_addr;
 	const void *first_bad_addr;
 	size_t access_size;
-	bool is_write;
+	enum acc_type access_type;
 	unsigned long ip;
 };
 
@@ -109,7 +117,7 @@ static inline bool kasan_report_enabled(void)
 }
 
 void kasan_report(unsigned long addr, size_t size,
-		bool is_write, unsigned long ip);
+		enum acc_type type, unsigned long ip);
 
 #ifdef CONFIG_SLAB
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index b3c122d..e0bee22 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -96,7 +96,7 @@ static void print_error_description(struct kasan_access_info *info)
 		bug_type, (void *)info->ip,
 		info->access_addr);
 	pr_err("%s of size %zu by task %s/%d\n",
-		info->is_write ? "Write" : "Read",
+		info->access_type == WRITE_MODE ? "Write" : "Read",
 		info->access_size, current->comm, task_pid_nr(current));
 }
 
@@ -267,7 +267,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 		pr_err("BUG: KASAN: %s on address %p\n",
 			bug_type, info->access_addr);
 		pr_err("%s of size %zu by task %s/%d\n",
-			info->is_write ? "Write" : "Read",
+			info->access_type == WRITE_MODE ? "Write" : "Read",
 			info->access_size, current->comm,
 			task_pid_nr(current));
 		dump_stack();
@@ -283,7 +283,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 }
 
 void kasan_report(unsigned long addr, size_t size,
-		bool is_write, unsigned long ip)
+		enum acc_type type, unsigned long ip)
 {
 	struct kasan_access_info info;
 
@@ -292,7 +292,7 @@ void kasan_report(unsigned long addr, size_t size,
 
 	info.access_addr = (void *)addr;
 	info.access_size = size;
-	info.is_write = is_write;
+	info.access_type = type;
 	info.ip = ip;
 
 	kasan_report_error(&info);
@@ -302,14 +302,14 @@ void kasan_report(unsigned long addr, size_t size,
 #define DEFINE_ASAN_REPORT_LOAD(size)                     \
 void __asan_report_load##size##_noabort(unsigned long addr) \
 {                                                         \
-	kasan_report(addr, size, false, _RET_IP_);	  \
+	kasan_report(addr, size, READ_MODE, _RET_IP_);	  \
 }                                                         \
 EXPORT_SYMBOL(__asan_report_load##size##_noabort)
 
 #define DEFINE_ASAN_REPORT_STORE(size)                     \
 void __asan_report_store##size##_noabort(unsigned long addr) \
 {                                                          \
-	kasan_report(addr, size, true, _RET_IP_);	   \
+	kasan_report(addr, size, WRITE_MODE, _RET_IP_);	   \
 }                                                          \
 EXPORT_SYMBOL(__asan_report_store##size##_noabort)
 
@@ -326,12 +326,12 @@ DEFINE_ASAN_REPORT_STORE(16);
 
 void __asan_report_load_n_noabort(unsigned long addr, size_t size)
 {
-	kasan_report(addr, size, false, _RET_IP_);
+	kasan_report(addr, size, READ_MODE, _RET_IP_);
 }
 EXPORT_SYMBOL(__asan_report_load_n_noabort);
 
 void __asan_report_store_n_noabort(unsigned long addr, size_t size)
 {
-	kasan_report(addr, size, true, _RET_IP_);
+	kasan_report(addr, size, WRITE_MODE, _RET_IP_);
 }
 EXPORT_SYMBOL(__asan_report_store_n_noabort);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

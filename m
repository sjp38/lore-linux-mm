Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 82E496B0261
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:46:27 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so143617904wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:27 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id bz18si17243027wib.94.2015.09.14.06.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:46:24 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so141042681wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:23 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 1/7] kasan: update reported bug types for not user nor kernel memory accesses
Date: Mon, 14 Sep 2015 15:46:02 +0200
Message-Id: <0d0e6ce0184c69afc556051ef83d2daa1f81e768.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

Each access with address lower than kasan_shadow_to_mem(KASAN_SHADOW_START)
is reported as user-memory-access. This is not always true, the accessed
address might not be in user space. Fix this by reporting such accesses as
null-ptr-derefs or wild-memory-accesses.

There's another reason for this change. For userspace ASan we have a bunch
of systems that analyze error types for the purpose of classification
and deduplication. Sooner of later we will write them to KASAN as well.
Then clearly and explicitly stated error types will bring value.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/kasan.c  |  8 +-------
 mm/kasan/kasan.h  |  3 ---
 mm/kasan/report.c | 50 +++++++++++++++++++++++---------------------------
 3 files changed, 24 insertions(+), 37 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 7b28e9c..035f268 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -236,18 +236,12 @@ static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
 static __always_inline void check_memory_region(unsigned long addr,
 						size_t size, bool write)
 {
-	struct kasan_access_info info;
-
 	if (unlikely(size == 0))
 		return;
 
 	if (unlikely((void *)addr <
 		kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
-		info.access_addr = (void *)addr;
-		info.access_size = size;
-		info.is_write = write;
-		info.ip = _RET_IP_;
-		kasan_report_user_access(&info);
+		kasan_report(addr, size, write, _RET_IP_);
 		return;
 	}
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index a6b46cc..4f6c62e 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -54,9 +54,6 @@ struct kasan_global {
 #endif
 };
 
-void kasan_report_error(struct kasan_access_info *info);
-void kasan_report_user_access(struct kasan_access_info *info);
-
 static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 {
 	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 7833f07..964aaf4 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -189,9 +189,10 @@ static void print_shadow_for_address(const void *addr)
 
 static DEFINE_SPINLOCK(report_lock);
 
-void kasan_report_error(struct kasan_access_info *info)
+static void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
+	const char *bug_type;
 
 	/*
 	 * Make sure we don't end up in loop.
@@ -200,32 +201,26 @@ void kasan_report_error(struct kasan_access_info *info)
 	spin_lock_irqsave(&report_lock, flags);
 	pr_err("================================="
 		"=================================\n");
-	print_error_description(info);
-	print_address_description(info);
-	print_shadow_for_address(info->first_bad_addr);
-	pr_err("================================="
-		"=================================\n");
-	spin_unlock_irqrestore(&report_lock, flags);
-	kasan_enable_current();
-}
-
-void kasan_report_user_access(struct kasan_access_info *info)
-{
-	unsigned long flags;
-
-	/*
-	 * Make sure we don't end up in loop.
-	 */
-	kasan_disable_current();
-	spin_lock_irqsave(&report_lock, flags);
-	pr_err("================================="
-		"=================================\n");
-	pr_err("BUG: KASan: user-memory-access on address %p\n",
-		info->access_addr);
-	pr_err("%s of size %zu by task %s/%d\n",
-		info->is_write ? "Write" : "Read",
-		info->access_size, current->comm, task_pid_nr(current));
-	dump_stack();
+	if (info->access_addr <
+			kasan_shadow_to_mem((void *)KASAN_SHADOW_START)) {
+		if ((unsigned long)info->access_addr < PAGE_SIZE)
+			bug_type = "null-ptr-deref";
+		else if ((unsigned long)info->access_addr < TASK_SIZE)
+			bug_type = "user-memory-access";
+		else
+			bug_type = "wild-memory-access";
+		pr_err("BUG: KASan: %s on address %p\n",
+			bug_type, info->access_addr);
+		pr_err("%s of size %zu by task %s/%d\n",
+			info->is_write ? "Write" : "Read",
+			info->access_size, current->comm,
+			task_pid_nr(current));
+		dump_stack();
+	} else {
+		print_error_description(info);
+		print_address_description(info);
+		print_shadow_for_address(info->first_bad_addr);
+	}
 	pr_err("================================="
 		"=================================\n");
 	spin_unlock_irqrestore(&report_lock, flags);
@@ -244,6 +239,7 @@ void kasan_report(unsigned long addr, size_t size,
 	info.access_size = size;
 	info.is_write = is_write;
 	info.ip = ip;
+
 	kasan_report_error(&info);
 }
 
-- 
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

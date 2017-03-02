Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 678836B038D
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:49:08 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g10so29046725wrg.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:49:08 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y31sor6758wmh.16.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 05:49:07 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 2/9] kasan: unify report headers
Date: Thu,  2 Mar 2017 14:48:44 +0100
Message-Id: <20170302134851.101218-3-andreyknvl@google.com>
In-Reply-To: <20170302134851.101218-1-andreyknvl@google.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Unify KASAN report header format for different kinds of bad memory
accesses. Makes the code simpler.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 2790b4cadfa3..34a6d1aec524 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -119,16 +119,22 @@ const char *get_wild_bug_type(struct kasan_access_info *info)
 	return bug_type;
 }
 
+static const char *get_bug_type(struct kasan_access_info *info)
+{
+	if (addr_has_shadow(info))
+		return get_shadow_bug_type(info);
+	return get_wild_bug_type(info);
+}
+
 static void print_error_description(struct kasan_access_info *info)
 {
-	const char *bug_type = get_shadow_bug_type(info);
+	const char *bug_type = get_bug_type(info);
 
 	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
-		bug_type, (void *)info->ip,
-		info->access_addr);
+		bug_type, (void *)info->ip, info->access_addr);
 	pr_err("%s of size %zu by task %s/%d\n",
-		info->is_write ? "Write" : "Read",
-		info->access_size, current->comm, task_pid_nr(current));
+		info->is_write ? "Write" : "Read", info->access_size,
+		current->comm, task_pid_nr(current));
 }
 
 static inline bool kernel_or_module_addr(const void *addr)
@@ -295,17 +301,11 @@ static void kasan_report_error(struct kasan_access_info *info)
 
 	kasan_start_report(&flags);
 
+	print_error_description(info);
+
 	if (!addr_has_shadow(info)) {
-		const char *bug_type = get_wild_bug_type(info);
-		pr_err("BUG: KASAN: %s on address %p\n",
-			bug_type, info->access_addr);
-		pr_err("%s of size %zu by task %s/%d\n",
-			info->is_write ? "Write" : "Read",
-			info->access_size, current->comm,
-			task_pid_nr(current));
 		dump_stack();
 	} else {
-		print_error_description(info);
 		print_address_description(info);
 		print_shadow_for_address(info->first_bad_addr);
 	}
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD8D96B0398
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:24 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b140so16483844wme.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:24 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 62sor85060wrm.22.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:23 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 2/9] kasan: unify report headers
Date: Mon,  6 Mar 2017 17:00:02 +0100
Message-Id: <37dfb2aed479ead0fba6b8795b4da89269d2c251.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
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
index e3af37b7a74c..fc0577d15671 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -119,16 +119,22 @@ static const char *get_wild_bug_type(struct kasan_access_info *info)
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

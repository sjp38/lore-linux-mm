Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 461506B0395
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:23 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y187so30246411wmy.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x81sor32934wmx.25.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:22 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 1/9] kasan: introduce helper functions for determining bug type
Date: Mon,  6 Mar 2017 17:00:01 +0100
Message-Id: <1f1fa8b358f8bb24bc80d585c654a7b2b33b318b.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Introduce get_shadow_bug_type() function, which determines bug type
based on the shadow value for a particular kernel address.
Introduce get_wild_bug_type() function, which determines bug type
for addresses which don't have a corresponding shadow value.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 40 ++++++++++++++++++++++++++++++----------
 1 file changed, 30 insertions(+), 10 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index f479365530b6..e3af37b7a74c 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -49,7 +49,13 @@ static const void *find_first_bad_addr(const void *addr, size_t size)
 	return first_bad_addr;
 }
 
-static void print_error_description(struct kasan_access_info *info)
+static bool addr_has_shadow(struct kasan_access_info *info)
+{
+	return (info->access_addr >=
+		kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
+}
+
+static const char *get_shadow_bug_type(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
 	u8 *shadow_addr;
@@ -96,6 +102,27 @@ static void print_error_description(struct kasan_access_info *info)
 		break;
 	}
 
+	return bug_type;
+}
+
+static const char *get_wild_bug_type(struct kasan_access_info *info)
+{
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
+}
+
+static void print_error_description(struct kasan_access_info *info)
+{
+	const char *bug_type = get_shadow_bug_type(info);
+
 	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
 		bug_type, (void *)info->ip,
 		info->access_addr);
@@ -265,18 +292,11 @@ static void print_shadow_for_address(const void *addr)
 static void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
-	const char *bug_type;
 
 	kasan_start_report(&flags);
 
-	if (info->access_addr <
-			kasan_shadow_to_mem((void *)KASAN_SHADOW_START)) {
-		if ((unsigned long)info->access_addr < PAGE_SIZE)
-			bug_type = "null-ptr-deref";
-		else if ((unsigned long)info->access_addr < TASK_SIZE)
-			bug_type = "user-memory-access";
-		else
-			bug_type = "wild-memory-access";
+	if (!addr_has_shadow(info)) {
+		const char *bug_type = get_wild_bug_type(info);
 		pr_err("BUG: KASAN: %s on address %p\n",
 			bug_type, info->access_addr);
 		pr_err("%s of size %zu by task %s/%d\n",
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

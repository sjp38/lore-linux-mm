Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29FD36B035E
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id s66so4383058wrc.15
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:43 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id r5si4687955wra.223.2017.03.24.12.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:41 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id u132so20731867wmg.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:41 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 2/9] kasan: unify report headers
Date: Fri, 24 Mar 2017 20:32:28 +0100
Message-Id: <1e8bb4d01cf38337d7bbbd0d09bc6da01c60da42.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
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
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

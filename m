Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 525A76B036E
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t195so4685652wme.11
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:44 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id d75si4377007wme.36.2017.03.24.12.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:43 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id n11so10106667wma.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:42 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 1/9] kasan: introduce helper functions for determining bug type
Date: Fri, 24 Mar 2017 20:32:27 +0100
Message-Id: <69485dff9439fca82343965d3746b52c36716d91.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
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
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

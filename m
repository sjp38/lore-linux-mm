Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB4B6B0263
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:48:14 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so55057841wic.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:14 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id d3si11358358wie.23.2015.09.03.07.48.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:48:09 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so76643523wic.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:08 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 2/7] kasan: update reported bug types for kernel memory accesses
Date: Thu,  3 Sep 2015 16:47:37 +0200
Message-Id: <8e4af35aa9e69f3cfd84cce8b571cce91d04b992.1441290219.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

Update the names of the bad access types to better reflect the type of
the access that happended and make these error types "literals" that can
be used for classification and deduplication in scripts.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 4d3551d..a30ca44 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -48,7 +48,7 @@ static const void *find_first_bad_addr(const void *addr, size_t size)
 
 static void print_error_description(struct kasan_access_info *info)
 {
-	const char *bug_type = "unknown crash";
+	const char *bug_type = "unknown-crash";
 	u8 shadow_val;
 
 	info->first_bad_addr = find_first_bad_addr(info->access_addr,
@@ -57,21 +57,25 @@ static void print_error_description(struct kasan_access_info *info)
 	shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
 
 	switch (shadow_val) {
-	case KASAN_FREE_PAGE:
-	case KASAN_KMALLOC_FREE:
-		bug_type = "use after free";
+	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
+		bug_type = "out-of-bounds";
 		break;
 	case KASAN_PAGE_REDZONE:
 	case KASAN_KMALLOC_REDZONE:
+		bug_type = "slab-out-of-bounds";
+		break;
 	case KASAN_GLOBAL_REDZONE:
-	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
-		bug_type = "out of bounds access";
+		bug_type = "global-out-of-bounds";
 		break;
 	case KASAN_STACK_LEFT:
 	case KASAN_STACK_MID:
 	case KASAN_STACK_RIGHT:
 	case KASAN_STACK_PARTIAL:
-		bug_type = "out of bounds on stack";
+		bug_type = "stack-out-of-bounds";
+		break;
+	case KASAN_FREE_PAGE:
+	case KASAN_KMALLOC_FREE:
+		bug_type = "use-after-free";
 		break;
 	}
 
-- 
2.5.0.457.gab17608

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC036B0258
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:48:10 -0400 (EDT)
Received: by wibz8 with SMTP id z8so101718508wib.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:09 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id ay2si5102126wjb.121.2015.09.03.07.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:48:07 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so22611457wic.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:07 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 3/7] kasan: accurately determine the type of the bad access
Date: Thu,  3 Sep 2015 16:47:38 +0200
Message-Id: <4bcaa6fdf682a746c0a58de2884aeee13dd2805f.1441290220.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

Makes KASAN accurately determine the type of the bad access. If the shadow
byte value is in the [0, KASAN_SHADOW_SCALE_SIZE) range we can look at
the next shadow byte to determine the type of the access.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index a30ca44..6126272 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -49,15 +49,26 @@ static const void *find_first_bad_addr(const void *addr, size_t size)
 static void print_error_description(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
-	u8 shadow_val;
+	u8 *shadow_addr;
 
 	info->first_bad_addr = find_first_bad_addr(info->access_addr,
 						info->access_size);
 
-	shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
+	shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);
 
-	switch (shadow_val) {
+	/*
+	 * If shadow byte value is in [0, KASAN_SHADOW_SCALE_SIZE) we can look
+	 * at the next shadow byte to determine the type of the bad access.
+	 */
+	if (*shadow_addr > 0 && *shadow_addr <= KASAN_SHADOW_SCALE_SIZE - 1)
+		shadow_addr++;
+
+	switch (*shadow_addr) {
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
+		/*
+		 * In theory it's still possible to see these shadow values
+		 * due to a data race in the kernel code.
+		 */
 		bug_type = "out-of-bounds";
 		break;
 	case KASAN_PAGE_REDZONE:
-- 
2.5.0.457.gab17608

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

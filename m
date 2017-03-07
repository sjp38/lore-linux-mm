Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 901ED6B038B
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 19:53:15 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so217614183pfb.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 16:53:15 -0800 (PST)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id o1si3950549pgn.177.2017.03.06.16.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 16:53:14 -0800 (PST)
Received: by mail-pg0-x234.google.com with SMTP id 187so18285476pgb.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 16:53:14 -0800 (PST)
Date: Mon, 6 Mar 2017 16:53:13 -0800
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: Remove rodata_test_data export, add pr_fmt
Message-ID: <20170307005313.GA85809@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jinbum Park <jinb.park7@gmail.com>, Arjan van de Ven <arjan@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit 3ad38ceb2769 ("x86/mm: Remove CONFIG_DEBUG_NX_TEST"), nothing
is using the exported rodata_test_data variable, so drop the export.
Additionally updates the pr_fmt to avoid redundant strings and adjusts
some whitespace.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/rodata_test.h |  1 -
 mm/rodata_test.c            | 17 +++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/rodata_test.h b/include/linux/rodata_test.h
index ea05f6c51413..84766bcdd01f 100644
--- a/include/linux/rodata_test.h
+++ b/include/linux/rodata_test.h
@@ -14,7 +14,6 @@
 #define _RODATA_TEST_H
 
 #ifdef CONFIG_DEBUG_RODATA_TEST
-extern const int rodata_test_data;
 void rodata_test(void);
 #else
 static inline void rodata_test(void) {}
diff --git a/mm/rodata_test.c b/mm/rodata_test.c
index 0fd21670b513..6bb4deb12e78 100644
--- a/mm/rodata_test.c
+++ b/mm/rodata_test.c
@@ -9,11 +9,12 @@
  * as published by the Free Software Foundation; version 2
  * of the License.
  */
+#define pr_fmt(fmt) "rodata_test: " fmt
+
 #include <linux/uaccess.h>
 #include <asm/sections.h>
 
 const int rodata_test_data = 0xC3;
-EXPORT_SYMBOL_GPL(rodata_test_data);
 
 void rodata_test(void)
 {
@@ -23,20 +24,20 @@ void rodata_test(void)
 	/* test 1: read the value */
 	/* If this test fails, some previous testrun has clobbered the state */
 	if (!rodata_test_data) {
-		pr_err("rodata_test: test 1 fails (start data)\n");
+		pr_err("test 1 fails (start data)\n");
 		return;
 	}
 
 	/* test 2: write to the variable; this should fault */
 	if (!probe_kernel_write((void *)&rodata_test_data,
-						(void *)&zero, sizeof(zero))) {
-		pr_err("rodata_test: test data was not read only\n");
+				(void *)&zero, sizeof(zero))) {
+		pr_err("test data was not read only\n");
 		return;
 	}
 
 	/* test 3: check the value hasn't changed */
 	if (rodata_test_data == zero) {
-		pr_err("rodata_test: test data was changed\n");
+		pr_err("test data was changed\n");
 		return;
 	}
 
@@ -44,13 +45,13 @@ void rodata_test(void)
 	start = (unsigned long)__start_rodata;
 	end = (unsigned long)__end_rodata;
 	if (start & (PAGE_SIZE - 1)) {
-		pr_err("rodata_test: start of .rodata is not page size aligned\n");
+		pr_err("start of .rodata is not page size aligned\n");
 		return;
 	}
 	if (end & (PAGE_SIZE - 1)) {
-		pr_err("rodata_test: end of .rodata is not page size aligned\n");
+		pr_err("end of .rodata is not page size aligned\n");
 		return;
 	}
 
-	pr_info("rodata_test: all tests were successful\n");
+	pr_info("all tests were successful\n");
 }
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

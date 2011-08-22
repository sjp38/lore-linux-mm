Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF376B016E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 12:27:29 -0400 (EDT)
Received: by mail-iy0-f175.google.com with SMTP id 15so11611798iyn.34
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 09:27:28 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 4/4] debug-pagealloc: use memchr_inv
Date: Tue, 23 Aug 2011 01:29:08 +0900
Message-Id: <1314030548-21082-5-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>

Use newly introduced memchr_inv for page verification.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 mm/debug-pagealloc.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/debug-pagealloc.c b/mm/debug-pagealloc.c
index 5afe80c..d8470d4 100644
--- a/mm/debug-pagealloc.c
+++ b/mm/debug-pagealloc.c
@@ -1,4 +1,5 @@
 #include <linux/kernel.h>
+#include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/page-debug-flags.h>
@@ -62,11 +63,8 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
 	unsigned char *start;
 	unsigned char *end;
 
-	for (start = mem; start < mem + bytes; start++) {
-		if (*start != PAGE_POISON)
-			break;
-	}
-	if (start == mem + bytes)
+	start = memchr_inv(mem, PAGE_POISON, bytes);
+	if (!start)
 		return;
 
 	for (end = mem + bytes - 1; end > start; end--) {
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

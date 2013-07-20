Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id B44D66B0031
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 13:13:33 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md12so5510245pbc.30
        for <linux-mm@kvack.org>; Sat, 20 Jul 2013 10:13:32 -0700 (PDT)
From: Jerry Zhou <uulinux@gmail.com>
Subject: [PATCH] mm: negative left shift count when PAGE_SHIFT > 20
Date: Sun, 21 Jul 2013 01:12:54 +0800
Message-Id: <1374340374-4819-1-git-send-email-uulinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zhuwei.lu@archermind.com, tianfu.huang@archermind.com, chunhua.zhou@archermind.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerry Zhou <uulinux@gmail.com>

When PAGE_SHIFT > 20, the result of "20 - PAGE_SHIFT" is negative. The
previous calculating here will generate an unexpected result. In
addition, if PAGE_SIZE >= 1MB, The memory size of "numentries" was
already integral multiple of 1MB.

Signed-off-by: Jerry Zhou <uulinux@gmail.com>
---
 mm/page_alloc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..7c469c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5745,9 +5745,10 @@ void *__init alloc_large_system_hash(const char *tablename,
 	if (!numentries) {
 		/* round applicable memory size up to nearest megabyte */
 		numentries = nr_kernel_pages;
-		numentries += (1UL << (20 - PAGE_SHIFT)) - 1;
-		numentries >>= 20 - PAGE_SHIFT;
-		numentries <<= 20 - PAGE_SHIFT;
+
+		/* It isn't necessary when PAGE_SIZE >= 1MB */
+		if (PAGE_SHIFT < 20)
+			numentries = round_up(numentries, (1<<20)/PAGE_SIZE);
 
 		/* limit to 1 bucket per 2^scale bytes of low memory */
 		if (scale > PAGE_SHIFT)
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

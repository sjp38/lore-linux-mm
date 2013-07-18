Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 510B96B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 12:56:49 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3384455pbb.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 09:56:48 -0700 (PDT)
From: Jerry <uulinux@gmail.com>
Subject: [PATCH] mm: negative left shift count when PAGE_SHIFT > 20
Date: Fri, 19 Jul 2013 00:56:12 +0800
Message-Id: <1374166572-7988-1-git-send-email-uulinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zhuwei.lu@archermind.com, tianfu.huang@archermind.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerry <uulinux@gmail.com>

When PAGE_SHIFT > 20, the result of "20 - PAGE_SHIFT" is negative. The
calculating here will generate an unexpected result. In addition, if
PAGE_SHIFT > 20, The memory size represented by numentries was already
integral multiple of 1MB.

Signed-off-by: Jerry <uulinux@gmail.com>
---
 mm/page_alloc.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..cd41797 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5745,9 +5745,11 @@ void *__init alloc_large_system_hash(const char *tablename,
 	if (!numentries) {
 		/* round applicable memory size up to nearest megabyte */
 		numentries = nr_kernel_pages;
-		numentries += (1UL << (20 - PAGE_SHIFT)) - 1;
-		numentries >>= 20 - PAGE_SHIFT;
-		numentries <<= 20 - PAGE_SHIFT;
+		if (20 > PAGE_SHIFT) {
+			numentries += (1UL << (20 - PAGE_SHIFT)) - 1;
+			numentries >>= 20 - PAGE_SHIFT;
+			numentries <<= 20 - PAGE_SHIFT;
+		}
 
 		/* limit to 1 bucket per 2^scale bytes of low memory */
 		if (scale > PAGE_SHIFT)
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

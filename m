Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I48xdf016295
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:08:59 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I48xnd163816
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:59 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I48wc5006922
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:58 -0600
Date: Mon, 17 Jul 2006 22:08:57 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040852.11926.82852.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
References: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 006/008] Don't need to zero past end-of-file in file tail
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Don't need to zero past end-of-file in file tail

It will always be unpacked if the file is later grown

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
---
diff -Nurp linux005/mm/truncate.c linux006/mm/truncate.c
--- linux005/mm/truncate.c	2006-06-17 20:49:35.000000000 -0500
+++ linux006/mm/truncate.c	2006-07-17 23:04:38.000000000 -0500
@@ -14,11 +14,16 @@
 #include <linux/pagevec.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include <linux/file_tail.h>
 
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
-	memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
+#ifdef CONFIG_FILE_TAILS
+	if (PageTail(page))
+		return;
+#endif
+	memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE - partial);
 	if (PagePrivate(page))
 		do_invalidatepage(page, partial);
 }

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

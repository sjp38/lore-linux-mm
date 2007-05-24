Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCDXu3017390
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:13:33 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCCVqb523936
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCCVfh026158
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:31 -0400
Date: Thu, 24 May 2007 08:12:31 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121230.13533.57602.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 011/012] Make sure tail page is freed correctly
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Make sure tail page is freed correctly

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/page_alloc.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -Nurp linux010/mm/page_alloc.c linux011/mm/page_alloc.c
--- linux010/mm/page_alloc.c	2007-05-21 15:15:48.000000000 -0500
+++ linux011/mm/page_alloc.c	2007-05-23 22:53:12.000000000 -0500
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/file_tail.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -796,6 +797,11 @@ static void fastcall free_hot_cold_page(
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
+	if (unlikely(PageFileTail(page))) {
+		page_cache_free_tail(page);
+		return;
+	}
+
 	if (PageAnon(page))
 		page->mapping = NULL;
 	if (free_pages_check(page))

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

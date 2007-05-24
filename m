Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCDRHg017304
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:13:27 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCCQw6510308
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:26 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCCP64013457
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:25 -0400
Date: Thu, 24 May 2007 08:12:25 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121225.13533.83258.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 010/012] unpack tail page to avoid memory mapping
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

unpack tail page to avoid memory mapping

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/memory.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -Nurp linux009/mm/memory.c linux010/mm/memory.c
--- linux009/mm/memory.c	2007-05-21 15:15:48.000000000 -0500
+++ linux010/mm/memory.c	2007-05-23 22:53:12.000000000 -0500
@@ -50,6 +50,7 @@
 #include <linux/delayacct.h>
 #include <linux/init.h>
 #include <linux/writeback.h>
+#include <linux/file_tail.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2324,6 +2325,15 @@ retry:
 	else if (unlikely(new_page == NOPAGE_REFAULT))
 		return VM_FAULT_MINOR;
 
+	if (PageFileTail(new_page)) {
+		/* Can new_page->mapping be different from mapping? */
+		struct address_space *mapping2 = new_page->mapping;
+		page_cache_release(new_page);
+		if (unpack_file_tail(mapping2))
+			return VM_FAULT_OOM; /* Can we do better? */
+		goto retry;
+	}
+
 	/*
 	 * Should we do an early C-O-W break?
 	 */

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

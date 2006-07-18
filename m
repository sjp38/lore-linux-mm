Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I48meK016047
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:08:48 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I48mpb302476
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:48 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I48lVx006749
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:47 -0600
Date: Mon, 17 Jul 2006 22:08:46 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040844.11926.73881.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
References: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 005/008] unpack tail page to avoid memory mapping
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

unpack tail page to avoid memory mapping

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
---
diff -Nurp linux004/mm/memory.c linux005/mm/memory.c
--- linux004/mm/memory.c	2006-06-17 20:49:35.000000000 -0500
+++ linux005/mm/memory.c	2006-07-17 23:04:38.000000000 -0500
@@ -48,6 +48,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/file_tail.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2071,6 +2072,15 @@ retry:
 	if (new_page == NOPAGE_OOM)
 		return VM_FAULT_OOM;
 
+#ifdef CONFIG_FILE_TAILS
+	if (PageTail(new_page)) {
+		/* Can new_page->mapping be different from mapping? */
+		struct address_space *mapping2 = new_page->mapping;
+		page_cache_release(new_page);
+		unpack_file_tail(mapping2);
+		goto retry;
+	}
+#endif
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

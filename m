Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCDGbV017090
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:13:16 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCCFei503362
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:15 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCCEgA025795
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:14 -0400
Date: Thu, 24 May 2007 08:12:14 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121214.13533.15928.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 008/012] bh_offset needs to take page_address into consideration
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

bh_offset needs to take page_address into consideration

ToDo: Check how well gcc optimizes bh_offset when CONFIG_VM_FILE_TAILS is
not defined.  Some optimization may be needed, but we want to avoid
unnecessary ifdefs.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/linux/buffer_head.h |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff -Nurp linux007/include/linux/buffer_head.h linux008/include/linux/buffer_head.h
--- linux007/include/linux/buffer_head.h	2007-05-21 15:15:43.000000000 -0500
+++ linux008/include/linux/buffer_head.h	2007-05-23 22:53:12.000000000 -0500
@@ -129,7 +129,17 @@ BUFFER_FNS(Ordered, ordered)
 BUFFER_FNS(Eopnotsupp, eopnotsupp)
 BUFFER_FNS(Unwritten, unwritten)
 
-#define bh_offset(bh)		((unsigned long)(bh)->b_data & ~PAGE_MASK)
+/*
+ * If CONFIG_VM_FILE_TAILS is defined, page_address(bh) may not be
+ * aligned to PAGE_SIZE, so bh_offset must take that into account.
+ */
+static inline unsigned long bh_offset(struct buffer_head *bh)
+{
+	return ((unsigned long)bh->b_data -
+		(unsigned long)page_address(bh->b_page)) &
+	       ~PAGE_MASK;
+}
+
 #define touch_buffer(bh)	mark_page_accessed(bh->b_page)
 
 /* If we *know* page->private refers to buffer_heads */

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

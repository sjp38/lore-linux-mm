Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TKripm016673
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:44 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TKriwh674790
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TKrieY014732
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:53:44 -0400
Date: Wed, 29 Aug 2007 16:53:42 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070829205342.28328.57663.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 03/07] Release tail when inode is freed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Release tail when inode is freed

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 fs/inode.c |    2 ++
 1 file changed, 2 insertions(+)

diff -Nurp linux002/fs/inode.c linux003/fs/inode.c
--- linux002/fs/inode.c	2007-08-29 13:27:46.000000000 -0500
+++ linux003/fs/inode.c	2007-08-29 13:27:46.000000000 -0500
@@ -10,6 +10,7 @@
 #include <linux/init.h>
 #include <linux/quotaops.h>
 #include <linux/slab.h>
+#include <linux/vm_file_tail.h>
 #include <linux/writeback.h>
 #include <linux/module.h>
 #include <linux/backing-dev.h>
@@ -245,6 +246,7 @@ void __iget(struct inode * inode)
 void clear_inode(struct inode *inode)
 {
 	might_sleep();
+	vm_file_tail_free(inode->i_mapping);
 	invalidate_inode_buffers(inode);
        
 	BUG_ON(inode->i_data.nrpages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

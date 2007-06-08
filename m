Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 946421223F
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:06:29 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 02 of 16] avoid oom deadlock in nfs_create_request
Message-Id: <d64cb81222748354bf5b.1181332980@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332960 -7200
# Node ID d64cb81222748354bf5b16258197217465f35aeb
# Parent  8e38f7656968417dfee09fbb6450a8f1e70f8b21
avoid oom deadlock in nfs_create_request

When sigkill is pending after the oom killer set TIF_MEMDIE, the task
must go away or the VM will malfunction.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -61,16 +61,20 @@ nfs_create_request(struct nfs_open_conte
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_page		*req;
 
-	for (;;) {
-		/* try to allocate the request struct */
-		req = nfs_page_alloc();
-		if (req != NULL)
-			break;
-
-		if (signalled() && (server->flags & NFS_MOUNT_INTR))
-			return ERR_PTR(-ERESTARTSYS);
-		yield();
-	}
+	/* try to allocate the request struct */
+	req = nfs_page_alloc();
+	if (unlikely(!req)) {
+		/*
+		 * -ENOMEM will be returned only when TIF_MEMDIE is set
+		 * so userland shouldn't risk to get confused by a new
+		 * unhandled ENOMEM errno.
+		 */
+		WARN_ON(!test_thread_flag(TIF_MEMDIE));
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (signalled() && (server->flags & NFS_MOUNT_INTR))
+		return ERR_PTR(-ERESTARTSYS);
 
 	/* Initialize the request struct. Initially, we assume a
 	 * long write-back delay. This will be adjusted in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

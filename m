Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 02 of 13] avoid oom deadlock in nfs_create_request
Message-Id: <ddd02ad798f6902fc561.1199778633@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:33 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199469588 -3600
# Node ID ddd02ad798f6902fc561843c60f1189a44fdb439
# Parent  31ccca6f0b3ee1b340b9d32c0231eb1f957ee1ad
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
 
-		if (signalled() && (server->flags & NFS_MOUNT_INTR))
-			return ERR_PTR(-ERESTARTSYS);
-		yield();
-	}
+	if (signalled() && (server->flags & NFS_MOUNT_INTR))
+		return ERR_PTR(-ERESTARTSYS);
 
 	/* Initialize the request struct. Initially, we assume a
 	 * long write-back delay. This will be adjusted in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

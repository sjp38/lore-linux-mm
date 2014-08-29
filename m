Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 40E326B0037
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:06:58 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so1020596wib.5
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 09:06:57 -0700 (PDT)
Received: from ducie-dc1.codethink.co.uk (ducie-dc1.codethink.co.uk. [185.25.241.215])
        by mx.google.com with ESMTPS id mw7si779509wic.87.2014.08.29.09.06.56
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 09:06:56 -0700 (PDT)
From: Rob Jones <rob.jones@codethink.co.uk>
Subject: [PATCH 1/4] ipc: Use __seq_open_private() instead of seq_open()
Date: Fri, 29 Aug 2014 17:06:37 +0100
Message-Id: <1409328400-18212-2-git-send-email-rob.jones@codethink.co.uk>
In-Reply-To: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, jbaron@akamai.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, linux-kernel@codethink.co.uk, rob.jones@codethink.co.uk

Using __seq_open_private() removes boilerplate code from
sysvipc_proc_open().

The resultant code is shorter and easier to follow.

However, please note that  __seq_open_private() call kzalloc() rather than
kmalloc() which may affect timing due to the memory initialisation overhead.

Signed-off-by: Rob Jones <rob.jones@codethink.co.uk>
---
 ipc/util.c |   20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/ipc/util.c b/ipc/util.c
index 2eb0d1e..98cb51d 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -892,28 +892,16 @@ static const struct seq_operations sysvipc_proc_seqops = {
 
 static int sysvipc_proc_open(struct inode *inode, struct file *file)
 {
-	int ret;
-	struct seq_file *seq;
 	struct ipc_proc_iter *iter;
 
-	ret = -ENOMEM;
-	iter = kmalloc(sizeof(*iter), GFP_KERNEL);
+	iter = __seq_open_private(file, &sysvipc_proc_seqops, sizeof(*iter));
 	if (!iter)
-		goto out;
-
-	ret = seq_open(file, &sysvipc_proc_seqops);
-	if (ret) {
-		kfree(iter);
-		goto out;
-	}
-
-	seq = file->private_data;
-	seq->private = iter;
+		return -ENOMEM;
 
 	iter->iface = PDE_DATA(inode);
 	iter->ns    = get_ipc_ns(current->nsproxy->ipc_ns);
-out:
-	return ret;
+
+	return 0;
 }
 
 static int sysvipc_proc_release(struct inode *inode, struct file *file)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

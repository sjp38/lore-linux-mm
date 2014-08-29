Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 297466B003A
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:07:16 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id ex7so2822792wid.1
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 09:07:15 -0700 (PDT)
Received: from ducie-dc1.codethink.co.uk (ducie-dc1.codethink.co.uk. [185.25.241.215])
        by mx.google.com with ESMTPS id wj4si674128wjb.133.2014.08.29.09.07.14
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 09:07:14 -0700 (PDT)
From: Rob Jones <rob.jones@codethink.co.uk>
Subject: [PATCH 4/4] lib: Use seq_open_private() instead of seq_open()
Date: Fri, 29 Aug 2014 17:06:40 +0100
Message-Id: <1409328400-18212-5-git-send-email-rob.jones@codethink.co.uk>
In-Reply-To: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, jbaron@akamai.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, linux-kernel@codethink.co.uk, rob.jones@codethink.co.uk

Using seq_open_private() removes boilerplate code from ddebug_proc_open()

The resultant code is shorter and easier to follow.

This patch does not change any functionality.

Signed-off-by: Rob Jones <rob.jones@codethink.co.uk>
---
 lib/dynamic_debug.c |   17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 7288e38..e067fb5 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -827,22 +827,9 @@ static const struct seq_operations ddebug_proc_seqops = {
  */
 static int ddebug_proc_open(struct inode *inode, struct file *file)
 {
-	struct ddebug_iter *iter;
-	int err;
-
 	vpr_info("called\n");
-
-	iter = kzalloc(sizeof(*iter), GFP_KERNEL);
-	if (iter == NULL)
-		return -ENOMEM;
-
-	err = seq_open(file, &ddebug_proc_seqops);
-	if (err) {
-		kfree(iter);
-		return err;
-	}
-	((struct seq_file *)file->private_data)->private = iter;
-	return 0;
+	return seq_open_private(file, &ddebug_proc_seqops,
+				sizeof(struct ddebug_iter));
 }
 
 static const struct file_operations ddebug_proc_fops = {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

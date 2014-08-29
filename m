Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id BA6816B0038
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:07:03 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so2423635wes.4
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 09:07:03 -0700 (PDT)
Received: from ducie-dc1.codethink.co.uk (ducie-dc1.codethink.co.uk. [185.25.241.215])
        by mx.google.com with ESMTPS id hf5si929836wib.20.2014.08.29.09.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 09:07:02 -0700 (PDT)
From: Rob Jones <rob.jones@codethink.co.uk>
Subject: [PATCH 2/4] mm: Use seq_open_private() instead of seq_open()
Date: Fri, 29 Aug 2014 17:06:38 +0100
Message-Id: <1409328400-18212-3-git-send-email-rob.jones@codethink.co.uk>
In-Reply-To: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, jbaron@akamai.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, linux-kernel@codethink.co.uk, rob.jones@codethink.co.uk

Using seq_open_private() removes boilerplate code from vmalloc_open().

The resultant code is shorter and easier to follow.

However, please note that seq_open_private() call kzalloc() rather than
kmalloc() which may affect timing due to the memory initialisation overhead.

Signed-off-by: Rob Jones <rob.jones@codethink.co.uk>
---
 mm/vmalloc.c |   20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index bf233b2..0d6caee 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2647,21 +2647,11 @@ static const struct seq_operations vmalloc_op = {
 
 static int vmalloc_open(struct inode *inode, struct file *file)
 {
-	unsigned int *ptr = NULL;
-	int ret;
-
-	if (IS_ENABLED(CONFIG_NUMA)) {
-		ptr = kmalloc(nr_node_ids * sizeof(unsigned int), GFP_KERNEL);
-		if (ptr == NULL)
-			return -ENOMEM;
-	}
-	ret = seq_open(file, &vmalloc_op);
-	if (!ret) {
-		struct seq_file *m = file->private_data;
-		m->private = ptr;
-	} else
-		kfree(ptr);
-	return ret;
+	if (IS_ENABLED(CONFIG_NUMA))
+		return seq_open_private(file, &vmalloc_op,
+					nr_node_ids * sizeof(unsigned int));
+	else
+		return seq_open(file, &vmalloc_op);
 }
 
 static const struct file_operations proc_vmalloc_operations = {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

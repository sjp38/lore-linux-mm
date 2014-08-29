Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C79BA6B0039
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:07:14 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id r20so2788718wiv.11
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 09:07:14 -0700 (PDT)
Received: from ducie-dc1.codethink.co.uk (ducie-dc1.codethink.co.uk. [185.25.241.215])
        by mx.google.com with ESMTPS id pm5si646858wjc.146.2014.08.29.09.07.13
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 09:07:13 -0700 (PDT)
From: Rob Jones <rob.jones@codethink.co.uk>
Subject: [PATCH 3/4] mm: Use __seq_open_private() instead of seq_open()
Date: Fri, 29 Aug 2014 17:06:39 +0100
Message-Id: <1409328400-18212-4-git-send-email-rob.jones@codethink.co.uk>
In-Reply-To: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, jbaron@akamai.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, linux-kernel@codethink.co.uk, rob.jones@codethink.co.uk

Using __seq_open_private() removes boilerplate code from slabstats_open()

The resultant code is shorter and easier to follow.

This patch does not change any functionality.

Signed-off-by: Rob Jones <rob.jones@codethink.co.uk>
---
 mm/slab.c |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 19d9218..d67f319 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4339,19 +4339,15 @@ static const struct seq_operations slabstats_op = {
 
 static int slabstats_open(struct inode *inode, struct file *file)
 {
-	unsigned long *n = kzalloc(PAGE_SIZE, GFP_KERNEL);
-	int ret = -ENOMEM;
-	if (n) {
-		ret = seq_open(file, &slabstats_op);
-		if (!ret) {
-			struct seq_file *m = file->private_data;
-			*n = PAGE_SIZE / (2 * sizeof(unsigned long));
-			m->private = n;
-			n = NULL;
-		}
-		kfree(n);
-	}
-	return ret;
+	unsigned long *n;
+
+	n = __seq_open_private(file, &slabstats_op, PAGE_SIZE);
+	if (!n)
+		return -ENOMEM;
+
+	*n = PAGE_SIZE / (2 * sizeof(unsigned long));
+
+	return 0;
 }
 
 static const struct file_operations proc_slabstats_operations = {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

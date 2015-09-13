Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 613506B0253
	for <linux-mm@kvack.org>; Sun, 13 Sep 2015 19:57:49 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so78844303igb.0
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 16:57:49 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id 92si7229010iok.118.2015.09.13.16.57.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Sep 2015 16:57:48 -0700 (PDT)
Received: by igbni9 with SMTP id ni9so71173346igb.0
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 16:57:48 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] userfaultfd: add missing mmput() in error path
Date: Sun, 13 Sep 2015 18:57:27 -0500
Message-Id: <1442188647-4233-1-git-send-email-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: aarcange@redhat.com, linux-kernel@vger.kernel.org, Eric Biggers <ebiggers3@gmail.com>

Signed-off-by: Eric Biggers <ebiggers3@gmail.com>
---
 fs/userfaultfd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 634e676..f9aeb40 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1287,8 +1287,10 @@ static struct file *userfaultfd_file_create(int flags)
 
 	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
 				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
-	if (IS_ERR(file))
+	if (IS_ERR(file)) {
+		mmput(ctx->mm);
 		kmem_cache_free(userfaultfd_ctx_cachep, ctx);
+	}
 out:
 	return file;
 }
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

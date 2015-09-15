Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0756B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 20:57:14 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so65841709qkf.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 17:57:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m75si14705013qki.120.2015.09.14.17.57.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 17:57:13 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] userfaultfd: add missing mmput() in error path
Date: Tue, 15 Sep 2015 02:57:09 +0200
Message-Id: <1442278629-23100-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Eric Biggers <ebiggers3@gmail.com>

From: Eric Biggers <ebiggers3@gmail.com>

This fixes a memleak if anon_inode_getfile() fails in userfaultfd().

Signed-off-by: Eric Biggers <ebiggers3@gmail.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

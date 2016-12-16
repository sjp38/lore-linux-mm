Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCC86B0268
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:27 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 136so91837773iou.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 66si2951684itb.43.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 10/42] userfaultfd: non-cooperative: dup_userfaultfd: use mm_count instead of mm_users
Date: Fri, 16 Dec 2016 15:47:49 +0100
Message-Id: <20161216144821.5183-11-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>

Since commit d2005e3f41d4 (userfaultfd: don't pin the user memory in
userfaultfd_file_create()) userfaultfd uses mm_count rather than mm_users
to pin mm_struct. Make dup_userfaultfd consistent with this behaviour

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 6fe0efd..9bb7caf 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -525,7 +525,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 		ctx->features = octx->features;
 		ctx->released = false;
 		ctx->mm = vma->vm_mm;
-		atomic_inc(&ctx->mm->mm_users);
+		atomic_inc(&ctx->mm->mm_count);
 
 		userfaultfd_ctx_get(octx);
 		fctx->orig = octx;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

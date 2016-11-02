Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8E5C6B02AA
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l20so10727824qta.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 8si1933052qkb.112.2016.11.02.12.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 10/33] userfaultfd: non-cooperative: dup_userfaultfd: use mm_count instead of mm_users
Date: Wed,  2 Nov 2016 20:33:42 +0100
Message-Id: <1478115245-32090-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

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
index 07b1c25..e0bb733 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -523,7 +523,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
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

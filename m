Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9646D6B025F
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 19:25:09 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u193so13224905oie.4
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 16:25:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d206si6865088oia.240.2017.12.22.16.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 16:25:08 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK fails
Date: Sat, 23 Dec 2017 01:25:05 +0100
Message-Id: <20171223002505.593-2-aarcange@redhat.com>
In-Reply-To: <20171223002505.593-1-aarcange@redhat.com>
References: <20171222222346.GB28786@zzz.localdomain>
 <20171223002505.593-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

The previous fix 384632e67e0829deb8015ee6ad916b180049d252 corrected
the refcounting in case of UFFD_EVENT_FORK failure for the fork
userfault paths. That still didn't clear the vma->vm_userfaultfd_ctx
of the vmas that were set to point to the aborted new uffd ctx earlier
in dup_userfaultfd.

Cc: stable@vger.kernel.org
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 896f810b6a06..1a88916455bd 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -591,11 +591,14 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 					      struct userfaultfd_wait_queue *ewq)
 {
+	struct userfaultfd_ctx *release_new_ctx;
+
 	if (WARN_ON_ONCE(current->flags & PF_EXITING))
 		goto out;
 
 	ewq->ctx = ctx;
 	init_waitqueue_entry(&ewq->wq, current);
+	release_new_ctx = NULL;
 
 	spin_lock(&ctx->event_wqh.lock);
 	/*
@@ -622,8 +625,7 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 				new = (struct userfaultfd_ctx *)
 					(unsigned long)
 					ewq->msg.arg.reserved.reserved1;
-
-				userfaultfd_ctx_put(new);
+				release_new_ctx = new;
 			}
 			break;
 		}
@@ -638,6 +640,20 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	__set_current_state(TASK_RUNNING);
 	spin_unlock(&ctx->event_wqh.lock);
 
+	if (release_new_ctx) {
+		struct vm_area_struct *vma;
+		struct mm_struct *mm = release_new_ctx->mm;
+
+		/* the various vma->vm_userfaultfd_ctx still points to it */
+		down_write(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
+			if (vma->vm_userfaultfd_ctx.ctx == release_new_ctx)
+				vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		up_write(&mm->mmap_sem);
+
+		userfaultfd_ctx_put(release_new_ctx);
+	}
+
 	/*
 	 * ctx may go away after this if the userfault pseudo fd is
 	 * already released.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

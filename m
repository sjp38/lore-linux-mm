Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F45F6B0005
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:26:29 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l26-v6so10097486oii.14
        for <linux-mm@kvack.org>; Sun, 29 Jul 2018 23:26:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v64-v6si6670983oie.317.2018.07.29.23.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jul 2018 23:26:28 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6U6JNnQ103352
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:26:27 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2khtrnw07c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:26:27 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 30 Jul 2018 07:26:24 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH RESEND] userfaultfd: remove uffd flags from vma->vm_flags if UFFD_EVENT_FORK fails
Date: Mon, 30 Jul 2018 09:26:15 +0300
Message-Id: <1532931975-25473-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Biggers <ebiggers3@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+121be635a7a35ddb7dcb@syzkaller.appspotmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>, stable@vger.kernel.org

The fix in commit 0cbb4b4f4c44 ("userfaultfd: clear the
vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK fails") cleared the
vma->vm_userfaultfd_ctx but kept userfaultfd flags in vma->vm_flags that
were copied from the parent process VMA.

As the result, there is an inconsistency between the values of
vma->vm_userfaultfd_ctx.ctx and vma->vm_flags which triggers BUG_ON in
userfaultfd_release().

Clearing the uffd flags from vma->vm_flags in case of UFFD_EVENT_FORK
failure resolves the issue.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reported-by: syzbot+121be635a7a35ddb7dcb@syzkaller.appspotmail.com
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Eric Biggers <ebiggers3@gmail.com>
Cc: stable@vger.kernel.org
---
 fs/userfaultfd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 594d192b2331..bad9cea37f12 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -633,8 +633,10 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 		/* the various vma->vm_userfaultfd_ctx still points to it */
 		down_write(&mm->mmap_sem);
 		for (vma = mm->mmap; vma; vma = vma->vm_next)
-			if (vma->vm_userfaultfd_ctx.ctx == release_new_ctx)
+			if (vma->vm_userfaultfd_ctx.ctx == release_new_ctx) {
 				vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+				vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
+			}
 		up_write(&mm->mmap_sem);
 
 		userfaultfd_ctx_put(release_new_ctx);
-- 
2.7.4

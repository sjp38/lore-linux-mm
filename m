Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F41D8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:34:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c84so12319783qkb.13
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 21:34:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si246862qvd.172.2018.12.10.21.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 21:34:17 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH v2] userfaultfd: clear flag if remap event not enabled
Date: Tue, 11 Dec 2018 13:34:09 +0800
Message-Id: <20181211053409.20317-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterx@redhat.com, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Pravin Shedge <pravin.shedge4linux@gmail.com>, linux-mm@kvack.org

When the process being tracked do mremap() without
UFFD_FEATURE_EVENT_REMAP on the corresponding tracking uffd file
handle, we should not generate the remap event, and at the same
time we should clear all the uffd flags on the new VMA.  Without
this patch, we can still have the VM_UFFD_MISSING|VM_UFFD_WP
flags on the new VMA even the fault handling process does not
even know the existance of the VMA.

CC: Andrea Arcangeli <aarcange@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
CC: Kirill A. Shutemov <kirill@shutemov.name>
CC: Hugh Dickins <hughd@google.com>
CC: Pavel Emelyanov <xemul@virtuozzo.com>
CC: Pravin Shedge <pravin.shedge4linux@gmail.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cd58939dc977..4567b5b6fd32 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -736,10 +736,18 @@ void mremap_userfaultfd_prep(struct vm_area_struct *vma,
 	struct userfaultfd_ctx *ctx;
 
 	ctx = vma->vm_userfaultfd_ctx.ctx;
-	if (ctx && (ctx->features & UFFD_FEATURE_EVENT_REMAP)) {
+
+	if (!ctx)
+		return;
+
+	if (ctx->features & UFFD_FEATURE_EVENT_REMAP) {
 		vm_ctx->ctx = ctx;
 		userfaultfd_ctx_get(ctx);
 		WRITE_ONCE(ctx->mmap_changing, true);
+	} else {
+		/* Drop uffd context if remap feature not enabled */
+		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
 	}
 }
 
-- 
2.17.1

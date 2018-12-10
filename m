Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADE758E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 01:51:33 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id d196so9514510qkb.6
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 22:51:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i2si6462165qvg.76.2018.12.09.22.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Dec 2018 22:51:32 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH] userfaultfd: clear flag if remap event not enabled
Date: Mon, 10 Dec 2018 14:51:21 +0800
Message-Id: <20181210065121.14984-1-peterx@redhat.com>
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
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cd58939dc977..798ae8a438ff 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -740,6 +740,9 @@ void mremap_userfaultfd_prep(struct vm_area_struct *vma,
 		vm_ctx->ctx = ctx;
 		userfaultfd_ctx_get(ctx);
 		WRITE_ONCE(ctx->mmap_changing, true);
+	} else if (ctx) {
+		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
+		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
 	}
 }
 
-- 
2.17.1

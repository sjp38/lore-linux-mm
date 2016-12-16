Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFCD56B0266
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:26 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id q186so21186969itb.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w10si2945620itf.37.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 12/42] userfaultfd: non-cooperative: optimize mremap_userfaultfd_complete()
Date: Fri, 16 Dec 2016 15:47:51 +0100
Message-Id: <20161216144821.5183-13-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Optimize the mremap_userfaultfd_complete() interface to pass only the
vm_userfaultfd_ctx pointer through the stack as a microoptimization.

Reported-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c              | 4 ++--
 include/linux/userfaultfd_k.h | 4 ++--
 mm/mremap.c                   | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index c047b6f..0b57045 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -575,11 +575,11 @@ void mremap_userfaultfd_prep(struct vm_area_struct *vma,
 	}
 }
 
-void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx vm_ctx,
+void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *vm_ctx,
 				 unsigned long from, unsigned long to,
 				 unsigned long len)
 {
-	struct userfaultfd_ctx *ctx = vm_ctx.ctx;
+	struct userfaultfd_ctx *ctx = vm_ctx->ctx;
 	struct userfaultfd_wait_queue ewq;
 
 	if (!ctx)
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 7f318a4..78ec197 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -57,7 +57,7 @@ extern void dup_userfaultfd_complete(struct list_head *);
 
 extern void mremap_userfaultfd_prep(struct vm_area_struct *,
 				    struct vm_userfaultfd_ctx *);
-extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx,
+extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *,
 					unsigned long from, unsigned long to,
 					unsigned long len);
 
@@ -100,7 +100,7 @@ static inline void mremap_userfaultfd_prep(struct vm_area_struct *vma,
 {
 }
 
-static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx ctx,
+static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *ctx,
 					       unsigned long from,
 					       unsigned long to,
 					       unsigned long len)
diff --git a/mm/mremap.c b/mm/mremap.c
index 504b560..8779928 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -608,6 +608,6 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
-	mremap_userfaultfd_complete(uf, addr, new_addr, old_len);
+	mremap_userfaultfd_complete(&uf, addr, new_addr, old_len);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

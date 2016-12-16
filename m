Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 632746B026B
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:28 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id b194so92402470ioa.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z4si2927778itf.114.2016.12.16.06.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:27 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 15/42] userfaultfd: non-cooperative: wake userfaults after UFFDIO_UNREGISTER
Date: Fri, 16 Dec 2016 15:47:54 +0100
Message-Id: <20161216144821.5183-16-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Userfaults may still happen after the userfaultfd monitor thread
received a UFFD_EVENT_MADVDONTNEED until UFFDIO_UNREGISTER is run.

Wake any pending userfault within UFFDIO_UNREGISTER protected by the
mmap_sem for writing, so they will not be reported to userland leading
to UFFDIO_COPY returning -EINVAL (as the range was already
unregistered) and they will not hang permanently either.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ca039a7..22f978d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1269,6 +1269,19 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 			start = vma->vm_start;
 		vma_end = min(end, vma->vm_end);
 
+		if (userfaultfd_missing(vma)) {
+			/*
+			 * Wake any concurrent pending userfault while
+			 * we unregister, so they will not hang
+			 * permanently and it avoids userland to call
+			 * UFFDIO_WAKE explicitly.
+			 */
+			struct userfaultfd_wake_range range;
+			range.start = start;
+			range.len = vma_end - start;
+			wake_userfault(vma->vm_userfaultfd_ctx.ctx, &range);
+		}
+
 		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
 		prev = vma_merge(mm, prev, start, vma_end, new_flags,
 				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

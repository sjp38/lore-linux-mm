Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 661126B7C54
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:20:33 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q33so1680555qte.23
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:20:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j93si950125qtb.131.2018.12.06.13.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:20:32 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: check VM_MAYWRITE was set after verifying the uffd is registered
Date: Thu,  6 Dec 2018 16:20:28 -0500
Message-Id: <20181206212028.18726-2-aarcange@redhat.com>
In-Reply-To: <20181206212028.18726-1-aarcange@redhat.com>
References: <20181206212028.18726-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Calling UFFDIO_UNREGISTER on virtual ranges not yet registered in uffd
could trigger an harmless false positive WARN_ON. Check the vma is
already registered before checking VM_MAYWRITE to shut off the
false positive warning.

Cc: <stable@vger.kernel.org>
Fixes: 29ec90660d68 ("userfaultfd: shmem/hugetlbfs: only allow to register VM_MAYWRITE vmas")
Reported-by: syzbot+06c7092e7d71218a2c16@syzkaller.appspotmail.com
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cd58939dc977..7a85e609fc27 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1566,7 +1566,6 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		cond_resched();
 
 		BUG_ON(!vma_can_userfault(vma));
-		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
@@ -1575,6 +1574,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		if (!vma->vm_userfaultfd_ctx.ctx)
 			goto skip;
 
+		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
+
 		if (vma->vm_start > start)
 			start = vma->vm_start;
 		vma_end = min(end, vma->vm_end);

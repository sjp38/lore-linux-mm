Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA386B02BB
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o68so24650623qkf.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v54si1940196qtv.30.2016.11.02.12.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 29/33] userfaultfd: shmem: avoid leaking blocks and used blocks in UFFDIO_COPY
Date: Wed,  2 Nov 2016 20:34:01 +0100
Message-Id: <1478115245-32090-30-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

If the atomic copy_user fails because of a real dangling userland
pointer, we won't go back into the shmem method, so when the method
returns it must not leave anything charged up, except the page itself.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 5d39f88..578622e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2183,17 +2183,17 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	pte_t _dst_pte, *dst_pte;
 	int ret;
 
-	if (!*pagep) {
-		ret = -ENOMEM;
-		if (shmem_acct_block(info->flags, 1))
-			goto out;
-		if (sbinfo->max_blocks) {
-			if (percpu_counter_compare(&sbinfo->used_blocks,
-						   sbinfo->max_blocks) >= 0)
-				goto out_unacct_blocks;
-			percpu_counter_inc(&sbinfo->used_blocks);
-		}
+	ret = -ENOMEM;
+	if (shmem_acct_block(info->flags, 1))
+		goto out;
+	if (sbinfo->max_blocks) {
+		if (percpu_counter_compare(&sbinfo->used_blocks,
+					   sbinfo->max_blocks) >= 0)
+			goto out_unacct_blocks;
+		percpu_counter_inc(&sbinfo->used_blocks);
+	}
 
+	if (!*pagep) {
 		page = shmem_alloc_page(gfp, info, pgoff);
 		if (!page)
 			goto out_dec_used_blocks;
@@ -2206,6 +2206,9 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 		/* fallback to copy_from_user outside mmap_sem */
 		if (unlikely(ret)) {
 			*pagep = page;
+			if (sbinfo->max_blocks)
+				percpu_counter_add(&sbinfo->used_blocks, -1);
+			shmem_unacct_blocks(info->flags, 1);
 			/* don't free the page */
 			return -EFAULT;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

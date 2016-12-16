Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33D906B027A
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:30 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 81so92925001iog.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x5si2930874itd.75.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:29 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 36/42] userfaultfd: shmem: avoid leaking blocks and used blocks in UFFDIO_COPY
Date: Fri, 16 Dec 2016 15:48:15 +0100
Message-Id: <20161216144821.5183-37-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

If the atomic copy_user fails because of a real dangling userland
pointer, we won't go back into the shmem method, so when the method
returns it must not leave anything charged up, except the page itself.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index f0f1431..9f3941b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2210,17 +2210,17 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
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
@@ -2233,6 +2233,9 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
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

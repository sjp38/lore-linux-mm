Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5C46B02BC
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i34so24642883qkh.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d29si1941110qtb.31.2016.11.02.12.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 28/33] userfaultfd: shmem: lock the page before adding it to pagecache
Date: Wed,  2 Nov 2016 20:34:00 +0100
Message-Id: <1478115245-32090-29-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

A VM_BUG_ON triggered on the shmem selftest.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index fe469e5..5d39f88 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2214,6 +2214,10 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 		*pagep = NULL;
 	}
 
+	VM_BUG_ON(PageLocked(page) || PageSwapBacked(page));
+	__SetPageLocked(page);
+	__SetPageSwapBacked(page);
+
 	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg, false);
 	if (ret)
 		goto out_release;
@@ -2263,6 +2267,7 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 out_release_uncharge:
 	mem_cgroup_cancel_charge(page, memcg, false);
 out_release:
+	unlock_page(page);
 	put_page(page);
 out_dec_used_blocks:
 	if (sbinfo->max_blocks)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

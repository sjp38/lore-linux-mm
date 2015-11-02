Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C80886B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 12:01:34 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so29715918pab.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:01:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id uh5si36198533pab.115.2015.11.02.09.01.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 09:01:34 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/5] ksm: use find_mergeable_vma in try_to_merge_with_ksm_page
Date: Mon,  2 Nov 2015 18:01:30 +0100
Message-Id: <1446483691-8494-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
References: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Doing the VM_MERGEABLE check after the page == kpage check won't
provide any meaningful benefit. The !vma->anon_vma check of
find_mergeable_vma is the only superfluous bit in using
find_mergeable_vma because the !PageAnon check of
try_to_merge_one_page() implicitly checks for that, but it still looks
cleaner to share the same find_mergeable_vma().

Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index d4ee159..0183083 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1021,8 +1021,6 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 	if (page == kpage)			/* ksm page forked */
 		return 0;
 
-	if (!(vma->vm_flags & VM_MERGEABLE))
-		goto out;
 	if (PageTransCompound(page) && page_trans_compound_anon_split(page))
 		goto out;
 	BUG_ON(PageTransCompound(page));
@@ -1087,10 +1085,8 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	int err = -EFAULT;
 
 	down_read(&mm->mmap_sem);
-	if (ksm_test_exit(mm))
-		goto out;
-	vma = find_vma(mm, rmap_item->address);
-	if (!vma || vma->vm_start > rmap_item->address)
+	vma = find_mergeable_vma(mm, rmap_item->address);
+	if (!vma)
 		goto out;
 
 	err = try_to_merge_one_page(vma, page, kpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

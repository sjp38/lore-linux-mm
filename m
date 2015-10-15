Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0999A82F66
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 12:04:38 -0400 (EDT)
Received: by padcn9 with SMTP id cn9so10062290pad.3
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:04:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lu5si22511404pab.178.2015.10.15.09.04.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 09:04:30 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/6] ksm: use find_mergeable_vma in try_to_merge_with_ksm_page
Date: Thu, 15 Oct 2015 18:04:24 +0200
Message-Id: <1444925065-4841-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Doing the VM_MERGEABLE check after the page == kpage check won't
provide any meaningful benefit. The !vma->anon_vma check of
find_mergeable_vma is the only superfluous bit in using
find_mergeable_vma because the !PageAnon check of
try_to_merge_one_page() implicitly checks for that, but it still looks
cleaner to share the same find_mergeable_vma().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 241588e..10618a3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1057,8 +1057,6 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 	if (page == kpage)			/* ksm page forked */
 		return 0;
 
-	if (!(vma->vm_flags & VM_MERGEABLE))
-		goto out;
 	if (PageTransCompound(page) && page_trans_compound_anon_split(page))
 		goto out;
 	BUG_ON(PageTransCompound(page));
@@ -1135,8 +1133,8 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 		return err;
 
 	down_read(&mm->mmap_sem);
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

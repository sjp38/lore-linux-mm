Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCE06B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 15:39:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q67-v6so11895370wrb.12
        for <linux-mm@kvack.org>; Mon, 21 May 2018 12:39:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c10-v6si1013230edq.130.2018.05.21.12.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 12:39:12 -0700 (PDT)
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4LJbOaR001491
	for <linux-mm@kvack.org>; Mon, 21 May 2018 12:39:10 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2j434w081q-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 May 2018 12:39:10 -0700
From: Song Liu <songliubraving@fb.com>
Subject: [PATCH] mm/THP: use hugepage_vma_check() in khugepaged_enter_vma_merge()
Date: Mon, 21 May 2018 12:38:53 -0700
Message-ID: <20180521193853.3089484-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Song Liu <songliubraving@fb.com>, linux-kernel@vger.kernel.org

khugepaged_enter_vma_merge() is using a different approach to check
whether a vma is valid for khugepaged_enter():

    if (!vma->anon_vma)
            /*
             * Not yet faulted in so we will register later in the
             * page fault if needed.
             */
            return 0;
    if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
            /* khugepaged not yet working on file or special mappings */
            return 0;

This check has some problems. One of the obvious problems is that
it doesn't check shmem_file(), so that vma backed with shmem files
will not call khugepaged_enter().

This patch fixes these problems by reusing hugepage_vma_check() in
khugepaged_enter_vma_merge().

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/khugepaged.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4b..e50c2bd 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -430,18 +430,14 @@ int __khugepaged_enter(struct mm_struct *mm)
 	return 0;
 }
 
+static bool hugepage_vma_check(struct vm_area_struct *vma);
+
 int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 			       unsigned long vm_flags)
 {
 	unsigned long hstart, hend;
-	if (!vma->anon_vma)
-		/*
-		 * Not yet faulted in so we will register later in the
-		 * page fault if needed.
-		 */
-		return 0;
-	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
-		/* khugepaged not yet working on file or special mappings */
+
+	if (!hugepage_vma_check(vma))
 		return 0;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
-- 
2.9.5

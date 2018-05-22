Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 894E06B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 15:44:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 3-v6so15411752wry.0
        for <linux-mm@kvack.org>; Tue, 22 May 2018 12:44:37 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t55-v6si447727edb.420.2018.05.22.12.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 12:44:35 -0700 (PDT)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4MJeMCS013681
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:44:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2j4r8788tr-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:44:33 -0700
From: Song Liu <songliubraving@fb.com>
Subject: [PATCH v2] mm/THP: use hugepage_vma_check() in khugepaged_enter_vma_merge()
Date: Tue, 22 May 2018 12:44:30 -0700
Message-ID: <20180522194430.426688-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Song Liu <songliubraving@fb.com>, linux-kernel@vger.kernel.org, mhocko@kernel.org, rientjes@google.com, aarcange@redhat.com, kirill@shutemov.name

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
will not call khugepaged_enter(). Here is an example of failed madvise():

   /* mount /dev/shm with huge=advise:
    *     mount -o remount,huge=advise /dev/shm */
   /* create file /dev/shm/huge */
   #define HUGE_FILE "/dev/shm/huge"

   fd = open(HUGE_FILE, O_RDONLY);
   ptr = mmap(NULL, FILE_SIZE, PROT_READ, MAP_PRIVATE, fd, 0);
   ret = madvise(ptr, FILE_SIZE, MADV_HUGEPAGE);

madvise() will return 0, but this memory region is never put in huge
page (check from /proc/meminfo: ShmemHugePages).

This patch fixes these problems by reusing hugepage_vma_check() in
khugepaged_enter_vma_merge().

vma->vm_flags is not yet updated in khugepaged_enter_vma_merge(),
so we need to pass the new vm_flags to hugepage_vma_check() through
a separate argument.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/khugepaged.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4b..9f74e51 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -430,18 +430,15 @@ int __khugepaged_enter(struct mm_struct *mm)
 	return 0;
 }
 
+static bool hugepage_vma_check(struct vm_area_struct *vma,
+			       unsigned long vm_flags);
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
+	if (!hugepage_vma_check(vma, vm_flags))
 		return 0;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
@@ -819,10 +816,11 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 }
 #endif
 
-static bool hugepage_vma_check(struct vm_area_struct *vma)
+static bool hugepage_vma_check(struct vm_area_struct *vma,
+			       unsigned long vm_flags)
 {
-	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
-	    (vma->vm_flags & VM_NOHUGEPAGE) ||
+	if ((!(vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
+	    (vm_flags & VM_NOHUGEPAGE) ||
 	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
 		return false;
 	if (shmem_file(vma->vm_file)) {
@@ -835,7 +833,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	return !(vma->vm_flags & VM_NO_KHUGEPAGED);
+	return !(vm_flags & VM_NO_KHUGEPAGED);
 }
 
 /*
@@ -862,7 +860,7 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address,
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
 		return SCAN_ADDRESS_RANGE;
-	if (!hugepage_vma_check(vma))
+	if (!hugepage_vma_check(vma, vma->vm_flags))
 		return SCAN_VMA_CHECK;
 	return 0;
 }
@@ -1694,7 +1692,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			progress++;
 			break;
 		}
-		if (!hugepage_vma_check(vma)) {
+		if (!hugepage_vma_check(vma, vma->vm_flags)) {
 skip:
 			progress++;
 			continue;
-- 
2.9.5

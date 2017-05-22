Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF757831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 02:12:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d127so23320741wmf.15
        for <linux-mm@kvack.org>; Sun, 21 May 2017 23:12:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u10si5222829wma.89.2017.05.21.23.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 23:12:52 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4M68gNE091807
	for <linux-mm@kvack.org>; Mon, 22 May 2017 02:12:50 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2akabnksft-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 May 2017 02:12:50 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 22 May 2017 07:12:49 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Date: Mon, 22 May 2017 09:12:42 +0300
Message-Id: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Currently applications can explicitly enable or disable THP for a memory
region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
these advises is used, the region will always have
VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
the region according to system-wide settings.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/uapi/asm-generic/mman-common.h | 3 +++
 mm/khugepaged.c                        | 7 +++++++
 mm/madvise.c                           | 5 +++++
 3 files changed, 15 insertions(+)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 8c27db0..3201712 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -58,6 +58,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_DONTDUMP flag */
 
+#define MADV_CLR_HUGEPAGE 18		/* Clear flags controlling backing with
+					   hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 945fd1c..b9ee9bb 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -336,6 +336,13 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		 * it got registered before VM_NOHUGEPAGE was set.
 		 */
 		break;
+	case MADV_CLR_HUGEPAGE:
+		*vm_flags &= ~(VM_HUGEPAGE | VM_NOHUGEPAGE);
+		/*
+		 * The vma will be treated according to the
+		 * system-wide settings in transparent_hugepage_flags
+		 */
+		break;
 	}
 
 	return 0;
diff --git a/mm/madvise.c b/mm/madvise.c
index 25b78ee..ae650a3 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -105,6 +105,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 		break;
 	case MADV_HUGEPAGE:
 	case MADV_NOHUGEPAGE:
+	case MADV_CLR_HUGEPAGE:
 		error = hugepage_madvise(vma, &new_flags, behavior);
 		if (error) {
 			/*
@@ -684,6 +685,7 @@ madvise_behavior_valid(int behavior)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	case MADV_HUGEPAGE:
 	case MADV_NOHUGEPAGE:
+	case MADV_CLR_HUGEPAGE:
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
@@ -739,6 +741,9 @@ madvise_behavior_valid(int behavior)
  *  MADV_NOHUGEPAGE - mark the given range as not worth being backed by
  *		transparent huge pages so the existing pages will not be
  *		coalesced into THP and new pages will not be allocated as THP.
+ *  MADV_CLR_HUGEPAGE - clear MADV_HUGEPAGE/MADV_NOHUGEPAGE marking;
+ *		the range will be treated by khugepaged according to the
+ *		system wide settings
  *  MADV_DONTDUMP - the application wants to prevent pages in the given range
  *		from being included in its core dump.
  *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 041306B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 17:47:59 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so410417wib.7
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 14:47:59 -0700 (PDT)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id p10si14837081wic.44.2014.07.10.14.47.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 14:47:58 -0700 (PDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so178045wgh.35
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 14:47:57 -0700 (PDT)
From: Oded Gabbay <oded.gabbay@gmail.com>
Subject: [PATCH 01/83] mm: Add kfd_process pointer to mm_struct
Date: Fri, 11 Jul 2014 00:47:26 +0300
Message-Id: <1405028848-5660-1-git-send-email-oded.gabbay@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Airlie <airlied@linux.ie>, Alex Deucher <alexander.deucher@amd.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, John Bridgman <John.Bridgman@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Joerg Roedel <joro@8bytes.org>, linux-mm <linux-mm@kvack.org>, Oded Gabbay <oded.gabbay@amd.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michel Lespinasse <walken@google.com>

This patch enables the KFD to retrieve the kfd_process
object from the process's mm_struct. This is needed because kfd_process
lifespan is bound to the process's mm_struct lifespan.

When KFD is notified about an mm_struct tear-down, it checks if the
kfd_process pointer is valid. If so, it releases the kfd_process object
and all relevant resources.

Signed-off-by: Oded Gabbay <oded.gabbay@amd.com>
---
 include/linux/mm_types.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 678097c..6179107 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -20,6 +20,10 @@
 struct hmm;
 #endif
 
+#ifdef CONFIG_HSA_RADEON
+struct kfd_process;
+#endif
+
 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
 #endif
@@ -439,6 +443,16 @@ struct mm_struct {
 	 */
 	struct hmm *hmm;
 #endif
+#if defined(CONFIG_HSA_RADEON) || defined(CONFIG_HSA_RADEON_MODULE)
+	/*
+	 * kfd always register an mmu_notifier we rely on mmu notifier to keep
+	 * refcount on mm struct as well as forbiding registering kfd on a
+	 * dying mm
+	 *
+	 * This field is set with mmap_sem old in write mode.
+	 */
+	struct kfd_process *kfd_process;
+#endif
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

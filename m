Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 523096B003B
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 09:58:17 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id e89so1978945qgf.17
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 06:58:17 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0188.outbound.protection.outlook.com. [207.46.163.188])
        by mx.google.com with ESMTPS id 109si2542274qgu.105.2014.07.17.06.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Jul 2014 06:58:16 -0700 (PDT)
Message-ID: <53C7D666.6000405@amd.com>
Date: Thu, 17 Jul 2014 16:57:58 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: [PATCH v2 01/25] mm: Add kfd_process pointer to mm_struct
References: <1405603773-32688-1-git-send-email-oded.gabbay@amd.com>
In-Reply-To: <1405603773-32688-1-git-send-email-oded.gabbay@amd.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Airlie <airlied@linux.ie>, Jerome Glisse <j.glisse@gmail.com>, Alex
 Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <deathsimple@vodafone.de>, =?UTF-8?B?TWljaGVsIETDpG56ZXI=?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, Oded
 Gabbay <oded.gabbay@amd.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter
 Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Forgot to add mm mailing list. Sorry.

This patch enables the amdkfd driver to retrieve the kfd_process
object from the process's mm_struct. This is needed because kfd_process
lifespan is bound to the process's mm_struct lifespan.

When amdkfd is notified about an mm_struct tear-down, it checks if the
kfd_process pointer is valid. If so, it releases the kfd_process object
and all relevant resources.

In v3 of the patchset I will update the binding to match the final discussions
on [PATCH 1/8] mmput: use notifier chain to call subsystem exit handler.
In the meantime, I'm going to try and see if I can drop the kfd_process
in mm_struct and remove the use of the new notification chain in mmput.
Instead, I will try to use the mmu release notifier.

Signed-off-by: Oded Gabbay <oded.gabbay@amd.com>
---
  include/linux/mm_types.h | 14 ++++++++++++++
  1 file changed, 14 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 678097c..ff71496 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -20,6 +20,10 @@
  struct hmm;
  #endif
  +#if defined(CONFIG_HSA_RADEON) || defined(CONFIG_HSA_RADEON_MODULE)
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

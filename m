Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD916B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 04:52:51 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so1158079pab.15
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 01:52:51 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id zy5si1647797pbc.35.2014.07.30.01.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 01:52:50 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH] mm: BUG when __kmap_atomic_idx crosses boundary
Date: Wed, 30 Jul 2014 14:22:35 +0530
Message-Id: <1406710355-4360-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chintan Pandya <cpandya@codeaurora.org>

__kmap_atomic_idx >= KM_TYPE_NR or < ZERO is a bug.
Report it even if CONFIG_DEBUG_HIGHMEM is not enabled.
That saves much debugging efforts.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
 include/linux/highmem.h | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 7fb31da..f42cafd 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -93,8 +93,8 @@ static inline int kmap_atomic_idx_push(void)
 
 #ifdef CONFIG_DEBUG_HIGHMEM
 	WARN_ON_ONCE(in_irq() && !irqs_disabled());
-	BUG_ON(idx > KM_TYPE_NR);
 #endif
+	BUG_ON(idx >= KM_TYPE_NR);
 	return idx;
 }
 
@@ -105,13 +105,9 @@ static inline int kmap_atomic_idx(void)
 
 static inline void kmap_atomic_idx_pop(void)
 {
-#ifdef CONFIG_DEBUG_HIGHMEM
 	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
 
 	BUG_ON(idx < 0);
-#else
-	__this_cpu_dec(__kmap_atomic_idx);
-#endif
 }
 
 #endif
-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

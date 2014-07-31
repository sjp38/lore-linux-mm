Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 261216B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 02:24:45 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so2856470pdb.19
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 23:24:44 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id aj7si4779744pad.74.2014.07.30.23.24.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 23:24:43 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH v2] mm: BUG when __kmap_atomic_idx equals KM_TYPE_NR
Date: Thu, 31 Jul 2014 11:54:31 +0530
Message-Id: <1406787871-2951-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chintan Pandya <cpandya@codeaurora.org>

__kmap_atomic_idx is per_cpu variable. Each CPU can
use KM_TYPE_NR entries from FIXMAP i.e. from 0 to
KM_TYPE_NR - 1. Allowing __kmap_atomic_idx to over-
shoot to KM_TYPE_NR can mess up with next CPU's 0th
entry which is a bug. Hence BUG_ON if
__kmap_atomic_idx >= KM_TYPE_NR.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
Changes:

V1 --> V2

	Not touching CONFIG_DEBUG_HIGHMEM.

 include/linux/highmem.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 7fb31da..9286a46 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -93,7 +93,7 @@ static inline int kmap_atomic_idx_push(void)
 
 #ifdef CONFIG_DEBUG_HIGHMEM
 	WARN_ON_ONCE(in_irq() && !irqs_disabled());
-	BUG_ON(idx > KM_TYPE_NR);
+	BUG_ON(idx >= KM_TYPE_NR);
 #endif
 	return idx;
 }
-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0DA6B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 07:02:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v8so8186870wmv.1
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 04:02:45 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id k32si3750663wrf.11.2018.04.04.04.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 04:02:44 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm/hmm: fix header file if/else/endif maze, again
Date: Wed,  4 Apr 2018 13:02:15 +0200
Message-Id: <20180404110236.804484-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The last fix was still wrong, as we need the inline dummy functions
also for the case that CONFIG_HMM is enabled but CONFIG_HMM_MIRROR
is not:

kernel/fork.o: In function `__mmdrop':
fork.c:(.text+0x14f6): undefined reference to `hmm_mm_destroy'

This adds back the second copy of the dummy functions, hopefully
this time in the right place.

Fixes: 8900d06a277a ("mm/hmm: fix header file if/else/endif maze")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/hmm.h | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 5d26e0a223d9..39988924de3a 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -376,8 +376,18 @@ bool hmm_vma_range_done(struct hmm_range *range);
  * See the function description in mm/hmm.c for further documentation.
  */
 int hmm_vma_fault(struct hmm_range *range, bool block);
-#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
+/* Below are for HMM internal use only! Not to be used by device driver! */
+void hmm_mm_destroy(struct mm_struct *mm);
+
+static inline void hmm_mm_init(struct mm_struct *mm)
+{
+	mm->hmm = NULL;
+}
+#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
+static inline void hmm_mm_destroy(struct mm_struct *mm) {}
+static inline void hmm_mm_init(struct mm_struct *mm) {}
+#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
 struct hmm_devmem;
@@ -550,16 +560,9 @@ struct hmm_device {
 struct hmm_device *hmm_device_new(void *drvdata);
 void hmm_device_put(struct hmm_device *hmm_device);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-
-/* Below are for HMM internal use only! Not to be used by device driver! */
-void hmm_mm_destroy(struct mm_struct *mm);
-
-static inline void hmm_mm_init(struct mm_struct *mm)
-{
-	mm->hmm = NULL;
-}
 #else /* IS_ENABLED(CONFIG_HMM) */
 static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM) */
+
 #endif /* LINUX_HMM_H */
-- 
2.9.0

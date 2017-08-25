Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFBE6810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:31:38 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u11so5876031qtu.7
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:31:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i10si6965789qtg.11.2017.08.25.14.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 14:31:37 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/hmm: struct hmm is only use by HMM mirror functionality v2
Date: Fri, 25 Aug 2017 17:31:33 -0400
Message-Id: <20170825213133.27286-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Subhash Gutti <sgutti@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The struct hmm is only use if the HMM mirror functionality is enabled
move associated code behind CONFIG_HMM_MIRROR to avoid build error if
one enable some of the HMM memory configuration without the mirror
feature.

Changed since v1:
  - make it clear that it replace Arnd patch
  - make sure it apply on top of lastest mm

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reported-by: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
Cc: Subhash Gutti <sgutti@nvidia.com>,
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
---
 include/linux/hmm.h | 8 ++++----
 mm/hmm.c            | 7 +++----
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 5866f3194c26..9583d9a15f9c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -501,18 +501,18 @@ void hmm_device_put(struct hmm_device *hmm_device);
 
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
+#if IS_ENABLED(CONFIG_HMM_MIRROR)
 void hmm_mm_destroy(struct mm_struct *mm);
 
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
-
-#else /* IS_ENABLED(CONFIG_HMM) */
-
-/* Below are for HMM internal use only! Not to be used by device driver! */
+#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
+#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
+
 
 #endif /* IS_ENABLED(CONFIG_HMM) */
 #endif /* LINUX_HMM_H */
diff --git a/mm/hmm.c b/mm/hmm.c
index 4a179a16ab10..cf9cf0db809e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -41,11 +41,12 @@
  */
 DEFINE_STATIC_KEY_FALSE(device_private_key);
 EXPORT_SYMBOL(device_private_key);
-static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
 
-#ifdef CONFIG_HMM
+#if IS_ENABLED(CONFIG_HMM_MIRROR)
+static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
+
 /*
  * struct hmm - HMM per mm struct
  *
@@ -128,9 +129,7 @@ void hmm_mm_destroy(struct mm_struct *mm)
 {
 	kfree(mm->hmm);
 }
-#endif /* CONFIG_HMM */
 
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 static void hmm_invalidate_range(struct hmm *hmm,
 				 enum hmm_update_type action,
 				 unsigned long start,
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

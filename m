Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDC2044088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:42:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w78so5212444qkw.7
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:42:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f126si4860368qkd.367.2017.08.24.17.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 17:42:38 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/hmm: struct hmm is only use by HMM mirror functionality
Date: Thu, 24 Aug 2017 20:42:26 -0400
Message-Id: <1503621746-17876-1-git-send-email-jglisse@redhat.com>
In-Reply-To: <20170824230850.1810408-1-arnd@arndb.de>
References: <20170824230850.1810408-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Subhash Gutti <sgutti@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The struct hmm is only use if the HMM mirror functionality is enabled
move associated code behind CONFIG_HMM_MIRROR to avoid build error if
one enable some of the HMM memory configuration without the mirror
feature.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
Cc: Subhash Gutti <sgutti@nvidia.com>,
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
---
 include/linux/hmm.h | 7 +++----
 mm/hmm.c            | 4 +---
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 5866f31..b4355d7 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -499,7 +499,7 @@ struct hmm_device *hmm_device_new(void *drvdata);
 void hmm_device_put(struct hmm_device *hmm_device);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
-
+#if IS_ENABLED(CONFIG_HMM_MIRROR)
 /* Below are for HMM internal use only! Not to be used by device driver! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
@@ -507,12 +507,11 @@ static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
-
-#else /* IS_ENABLED(CONFIG_HMM) */
-
+#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 /* Below are for HMM internal use only! Not to be used by device driver! */
 static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
+#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 #endif /* IS_ENABLED(CONFIG_HMM) */
 #endif /* LINUX_HMM_H */
diff --git a/mm/hmm.c b/mm/hmm.c
index 3faa4d4..7e4f42b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -43,7 +43,7 @@ DEFINE_STATIC_KEY_FALSE(device_private_key);
 EXPORT_SYMBOL(device_private_key);
 
 
-#ifdef CONFIG_HMM
+#if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
 /*
@@ -128,9 +128,7 @@ void hmm_mm_destroy(struct mm_struct *mm)
 {
 	kfree(mm->hmm);
 }
-#endif /* CONFIG_HMM */
 
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 static void hmm_invalidate_range(struct hmm *hmm,
 				 enum hmm_update_type action,
 				 unsigned long start,
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 144536B04ED
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 19:08:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a47so1091763wra.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:08:57 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id v63si110468wma.118.2017.08.24.16.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 16:08:55 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: HMM always needs MMU_NOTIFIER
Date: Fri, 25 Aug 2017 01:08:23 +0200
Message-Id: <20170824230850.1810408-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Subhash Gutti <sgutti@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When building a kernel with HMM enabled but without MMU_NOTIFIER,
we run into a build error:

mm/hmm.c:66:22: error: field 'mmu_notifier' has incomplete type
  struct mmu_notifier mmu_notifier;

If I read this right, the dependency is correct, but the #ifdef
annotations in the mm/hmm.c are not. This changes them in
a way to make it all build cleanly.

Fixes: e4e0061ea15c ("mm/device-public-memory: device memory cache coherent with CPU")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I did not try very hard to understand what the code is
supposed to do, please check if this makes sense beyond fixing
the build before applying.
---
 mm/hmm.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 4a179a16ab10..b9e9f14e7454 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -41,11 +41,16 @@
  */
 DEFINE_STATIC_KEY_FALSE(device_private_key);
 EXPORT_SYMBOL(device_private_key);
-static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
+void hmm_mm_destroy(struct mm_struct *mm)
+{
+	kfree(mm->hmm);
+}
+
+#if IS_ENABLED(CONFIG_HMM_MIRROR)
+static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-#ifdef CONFIG_HMM
 /*
  * struct hmm - HMM per mm struct
  *
@@ -124,13 +129,6 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	return mm->hmm;
 }
 
-void hmm_mm_destroy(struct mm_struct *mm)
-{
-	kfree(mm->hmm);
-}
-#endif /* CONFIG_HMM */
-
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 static void hmm_invalidate_range(struct hmm *hmm,
 				 enum hmm_update_type action,
 				 unsigned long start,
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

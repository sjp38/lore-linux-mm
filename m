Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 36A4F6B0027
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:55:51 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r5so6581406qkb.22
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:55:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h21si4154248qte.275.2018.03.22.17.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 17:55:50 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 02/15] mm/hmm: fix header file if/else/endif maze v2
Date: Thu, 22 Mar 2018 20:55:14 -0400
Message-Id: <20180323005527.758-3-jglisse@redhat.com>
In-Reply-To: <20180323005527.758-1-jglisse@redhat.com>
References: <20180323005527.758-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, stable@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The #if/#else/#endif for IS_ENABLED(CONFIG_HMM) were wrong. Because
of this after multiple include there was multiple definition of both
hmm_mm_init() and hmm_mm_destroy() leading to build failure if HMM
was enabled (CONFIG_HMM set).

Changed since v1:
  - Fix the maze when CONFIG_HMM is disabled not just when it is
    disabled. This fix bot build failure.
  - Improved commit message.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Cc: stable@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
---
 include/linux/hmm.h | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 325017ad9311..36dd21fe5caf 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -498,23 +498,16 @@ struct hmm_device {
 struct hmm_device *hmm_device_new(void *drvdata);
 void hmm_device_put(struct hmm_device *hmm_device);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-#endif /* IS_ENABLED(CONFIG_HMM) */
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 void hmm_mm_destroy(struct mm_struct *mm);
 
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
-#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
-static inline void hmm_mm_init(struct mm_struct *mm) {}
-#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-
-
 #else /* IS_ENABLED(CONFIG_HMM) */
 static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
+#endif /* IS_ENABLED(CONFIG_HMM) */
 #endif /* LINUX_HMM_H */
-- 
2.14.3

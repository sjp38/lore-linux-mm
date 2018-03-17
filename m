Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE1336B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 21:20:43 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z1so7831030qtz.12
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:20:43 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e54si3576458qtf.248.2018.03.16.18.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 18:20:42 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 02/14] mm/hmm: fix header file if/else/endif maze v2
Date: Fri, 16 Mar 2018 21:20:39 -0400
Message-Id: <20180317012039.3145-1-jglisse@redhat.com>
In-Reply-To: <20180316191414.3223-3-jglisse@redhat.com>
References: <20180316191414.3223-3-jglisse@redhat.com>
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
    enabled. This fix bot build failure.
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

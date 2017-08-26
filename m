Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A94F96810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 20:21:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x36so7658093qtx.9
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:21:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p187si7202299qkf.216.2017.08.25.17.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 17:21:53 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/hmm: fix build when HMM is disabled
Date: Fri, 25 Aug 2017 20:21:49 -0400
Message-Id: <20170826002149.20919-1-jglisse@redhat.com>
In-Reply-To: <3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org>
References: <3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Combinatorial Kconfig is painfull. Withi this patch all below combination
build.

1)

2)
CONFIG_HMM_MIRROR=y

3)
CONFIG_DEVICE_PRIVATE=y

4)
CONFIG_DEVICE_PUBLIC=y

5)
CONFIG_HMM_MIRROR=y
CONFIG_DEVICE_PUBLIC=y

6)
CONFIG_HMM_MIRROR=y
CONFIG_DEVICE_PRIVATE=y

7)
CONFIG_DEVICE_PRIVATE=y
CONFIG_DEVICE_PUBLIC=y

8)
CONFIG_HMM_MIRROR=y
CONFIG_DEVICE_PRIVATE=y
CONFIG_DEVICE_PUBLIC=y

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reported-by: Randy Dunlap <rdunlap@infradead.org>
---
 include/linux/hmm.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 9583d9a15f9c..96d6b1232c07 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -498,7 +498,7 @@ struct hmm_device {
 struct hmm_device *hmm_device_new(void *drvdata);
 void hmm_device_put(struct hmm_device *hmm_device);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-
+#endif /* IS_ENABLED(CONFIG_HMM) */
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
@@ -513,6 +513,4 @@ static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
-
-#endif /* IS_ENABLED(CONFIG_HMM) */
 #endif /* LINUX_HMM_H */
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

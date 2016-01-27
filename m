Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 057AD6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:09:50 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id 123so144489087wmz.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:09:49 -0800 (PST)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id u3si7491990wju.201.2016.01.27.02.09.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 02:09:43 -0800 (PST)
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 27 Jan 2016 10:09:42 -0000
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH v3 1/3] mm: provide debug_pagealloc_enabled() without CONFIG_DEBUG_PAGEALLOC
Date: Wed, 27 Jan 2016 11:09:59 +0100
Message-Id: <1453889401-43496-2-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk, Christian Borntraeger <borntraeger@de.ibm.com>

We can provide debug_pagealloc_enabled() also if CONFIG_DEBUG_PAGEALLOC
is not set. It will return false in that case.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/mm.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f1cd22f..ae84716 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2194,13 +2194,18 @@ kernel_map_pages(struct page *page, int numpages, int enable)
 #ifdef CONFIG_HIBERNATION
 extern bool kernel_page_present(struct page *page);
 #endif /* CONFIG_HIBERNATION */
-#else
+#else  /* CONFIG_DEBUG_PAGEALLOC */
+static inline bool debug_pagealloc_enabled(void)
+{
+	return false;
+}
+
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable) {}
 #ifdef CONFIG_HIBERNATION
 static inline bool kernel_page_present(struct page *page) { return true; }
 #endif /* CONFIG_HIBERNATION */
-#endif
+#endif /* CONFIG_DEBUG_PAGEALLOC */
 
 #ifdef __HAVE_ARCH_GATE_AREA
 extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

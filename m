Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 034076B0259
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 03:39:50 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id r129so153589691wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 00:39:49 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id d95si5097689wma.48.2016.02.03.00.39.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 00:39:45 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 3 Feb 2016 08:39:44 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 650122190019
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:39:29 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u138dgcC4653478
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 08:39:42 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u138dels027095
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 01:39:42 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH v4 1/4] mm: provide debug_pagealloc_enabled() without CONFIG_DEBUG_PAGEALLOC
Date: Wed,  3 Feb 2016 09:39:32 +0100
Message-Id: <1454488775-108777-7-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com>
References: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>

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

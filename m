Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 173936B0261
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:49:31 -0500 (EST)
Received: by pfdd184 with SMTP id d184so33350517pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:30 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id f7si13946512pas.159.2015.12.09.09.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:49:24 -0800 (PST)
Received: by pfdd184 with SMTP id d184so33349346pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:24 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v4 6/7] sh: mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 09:29:23 -0800
Message-Id: <1449682164-9933-7-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
References: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, linux-sh@vger.kernel.org

Cc: linux-sh@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/sh/mm/gup.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/sh/mm/gup.c b/arch/sh/mm/gup.c
index e7af6a6..fa72aac 100644
--- a/arch/sh/mm/gup.c
+++ b/arch/sh/mm/gup.c
@@ -14,6 +14,9 @@
 #include <linux/highmem.h>
 #include <asm/pgtable.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #ifndef CONFIG_X2TLB
@@ -178,6 +181,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	/*
 	 * This doesn't prevent pagetable teardown, but does prevent
 	 * the pagetables and pages from being freed.
@@ -244,6 +249,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
 	return nr;
 
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D4AC76B0259
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:26:11 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so20544384pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:11 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ef10si219145pac.158.2015.12.01.15.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:26:05 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so19846806pac.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:05 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 6/7] sh: mm/gup: add gup trace points
Date: Tue,  1 Dec 2015 15:06:16 -0800
Message-Id: <1449011177-30686-7-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, linux-sh@vger.kernel.org

Cc: linux-sh@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/sh/mm/gup.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/sh/mm/gup.c b/arch/sh/mm/gup.c
index e7af6a6..6df3e97 100644
--- a/arch/sh/mm/gup.c
+++ b/arch/sh/mm/gup.c
@@ -12,6 +12,10 @@
 #include <linux/mm.h>
 #include <linux/vmstat.h>
 #include <linux/highmem.h>
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 #include <asm/pgtable.h>
 
 static inline pte_t gup_get_pte(pte_t *ptep)
@@ -178,6 +182,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	/*
 	 * This doesn't prevent pagetable teardown, but does prevent
 	 * the pagetables and pages from being freed.
@@ -231,6 +237,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	if (end < start)
 		goto slow_irqon;
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	local_irq_disable();
 	pgdp = pgd_offset(mm, addr);
 	do {
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

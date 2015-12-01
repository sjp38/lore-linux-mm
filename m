Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 101746B0257
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:26:08 -0500 (EST)
Received: by pacej9 with SMTP id ej9so19931814pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:07 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id wh2si216707pac.170.2015.12.01.15.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:26:03 -0800 (PST)
Received: by padhx2 with SMTP id hx2so19965704pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:03 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 4/7] mips: mm/gup: add gup trace points
Date: Tue,  1 Dec 2015 15:06:14 -0800
Message-Id: <1449011177-30686-5-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/mips/mm/gup.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 349995d..3c5b8c8 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -12,6 +12,9 @@
 #include <linux/swap.h>
 #include <linux/hugetlb.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 #include <asm/cpu-features.h>
 #include <asm/pgtable.h>
 
@@ -211,6 +214,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
@@ -277,6 +282,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	if (end < start || cpu_has_dc_aliases)
 		goto slow_irqon;
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	/* XXX: batch / limit 'nr' */
 	local_irq_disable();
 	pgdp = pgd_offset(mm, addr);
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

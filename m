Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B00B56B0257
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:42:29 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so35724672pac.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:29 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id c10si15119524pat.36.2015.12.09.13.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 13:42:25 -0800 (PST)
Received: by pacej9 with SMTP id ej9so35940672pac.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:25 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v5 4/7] mips: mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 13:22:28 -0800
Message-Id: <1449696151-4195-5-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, linux-mips@linux-mips.org

Cc: linux-mips@linux-mips.org
Acked-by: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/mips/mm/gup.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 349995d..7d90883 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -15,6 +15,8 @@
 #include <asm/cpu-features.h>
 #include <asm/pgtable.h>
 
+#include <trace/events/gup.h>
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #if defined(CONFIG_PHYS_ADDR_T_64BIT) && defined(CONFIG_CPU_MIPS32)
@@ -211,6 +213,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
@@ -291,6 +295,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
 	return nr;
 slow:
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

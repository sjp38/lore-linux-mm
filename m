Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BA3E26B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 15:00:01 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so16919545pac.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 12:00:01 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id sj4si7051562pac.228.2015.12.08.11.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 11:59:57 -0800 (PST)
Received: by pfdd184 with SMTP id d184so17006133pfd.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:57 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v3 4/7] mips: mm/gup: add gup trace points
Date: Tue,  8 Dec 2015 11:39:52 -0800
Message-Id: <1449603595-718-5-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
References: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, linux-mips@linux-mips.org

Cc: linux-mips@linux-mips.org
Acked-by: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/mips/mm/gup.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 349995d..2107499 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -15,6 +15,9 @@
 #include <asm/cpu-features.h>
 #include <asm/pgtable.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #if defined(CONFIG_PHYS_ADDR_T_64BIT) && defined(CONFIG_CPU_MIPS32)
@@ -211,6 +214,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
@@ -291,6 +296,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
 
+	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
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

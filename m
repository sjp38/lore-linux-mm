Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 109A06B025F
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:49:27 -0500 (EST)
Received: by pfu207 with SMTP id 207so33386486pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:26 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id wg10si14032464pac.23.2015.12.09.09.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:49:22 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so33170640pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:22 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v4 4/7] mips: mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 09:29:21 -0800
Message-Id: <1449682164-9933-5-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
References: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
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
index 349995d..e0d8838 100644
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
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
@@ -291,6 +296,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
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

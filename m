Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B762C6B0256
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 14:59:59 -0500 (EST)
Received: by pfnn128 with SMTP id n128so17050020pfn.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:59 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id wh2si7074752pac.170.2015.12.08.11.59.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 11:59:56 -0800 (PST)
Received: by pfu207 with SMTP id 207so17043803pfu.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:56 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v3 3/7] x86: mm/gup: add gup trace points
Date: Tue,  8 Dec 2015 11:39:51 -0800
Message-Id: <1449603595-718-4-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
References: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/x86/mm/gup.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index ae9a37b..081f69d 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -12,6 +12,9 @@
 
 #include <asm/pgtable.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>>
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #ifndef CONFIG_X86_PAE
@@ -270,6 +273,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
@@ -373,6 +378,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
 
+	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EA4E16B0257
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:13:28 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so53477704pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:28 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id xq4si7530356pab.229.2015.12.02.15.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 15:13:24 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so55174664pab.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:24 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH V2 4/7] mips: mm/gup: add gup trace points
Date: Wed,  2 Dec 2015 14:53:30 -0800
Message-Id: <1449096813-22436-5-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
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

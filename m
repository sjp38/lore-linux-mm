Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BE56F6B025A
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:13:34 -0500 (EST)
Received: by pacej9 with SMTP id ej9so53661100pac.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:34 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id di6si7536236pad.172.2015.12.02.15.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 15:13:28 -0800 (PST)
Received: by pfbg73 with SMTP id g73so2432862pfb.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:27 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH V2 7/7] sparc64: mm/gup: add gup trace points
Date: Wed,  2 Dec 2015 14:53:33 -0800
Message-Id: <1449096813-22436-8-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org

Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
The context depends on the below patch:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1028752.html

 arch/sparc/mm/gup.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index cf4fb47..6dcfc4d 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -10,6 +10,10 @@
 #include <linux/vmstat.h>
 #include <linux/pagemap.h>
 #include <linux/rwsem.h>
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 #include <asm/pgtable.h>
 
 /*
@@ -177,6 +181,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	local_irq_save(flags);
 	pgdp = pgd_offset(mm, addr);
 	do {
@@ -209,6 +215,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	if (end < start)
 		goto slow_irqon;
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

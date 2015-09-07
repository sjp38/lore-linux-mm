Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 783416B0257
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 04:29:12 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so90599871pac.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 01:29:12 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id ca3si10612164pad.55.2015.09.07.01.29.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Sep 2015 01:29:11 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Sep 2015 13:59:08 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 05F411258018
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 13:58:24 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t878Sfa721430314
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:42 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t878SeD1009882
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:40 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 2/4] mm/kasan: MODULE_VADDR is not available on all archs
Date: Mon,  7 Sep 2015 13:58:37 +0530
Message-Id: <1441614519-20298-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ryabinin.a.a@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Use is_module_address instead

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/kasan/report.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 6c3f82b0240b..d269f2087faf 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -22,6 +22,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/kasan.h>
+#include <linux/module.h>
 
 #include <asm/sections.h>
 
@@ -85,9 +86,11 @@ static void print_error_description(struct kasan_access_info *info)
 
 static inline bool kernel_or_module_addr(const void *addr)
 {
-	return (addr >= (void *)_stext && addr < (void *)_end)
-		|| (addr >= (void *)MODULES_VADDR
-			&& addr < (void *)MODULES_END);
+	if (addr >= (void *)_stext && addr < (void *)_end)
+		return true;
+	if (is_module_address((unsigned long)addr))
+		return true;
+	return false;
 }
 
 static inline bool init_task_stack_addr(const void *addr)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

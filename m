Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D73956B0255
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 03:55:34 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so33991785pac.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 00:55:34 -0700 (PDT)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id g10si40140989pat.82.2015.09.03.00.55.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Sep 2015 00:55:34 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 3 Sep 2015 17:55:29 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E802C2BB004D
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 17:55:25 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t837t9HX66912264
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:55:18 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t837sqw5016073
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:54:52 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/4] kasan: MODULE_VADDR is not available on all archs
Date: Thu,  3 Sep 2015 13:24:21 +0530
Message-Id: <1441266863-5435-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Use is_module_text_address instead

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/kasan/report.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 6c3f82b0240b..01d2efec8ea4 100644
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
+	if (is_module_text_address((unsigned long)addr))
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

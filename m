Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3220E6B0255
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 04:28:49 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so90589767pac.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 01:28:48 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id ya7si7990381pab.157.2015.09.07.01.28.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Sep 2015 01:28:48 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Sep 2015 13:58:44 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 492D3394005E
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 13:58:42 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t878Sfh047186162
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:41 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t878Sedw009898
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:41 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 4/4] mm/kasan: Prevent deadlock in kasan reporting
Date: Mon,  7 Sep 2015 13:58:39 +0530
Message-Id: <1441614519-20298-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ryabinin.a.a@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

When we end up calling kasan_report in real mode, our shadow mapping
for the spinlock variable will show poisoned. This will result
in us calling kasan_report_error with lock_report spin lock held.
To prevent this disable kasan reporting when we are priting
error w.r.t kasan.

Reviewed-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/kasan/report.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index c5367089703c..7833f074ede8 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -173,12 +173,10 @@ static void print_shadow_for_address(const void *addr)
 		 * function, because generic functions may try to
 		 * access kasan mapping for the passed address.
 		 */
-		kasan_disable_current();
 		memcpy(shadow_buf, shadow_row, SHADOW_BYTES_PER_ROW);
 		print_hex_dump(KERN_ERR, buffer,
 			DUMP_PREFIX_NONE, SHADOW_BYTES_PER_ROW, 1,
 			shadow_buf, SHADOW_BYTES_PER_ROW, 0);
-		kasan_enable_current();
 
 		if (row_is_guilty(shadow_row, shadow))
 			pr_err("%*c\n",
@@ -195,6 +193,10 @@ void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
 
+	/*
+	 * Make sure we don't end up in loop.
+	 */
+	kasan_disable_current();
 	spin_lock_irqsave(&report_lock, flags);
 	pr_err("================================="
 		"=================================\n");
@@ -204,12 +206,17 @@ void kasan_report_error(struct kasan_access_info *info)
 	pr_err("================================="
 		"=================================\n");
 	spin_unlock_irqrestore(&report_lock, flags);
+	kasan_enable_current();
 }
 
 void kasan_report_user_access(struct kasan_access_info *info)
 {
 	unsigned long flags;
 
+	/*
+	 * Make sure we don't end up in loop.
+	 */
+	kasan_disable_current();
 	spin_lock_irqsave(&report_lock, flags);
 	pr_err("================================="
 		"=================================\n");
@@ -222,6 +229,7 @@ void kasan_report_user_access(struct kasan_access_info *info)
 	pr_err("================================="
 		"=================================\n");
 	spin_unlock_irqrestore(&report_lock, flags);
+	kasan_enable_current();
 }
 
 void kasan_report(unsigned long addr, size_t size,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

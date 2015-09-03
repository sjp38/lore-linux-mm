Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 16C4A6B0257
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 03:55:37 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so39714690pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 00:55:36 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id pa4si40125840pdb.151.2015.09.03.00.55.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Sep 2015 00:55:36 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 3 Sep 2015 17:55:32 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E78A93578052
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 17:55:28 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t837tCMV37683404
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:55:21 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t837suZP016273
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:54:56 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 4/4] kasan: Prevent deadlock in kasan reporting
Date: Thu,  3 Sep 2015 13:24:23 +0530
Message-Id: <1441266863-5435-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We we end up calling kasan_report in real mode, our shadow mapping
for even spinlock variable will show poisoned. This will result
in us calling kasan_report_error with lock_report spin lock held.
To prevent this disable kasan reporting when we are priting
error w.r.t kasan.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/kasan/report.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 440bda3a3ecd..8c409b1664c8 100644
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

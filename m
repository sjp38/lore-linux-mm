Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7CD6B0256
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 03:55:36 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so39714296pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 00:55:35 -0700 (PDT)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id pa5si40154655pac.22.2015.09.03.00.55.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Sep 2015 00:55:35 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 3 Sep 2015 17:55:31 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8D87D2CE8057
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 17:55:27 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t837tBiJ22413344
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:55:19 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t837ssoD016173
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:54:54 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 3/4] kasan: Don't use kasan shadow pointer in generic functions
Date: Thu,  3 Sep 2015 13:24:22 +0530
Message-Id: <1441266863-5435-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We can't use generic functions like print_hex_dump to access kasan
shadow region. This require us to setup another kasan shadow region
for the address passed (kasan shadow address). Most architecture won't
be able to do that. Hence make a copy of the shadow region row and
pass that to generic functions.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/kasan/report.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 01d2efec8ea4..440bda3a3ecd 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -164,14 +164,20 @@ static void print_shadow_for_address(const void *addr)
 	for (i = -SHADOW_ROWS_AROUND_ADDR; i <= SHADOW_ROWS_AROUND_ADDR; i++) {
 		const void *kaddr = kasan_shadow_to_mem(shadow_row);
 		char buffer[4 + (BITS_PER_LONG/8)*2];
+		char shadow_buf[SHADOW_BYTES_PER_ROW];
 
 		snprintf(buffer, sizeof(buffer),
 			(i == 0) ? ">%p: " : " %p: ", kaddr);
-
+		/*
+		 * We should not pass a shadow pointer to generic
+		 * function, because generic functions may try to
+		 * access kasan mapping for the passed address.
+		 */
 		kasan_disable_current();
+		memcpy(shadow_buf, shadow_row, SHADOW_BYTES_PER_ROW);
 		print_hex_dump(KERN_ERR, buffer,
 			DUMP_PREFIX_NONE, SHADOW_BYTES_PER_ROW, 1,
-			shadow_row, SHADOW_BYTES_PER_ROW, 0);
+			shadow_buf, SHADOW_BYTES_PER_ROW, 0);
 		kasan_enable_current();
 
 		if (row_is_guilty(shadow_row, shadow))
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

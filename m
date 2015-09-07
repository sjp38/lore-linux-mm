Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF506B0259
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 04:29:17 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so90602097pac.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 01:29:17 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id jf11si18835209pbd.111.2015.09.07.01.29.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Sep 2015 01:29:16 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Sep 2015 13:59:13 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 01A9A3940061
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 13:59:11 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t878Sf4S2031782
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:41 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t878SexJ009885
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:41 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 3/4] mm/kasan: Don't use kasan shadow pointer in generic functions
Date: Mon,  7 Sep 2015 13:58:38 +0530
Message-Id: <1441614519-20298-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ryabinin.a.a@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We can't use generic functions like print_hex_dump to access kasan
shadow region. This require us to setup another kasan shadow region
for the address passed (kasan shadow address). Some architectures won't
be able to do that. Hence make a copy of the shadow region row and
pass that to generic functions.

Reviewed-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/kasan/report.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index d269f2087faf..c5367089703c 100644
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

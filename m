Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAD86B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:44:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k10so6862854wrk.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:44:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n1si1452390edc.264.2017.10.02.14.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:44:24 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v92LiMEO075900
	for <linux-mm@kvack.org>; Mon, 2 Oct 2017 17:44:22 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dbwc88jk9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 02 Oct 2017 17:44:22 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 2 Oct 2017 15:44:07 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH] mm/migrate: Fix early increment of migrate->npages
Date: Mon,  2 Oct 2017 16:44:02 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <1506980642-16541-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The intention here is to set the same array element in src and dst.
Switch the order of these lines so that migrate->npages is only
incremented after we've used it.

Fixes: 8315ada7f095 ("mm/migrate: allow migrate_vma() to alloc new page on empty entry")
Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index dea0ceb..c4546cc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2146,8 +2146,8 @@ static int migrate_vma_collect_hole(unsigned long start,
 	unsigned long addr;
 
 	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
-		migrate->src[migrate->npages++] = MIGRATE_PFN_MIGRATE;
 		migrate->dst[migrate->npages] = 0;
+		migrate->src[migrate->npages++] = MIGRATE_PFN_MIGRATE;
 		migrate->cpages++;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

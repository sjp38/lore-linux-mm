Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BCD006B0092
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:12:58 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so6972845pdi.33
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 01:12:58 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ws5si9849139pab.180.2013.12.10.01.09.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 01:12:57 -0800 (PST)
Message-ID: <52A6D9B0.7040506@huawei.com>
Date: Tue, 10 Dec 2013 17:06:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linn@hp.com, penberg@kernel.org, yinghai@kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Xishi Qiu <qiuxishi@huawei.com>

In the following case, e820_all_mapped() will return 1.
A < start < B-1 and B < end < C, it means <start, end> spans two regions.
<start, end>:	        [start - end]
e820 addr:	    ...[A - B-1][B - C]...

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 arch/x86/kernel/e820.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 174da5f..31ecab2 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -85,20 +85,11 @@ int __init e820_all_mapped(u64 start, u64 end, unsigned type)
 
 		if (type && ei->type != type)
 			continue;
-		/* is the region (part) in overlap with the current region ?*/
+		/* is the region (part) in overlap with the current region ? */
 		if (ei->addr >= end || ei->addr + ei->size <= start)
 			continue;
-
-		/* if the region is at the beginning of <start,end> we move
-		 * start to the end of the region since it's ok until there
-		 */
-		if (ei->addr <= start)
-			start = ei->addr + ei->size;
-		/*
-		 * if start is now at or beyond end, we're done, full
-		 * coverage
-		 */
-		if (start >= end)
+		/* is the region full coverage of <start, end> ? */
+		if (ei->addr <= start && ei->addr + ei->size >= end)
 			return 1;
 	}
 	return 0;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

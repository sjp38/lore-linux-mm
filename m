Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F33156B026F
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a141so83282wma.8
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d23si4149114wra.15.2017.11.30.14.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:57 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:55 -0800
From: akpm@linux-foundation.org
Subject: [patch 14/15] mm/vmstat.c: walk the zone in pageblock_nr_pages
 steps
Message-ID: <5a20831b.ULuDgReaEYdaW2tL%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, zhongjiang@huawei.com, iamjoonsoo.kim@lge.com

From: zhong jiang <zhongjiang@huawei.com>
Subject: mm/vmstat.c: walk the zone in pageblock_nr_pages steps

when walking the zone, we can happens to the holes. we should not
align MAX_ORDER_NR_PAGES, so it can skip the normal memory.

In addition, pagetypeinfo_showmixedcount_print reflect fragmentization.
we hope to get more accurate data. therefore, I decide to fix it.

Link: http://lkml.kernel.org/r/1469502526-24486-2-git-send-email-zhongjiang@huawei.com
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_owner.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_owner.c~mm-walk-the-zone-in-pageblock_nr_pages-steps mm/page_owner.c
--- a/mm/page_owner.c~mm-walk-the-zone-in-pageblock_nr_pages-steps
+++ a/mm/page_owner.c
@@ -274,7 +274,7 @@ void pagetypeinfo_showmixedcount_print(s
 	 */
 	for (; pfn < end_pfn; ) {
 		if (!pfn_valid(pfn)) {
-			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
+			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 			continue;
 		}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

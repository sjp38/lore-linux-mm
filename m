Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FDA76B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 06:43:26 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so145658241pfy.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 03:43:26 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id s5si3844968pgh.144.2017.02.07.03.43.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 03:43:25 -0800 (PST)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: fix a overflow in test_pages_in_a_zone()
Date: Tue, 7 Feb 2017 19:34:59 +0800
Message-ID: <1486467299-22648-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, toshi.kani@hpe.com
Cc: vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

when the mailline introduce the commit a96dfddbcc04
("base/memory, hotplug: fix a kernel oops in show_valid_zones()"),
it obtains the valid start and end pfn from the given pfn range.
The valid start pfn can fix the actual issue, but it introduce
another issue. The valid end pfn will may exceed the given end_pfn.

Ahthough the incorrect overflow will not result in actual problem
at present, but I think it need to be fixed.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b8c11e0..f611584 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1521,7 +1521,7 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 
 	if (zone) {
 		*valid_start = start;
-		*valid_end = end;
+		*valid_end = min(end, end_pfn);
 		return 1;
 	} else {
 		return 0;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

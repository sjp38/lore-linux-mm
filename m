Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id CCB2E6B0075
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:48:48 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 19:45:30 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A755D2CE805B
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:41 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7M9WXJT10158504
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:32:33 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7M9mehb005566
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:41 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 4/6] mm/hwpoison: don't set migration type twice to avoid hold heavy contend zone->lock
Date: Thu, 22 Aug 2013 17:48:25 +0800
Message-Id: <1377164907-24801-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Set pageblock migration type will hold zone->lock which is heavy contended 
in system to avoid race. However, soft offline page will set pageblock 
migration type twice during get page if the page is in used, not hugetlbfs 
page and not on lru list. There is unnecessary to set the pageblock migration
type and hold heavy contended zone->lock again if the first round get page 
have already set the pageblock to right migration type.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 6bfd51e..3bfb45f 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1413,7 +1413,8 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 	 * was free. This flag should be kept set until the source page
 	 * is freed and PG_hwpoison on it is set.
 	 */
-	set_migratetype_isolate(p, true);
+	if (get_pageblock_migratetype(p) == MIGRATE_ISOLATE)
+		set_migratetype_isolate(p, true);
 	/*
 	 * When the target page is a free hugepage, just remove it
 	 * from free hugepage list.
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

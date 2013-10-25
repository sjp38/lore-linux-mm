Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 21D5A6B00DD
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 14:09:51 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so5596461pad.14
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 11:09:50 -0700 (PDT)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id mj9si5745921pab.103.2013.10.25.11.09.49
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 11:09:50 -0700 (PDT)
Received: by mail-ee0-f45.google.com with SMTP id c50so2745498eek.18
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 11:09:47 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] Fix page_group_by_mobility_disabled breakage
Date: Fri, 25 Oct 2013 14:09:35 -0400
Message-Id: <1382724575-8450-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Currently, set_pageblock_migratetype screw up MIGRATE_CMA and
MIGRATE_ISOLATE if page_group_by_mobility_disabled is true. It
rewrite the argument to MIGRATE_UNMOVABLE and we lost these attribute.

The problem was introduced commit 49255c619f (page allocator: move
check for disabled anti-fragmentation out of fastpath). So, 4 years
lived issue may mean that nobody uses page_group_by_mobility_disabled.

But anyway, this patch fixes the problem.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..ef44d95 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -234,8 +234,8 @@ int page_group_by_mobility_disabled __read_mostly;
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
-
-	if (unlikely(page_group_by_mobility_disabled))
+	if (unlikely(page_group_by_mobility_disabled &&
+		     migratetype < MIGRATE_PCPTYPES))
 		migratetype = MIGRATE_UNMOVABLE;
 
 	set_pageblock_flags_group(page, (unsigned long)migratetype,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

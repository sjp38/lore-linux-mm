Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C22C6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 03:43:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 77so16767980pfz.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 00:43:00 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id h8si2855035paz.143.2016.05.17.00.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 00:42:59 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 145so1054475pfz.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 00:42:59 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: bad_page() checks bad_flags instead of page->flags for hwpoison page
Date: Tue, 17 May 2016 16:42:55 +0900
Message-Id: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

There's a race window between checking page->flags and unpoisoning, which
taints kernel with "BUG: Bad page state". That's overkill. It's safer to
use bad_flags to detect hwpoisoned page.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git tmp/mm/page_alloc.c tmp_patched/mm/page_alloc.c
index 5b269bc..4e0fa37 100644
--- tmp/mm/page_alloc.c
+++ tmp_patched/mm/page_alloc.c
@@ -522,8 +522,8 @@ static void bad_page(struct page *page, const char *reason,
 	static unsigned long nr_shown;
 	static unsigned long nr_unshown;
 
-	/* Don't complain about poisoned pages */
-	if (PageHWPoison(page)) {
+	/* Don't complain about hwpoisoned pages */
+	if (bad_flags == __PG_HWPOISON) {
 		page_mapcount_reset(page); /* remove PageBuddy */
 		return;
 	}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

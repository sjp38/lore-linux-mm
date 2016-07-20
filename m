Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0EFF6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 11:21:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p41so34856056lfi.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 08:21:53 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id q4si4458496wma.14.2016.07.20.08.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 08:21:52 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id DBF831C1407
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 16:21:51 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/5] mm, vmscan: Do not account skipped pages as scanned
Date: Wed, 20 Jul 2016 16:21:47 +0100
Message-Id: <1469028111-1622-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Page reclaim determines whether a pgdat is unreclaimable by examining how
many pages have been scanned since a page was freed and comparing that
to the LRU sizes. Skipped pages are not considered reclaim candidates but
contribute to scanned. This can prematurely mark a pgdat as unreclaimable
and trigger an OOM kill.

While this does not fix an OOM kill message reported by Joonsoo Kim,
it did stop pgdat being marked unreclaimable.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 22aec2bcfeec..b16d578ce556 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1415,7 +1415,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
-					!list_empty(src); scan++) {
+					!list_empty(src);) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1429,6 +1429,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 		}
 
+		/* Pages skipped do not contribute to scan */
+		scan++;
+
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 087AD6B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:45:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so156307356lfb.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:45:48 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id ul8si17950503wjb.148.2016.08.05.03.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 03:58:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id B8A421C1C04
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:58:06 +0100 (IST)
Date: Fri, 5 Aug 2016 11:58:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] proc, meminfo: Use correct helpers for calculating LRU sizes
 in meminfo
Message-ID: <20160805105805.GR2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

meminfo_proc_show and si_mem_available are using the wrong helpers for
calculating the size of the LRUs. The user-visible impact is that there
appears to be an abnormally high number of unevictable pages.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 fs/proc/meminfo.c | 2 +-
 mm/page_alloc.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 09e18fdf61e5..b9a8c813e5e6 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -46,7 +46,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		cached = 0;
 
 	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
-		pages[lru] = global_page_state(NR_LRU_BASE + lru);
+		pages[lru] = global_node_page_state(NR_LRU_BASE + lru);
 
 	available = si_mem_available();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fb975cec3518..baa97da3687d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4064,7 +4064,7 @@ long si_mem_available(void)
 	int lru;
 
 	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
-		pages[lru] = global_page_state(NR_LRU_BASE + lru);
+		pages[lru] = global_node_page_state(NR_LRU_BASE + lru);
 
 	for_each_zone(zone)
 		wmark_low += zone->watermark[WMARK_LOW];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

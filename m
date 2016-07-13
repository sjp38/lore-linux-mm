Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2113C6B025F
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:00:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so31396531wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:00:11 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id lu3si24997wjb.159.2016.07.13.03.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 03:00:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 9840D1C1FE1
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:00:06 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/4] mm: vmstat: account per-zone stalls and pages skipped during reclaim -fix
Date: Wed, 13 Jul 2016 11:00:02 +0100
Message-Id: <1468404004-5085-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As pointed out by Johannes -- the PG prefix seems to stand for page, and
all stat names that contain it represent some per-page event. PGSTALL is
not a page event. This patch renames it.

This is a fix for the mmotm patch
mm-vmstat-account-per-zone-stalls-and-pages-skipped-during-reclaim.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/vm_event_item.h | 2 +-
 mm/vmscan.c                   | 2 +-
 mm/vmstat.c                   | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 6d47f66f0e9c..4d6ec58a8d45 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -23,7 +23,7 @@
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
-		FOR_ALL_ZONES(PGSTALL),
+		FOR_ALL_ZONES(ALLOCSTALL),
 		FOR_ALL_ZONES(PGSCAN_SKIP),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 21eae17ee730..429bf3a9c06c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2674,7 +2674,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	delayacct_freepages_start();
 
 	if (global_reclaim(sc))
-		__count_zid_vm_events(PGSTALL, sc->reclaim_idx, 1);
+		__count_zid_vm_events(ALLOCSTALL, sc->reclaim_idx, 1);
 
 	do {
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7415775faf08..91ecca96dcae 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -980,7 +980,7 @@ const char * const vmstat_text[] = {
 	"pswpout",
 
 	TEXTS_FOR_ZONES("pgalloc")
-	TEXTS_FOR_ZONES("pgstall")
+	TEXTS_FOR_ZONES("allocstall")
 	TEXTS_FOR_ZONES("pgskip")
 
 	"pgfree",
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

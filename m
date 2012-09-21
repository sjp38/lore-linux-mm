Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 6DD2A6B005A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 06:46:29 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/9] Revert "mm: compaction: check lock contention first before taking lock"
Date: Fri, 21 Sep 2012 11:46:15 +0100
Message-Id: <1348224383-1499-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1348224383-1499-1-git-send-email-mgorman@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This reverts
mm-compaction-check-lock-contention-first-before-taking-lock.patch as it
is replaced by a later patch in the series.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 3bb7232..4a77b4b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -347,9 +347,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
-	if (!locked)
-		return 0;
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	locked = true;
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

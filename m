Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 491F86B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 08:06:28 -0400 (EDT)
Date: Thu, 27 Sep 2012 13:06:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: compaction: cache if a pageblock was scanned and no
 pages were isolated -fix2
Message-ID: <20120927120621.GB3429@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-9-git-send-email-mgorman@suse.de>
 <20120921143656.60a9a6cd.akpm@linux-foundation.org>
 <20120924093938.GZ11266@suse.de>
 <20120924142644.06c38b80.akpm@linux-foundation.org>
 <20120925091207.GD11266@suse.de>
 <20120925130352.0d60957a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120925130352.0d60957a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The clearing of PG_migrate_skip potentially takes a long time if the
zone is massive. Be safe and check if it needs to reschedule.

This is a fix for
mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index fb07abb..722d10f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -85,6 +85,9 @@ static void reset_isolation_suitable(struct zone *zone)
 	/* Walk the zone and mark every pageblock as suitable for isolation */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		struct page *page;
+
+		cond_resched();
+
 		if (!pfn_valid(pfn))
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

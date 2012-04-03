Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E627E6B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 10:10:26 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M1W006PAQ05WT@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 03 Apr 2012 15:09:41 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1W00GIJQ1CXU@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Apr 2012 15:10:25 +0100 (BST)
Date: Tue, 03 Apr 2012 16:10:15 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv24 10/16] mm: Serialize access to min_free_kbytes
In-reply-to: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1333462221-3987-11-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>, Sandeep Patil <psandeep.s@gmail.com>

From: Mel Gorman <mgorman@suse.de>

There is a race between the min_free_kbytes sysctl, memory hotplug
and transparent hugepage support enablement.  Memory hotplug uses a
zonelists_mutex to avoid a race when building zonelists. Reuse it to
serialise watermark updates.

[a.p.zijlstra@chello.nl: Older patch fixed the race with spinlock]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Tested-by: Barry Song <Baohua.Song@csr.com>
---
 mm/page_alloc.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 216e575..8b19caa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5020,14 +5020,7 @@ static void setup_per_zone_lowmem_reserve(void)
 	calculate_totalreserve_pages();
 }
 
-/**
- * setup_per_zone_wmarks - called when min_free_kbytes changes
- * or when memory is hot-{added|removed}
- *
- * Ensures that the watermark[min,low,high] values for each zone are set
- * correctly with respect to min_free_kbytes.
- */
-void setup_per_zone_wmarks(void)
+static void __setup_per_zone_wmarks(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
@@ -5082,6 +5075,20 @@ void setup_per_zone_wmarks(void)
 	calculate_totalreserve_pages();
 }
 
+/**
+ * setup_per_zone_wmarks - called when min_free_kbytes changes
+ * or when memory is hot-{added|removed}
+ *
+ * Ensures that the watermark[min,low,high] values for each zone are set
+ * correctly with respect to min_free_kbytes.
+ */
+void setup_per_zone_wmarks(void)
+{
+	mutex_lock(&zonelists_mutex);
+	__setup_per_zone_wmarks();
+	mutex_unlock(&zonelists_mutex);
+}
+
 /*
  * The inactive anon list should be small enough that the VM never has to
  * do too much work, but large enough that each inactive page has a chance
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

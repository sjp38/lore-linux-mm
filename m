Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D8CFF6B011D
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:35:50 -0400 (EDT)
From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 2/3] mm: make the threshold of enabling THP configurable
Date: Tue, 21 Jun 2011 00:34:29 +0800
Message-Id: <1308587683-2555-2-git-send-email-amwang@redhat.com>
In-Reply-To: <1308587683-2555-1-git-send-email-amwang@redhat.com>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Amerigo Wang <amwang@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

Don't hard-code 512M as the threshold in kernel, make it configruable,
and set 512M by default.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 mm/Kconfig       |   10 ++++++++++
 mm/huge_memory.c |    2 +-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 8ca47a5..a826471 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -340,6 +340,16 @@ choice
 	  benefit.
 endchoice
 
+config TRANSPARENT_HUGEPAGE_THRESHOLD
+	depends on TRANSPARENT_HUGEPAGE
+	int "The minimal threshold of enabling Transparent Hugepage"
+	range 512 8192
+	default "512"
+	help
+	  The threshold of enabling Transparent Huagepage automatically,
+	  in Mbytes, below this value, Transparent Hugepage will be disabled
+	  by default during boot.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9c63c90..7fb44cc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -544,7 +544,7 @@ static int __init hugepage_init(void)
 	 * where the extra memory used could hurt more than TLB overhead
 	 * is likely to save.  The admin can still enable it through /sys.
 	 */
-	if (totalram_pages < (512 << (20 - PAGE_SHIFT)))
+	if (totalram_pages < (CONFIG_TRANSPARENT_HUGEPAGE_THRESHOLD << (20 - PAGE_SHIFT)))
 		transparent_hugepage_flags = 0;
 
 	start_khugepaged();
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

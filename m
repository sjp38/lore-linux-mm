Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 541FC6B0103
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 04:11:44 -0400 (EDT)
From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH v2 2/4] mm: make the threshold of enabling THP configurable
Date: Tue, 21 Jun 2011 16:10:43 +0800
Message-Id: <1308643849-3325-2-git-send-email-amwang@redhat.com>
In-Reply-To: <1308643849-3325-1-git-send-email-amwang@redhat.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Amerigo Wang <amwang@redhat.com>, dave@linux.vnet.ibm.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

Don't hard-code 512M as the threshold in kernel, make it configruable,
and set 512M by default.

And print info when THP is disabled automatically on small systems.

V2: Add more description in help messages, correct some typos,
print the mini threshold too.

Cc: dave@linux.vnet.ibm.com
Signed-off-by: WANG Cong <amwang@redhat.com>
---
 mm/Kconfig       |   20 ++++++++++++++++++++
 mm/huge_memory.c |    7 ++++++-
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 8ca47a5..f1b3175f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -340,6 +340,26 @@ choice
 	  benefit.
 endchoice
 
+config TRANSPARENT_HUGEPAGE_THRESHOLD
+	depends on TRANSPARENT_HUGEPAGE
+	int "The minimal threshold of enabling Transparent Hugepage"
+	range 512 8192
+	default "512"
+	help
+	  The threshold of enabling Transparent Huagepage automatically,
+	  in Mbytes, below this value Transparent Hugepage will be disabled
+	  by default during boot. You can still enable it via /sys after
+	  boot.
+
+	  Transparent hugepages are created by moving other pages out of
+	  the way to create large, contiguous swaths of free memory.
+	  However, some memory on a system can not be easily moved.  It is
+	  likely on small systems that this unmovable memory will occupy a
+	  large portion of total memory, which makes even attempting to
+	  create transparent hugepages very expensive.
+
+	  If you are unsure, set this to the smallest possible value.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e4a4f2b..126c96b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -546,8 +546,13 @@ static int __init hugepage_init(void)
 	 * where the extra memory used could hurt more than TLB overhead
 	 * is likely to save.  The admin can still enable it through /sys.
 	 */
-	if (totalram_pages < (512 << (20 - PAGE_SHIFT)))
+	if (totalram_pages < (CONFIG_TRANSPARENT_HUGEPAGE_THRESHOLD
+					<< (20 - PAGE_SHIFT))) {
+		printk(KERN_INFO "THP: disabled automatically"
+				 "with less than %dMB of RAM\n",
+				 CONFIG_TRANSPARENT_HUGEPAGE_THRESHOLD);
 		transparent_hugepage_flags = 0;
+	}
 
 	start_khugepaged();
 
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

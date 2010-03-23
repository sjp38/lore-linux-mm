Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B26F56B01B1
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 08:25:53 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 04/11] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA or memory hot-remove
Date: Tue, 23 Mar 2010 12:25:39 +0000
Message-Id: <1269347146-7461-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_MIGRATION currently depends on CONFIG_NUMA or on the architecture
being able to hot-remove memory. The main users of page migration such as
sys_move_pages(), sys_migrate_pages() and cpuset process migration are
only beneficial on NUMA so it makes sense.

As memory compaction will operate within a zone and is useful on both NUMA
and non-NUMA systems, this patch allows CONFIG_MIGRATION to be set if the
user selects CONFIG_COMPACTION as an option.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/Kconfig |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 9c61158..04e241b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -172,17 +172,29 @@ config SPLIT_PTLOCK_CPUS
 	default "4"
 
 #
+# support for memory compaction
+config COMPACTION
+	bool "Allow for memory compaction"
+	def_bool y
+	select MIGRATION
+	depends on EXPERIMENTAL && HUGETLBFS && MMU
+	help
+	  Allows the compaction of memory for the allocation of huge pages.
+
+#
 # support for page migration
 #
 config MIGRATION
 	bool "Page migration"
 	def_bool y
-	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
+	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
 	help
 	  Allows the migration of the physical location of pages of processes
-	  while the virtual addresses are not changed. This is useful for
-	  example on NUMA systems to put pages nearer to the processors accessing
-	  the page.
+	  while the virtual addresses are not changed. This is useful in
+	  two situations. The first is on NUMA systems to put pages nearer
+	  to the processors accessing. The second is when allocating huge
+	  pages as migration can relocate pages to satisfy a huge page
+	  allocation instead of reclaiming.
 
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

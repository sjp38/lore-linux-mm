Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BBAED6B0047
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 11:26:16 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/7] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
Date: Wed,  6 Jan 2010 16:26:03 +0000
Message-Id: <1262795169-9095-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_MIGRATION currently depends on CONFIG_NUMA. The current users of
page migration such as sys_move_pages(), sys_migrate_pages() and cpuset
process migration are ordinarily only beneficial on NUMA.

As memory compaction will operate within a zone and is useful on both NUMA
and non-NUMA systems, this patch allows CONFIG_MIGRATION to be set if the
user selects CONFIG_COMPACTION as an option.

TODO
  o After this patch is applied, the migration core is available but it
    also makes NUMA-specific features available. This is too much
    exposure so revisit this.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/Kconfig |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 17b8947..1d8e2b2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -168,12 +168,22 @@ config SPLIT_PTLOCK_CPUS
 	default "4"
 
 #
+# support for memory compaction
+config COMPACTION
+	bool "Allow for memory compaction"
+	def_bool y
+	select MIGRATION
+	depends on EXPERIMENTAL && HUGETLBFS
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
 	  while the virtual addresses are not changed. This is useful for
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

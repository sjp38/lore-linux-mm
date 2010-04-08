Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5EBF4620089
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:10 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 52 of 67] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
	or memory hot-remove
Message-Id: <7963905262c4142ae535.1270691495@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Mel Gorman <mel@csn.ul.ie>

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

diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -172,6 +172,16 @@ config SPLIT_PTLOCK_CPUS
 	default "4"
 
 #
+# support for memory compaction
+config COMPACTION
+	bool "Allow for memory compaction"
+	def_bool y
+	select MIGRATION
+	depends on EXPERIMENTAL && HUGETLB_PAGE && MMU
+	help
+	  Allows the compaction of memory for the allocation of huge pages.
+
+#
 # support for page migration
 #
 config MIGRATION
@@ -180,9 +190,11 @@ config MIGRATION
 	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

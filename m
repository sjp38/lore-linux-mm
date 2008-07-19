Message-Id: <20080719084304.258867470@jp.fujitsu.com>
References: <20080719084213.588795788@jp.fujitsu.com>
Date: Sat, 19 Jul 2008 17:42:16 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [-mm][splitlru][PATCH 3/3] revert to unevictable-lru-infrastructure-kconfig-fix.patch
Content-Disposition: inline; filename=revert-kconfig.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

CONFIG_UNEVICTABLE_LRU automatically turn on CONFIG_PAGE_WALKER.
it cause build error on nommu machine.

Now, it is unnecessary because munlock was rewritten.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Li Zefan <lizf@cn.fujitsu.com>
CC: Hugh Dickins <hugh@veritas.com>
CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
CC: Rik van Riel <riel@redhat.com>

---
 init/Kconfig |    1 -
 mm/Kconfig   |    5 -----
 mm/Makefile  |    2 +-
 3 files changed, 1 insertion(+), 7 deletions(-)

Index: b/init/Kconfig
===================================================================
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -803,7 +803,6 @@ source "arch/Kconfig"
 config PROC_PAGE_MONITOR
  	default y
 	depends on PROC_FS && MMU
-	select PAGE_WALKER
 	bool "Enable /proc page monitoring" if EMBEDDED
  	help
 	  Various /proc files exist to monitor process memory utilization:
Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -209,14 +209,9 @@ config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
 
-# automatically selected by UNEVICTABLE_LRU or PROC_PAGE_MONITOR
-config PAGE_WALKER
-	def_bool n
-
 config UNEVICTABLE_LRU
 	bool "Add LRU list to track non-evictable pages"
 	default y
-	select PAGE_WALKER
 	help
 	  Keeps unevictable pages off of the active and inactive pageout
 	  lists, so kswapd will not waste CPU time or have its balancing
Index: b/mm/Makefile
===================================================================
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -13,7 +13,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o $(mmu-y)
 
-obj-$(CONFIG_PAGE_WALKER) += pagewalk.o
+obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

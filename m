Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j3BMxZLg166964
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 18:59:35 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3BMxZCt368678
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 16:59:35 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j3BMxYQc029546
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 16:59:34 -0600
Subject: [PATCH 2/3] mm/Kconfig: hide "Memory Model" selection menu
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 11 Apr 2005 15:59:33 -0700
Message-Id: <E1DL7sT-000353-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, zippel@linux-m68k.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I got some feedback from users who think that the new "Memory
Model" menu is a little invasive.  This patch will hide that menu,
except when CONFIG_EXPERIMENTAL is enabled *or* when an individual
architecture wants it.

An individual arch may want to enable it because they've removed
their arch-specific DISCONTIG prompt in favor of the mm/Kconfig one.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 arch/i386/Kconfig          |    0 
 memhotplug-dave/mm/Kconfig |   21 +++++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff -puN mm/Kconfig~A1-mm-Kconfig-hide-selection-menu mm/Kconfig
--- memhotplug/mm/Kconfig~A1-mm-Kconfig-hide-selection-menu	2005-04-11 15:49:10.000000000 -0700
+++ memhotplug-dave/mm/Kconfig	2005-04-11 15:49:10.000000000 -0700
@@ -1,9 +1,14 @@
+config SELECT_MEMORY_MODEL
+	def_bool y
+	depends on EXPERIMENTAL || ARCH_SELECT_MEMORY_MODEL
+
 choice
 	prompt "Memory model"
-	default DISCONTIGMEM if ARCH_DISCONTIGMEM_DEFAULT
-	default FLATMEM
+	depends on SELECT_MEMORY_MODEL
+	default DISCONTIGMEM_MANUAL if ARCH_DISCONTIGMEM_DEFAULT
+	default FLATMEM_MANUAL
 
-config FLATMEM
+config FLATMEM_MANUAL
 	bool "Flat Memory"
 	depends on !ARCH_DISCONTIGMEM_ENABLE || ARCH_FLATMEM_ENABLE
 	help
@@ -14,7 +19,7 @@ config FLATMEM
 
 	  If unsure, choose this option over any other.
 
-config DISCONTIGMEM
+config DISCONTIGMEM_MANUAL
 	bool "Discontigious Memory"
 	depends on ARCH_DISCONTIGMEM_ENABLE
 	help
@@ -22,6 +27,14 @@ config DISCONTIGMEM
 
 endchoice
 
+config DISCONTIGMEM
+	def_bool y
+	depends on (!SELECT_MEMORY_MODEL && ARCH_DISCONTIGMEM_ENABLE) || DISCONTIGMEM_MANUAL
+
+config FLATMEM
+	def_bool y
+	depends on !DISCONTIGMEM || FLATMEM_MANUAL
+
 #
 # Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
 # to represent different areas of memory.  This variable allows
diff -puN arch/i386/Kconfig~A1-mm-Kconfig-hide-selection-menu arch/i386/Kconfig
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

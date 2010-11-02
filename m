Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5BBAD6B017E
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 23:21:08 -0400 (EDT)
Received: by vws18 with SMTP id 18so4496757vws.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 20:21:06 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: [PATCH] Add Kconfig option for default swappiness
Date: Mon,  1 Nov 2010 23:20:52 -0400
Message-Id: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

This will allow distributions to tune this important vm parameter in a more
self-contained manner.

Signed-off-by: Ben Gamari <bgamari.foss@gmail.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/sysctl/vm.txt |    2 +-
 mm/Kconfig                  |   14 ++++++++++++++
 mm/vmscan.c                 |    2 +-
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 30289fa..d159d02 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -643,7 +643,7 @@ This control is used to define how aggressive the kernel will swap
 memory pages.  Higher values will increase agressiveness, lower values
 decrease the amount of swap.
 
-The default value is 60.
+The default value is 60 (changed with CONFIG_DEFAULT_SWAPINESS).
 
 ==============================================================
 
diff --git a/mm/Kconfig b/mm/Kconfig
index c2c8a4a..dc23737 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -61,6 +61,20 @@ config SPARSEMEM_MANUAL
 
 endchoice
 
+config DEFAULT_SWAPPINESS
+	int "Default swappiness"
+	default "60"
+	range 0 100
+	help
+	  This control is used to define how aggressive the kernel will swap
+	  memory pages.  Higher values will increase agressiveness, lower
+	  values decrease the amount of swap. Valid values range from 0 to 100.
+
+	  This only sets the default value at boot. Swappiness can be set at
+	  runtime through /proc/sys/vm/swappiness.
+
+	  If unsure, keep default value of 60.
+
 config DISCONTIGMEM
 	def_bool y
 	depends on (!SELECT_MEMORY_MODEL && ARCH_DISCONTIGMEM_ENABLE) || DISCONTIGMEM_MANUAL
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8a6fdc..d9f5bba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -133,7 +133,7 @@ struct scan_control {
 /*
  * From 0 .. 100.  Higher means more swappy.
  */
-int vm_swappiness = 60;
+int vm_swappiness = CONFIG_DEFAULT_SWAPPINESS;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
 static LIST_HEAD(shrinker_list);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

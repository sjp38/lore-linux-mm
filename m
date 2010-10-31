Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F109F6B0174
	for <linux-mm@kvack.org>; Sun, 31 Oct 2010 14:08:42 -0400 (EDT)
Received: by vws18 with SMTP id 18so2475142vws.14
        for <linux-mm@kvack.org>; Sun, 31 Oct 2010 11:08:41 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: [RFC PATCH] Add Kconfig option for default swappiness
Date: Sun, 31 Oct 2010 14:08:28 -0400
Message-Id: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

This will allow distributions to tune this important vm parameter in a more
self-contained manner.

Signed-off-by: Ben Gamari <bgamari.foss@gmail.com>
---
 Documentation/sysctl/vm.txt |    2 +-
 mm/Kconfig                  |   11 +++++++++++
 mm/vmscan.c                 |    2 +-
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 6c7d18c..792823b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -614,7 +614,7 @@ This control is used to define how aggressive the kernel will swap
 memory pages.  Higher values will increase agressiveness, lower values
 decrease the amount of swap.
 
-The default value is 60.
+The default value is 60 (changed with CONFIG_DEFAULT_SWAPINESS).
 
 ==============================================================
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 9c61158..729ecec 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -61,6 +61,17 @@ config SPARSEMEM_MANUAL
 
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
+	  If unsure, keep default value of 60.
+
 config DISCONTIGMEM
 	def_bool y
 	depends on (!SELECT_MEMORY_MODEL && ARCH_DISCONTIGMEM_ENABLE) || DISCONTIGMEM_MANUAL
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3ff3311..342975f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -126,7 +126,7 @@ struct scan_control {
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

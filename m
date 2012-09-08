Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B72F16B009E
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 16:50:00 -0400 (EDT)
Received: by yenl1 with SMTP id l1so249834yen.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 13:49:59 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 01/10] Makefile: Add option CONFIG_DISABLE_GCC_AUTOMATIC_INLINING
Date: Sat,  8 Sep 2012 17:47:50 -0300
Message-Id: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Michal Marek <mmarek@suse.cz>

As its name suggest this option prevents gcc from auto inlining
small functions. This is very important if one wants to obtain
traces with accurate call sites.

Without this option, gcc will collapse some small functions,
even when not marked as 'inline' thus making impossible to
correlate the trace caller address to the real function it belongs.

Of course, the resultant kernel is slower and slightly smaller,
but that's not an issue if the focus is on tracing accuracy.

Cc: Michal Marek <mmarek@suse.cz>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 Makefile          |    4 ++++
 lib/Kconfig.debug |   11 +++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/Makefile b/Makefile
index ddf5be9..df6045a 100644
--- a/Makefile
+++ b/Makefile
@@ -561,6 +561,10 @@ else
 KBUILD_CFLAGS	+= -O2
 endif
 
+ifdef CONFIG_DISABLE_GCC_AUTOMATIC_INLINING
+KBUILD_CFLAGS	+= -fno-inline-small-functions
+endif
+
 include $(srctree)/arch/$(SRCARCH)/Makefile
 
 ifdef CONFIG_READABLE_ASM
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 2403a63..c8fd50f 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1265,6 +1265,17 @@ config LATENCYTOP
 source mm/Kconfig.debug
 source kernel/trace/Kconfig
 
+config DISABLE_GCC_AUTOMATIC_INLINING
+	bool "Disable gcc automatic inlining"
+	depends on TRACING
+	help
+	  This option tells gcc he's not allowed to inline functions automatically,
+	  when they are not marked as 'inline'.
+	  In turn, this enables to trace an event with an accurate call site.
+	  Of course, the resultant kernel is slower and slightly smaller.
+
+	  Select this option only if you want to trace call sites accurately.
+
 config PROVIDE_OHCI1394_DMA_INIT
 	bool "Remote debugging over FireWire early on boot"
 	depends on PCI && X86
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

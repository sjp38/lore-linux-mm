Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j34HoBCe024826
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 13:50:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j34HoBoc094672
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 13:50:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j34HoB6S026143
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 12:50:11 -0500
Subject: [PATCH 1/4] create mm/Kconfig for arch-independent memory options
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 04 Apr 2005 10:50:09 -0700
Message-Id: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

With sparsemem being introduced, we need a central place for new
memory-related .config options: mm/Kconfig.  This allows us to
remove many of the duplicated arch-specific options.

The new option, CONFIG_FLATMEM, is there to enable us to detangle
NUMA and DISCONTIGMEM.  This is a requirement for sparsemem
because sparsemem uses the NUMA code without the presence of
DISCONTIGMEM. The sparsemem patches use CONFIG_FLATMEM in generic
code, so this patch is a requirement before applying them.

Almost all places that used to do '#ifndef CONFIG_DISCONTIGMEM'
should use '#ifdef CONFIG_FLATMEM' instead.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/mm/Kconfig |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+)

diff -puN mm/Kconfig~A6-mm-Kconfig mm/Kconfig
--- memhotplug/mm/Kconfig~A6-mm-Kconfig	2005-04-04 09:04:48.000000000 -0700
+++ memhotplug-dave/mm/Kconfig	2005-04-04 10:15:23.000000000 -0700
@@ -0,0 +1,25 @@
+choice
+	prompt "Memory model"
+	default FLATMEM
+	default SPARSEMEM if ARCH_SPARSEMEM_DEFAULT
+	default DISCONTIGMEM if ARCH_DISCONTIGMEM_DEFAULT
+
+config FLATMEM
+	bool "Flat Memory"
+	depends on !ARCH_DISCONTIGMEM_ENABLE || ARCH_FLATMEM_ENABLE
+	help
+	  This option allows you to change some of the ways that
+	  Linux manages its memory internally.  Most users will
+	  only have one option here: FLATMEM.  This is normal
+	  and a correct option.
+
+	  If unsure, choose this option over any other.
+
+config DISCONTIGMEM
+	bool "Discontigious Memory"
+	depends on ARCH_DISCONTIGMEM_ENABLE
+	help
+	  If unsure, choose "Flat Memory" over this option.
+
+endchoice
+
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2PLsjKN401334
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 16:54:45 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2PLsibK247564
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 14:54:45 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2PLsib7025998
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 14:54:44 -0700
Subject: [RFC][PATCH 1/4] create mm/Kconfig for arch-independent memory options
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 25 Mar 2005 13:54:43 -0800
Message-Id: <E1DEwlP-0006BQ-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

With sparsemem and memory hotplug there are quite a few options that
we kept adding identically in several different architectures.  This
new file allows some of these to be consolidated.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/mm/Kconfig |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+)

diff -puN mm/Kconfig~A6-mm-Kconfig mm/Kconfig
--- memhotplug/mm/Kconfig~A6-mm-Kconfig	2005-03-25 08:08:22.000000000 -0800
+++ memhotplug-dave/mm/Kconfig	2005-03-25 08:08:22.000000000 -0800
@@ -0,0 +1,41 @@
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
+	  Some users of more advanced features like NUMA and
+	  memory hotplug may have different options here.
+	  DISCONTIGMEM is an more mature, better tested system,
+	  but is incompatible with memory hotplug and may suffer
+	  decreased performance over SPARSEMEM.  If unsure between
+	  "Sparse Memory" and "Discontiguous Memory", choose
+	  "Discontiguous Memory".
+
+	  If unsure, choose FLATMEM.
+
+config DISCONTIGMEM
+	bool "Discontigious Memory"
+	depends on ARCH_DISCONTIGMEM_ENABLE
+	help
+	  If unsure, choose this option over "Sparse Memory".
+
+endchoice
+
+#
+# Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
+# to represent different areas of memory.  This variable allows
+# those dependencies to exist individually.
+#
+config NEED_MULTIPLE_NODES
+	def_bool y
+	depends on DISCONTIGMEM || NUMA
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

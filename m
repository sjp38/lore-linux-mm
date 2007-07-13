Date: Fri, 13 Jul 2007 18:35:57 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] slob: sparsemem support.
Message-ID: <20070713093557.GA3403@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently slob is disabled if we're using sparsemem, due to an earlier
patch from Goto-san. Slob and static sparsemem work without any trouble
as it is, and the only hiccup is a missing slab_is_available() in the
case of sparsemem extreme. With this, we're rid of the last set of
restrictions for slob usage.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 init/Kconfig |    2 +-
 mm/slob.c    |    8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff -urN linux-2.6.22-rc6-mm1.orig/init/Kconfig linux-2.6.22-rc6-mm1/init/Kconfig
--- linux-2.6.22-rc6-mm1.orig/init/Kconfig	2007-07-06 07:47:49.000000000 +0900
+++ linux-2.6.22-rc6-mm1/init/Kconfig	2007-07-06 09:50:29.000000000 +0900
@@ -625,7 +625,7 @@
 	   and has enhanced diagnostics.
 
 config SLOB
-	depends on EMBEDDED && !SPARSEMEM
+	depends on EMBEDDED
 	bool "SLOB (Simple Allocator)"
 	help
 	   SLOB replaces the SLAB allocator with a drastically simpler
diff -urN linux-2.6.22-rc6-mm1.orig/mm/slob.c linux-2.6.22-rc6-mm1/mm/slob.c
--- linux-2.6.22-rc6-mm1.orig/mm/slob.c	2007-07-06 07:47:50.000000000 +0900
+++ linux-2.6.22-rc6-mm1/mm/slob.c	2007-07-06 09:56:16.000000000 +0900
@@ -606,6 +606,14 @@
 	return 0;
 }
 
+static unsigned int slob_ready __read_mostly;
+
+int slab_is_available(void)
+{
+	return slob_ready;
+}
+
 void __init kmem_cache_init(void)
 {
+	slob_ready = 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

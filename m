Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 8E0C890891
	for <linux-mm@kvack.org>; Mon,  4 Jun 2007 10:12:22 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1HvG6Q-0006An-00
	for <linux-mm@kvack.org>; Mon, 04 Jun 2007 10:12:22 -0700
Date: Mon, 4 Jun 2007 10:12:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Support slub_debug on by default
Message-ID: <Pine.LNX.4.64.0706041011570.23603@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---------- Forwarded message ----------
Date: Mon, 4 Jun 2007 10:02:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
To: akpm@linux-foundation.org
Cc: linux-mm@vger.kernel.org, Dave Jones <davej@redhat.com>,
    young dave <hidave.darkstar@gmail.com>
Subject: SLUB: Support slub_debug on by default

Add a new configuration variable

CONFIG_SLUB_DEBUG_ON

If set then the kernel will be booted by default with slab debugging
switched on. Similar to CONFIG_SLAB_DEBUG. By default slab debugging
is available but must be enabled by specifying "slub_debug" as a
kernel parameter.

Also add support to switch off slab debugging for a kernel that was
built with CONFIG_SLUB_DEBUG_ON. This works by specifying

slub_debug=-

as a kernel parameter.

Dave Jones wanted this feature. 
http://marc.info/?l=linux-kernel&m=118072189913045&w=2

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/kernel-parameters.txt |   38 +++++++++--------
 Documentation/vm/slub.txt           |    2 
 lib/Kconfig.debug                   |   13 +++++
 mm/slub.c                           |   79 +++++++++++++++++++++++-------------
 4 files changed, 87 insertions(+), 45 deletions(-)

Index: slub/lib/Kconfig.debug
===================================================================
--- slub.orig/lib/Kconfig.debug	2007-06-02 11:00:12.000000000 -0700
+++ slub/lib/Kconfig.debug	2007-06-02 12:39:22.000000000 -0700
@@ -155,6 +155,19 @@ config DEBUG_SLAB_LEAK
 	  which parts of the kernel are using slab objects.  May be used for
 	  tracking memory leaks and for instrumenting memory usage.
 
+config SLUB_DEBUG_ON
+	bool "SLUB debugging on by default"
+	depends on SLUB && SLUB_DEBUG
+	default n
+	help
+	  Boot with debugging on by default. SLUB boots by default with
+	  the runtime debug capabilities switched off. Enabling this is
+	  equivalent to specifying the "slub_debug" parameter on boot.
+	  There is no support for more fine grained debug control like
+	  possible with slub_debug=xxx. SLUB debugging may be switched
+	  off in a kernel built with CONFIG_SLUB_DEBUG_ON by specifying
+	  "slub_debug=-".
+
 config DEBUG_PREEMPT
 	bool "Debug preemptible kernel"
 	depends on DEBUG_KERNEL && PREEMPT && TRACE_IRQFLAGS_SUPPORT
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-06-02 11:05:47.000000000 -0700
+++ slub/mm/slub.c	2007-06-02 12:41:23.000000000 -0700
@@ -330,7 +330,11 @@ static inline int slab_index(void *p, st
 /*
  * Debug settings:
  */
+#ifdef CONFIG_SLUB_DEBUG_ON
+static int slub_debug = DEBUG_DEFAULT_FLAGS;
+#else
 static int slub_debug;
+#endif
 
 static char *slub_debug_slabs;
 
@@ -926,38 +930,57 @@ fail:
 
 static int __init setup_slub_debug(char *str)
 {
-	if (!str || *str != '=')
-		slub_debug = DEBUG_DEFAULT_FLAGS;
-	else {
-		str++;
-		if (*str == 0 || *str == ',')
-			slub_debug = DEBUG_DEFAULT_FLAGS;
-		else
-		for( ;*str && *str != ','; str++)
-			switch (*str) {
-			case 'f' : case 'F' :
-				slub_debug |= SLAB_DEBUG_FREE;
-				break;
-			case 'z' : case 'Z' :
-				slub_debug |= SLAB_RED_ZONE;
-				break;
-			case 'p' : case 'P' :
-				slub_debug |= SLAB_POISON;
-				break;
-			case 'u' : case 'U' :
-				slub_debug |= SLAB_STORE_USER;
-				break;
-			case 't' : case 'T' :
-				slub_debug |= SLAB_TRACE;
-				break;
-			default:
-				printk(KERN_ERR "slub_debug option '%c' "
-					"unknown. skipped\n",*str);
-			}
+	slub_debug = DEBUG_DEFAULT_FLAGS;
+	if (*str++ != '=' || !*str)
+		/*
+		 * No options specified. Switch on full debugging.
+		 */
+		goto out;
+
+	if (*str == ',')
+		/*
+		 * No options but restriction on slabs. This means full
+		 * debugging for slabs matching a pattern.
+		 */
+		goto check_slabs;
+
+	slub_debug = 0;
+	if (*str == '-')
+		/*
+		 * Switch off all debugging measures.
+		 */
+		goto out;
+
+	/*
+	 * Determine which debug features should be switched on
+	 */
+	for ( ;*str && *str != ','; str++) {
+		switch (*str) {
+		case 'f' : case 'F' :
+			slub_debug |= SLAB_DEBUG_FREE;
+			break;
+		case 'z' : case 'Z' :
+			slub_debug |= SLAB_RED_ZONE;
+			break;
+		case 'p' : case 'P' :
+			slub_debug |= SLAB_POISON;
+			break;
+		case 'u' : case 'U' :
+			slub_debug |= SLAB_STORE_USER;
+			break;
+		case 't' : case 'T' :
+			slub_debug |= SLAB_TRACE;
+			break;
+		default:
+			printk(KERN_ERR "slub_debug option '%c' "
+				"unknown. skipped\n",*str);
+		}
 	}
 
+check_slabs:
 	if (*str == ',')
 		slub_debug_slabs = str + 1;
+out:
 	return 1;
 }
 
Index: slub/Documentation/kernel-parameters.txt
===================================================================
--- slub.orig/Documentation/kernel-parameters.txt	2007-06-02 11:07:37.000000000 -0700
+++ slub/Documentation/kernel-parameters.txt	2007-06-02 12:50:10.000000000 -0700
@@ -1590,35 +1590,39 @@ and is between 256 and 4096 characters. 
 
 	slram=		[HW,MTD]
 
-	slub_debug	[MM, SLUB]
-			Enabling slub_debug allows one to determine the culprit
-			if slab objects become corrupted. Enabling slub_debug
-			creates guard zones around objects and poisons objects
-			when not in use. Also tracks the last alloc / free.
-			For more information see Documentation/vm/slub.txt.
+	slub_debug[=options[,slabs]]	[MM, SLUB]
+			Enabling slub_debug allows one to determine the
+			culprit if slab objects become corrupted. Enabling
+			slub_debug can create guard zones around objects and
+			may poison objects when not in use. Also tracks the
+			last alloc / free. For more information see
+			Documentation/vm/slub.txt.
 
 	slub_max_order= [MM, SLUB]
-			Determines the maximum allowed order for slabs. Setting
-			this too high may cause fragmentation.
-			For more information see Documentation/vm/slub.txt.
+			Determines the maximum allowed order for slabs.
+			A high setting may cause OOMs due to memory
+			fragmentation. For more information see
+			Documentation/vm/slub.txt.
 
 	slub_min_objects=	[MM, SLUB]
-			The minimum objects per slab. SLUB will increase the
-			slab order up to slub_max_order to generate a
-			sufficiently big slab to satisfy the number of objects.
-			The higher the number of objects the smaller the overhead
-			of tracking slabs.
+			The minimum number of objects per slab. SLUB will
+			increase the slab order up to slub_max_order to
+			generate a sufficiently large slab able to contain
+			the number of objects indicated. The higher the number
+			of objects the smaller the overhead of tracking slabs
+			and the less frequently locks need to be acquired.
 			For more information see Documentation/vm/slub.txt.
 
 	slub_min_order=	[MM, SLUB]
 			Determines the mininum page order for slabs. Must be
-			lower than slub_max_order
+			lower than slub_max_order.
 			For more information see Documentation/vm/slub.txt.
 
 	slub_nomerge	[MM, SLUB]
-			Disable merging of slabs of similar size. May be
+			Disable merging of slabs with similar size. May be
 			necessary if there is some reason to distinguish
-			allocs to different slabs.
+			allocs to different slabs. Debug options disable
+			merging on their own.
 			For more information see Documentation/vm/slub.txt.
 
 	smart2=		[HW]
Index: slub/Documentation/vm/slub.txt
===================================================================
--- slub.orig/Documentation/vm/slub.txt	2007-06-02 11:08:37.000000000 -0700
+++ slub/Documentation/vm/slub.txt	2007-06-02 11:09:33.000000000 -0700
@@ -41,6 +41,8 @@ Possible debug options are
 	P		Poisoning (object and padding)
 	U		User tracking (free and alloc)
 	T		Trace (please only use on single slabs)
+	-		Switch all debugging off (useful if the kernel is
+			configured with CONFIG_SLUB_DEBUG_ON)
 
 F.e. in order to boot just with sanity checks and red zoning one would specify:
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

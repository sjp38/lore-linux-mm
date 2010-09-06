Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B91686B0083
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 02:34:52 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L8B0078QBM0BE@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 06 Sep 2010 07:34:49 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8B003GTBLZT4@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Sep 2010 07:34:48 +0100 (BST)
Date: Mon, 06 Sep 2010 08:33:54 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv5 4/9] mm: cma: Added command line parameters support
In-reply-to: <cover.1283749231.git.mina86@mina86.com>
Message-id: 
 <ce06c9c347168e5e3de83d55655cb73b7583bef5.1283749231.git.mina86@mina86.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch adds a pair of early parameters ("cma" and
"cma.map") which let one override the CMA configuration
given by platform without the need to recompile the kernel.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/contiguous-memory.txt |   85 ++++++++++++++++++++++--
 Documentation/kernel-parameters.txt |    7 ++
 mm/Kconfig                          |    9 +++
 mm/cma.c                            |  125 +++++++++++++++++++++++++++++++++++
 4 files changed, 221 insertions(+), 5 deletions(-)

diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
index 15aff7a..3d9d42c 100644
--- a/Documentation/contiguous-memory.txt
+++ b/Documentation/contiguous-memory.txt
@@ -88,6 +88,20 @@
            early region and the framework will handle the rest
            including choosing the right early allocator.
 
+    4. CMA allows a run-time configuration of the memory regions it
+       will use to allocate chunks of memory from.  The set of memory
+       regions is given on command line so it can be easily changed
+       without the need for recompiling the kernel.
+
+       Each region has it's own size, alignment demand, a start
+       address (physical address where it should be placed) and an
+       allocator algorithm assigned to the region.
+
+       This means that there can be different algorithms running at
+       the same time, if different devices on the platform have
+       distinct memory usage characteristics and different algorithm
+       match those the best way.
+
 ** Use cases
 
     Let's analyse some imaginary system that uses the CMA to see how
@@ -162,7 +176,6 @@
     This solution also shows how with CMA you can assign private pools
     of memory to each device if that is required.
 
-
     Allocation mechanisms can be replaced dynamically in a similar
     manner as well. Let's say that during testing, it has been
     discovered that, for a given shared region of 40 MiB,
@@ -217,6 +230,42 @@
      it will be set to a PAGE_SIZE.  start will be aligned to
      alignment.
 
+     If command line parameter support is enabled, this attribute can
+     also be overriden by a command line "cma" parameter.  When given
+     on command line its forrmat is as follows:
+
+         regions-attr  ::= [ regions [ ';' ] ]
+         regions       ::= region [ ';' regions ]
+
+         region        ::= REG-NAME
+                             '=' size
+                           [ '@' start ]
+                           [ '/' alignment ]
+                           [ ':' ALLOC-NAME ]
+
+         size          ::= MEMSIZE   // size of the region
+         start         ::= MEMSIZE   // desired start address of
+                                     // the region
+         alignment     ::= MEMSIZE   // alignment of the start
+                                     // address of the region
+
+     REG-NAME specifies the name of the region.  All regions given at
+     via the regions attribute need to have a name.  Moreover, all
+     regions need to have a unique name.  If two regions have the same
+     name it is unspecified which will be used when requesting to
+     allocate memory from region with given name.
+
+     ALLOC-NAME specifies the name of allocator to be used with the
+     region.  If no allocator name is provided, the "default"
+     allocator will be used with the region.  The "default" allocator
+     is, of course, the first allocator that has been registered. ;)
+
+     size, start and alignment are specified in bytes with suffixes
+     that memparse() accept.  If start is given, the region will be
+     reserved on given starting address (or at close to it as
+     possible).  If alignment is specified, the region will be aligned
+     to given value.
+
 **** Map
 
      The format of the "map" attribute is as follows:
@@ -260,8 +309,33 @@
      SysFS and can be changed at run-time by writing to
      /sys/kernel/mm/contiguous/map.
 
+     If command line parameter support is enabled, this attribute can
+     also be overriden by a command line "cma.map" parameter.
+
+**** Examples
+
      Some examples (whitespace added for better readability):
 
+         cma = r1 = 64M       // 64M region
+                    @512M       // starting at address 512M
+                                // (or at least as near as possible)
+                    /1M         // make sure it's aligned to 1M
+                    :foo(bar);  // uses allocator "foo" with "bar"
+                                // as parameters for it
+               r2 = 64M       // 64M region
+                    /1M;        // make sure it's aligned to 1M
+                                // uses the first available allocator
+               r3 = 64M       // 64M region
+                    @512M       // starting at address 512M
+                    :foo;       // uses allocator "foo" with no parameters
+
+         cma_map = foo = r1;
+                       // device foo with kind==NULL uses region r1
+
+                   foo/quaz = r2;  // OR:
+                   /quaz = r2;
+                       // device foo with kind == "quaz" uses region r2
+
          cma_map = foo/quaz = r1;
                        // device foo with type == "quaz" uses region r1
 
@@ -529,10 +603,11 @@
 
         int cma_set_defaults(struct cma_region *regions, const char *map)
 
-    It needs to be called prior to reserving regions.  It let one
-    specify the list of regions defined by platform and the map
-    attribute.  The map may point to a string in __initdata.  See
-    above in this document for example usage of this function.
+    It needs to be called after early params have been parsed but
+    prior to reserving regions.  It let one specify the list of
+    regions defined by platform and the map attribute.  The map may
+    point to a string in __initdata.  See above in this document for
+    example usage of this function.
 
 ** Future work
 
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index b7eb33f..015e458 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -43,6 +43,7 @@ parameter is applicable:
 	AVR32	AVR32 architecture is enabled.
 	AX25	Appropriate AX.25 support is enabled.
 	BLACKFIN Blackfin architecture is enabled.
+	CMA	Contiguous Memory Allocator is enabled.
 	EDD	BIOS Enhanced Disk Drive Services (EDD) is enabled
 	EFI	EFI Partitioning (GPT) is enabled
 	EIDE	EIDE/ATAPI support is enabled.
@@ -478,6 +479,12 @@ and is between 256 and 4096 characters. It is defined in the file
 			Also note the kernel might malfunction if you disable
 			some critical bits.
 
+	cma=		[CMA] List of CMA regions.
+			See Documentation/contiguous-memory.txt for details.
+
+	cma.map=	[CMA] CMA mapping
+			See Documentation/contiguous-memory.txt for details.
+
 	cmo_free_hint=	[PPC] Format: { yes | no }
 			Specify whether pages are marked as being inactive
 			when they are freed.  This is used in CMO environments
diff --git a/mm/Kconfig b/mm/Kconfig
index 8bed799..b410910 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -353,6 +353,15 @@ config CMA_SYSFS
 	  <Documentation/contiguous-memory.txt> and
 	  <Documentation/ABI/testing/sysfs-kernel-mm-contiguous> files.
 
+config CMA_CMDLINE
+	bool "CMA command line parameters support"
+	depends on CMA_DEVELOPEMENT
+	help
+	  Enable support for cma and cma.map command line parameters.
+	  This lets overwrite the CMA defaults defined by for the
+	  platform.  This should only be usable during development and
+	  testing.
+
 config CMA_BEST_FIT
 	bool "CMA best-fit allocator"
 	depends on CMA
diff --git a/mm/cma.c b/mm/cma.c
index 955f08c..8191c97 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -103,6 +103,12 @@ static int __init cma_map_param(char *param)
 	return 0;
 }
 
+#if defined CONFIG_CMA_CMDLINE
+
+early_param("cma.map", cma_map_param);
+
+#endif
+
 
 
 /************************* Early regions *************************/
@@ -110,6 +116,125 @@ static int __init cma_map_param(char *param)
 struct list_head cma_early_regions __initdata =
 	LIST_HEAD_INIT(cma_early_regions);
 
+#ifdef CONFIG_CMA_CMDLINE
+
+/*
+ * regions-attr ::= [ regions [ ';' ] ]
+ * regions      ::= region [ ';' regions ]
+ *
+ * region       ::= [ '-' ] reg-name
+ *                    '=' size
+ *                  [ '@' start ]
+ *                  [ '/' alignment ]
+ *                  [ ':' alloc-name ]
+ *
+ * See Documentation/contiguous-memory.txt for details.
+ *
+ * Example:
+ * cma=reg1=64M:bf;reg2=32M@0x100000:bf;reg3=64M/1M:bf
+ *
+ * If allocator is ommited the first available allocater will be used.
+ */
+
+#define NUMPARSE(cond_ch, type, cond) ({				\
+		unsigned long long v = 0;				\
+		if (*param == (cond_ch)) {				\
+			const char *const msg = param + 1;		\
+			v = memparse(msg, &param);			\
+			if (!v || v > ~(type)0 || !(cond)) {		\
+				pr_err("param: invalid value near %s\n", msg); \
+				ret = -EINVAL;				\
+				break;					\
+			}						\
+		}							\
+		v;							\
+	})
+
+static int __init cma_param_parse(char *param)
+{
+	static struct cma_region regions[16];
+
+	size_t left = ARRAY_SIZE(regions);
+	struct cma_region *reg = regions;
+	int ret = 0;
+
+	pr_debug("param: %s\n", param);
+
+	for (; *param; ++reg) {
+		dma_addr_t start, alignment;
+		size_t size;
+
+		if (unlikely(!--left)) {
+			pr_err("param: too many early regions\n");
+			return -ENOSPC;
+		}
+
+		/* Parse name */
+		reg->name = param;
+		param = strchr(param, '=');
+		if (!param || param == reg->name) {
+			pr_err("param: expected \"<name>=\" near %s\n",
+			       reg->name);
+			ret = -EINVAL;
+			break;
+		}
+		*param = '\0';
+
+		/* Parse numbers */
+		size      = NUMPARSE('\0', size_t, true);
+		start     = NUMPARSE('@', dma_addr_t, true);
+		alignment = NUMPARSE('/', dma_addr_t, (v & (v - 1)) == 0);
+
+		alignment = max(alignment, (dma_addr_t)PAGE_SIZE);
+		start     = ALIGN(start, alignment);
+		size      = PAGE_ALIGN(size);
+		if (start + size < start) {
+			pr_err("param: invalid start, size combination\n");
+			ret = -EINVAL;
+			break;
+		}
+
+		/* Parse allocator */
+		if (*param == ':') {
+			reg->alloc_name = ++param;
+			while (*param && *param != ';')
+				++param;
+			if (param == reg->alloc_name)
+				reg->alloc_name = NULL;
+		}
+
+		/* Go to next */
+		if (*param == ';') {
+			*param = '\0';
+			++param;
+		} else if (*param) {
+			pr_err("param: expecting ';' or end of parameter near %s\n",
+			       param);
+			ret = -EINVAL;
+			break;
+		}
+
+		/* Add */
+		reg->size      = size;
+		reg->start     = start;
+		reg->alignment = alignment;
+		reg->copy_name = 1;
+
+		list_add_tail(&reg->list, &cma_early_regions);
+
+		pr_debug("param: registering early region %s (%p@%p/%p)\n",
+			 reg->name, (void *)reg->size, (void *)reg->start,
+			 (void *)reg->alignment);
+	}
+
+	return ret;
+}
+early_param("cma", cma_param_parse);
+
+#undef NUMPARSE
+
+#endif
+
 
 int __init __must_check cma_early_region_register(struct cma_region *reg)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5BF5F6003EF
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:20:49 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L6Q00LKTFQKNV@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 06 Aug 2010 14:20:44 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L6Q0001LFQJWR@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Aug 2010 14:20:43 +0100 (BST)
Date: Fri, 06 Aug 2010 15:22:10 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH/RFCv3 4/6] mm: cma: Added command line parameters support
In-reply-to: 
 <a5061fdb8e8819f1cc281c4279c295146fab6d68.1281100495.git.m.nazarewicz@samsung.com>
Message-id: 
 <05957b9dc9231d296525203d8347d4c9c5246c15.1281100495.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1281100495.git.m.nazarewicz@samsung.com>
 <743102607e2c5fb20e3c0676fadbcb93d501a78e.1281100495.git.m.nazarewicz@samsung.com>
 <6a924738f412a7ad738e99123411b7a20f761ae1.1281100495.git.m.nazarewicz@samsung.com>
 <a5061fdb8e8819f1cc281c4279c295146fab6d68.1281100495.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Hiremath Vaibhav <hvaibhav@ti.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, jaeryul.oh@samsung.com, kgene.kim@samsung.com, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

This patch adds a pair of early parameters ("cma" and
"cma.map") which let one override the CMA configuration
given by platform without the need to recompile the kernel.
---
 Documentation/contiguous-memory.txt |   82 ++++++++++++++++++++--
 Documentation/kernel-parameters.txt |    4 +
 mm/Kconfig                          |    6 ++
 mm/cma.c                            |  131 +++++++++++++++++++++++++++++++++++
 4 files changed, 218 insertions(+), 5 deletions(-)

diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
index 8f1c7f2..cd30401 100644
--- a/Documentation/contiguous-memory.txt
+++ b/Documentation/contiguous-memory.txt
@@ -86,6 +86,20 @@
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
 
     Lets analyse some imaginary system that uses the CMA to see how
@@ -179,7 +193,6 @@
     This solution also shows how with CMA you can assign private pools
     of memory to each device if that is required.
 
-
     Allocation mechanisms can be replaced dynamically in a similar
     manner as well. Let's say that during testing, it has been
     discovered that, for a given shared region of 40 MiB,
@@ -236,6 +249,46 @@
      it will be set to a PAGE_SIZE.  start will be aligned to
      alignment.
 
+     If command line parameter support is enabled, this attribute can
+     also be overriden by a command line "cma" parameter.  When given
+     on command line its forrmat is as follows:
+
+         regions-attr  ::= [ regions [ ';' ] ]
+         regions       ::= region [ ';' regions ]
+
+         region        ::= [ '-' ] REG-NAME
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
+     Optional minus sign in front of region name means that the region
+     sholud not be an "asterisk" region.  All regions given via "cma"
+     command line parameter are "asterisk" regions by default.
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
@@ -292,8 +345,26 @@
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
          cma_map = foo = r1;
                        // device foo with kind==NULL uses region r1
 
@@ -560,10 +631,11 @@
         int __init cma_set_defaults(struct cma_region *regions,
                                     const char *map)
 
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
index a698255..5c7af89 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -43,6 +43,7 @@ parameter is applicable:
 	AVR32	AVR32 architecture is enabled.
 	AX25	Appropriate AX.25 support is enabled.
 	BLACKFIN Blackfin architecture is enabled.
+	CMA	Contiguous Memory Allocator is enabled.
 	DRM	Direct Rendering Management support is enabled.
 	EDD	BIOS Enhanced Disk Drive Services (EDD) is enabled
 	EFI	EFI Partitioning (GPT) is enabled
@@ -476,6 +477,9 @@ and is between 256 and 4096 characters. It is defined in the file
 			Also note the kernel might malfunction if you disable
 			some critical bits.
 
+	cma=		[CMA] List of CMA regions.
+			See Documentation/contiguous-memory.txt for details.
+
 	cmo_free_hint=	[PPC] Format: { yes | no }
 			Specify whether pages are marked as being inactive
 			when they are freed.  This is used in CMO environments
diff --git a/mm/Kconfig b/mm/Kconfig
index ac0bb08..05404fc 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -339,6 +339,12 @@ config CMA_SYSFS
 	  Enable support for SysFS interface.
 
 config CMA_CMDLINE
+	bool "CMA command line parameters support"
+	depends on CMA_DEVELOPEMENT
+	help
+	  Enable support for cma, cma.map and cma.asterisk command line
+	  parameters.
+
 config CMA_BEST_FIT
 	bool "CMA best-fit allocator"
 	depends on CMA
diff --git a/mm/cma.c b/mm/cma.c
index 92ee869..8d27be8 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -124,6 +124,12 @@ static int __init cma_map_param(char *param)
 	return 0;
 }
 
+#if defined CONFIG_CMA_CMDLINE
+
+early_param("cma.map", cma_map_param);
+
+#endif
+
 
 
 /************************* Early regions *************************/
@@ -131,6 +137,131 @@ static int __init cma_map_param(char *param)
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
+		int noasterisk;
+
+		if (unlikely(!--left)) {
+			pr_err("param: too many early regions\n");
+			return -ENOSPC;
+		}
+
+		/* Parse name */
+		noasterisk = *param == '-';
+		if (noasterisk)
+			++param;
+
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
+		reg->asterisk  = !noasterisk;
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

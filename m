Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id CB1B06B0062
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:34:42 -0500 (EST)
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
Subject: [RFCv1 1/6] PASR: Initialize DDR layout
Date: Mon, 30 Jan 2012 14:33:51 +0100
Message-ID: <1327930436-10263-2-git-send-email-maxime.coquelin@stericsson.com>
In-Reply-To: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Mel Gorman <mel@csn.ul.ie>, Ankita Garg <ankita@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, Maxime Coquelin <maxime.coquelin@stericsson.com>, linus.walleij@stericsson.com, andrea.gallo@stericsson.com, vincent.guittot@stericsson.com, philippe.langlais@stericsson.com, loic.pallardy@stericsson.com

Build the DDR layout representation at early init.

To build the PASR MAP, two parameters are provided:

* ddr_die (mandatory): Should be added for every DDR dies present in the system.
   - Usage: ddr_die=xxx[M|G]@yyy[M|G] where xxx represents the size and yyy
     the base address of the die. E.g.: ddr_die=512M@0 ddr_die=512M@512M

* interleaved (optionnal): Should be added for every interleaved dependencies.
   - Usage: interleaved=xxx[M|G]@yyy[M|G]:zzz[M|G] where xxx is the size of
     the interleaved area between the adresses yyy and zzz. E.g
     interleaved=256M@0:512M

Signed-off-by: Maxime Coquelin <maxime.coquelin@stericsson.com>
---
 drivers/staging/Kconfig       |    2 +
 drivers/staging/Makefile      |    1 +
 drivers/staging/pasr/Kconfig  |   14 ++
 drivers/staging/pasr/Makefile |    4 +
 drivers/staging/pasr/helper.c |   84 +++++++++
 drivers/staging/pasr/helper.h |   16 ++
 drivers/staging/pasr/init.c   |  403 +++++++++++++++++++++++++++++++++++++++++
 include/linux/pasr.h          |   73 ++++++++
 8 files changed, 597 insertions(+), 0 deletions(-)
 create mode 100644 drivers/staging/pasr/Kconfig
 create mode 100644 drivers/staging/pasr/Makefile
 create mode 100644 drivers/staging/pasr/helper.c
 create mode 100644 drivers/staging/pasr/helper.h
 create mode 100644 drivers/staging/pasr/init.c
 create mode 100644 include/linux/pasr.h

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index d061318..ddb56aa 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -182,4 +182,6 @@ source "drivers/staging/nmf-cm/Kconfig"
 
 source "drivers/staging/camera_flash/Kconfig"
 
+source "drivers/staging/pasr/Kconfig"
+
 endif # STAGING
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index f0c7417..20a692d 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -5,6 +5,7 @@ obj-$(CONFIG_STAGING)		+= staging.o
 
 obj-y += tty/
 obj-y += generic_serial/
+obj-y += pasr/
 obj-$(CONFIG_ET131X)		+= et131x/
 obj-$(CONFIG_SLICOSS)		+= slicoss/
 obj-$(CONFIG_VIDEO_GO7007)	+= go7007/
diff --git a/drivers/staging/pasr/Kconfig b/drivers/staging/pasr/Kconfig
new file mode 100644
index 0000000..6bd2421
--- /dev/null
+++ b/drivers/staging/pasr/Kconfig
@@ -0,0 +1,14 @@
+config ARCH_HAS_PASR
+	bool
+
+config PASR
+	bool "DDR Partial Array Self-Refresh"
+	depends on ARCH_HAS_PASR
+	---help---
+	  PASR consists on masking the refresh of unused segments or banks
+	  when DDR is in self-refresh state.
+
+config PASR_DEBUG
+	bool "Add PASR debug prints"
+	def_bool n
+	depends on PASR
diff --git a/drivers/staging/pasr/Makefile b/drivers/staging/pasr/Makefile
new file mode 100644
index 0000000..72f7c27
--- /dev/null
+++ b/drivers/staging/pasr/Makefile
@@ -0,0 +1,4 @@
+pasr-objs := helper.o init.o
+obj-$(CONFIG_PASR) += pasr.o
+
+ccflags-$(CONFIG_PASR_DEBUG) := -DDEBUG
diff --git a/drivers/staging/pasr/helper.c b/drivers/staging/pasr/helper.c
new file mode 100644
index 0000000..7c48051
--- /dev/null
+++ b/drivers/staging/pasr/helper.c
@@ -0,0 +1,84 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ * Author: Maxime Coquelin <maxime.coquelin@stericsson.com> for ST-Ericsson.
+ * License terms:  GNU General Public License (GPL), version 2
+ */
+
+#include <linux/pasr.h>
+
+
+struct pasr_die *pasr_addr2die(struct pasr_map *map, phys_addr_t addr)
+{
+	unsigned int left, right, mid;
+
+	if (!map)
+		return NULL;
+
+	left = 0;
+	right = map->nr_dies;
+
+	addr &= ~(PASR_SECTION_SZ - 1);
+
+	while (left != right) {
+		struct pasr_die *d;
+		phys_addr_t start;
+
+		mid = (left + right) >> 1;
+		d = &map->die[mid];
+		start = addr & ~((PASR_SECTION_SZ * d->nr_sections) - 1);
+
+		if (start == d->start)
+			return d;
+		else if (start > d->start)
+			left = mid;
+		else
+			right = mid;
+	}
+
+	pr_err("%s: No die found for address %#x",
+			__func__, addr);
+	return NULL;
+}
+
+struct pasr_section *pasr_addr2section(struct pasr_map *map
+				, phys_addr_t addr)
+{
+	unsigned int left, right, mid;
+	struct pasr_die *die;
+
+	/* Find the die the address it is located in */
+	die = pasr_addr2die(map, addr);
+	if (!die)
+		goto err;
+
+	left = 0;
+	right = die->nr_sections;
+
+	addr &= ~(PASR_SECTION_SZ - 1);
+
+	 while (left != right) {
+		struct pasr_section *s;
+
+		mid = (left + right) >> 1;
+		s = &die->section[mid];
+
+		if (addr == s->start)
+			return s;
+		else if (addr > s->start)
+			left = mid;
+		else
+			right = mid;
+	}
+
+err:
+	/* Provided address isn't in any declared section */
+	pr_err("%s: No section found for address %#x",
+			__func__, addr);
+
+	return NULL;
+}
+
+phys_addr_t pasr_section2addr(struct pasr_section *s)
+{
+	return s->start;
+}
diff --git a/drivers/staging/pasr/helper.h b/drivers/staging/pasr/helper.h
new file mode 100644
index 0000000..6488f2f
--- /dev/null
+++ b/drivers/staging/pasr/helper.h
@@ -0,0 +1,16 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ * Author: Maxime Coquelin <maxime.coquelin@stericsson.com> for ST-Ericsson.
+ * License terms:  GNU General Public License (GPL), version 2
+ */
+
+#ifndef _PASR_HELPER_H
+#define _PASR_HELPER_H
+
+#include <linux/pasr.h>
+
+struct pasr_die *pasr_addr2die(struct pasr_map *map, phys_addr_t addr);
+struct pasr_section *pasr_addr2section(struct pasr_map *map, phys_addr_t addr);
+phys_addr_t pasr_section2addr(struct pasr_section *s);
+
+#endif /* _PASR_HELPER_H */
diff --git a/drivers/staging/pasr/init.c b/drivers/staging/pasr/init.c
new file mode 100644
index 0000000..2c7c280
--- /dev/null
+++ b/drivers/staging/pasr/init.c
@@ -0,0 +1,403 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ * Author: Maxime Coquelin <maxime.coquelin@stericsson.com> for ST-Ericsson.
+ * License terms:  GNU General Public License (GPL), version 2
+ */
+
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/sort.h>
+#include <linux/pasr.h>
+
+#include "helper.h"
+
+#define NR_DIES 8
+#define NR_INT 8
+
+struct ddr_die {
+	phys_addr_t addr;
+	unsigned long size;
+};
+
+struct interleaved_area {
+	phys_addr_t addr1;
+	phys_addr_t addr2;
+	unsigned long size;
+};
+
+struct pasr_info {
+	int nr_dies;
+	struct ddr_die die[NR_DIES];
+
+	int nr_int;
+	struct interleaved_area int_area[NR_INT];
+};
+
+static struct pasr_info __initdata pasr_info;
+static struct pasr_map pasr_map;
+
+static void add_ddr_die(phys_addr_t addr, unsigned long size);
+static void add_interleaved_area(phys_addr_t a1,
+		phys_addr_t a2, unsigned long size);
+
+static int __init ddr_die_param(char *p)
+{
+	phys_addr_t start;
+	unsigned long size;
+
+	size = memparse(p, &p);
+
+	if (*p != '@')
+		goto err;
+
+	start = memparse(p + 1, &p);
+
+	add_ddr_die(start, size);
+
+	return 0;
+err:
+	return -EINVAL;
+}
+early_param("ddr_die", ddr_die_param);
+
+static int __init interleaved_param(char *p)
+{
+	phys_addr_t start1, start2;
+	unsigned long size;
+
+	size = memparse(p, &p);
+
+	if (*p != '@')
+		goto err;
+
+	start1 = memparse(p + 1, &p);
+
+	if (*p != ':')
+		goto err;
+
+	start2 = memparse(p + 1, &p);
+
+	add_interleaved_area(start1, start2, size);
+
+	return 0;
+err:
+	return -EINVAL;
+}
+early_param("interleaved", interleaved_param);
+
+void __init add_ddr_die(phys_addr_t addr, unsigned long size)
+{
+	BUG_ON(pasr_info.nr_dies >= NR_DIES);
+
+	pasr_info.die[pasr_info.nr_dies].addr = addr;
+	pasr_info.die[pasr_info.nr_dies++].size = size;
+}
+
+void __init add_interleaved_area(phys_addr_t a1, phys_addr_t a2,
+		unsigned long size)
+{
+	BUG_ON(pasr_info.nr_int >= NR_INT);
+
+	pasr_info.int_area[pasr_info.nr_int].addr1 = a1;
+	pasr_info.int_area[pasr_info.nr_int].addr2 = a2;
+	pasr_info.int_area[pasr_info.nr_int++].size = size;
+}
+
+#ifdef DEBUG
+static void __init pasr_print_info(struct pasr_info *info)
+{
+	int i;
+
+	pr_info("PASR information coherent\n");
+
+
+	pr_info("DDR Dies layout:\n");
+	pr_info("\tid - start address - end address\n");
+	for (i = 0; i < info->nr_dies; i++)
+		pr_info("\t- %d : %#08x - %#08x\n",
+			i, (unsigned int)info->die[i].addr,
+			(unsigned int)(info->die[i].addr
+				+ info->die[i].size - 1));
+
+	if (info->nr_int == 0) {
+		pr_info("No interleaved areas declared\n");
+		return;
+	}
+
+	pr_info("Interleaving layout:\n");
+	pr_info("\tid - start @1 - end @2 : start @2 - end @2\n");
+	for (i = 0; i < info->nr_int; i++)
+		pr_info("\t-%d - %#08x - %#08x : %#08x - %#08x\n"
+			, i
+			, (unsigned int)info->int_area[i].addr1
+			, (unsigned int)(info->int_area[i].addr1
+				+ info->int_area[i].size - 1)
+			, (unsigned int)info->int_area[i].addr2
+			, (unsigned int)(info->int_area[i].addr2
+				+ info->int_area[i].size - 1));
+}
+#else
+#define pasr_print_info(info) do {} while (0)
+#endif /* DEBUG */
+
+static int __init is_in_physmem(phys_addr_t addr, struct ddr_die *d)
+{
+	return ((addr >= d->addr) && (addr <= d->addr + d->size));
+}
+
+static int __init pasr_check_interleave_in_physmem(struct pasr_info *info,
+						struct interleaved_area *i)
+{
+	struct ddr_die *d;
+	int j;
+	int err = 4;
+
+	for (j = 0; j < info->nr_dies; j++) {
+		d = &info->die[j];
+		if (is_in_physmem(i->addr1, d))
+			err--;
+		if (is_in_physmem(i->addr1 + i->size, d))
+			err--;
+		if (is_in_physmem(i->addr2, d))
+			err--;
+		if (is_in_physmem(i->addr2 + i->size, d))
+			err--;
+	}
+
+	return err;
+}
+
+static int __init ddrdie_cmp(const void *_a, const void *_b)
+{
+	const struct ddr_die *a = _a, *b = _b;
+
+	return a->addr < b->addr ? -1 : a->addr > b->addr ? 1 : 0;
+}
+
+static int __init interleaved_cmp(const void *_a, const void *_b)
+{
+	const struct interleaved_area *a = _a, *b = _b;
+
+	return a->addr1 < b->addr1 ? -1 : a->addr1 > b->addr1 ? 1 : 0;
+}
+
+static int __init pasr_info_sanity_check(struct pasr_info *info)
+{
+	int i;
+
+	/* Check at least one physical chunk is defined */
+	if (info->nr_dies == 0) {
+		pr_err("%s: No DDR dies declared in command line\n", __func__);
+		return -EINVAL;
+	}
+
+	/* Sort DDR dies areas */
+	sort(&info->die, info->nr_dies,
+			sizeof(info->die[0]), ddrdie_cmp, NULL);
+
+	/* Physical layout checking */
+	for (i = 0; i < info->nr_dies; i++) {
+		struct ddr_die *d1, *d2;
+
+		d1 = &info->die[i];
+
+		if (d1->size == 0) {
+			pr_err("%s: DDR die at %#x has 0 size\n",
+					__func__, d1->addr);
+			return -EINVAL;
+		}
+
+		/*  Check die is aligned on section boundaries */
+		if (((d1->addr & ~(PASR_SECTION_SZ - 1)) != d1->addr)
+			|| ((d1->size & ~(PASR_SECTION_SZ - 1)) != d1->size)) {
+			pr_err("%s: DDR die at %#x (size %#lx) is not aligned"
+					"on section boundaries %#x\n",
+					__func__, d1->addr,
+					d1->size, PASR_SECTION_SZ);
+			return -EINVAL;
+		}
+
+		if (i == 0)
+			continue;
+
+		/* Check areas are not overlapping */
+		d2 = d1;
+		d1 = &info->die[i-1];
+		if ((d1->addr + d1->size - 1) >= d2->addr) {
+			pr_err("%s: DDR dies at %#x and %#x are overlapping\n",
+					__func__, d1->addr, d2->addr);
+			return -EINVAL;
+		}
+	}
+
+	/* Interleave layout checking */
+	if (info->nr_int == 0)
+		goto out;
+
+	/* Sort interleaved areas */
+	sort(&info->int_area, info->nr_int,
+			sizeof(info->int_area[0]), interleaved_cmp, NULL);
+
+	for (i = 0; i < info->nr_int; i++) {
+		struct interleaved_area *i1;
+
+		i1 = &info->int_area[i];
+		if (i1->size == 0) {
+			pr_err("%s: Interleaved area %#x/%#x  has 0 size\n",
+					__func__, i1->addr1, i1->addr2);
+			return -EINVAL;
+		}
+
+		/* Check area is aligned on section boundaries */
+		if (((i1->addr1 & ~(PASR_SECTION_SZ - 1)) != i1->addr1)
+			|| ((i1->addr2 & ~(PASR_SECTION_SZ - 1)) != i1->addr2)
+			|| ((i1->size & ~(PASR_SECTION_SZ - 1)) != i1->size)) {
+			pr_err("%s: Interleaved area at %#x/%#x (size %#lx) is not"
+					"aligned on section boundaries %#x\n",
+					__func__, i1->addr1, i1->addr2,
+					i1->size, PASR_SECTION_SZ);
+			return -EINVAL;
+		}
+
+		/* Check interleaved areas are not overlapping */
+		if ((i1->addr1 + i1->size - 1) >= i1->addr2) {
+			pr_err("%s: Interleaved areas %#x"
+					"and %#x are overlapping\n",
+					__func__, i1->addr1, i1->addr2);
+			return -EINVAL;
+		}
+
+		/* Check the interleaved areas are in the physical areas */
+		if (pasr_check_interleave_in_physmem(info, i1)) {
+			pr_err("%s: Interleaved area %#x/%#x"
+					"not in physical memory\n",
+					__func__, i1->addr1, i1->addr2);
+			return -EINVAL;
+		}
+	}
+
+out:
+	return 0;
+}
+
+#ifdef DEBUG
+static void __init pasr_print_map(struct pasr_map *map)
+{
+	int i, j;
+
+	if (!map)
+		goto out;
+
+	pr_info("PASR map:\n");
+
+	for (i = 0; i < map->nr_dies; i++) {
+		struct pasr_die *die = &map->die[i];
+
+		pr_info("Die %d:\n", i);
+		for (j = 0; j < die->nr_sections; j++) {
+			struct pasr_section *s = &die->section[j];
+			pr_info("\tSection %d: @ = %#08x, Pair = %s\n"
+					, j, s->start, s->pair ? "Yes" : "No");
+		}
+	}
+out:
+	return;
+}
+#else
+#define pasr_print_map(map) do {} while (0)
+#endif /* DEBUG */
+
+static int __init pasr_build_map(struct pasr_info *info, struct pasr_map *map)
+{
+	int i, j;
+	struct pasr_die *die;
+
+	map->nr_dies = info->nr_dies;
+	die = map->die;
+
+	for (i = 0; i < info->nr_dies; i++) {
+		phys_addr_t addr = info->die[i].addr;
+		struct pasr_section *section = die[i].section;
+
+		die[i].start = addr;
+		die[i].idx = i;
+		die[i].nr_sections = info->die[i].size >> PASR_SECTION_SZ_BITS;
+
+		for (j = 0; j < die[i].nr_sections; j++) {
+			section[j].start = addr;
+			addr += PASR_SECTION_SZ;
+			section[j].die = &die[i];
+		}
+	}
+
+	for (i = 0; i < info->nr_int; i++) {
+		struct interleaved_area *ia = &info->int_area[i];
+		struct pasr_section *s1, *s2;
+		unsigned long offset = 0;
+
+		for (j = 0; j < (ia->size >> PASR_SECTION_SZ_BITS); j++) {
+			s1 = pasr_addr2section(map, ia->addr1 + offset);
+			s2 = pasr_addr2section(map, ia->addr2 + offset);
+			if (!s1 || !s2)
+				return -EINVAL;
+
+			offset += PASR_SECTION_SZ;
+
+			s1->pair = s2;
+			s2->pair = s1;
+		}
+	}
+	return 0;
+}
+
+int __init early_pasr_setup(void)
+{
+	int ret;
+
+	ret = pasr_info_sanity_check(&pasr_info);
+	if (ret) {
+		pr_err("PASR info sanity check failed (err %d)\n", ret);
+		return ret;
+	}
+
+	pasr_print_info(&pasr_info);
+
+	ret = pasr_build_map(&pasr_info, &pasr_map);
+	if (ret) {
+		pr_err("PASR build map failed (err %d)\n", ret);
+		return ret;
+	}
+
+	pasr_print_map(&pasr_map);
+
+	ret = pasr_init_core(&pasr_map);
+
+	pr_debug("PASR: First stage init done.\n");
+
+	return ret;
+}
+
+/*
+ * late_pasr_setup() has to be called after Linux allocator is
+ * initialized but before other CPUs are launched.
+ */
+int __init late_pasr_setup(void)
+{
+	int i, j;
+	struct pasr_section *s;
+
+	for_each_pasr_section(i, j, pasr_map, s) {
+		if (!s->lock) {
+			s->lock = kzalloc(sizeof(spinlock_t), GFP_KERNEL);
+			BUG_ON(!s->lock);
+			spin_lock_init(s->lock);
+			if (s->pair)
+				s->pair->lock = s->lock;
+		}
+	}
+
+	pr_debug("PASR Second stage init done.\n");
+
+	return 0;
+}
diff --git a/include/linux/pasr.h b/include/linux/pasr.h
new file mode 100644
index 0000000..93867f0
--- /dev/null
+++ b/include/linux/pasr.h
@@ -0,0 +1,73 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ * Author: Maxime Coquelin <maxime.coquelin@stericsson.com> for ST-Ericsson.
+ * License terms:  GNU General Public License (GPL), version 2
+ */
+#ifndef _LINUX_PASR_H
+#define _LINUX_PASR_H
+
+#include <linux/mm.h>
+#include <linux/spinlock.h>
+#include <mach/memory.h>
+
+#ifdef CONFIG_PASR
+
+/**
+ * struct pasr_section - Represent either a DDR Bank or Segment depending on
+ * the DDR configuration (Bank-Row-Column or Row-Bank-Coloumn)
+ *
+ * @start: Start address of the segment.
+ * @pair: Pointer on another segment in case of dependency (e.g. interleaving).
+ *	Masking of the dependant segments have to be done accordingly.
+ * @free_size: Represents the free memory size in the segment.
+ * @lock: Protect the free_size counter
+ * @die: Pointer to the Die the segment is part of.
+ */
+struct pasr_section {
+	phys_addr_t start;
+	struct pasr_section *pair;
+	unsigned long free_size;
+	spinlock_t *lock;
+	struct pasr_die *die;
+};
+
+/**
+ * struct pasr_die - Represent a DDR die
+ *
+ * @start: Start address of the die.
+ * @idx: Index of the die.
+ * @nr_sections: Number of Bank or Segment in the die.
+ * @section: Table of the die's segments.
+ * @mem_reg: Represents the PASR mask of the die. It is either MR16 or MR17,
+ *	depending on the addressing configuration (RBC or BRC).
+ * @apply_mask: Callback registred by the platform's PASR driver to apply the
+ *	calculated PASR mask.
+ * @cookie: Private data for the platform's PASR driver.
+ */
+struct pasr_die {
+	phys_addr_t start;
+	int idx;
+	int nr_sections;
+	struct pasr_section section[PASR_MAX_SECTION_NR_PER_DIE];
+};
+
+/**
+ * struct pasr_map - Represent the DDR physical map
+ *
+ * @nr_dies: Number of DDR dies.
+ * @die: Table of the dies.
+ */
+struct pasr_map {
+	int nr_dies;
+	struct pasr_die die[PASR_MAX_DIE_NR];
+};
+
+#define for_each_pasr_section(i, j, map, s) \
+        for (i = 0; i < map.nr_dies; i++) \
+                for (s = &map.die[i].section[0], j = 0; \
+                                j < map.die[i].nr_sections; \
+                                j++, s = &map.die[i].section[j])
+
+#endif /* CONFIG_PASR */
+
+#endif /* _LINUX_PASR_H */
-- 
1.7.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

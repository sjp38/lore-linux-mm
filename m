Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id D25886B0068
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:34:42 -0500 (EST)
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
Subject: [RFCv1 2/6] PASR: Add core Framework
Date: Mon, 30 Jan 2012 14:33:52 +0100
Message-ID: <1327930436-10263-3-git-send-email-maxime.coquelin@stericsson.com>
In-Reply-To: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Mel Gorman <mel@csn.ul.ie>, Ankita Garg <ankita@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, Maxime Coquelin <maxime.coquelin@stericsson.com>, linus.walleij@stericsson.com, andrea.gallo@stericsson.com, vincent.guittot@stericsson.com, philippe.langlais@stericsson.com, loic.pallardy@stericsson.com

This patch introduces the core of the PASR Framework, whose role is to update
sections counters and Self-Refresh masks when sections become free/used.

Signed-off-by: Maxime Coquelin <maxime.coquelin@stericsson.com>
---
 drivers/staging/pasr/Makefile |    3 +-
 drivers/staging/pasr/core.c   |  168 +++++++++++++++++++++++++++++++++++++++++
 include/linux/pasr.h          |   70 +++++++++++++++++
 3 files changed, 240 insertions(+), 1 deletions(-)
 create mode 100644 drivers/staging/pasr/core.c

diff --git a/drivers/staging/pasr/Makefile b/drivers/staging/pasr/Makefile
index 72f7c27..d172294 100644
--- a/drivers/staging/pasr/Makefile
+++ b/drivers/staging/pasr/Makefile
@@ -1,4 +1,5 @@
-pasr-objs := helper.o init.o
+pasr-objs := helper.o init.o core.o
+
 obj-$(CONFIG_PASR) += pasr.o
 
 ccflags-$(CONFIG_PASR_DEBUG) := -DDEBUG
diff --git a/drivers/staging/pasr/core.c b/drivers/staging/pasr/core.c
new file mode 100644
index 0000000..49bacb9
--- /dev/null
+++ b/drivers/staging/pasr/core.c
@@ -0,0 +1,168 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ * Author: Maxime Coquelin <maxime.coquelin@stericsson.com> for ST-Ericsson.
+ * License terms:  GNU General Public License (GPL), version 2
+ */
+
+#include <linux/mm.h>
+#include <linux/spinlock.h>
+#include <linux/pasr.h>
+
+#include "helper.h"
+
+enum pasr_state {
+	PASR_REFRESH,
+	PASR_NO_REFRESH,
+};
+
+struct pasr_fw {
+	struct pasr_map *map;
+};
+
+static struct pasr_fw pasr;
+
+void pasr_update_mask(struct pasr_section *section, enum pasr_state state)
+{
+	struct pasr_die *die = section->die;
+	phys_addr_t addr = section->start - die->start;
+	u8 bit = addr >> PASR_SECTION_SZ_BITS;
+
+	if (state == PASR_REFRESH)
+		die->mem_reg &= ~(1 << bit);
+	else
+		die->mem_reg |= (1 << bit);
+
+	pr_debug("%s(): %s refresh section 0x%08x. Die%d mem_reg = 0x%02x\n"
+			, __func__, state == PASR_REFRESH ? "Start" : "Stop"
+			, section->start, die->idx, die->mem_reg);
+
+	if (die->apply_mask)
+		die->apply_mask(&die->mem_reg, die->cookie);
+
+	return;
+}
+
+void pasr_put(phys_addr_t paddr, unsigned long size)
+{
+	struct pasr_section *s;
+	unsigned long cur_sz;
+	unsigned long flags;
+
+	if (!pasr.map) {
+		WARN_ONCE(1, KERN_INFO"%s(): Map not initialized.\n"
+			"\tCommand line parameters missing or incorrect\n"
+			, __func__);
+		goto out;
+	}
+
+	do {
+		s = pasr_addr2section(pasr.map, paddr);
+		if (!s)
+			goto out;
+
+		cur_sz = ((paddr + size) < (s->start + PASR_SECTION_SZ)) ?
+			size : s->start + PASR_SECTION_SZ - paddr;
+
+		if (s->lock)
+			spin_lock_irqsave(s->lock, flags);
+
+		s->free_size += cur_sz;
+		BUG_ON(s->free_size > PASR_SECTION_SZ);
+
+		if (s->free_size < PASR_SECTION_SZ)
+			goto unlock;
+
+		if (!s->pair)
+			pasr_update_mask(s, PASR_NO_REFRESH);
+		else if (s->pair->free_size == PASR_SECTION_SZ) {
+				pasr_update_mask(s, PASR_NO_REFRESH);
+				pasr_update_mask(s->pair, PASR_NO_REFRESH);
+		}
+unlock:
+		if (s->lock)
+			spin_unlock_irqrestore(s->lock, flags);
+
+		paddr += cur_sz;
+		size -= cur_sz;
+	} while (size);
+
+out:
+	return;
+}
+
+void pasr_get(phys_addr_t paddr, unsigned long size)
+{
+	unsigned long flags;
+	unsigned long cur_sz;
+	struct pasr_section *s;
+
+	if (!pasr.map) {
+		WARN_ONCE(1, KERN_INFO"%s(): Map not initialized.\n"
+			"\tCommand line parameters missing or incorrect\n"
+			, __func__);
+		return;
+	}
+
+	do {
+		s = pasr_addr2section(pasr.map, paddr);
+		if (!s)
+			goto out;
+
+		cur_sz = ((paddr + size) < (s->start + PASR_SECTION_SZ)) ?
+			size : s->start + PASR_SECTION_SZ - paddr;
+
+		if (s->lock)
+			spin_lock_irqsave(s->lock, flags);
+
+		if (s->free_size < PASR_SECTION_SZ)
+			goto unlock;
+
+		if (!s->pair)
+			pasr_update_mask(s, PASR_REFRESH);
+		else if (s->pair->free_size == PASR_SECTION_SZ) {
+				pasr_update_mask(s, PASR_REFRESH);
+				pasr_update_mask(s->pair, PASR_REFRESH);
+		}
+unlock:
+		BUG_ON(cur_sz > s->free_size);
+		s->free_size -= cur_sz;
+
+		if (s->lock)
+			spin_unlock_irqrestore(s->lock, flags);
+
+		paddr += cur_sz;
+		size -= cur_sz;
+	} while (size);
+
+out:
+	return;
+}
+
+int pasr_register_mask_function(phys_addr_t addr, void *function, void *cookie)
+{
+	struct pasr_die *die = pasr_addr2die(pasr.map, addr);
+
+	if (!die) {
+		pr_err("%s: No DDR die corresponding to address 0x%08x\n",
+				__func__, addr);
+		return -EINVAL;
+	}
+
+	if (addr != die->start)
+		pr_warning("%s: Addresses mismatch (Die = 0x%08x, addr = 0x%08x\n"
+				, __func__, die->start, addr);
+
+	die->cookie = cookie;
+	die->apply_mask = function;
+
+	die->apply_mask(&die->mem_reg, die->cookie);
+
+	return 0;
+}
+
+int __init pasr_init_core(struct pasr_map *map)
+{
+	pasr.map = map;
+	return 0;
+}
+
diff --git a/include/linux/pasr.h b/include/linux/pasr.h
index 93867f0..e85be73 100644
--- a/include/linux/pasr.h
+++ b/include/linux/pasr.h
@@ -49,6 +49,10 @@ struct pasr_die {
 	int idx;
 	int nr_sections;
 	struct pasr_section section[PASR_MAX_SECTION_NR_PER_DIE];
+	u16 mem_reg; /* Either MR16 or MR17 */
+
+	void (*apply_mask)(u16 *mem_reg, void *cookie);
+	void *cookie;
 };
 
 /**
@@ -68,6 +72,72 @@ struct pasr_map {
                                 j < map.die[i].nr_sections; \
                                 j++, s = &map.die[i].section[j])
 
+/**
+ * pasr_register_mask_function()
+ *
+ * @die_addr: Physical base address of the die.
+ * @function: Callback function for applying the DDR PASR mask.
+ * @cookie: Private data called with the callback function.
+ *
+ * This function is to be called by the platform specific PASR driver in
+ * charge of application of the PASR masks.
+ */
+int pasr_register_mask_function(phys_addr_t die_addr,
+		void *function, void *cookie);
+
+/**
+ * pasr_put()
+ *
+ * @paddr: Physical address of the freed memory chunk.
+ * @size: Size of the freed memory chunk.
+ *
+ * This function is to be placed in the allocators when memory chunks are
+ * inserted in the free memory pool.
+ * This function has only to be called for unused memory, otherwise retention
+ * cannot be guaranteed.
+ */
+void pasr_put(phys_addr_t paddr, unsigned long size);
+
+/**
+ * pasr_get()
+ *
+ * @paddr: Physical address of the allocated memory chunk.
+ * @size: Size of the allocated memory chunk.
+ *
+ * This function is to be placed in the allocators when memory chunks are
+ * removed from the free memory pool.
+ * If pasr_put() is used by the allocator, using this function is mandatory to
+ * guarantee retention.
+ */
+void pasr_get(phys_addr_t paddr, unsigned long size);
+
+
+static inline void pasr_kput(struct page *page, int order)
+{
+	if (order != MAX_ORDER - 1)
+		return;
+
+	pasr_put(page_to_phys(page), PAGE_SIZE << (MAX_ORDER - 1));
+}
+
+static inline void pasr_kget(struct page *page, int order)
+{
+	if (order != MAX_ORDER - 1)
+		return;
+
+	pasr_get(page_to_phys(page), PAGE_SIZE << (MAX_ORDER - 1));
+}
+
+int __init early_pasr_setup(void);
+int __init late_pasr_setup(void);
+int __init pasr_init_core(struct pasr_map *);
+
+#else
+#define pasr_kput(page, order) do {} while (0)
+#define pasr_kget(page, order) do {} while (0)
+
+#define pasr_put(paddr, size) do {} while (0)
+#define pasr_get(paddr, size) do {} while (0)
 #endif /* CONFIG_PASR */
 
 #endif /* _LINUX_PASR_H */
-- 
1.7.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

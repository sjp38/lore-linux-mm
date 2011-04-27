Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C5EBF6B0023
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:17:23 -0400 (EDT)
From: Stefan Assmann <sassmann@kpanic.de>
Subject: [RFC PATCH 2/3] support for broken memory modules (BadRAM)
Date: Wed, 27 Apr 2011 18:16:46 +0200
Message-Id: <1303921007-1769-3-git-send-email-sassmann@kpanic.de>
In-Reply-To: <1303921007-1769-1-git-send-email-sassmann@kpanic.de>
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com, sassmann@kpanic.de

BadRAM is a mechanism to exclude memory addresses (pages) from being used by
the system. The addresses are given to the kernel via kernel command line.
This is useful for systems with defective RAM modules, especially if the RAM
modules cannot be replaced.

command line parameter: badram=<addr>,<mask>[,...]

Patterns for the command line parameter can be obtained by running Memtest86.
In Memtest86 press "c" for configuration, select "Error Report Mode" and
finally "BadRAM Patterns"

This has already been done by Rick van Rein a long time ago but it never found
it's way into the kernel.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 mm/memory-failure.c |   95 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 95 insertions(+), 0 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 0207c2f..dac506c 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -52,6 +52,7 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/memory_hotplug.h>
+#include <linux/memblock.h>
 #include "internal.h"
 
 int sysctl_memory_failure_early_kill __read_mostly = 0;
@@ -1519,3 +1520,97 @@ int is_hwpoison_address(unsigned long addr)
 	return is_hwpoison_entry(entry);
 }
 EXPORT_SYMBOL_GPL(is_hwpoison_address);
+
+/*
+ * Return 0 if no address found else return 1, new address is stored in addrp.
+ **/
+static int __init next_masked_address(unsigned long *addrp, unsigned long mask)
+{
+	unsigned long total_mem = (max_pfn + 1) << PAGE_SHIFT;
+	unsigned long tmp_addr = *addrp;
+	unsigned long inc = 1;
+
+	while (inc & mask)
+		inc = inc << 1;
+
+	while (inc != 0) {
+		tmp_addr += inc;
+		tmp_addr &= ~mask;
+		tmp_addr |= ((*addrp) & mask);
+
+		/* address is bigger than phys memory */
+		if (tmp_addr >= total_mem)
+			return 0;
+
+		/* address found */
+		if (tmp_addr > *addrp) {
+			*addrp = tmp_addr;
+			return 1;
+		}
+
+		while (inc & ~mask)
+			inc = inc << 1;
+		inc = inc << 1;
+	}
+
+	return 0;
+}
+
+/*
+ * Set hwpoison pageflag on all pages specified by addr/mask.
+ */
+static int __init badram_mark_pages(unsigned long addr, unsigned long mask)
+{
+	unsigned long pagecount = 0;
+
+	mask |= ~PAGE_MASK; /* smallest chunk is a page */
+	addr &= mask;
+
+	printk(KERN_INFO "BadRAM: mark 0x%lx with mask 0x%0lx\n", addr, mask);
+
+	do {
+		unsigned long pfn = addr >> PAGE_SHIFT;
+		struct page *page = pfn_to_page(pfn);
+
+		if (!pfn_valid(pfn))
+			continue;
+		if (memblock_is_reserved(addr)) {
+			printk(KERN_DEBUG
+			       "BadRAM: page %lu reserved by kernel\n", pfn);
+			continue;
+		}
+
+		SetPageHWPoison(page);
+		atomic_long_add(1, &mce_bad_pages);
+		pagecount++;
+		pr_debug("BadRAM: page %lu (addr 0x%0lx) marked bad "
+			 "[total %lu]\n", pfn, addr, pagecount);
+	} while (next_masked_address(&addr, mask));
+
+	return pagecount;
+}
+
+static int __init badram_setup(char *str)
+{
+	printk(KERN_DEBUG "BadRAM: cmdline option is %s\n", str);
+
+	if (*str++ != '=')
+		return 0;
+
+	while (*str) {
+		unsigned long addr = 0, mask = 0, pagecount = 0;
+
+		if (!get_next_ulong(&str, &addr, ',', 16)) {
+			printk(KERN_WARNING "BadRAM: parsing error\n");
+			return 0;
+		}
+		if (!get_next_ulong(&str, &mask, ',', 16))
+			mask = ~(0UL);
+
+		pagecount = badram_mark_pages(addr, mask);
+		printk(KERN_INFO "BadRAM: %lu page(s) bad\n", pagecount);
+	}
+
+	return 0;
+}
+__setup("badram", badram_setup);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

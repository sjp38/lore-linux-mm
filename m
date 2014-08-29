Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0472A6B003D
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:10:35 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so2536061qac.19
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:35 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id v6si1419659qaf.35.2014.08.29.12.10.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 12:10:35 -0700 (PDT)
Received: by mail-qg0-f45.google.com with SMTP id e89so2681602qgf.4
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:35 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [RFC PATCH 4/6] hmm/dummy: dummy driver to showcase the hmm api v2
Date: Fri, 29 Aug 2014 15:10:13 -0400
Message-Id: <1409339415-3626-5-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
References: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Haggai Eran <haggaie@mellanox.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This is a dummy driver which full fill two purposes :
  - showcase the hmm api and gives references on how to use it.
  - provide an extensive user space api to stress test hmm.

This is a particularly dangerous module as it allow to access a
mirror of a process address space through its device file. Hence
it should not be enabled by default and only people actively
developing for hmm should use it.

Changed since v1:
  - Fixed all checkpatch.pl issue (ignoreing some over 80 characters).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/char/Kconfig           |    9 +
 drivers/char/Makefile          |    1 +
 drivers/char/hmm_dummy.c       | 1149 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/hmm_dummy.h |   30 ++
 4 files changed, 1189 insertions(+)
 create mode 100644 drivers/char/hmm_dummy.c
 create mode 100644 include/uapi/linux/hmm_dummy.h

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index 6e9f74a..199e111 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -600,5 +600,14 @@ config TILE_SROM
 	  device appear much like a simple EEPROM, and knows
 	  how to partition a single ROM for multiple purposes.
 
+config HMM_DUMMY
+	tristate "hmm dummy driver to test hmm."
+	depends on HMM
+	default n
+	help
+	  Say Y here if you want to build the hmm dummy driver that allow you
+	  to test the hmm infrastructure by mapping a process address space
+	  in hmm dummy driver device file. When in doubt, say "N".
+
 endmenu
 
diff --git a/drivers/char/Makefile b/drivers/char/Makefile
index a324f93..83d89b8 100644
--- a/drivers/char/Makefile
+++ b/drivers/char/Makefile
@@ -61,3 +61,4 @@ obj-$(CONFIG_JS_RTC)		+= js-rtc.o
 js-rtc-y = rtc.o
 
 obj-$(CONFIG_TILE_SROM)		+= tile-srom.o
+obj-$(CONFIG_HMM_DUMMY)		+= hmm_dummy.o
diff --git a/drivers/char/hmm_dummy.c b/drivers/char/hmm_dummy.c
new file mode 100644
index 0000000..ae3a048
--- /dev/null
+++ b/drivers/char/hmm_dummy.c
@@ -0,0 +1,1149 @@
+/*
+ * Copyright 2013 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/* This is a dummy driver made to exercice the HMM (hardware memory management)
+ * API of the kernel. It allow an userspace program to map its whole address
+ * space through the hmm dummy driver file.
+ *
+ * In here mirror address are address in the process address space that is
+ * being mirrored. While virtual address are the address in the current
+ * process that has the hmm dummy dev file mapped (address of the file
+ * mapping).
+ *
+ * You must be carefull to not mix one and another.
+ */
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/major.h>
+#include <linux/cdev.h>
+#include <linux/device.h>
+#include <linux/mutex.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/highmem.h>
+#include <linux/delay.h>
+#include <linux/hmm.h>
+
+#include <uapi/linux/hmm_dummy.h>
+
+#define HMM_DUMMY_DEVICE_NAME	"hmm_dummy_device"
+#define HMM_DUMMY_MAX_DEVICES	4
+
+struct hmm_dummy_device;
+
+struct hmm_dummy_mirror {
+	struct kref		kref;
+	struct file		*filp;
+	struct hmm_dummy_device	*ddevice;
+	struct hmm_mirror	mirror;
+	unsigned		minor;
+	pid_t			pid;
+	struct mm_struct	*mm;
+	unsigned long		*pgdp;
+	struct mutex		mutex;
+	bool			stop;
+};
+
+struct hmm_dummy_device {
+	struct cdev		cdev;
+	struct hmm_device	device;
+	dev_t			dev;
+	int			major;
+	struct mutex		mutex;
+	char			name[32];
+	/* device file mapping tracking (keep track of all vma) */
+	struct hmm_dummy_mirror	*dmirrors[HMM_DUMMY_MAX_DEVICES];
+	struct address_space	*fmapping[HMM_DUMMY_MAX_DEVICES];
+};
+
+/* We only create 2 device to show the inter device rmem sharing/migration
+ * capabilities.
+ */
+static struct hmm_dummy_device ddevices[2];
+
+
+/* hmm_dummy_pt - dummy page table, the dummy device fake its own page table.
+ *
+ * Helper function to manage the dummy device page table.
+ */
+#define HMM_DUMMY_PTE_VALID		(1UL << 0UL)
+#define HMM_DUMMY_PTE_READ		(1UL << 1UL)
+#define HMM_DUMMY_PTE_WRITE		(1UL << 2UL)
+#define HMM_DUMMY_PTE_DIRTY		(1UL << 3UL)
+#define HMM_DUMMY_PFN_SHIFT		(PAGE_SHIFT)
+
+#define ARCH_PAGE_SIZE			((unsigned long)PAGE_SIZE)
+#define ARCH_PAGE_SHIFT			((unsigned long)PAGE_SHIFT)
+
+#define HMM_DUMMY_PTRS_PER_LEVEL	(ARCH_PAGE_SIZE / sizeof(long))
+#ifdef CONFIG_64BIT
+#define HMM_DUMMY_BITS_PER_LEVEL	(ARCH_PAGE_SHIFT - 3UL)
+#else
+#define HMM_DUMMY_BITS_PER_LEVEL	(ARCH_PAGE_SHIFT - 2UL)
+#endif
+#define HMM_DUMMY_PLD_SHIFT		(ARCH_PAGE_SHIFT)
+#define HMM_DUMMY_PMD_SHIFT		(HMM_DUMMY_PLD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL)
+#define HMM_DUMMY_PUD_SHIFT		(HMM_DUMMY_PMD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL)
+#define HMM_DUMMY_PGD_SHIFT		(HMM_DUMMY_PUD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL)
+#define HMM_DUMMY_PGD_NPTRS		(1UL << HMM_DUMMY_BITS_PER_LEVEL)
+#define HMM_DUMMY_PMD_NPTRS		(1UL << HMM_DUMMY_BITS_PER_LEVEL)
+#define HMM_DUMMY_PUD_NPTRS		(1UL << HMM_DUMMY_BITS_PER_LEVEL)
+#define HMM_DUMMY_PLD_NPTRS		(1UL << HMM_DUMMY_BITS_PER_LEVEL)
+#define HMM_DUMMY_PLD_SIZE		(1UL << (HMM_DUMMY_PLD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL))
+#define HMM_DUMMY_PMD_SIZE		(1UL << (HMM_DUMMY_PMD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL))
+#define HMM_DUMMY_PUD_SIZE		(1UL << (HMM_DUMMY_PUD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL))
+#define HMM_DUMMY_PGD_SIZE		(1UL << (HMM_DUMMY_PGD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL))
+#define HMM_DUMMY_PLD_MASK		(~(HMM_DUMMY_PLD_SIZE - 1UL))
+#define HMM_DUMMY_PMD_MASK		(~(HMM_DUMMY_PMD_SIZE - 1UL))
+#define HMM_DUMMY_PUD_MASK		(~(HMM_DUMMY_PUD_SIZE - 1UL))
+#define HMM_DUMMY_PGD_MASK		(~(HMM_DUMMY_PGD_SIZE - 1UL))
+#define HMM_DUMMY_MAX_ADDR		(1UL << (HMM_DUMMY_PGD_SHIFT + HMM_DUMMY_BITS_PER_LEVEL))
+
+static inline unsigned long hmm_dummy_pld_index(unsigned long addr)
+{
+	return (addr >> HMM_DUMMY_PLD_SHIFT) & (HMM_DUMMY_PLD_NPTRS - 1UL);
+}
+
+static inline unsigned long hmm_dummy_pmd_index(unsigned long addr)
+{
+	return (addr >> HMM_DUMMY_PMD_SHIFT) & (HMM_DUMMY_PMD_NPTRS - 1UL);
+}
+
+static inline unsigned long hmm_dummy_pud_index(unsigned long addr)
+{
+	return (addr >> HMM_DUMMY_PUD_SHIFT) & (HMM_DUMMY_PUD_NPTRS - 1UL);
+}
+
+static inline unsigned long hmm_dummy_pgd_index(unsigned long addr)
+{
+	return (addr >> HMM_DUMMY_PGD_SHIFT) & (HMM_DUMMY_PGD_NPTRS - 1UL);
+}
+
+static inline unsigned long hmm_dummy_pld_base(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PLD_MASK);
+}
+
+static inline unsigned long hmm_dummy_pmd_base(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PMD_MASK);
+}
+
+static inline unsigned long hmm_dummy_pud_base(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PUD_MASK);
+}
+
+static inline unsigned long hmm_dummy_pgd_base(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PGD_MASK);
+}
+
+static inline unsigned long hmm_dummy_pld_next(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PLD_MASK) + HMM_DUMMY_PLD_SIZE;
+}
+
+static inline unsigned long hmm_dummy_pmd_next(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PMD_MASK) + HMM_DUMMY_PMD_SIZE;
+}
+
+static inline unsigned long hmm_dummy_pud_next(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PUD_MASK) + HMM_DUMMY_PUD_SIZE;
+}
+
+static inline unsigned long hmm_dummy_pgd_next(unsigned long addr)
+{
+	return (addr & HMM_DUMMY_PGD_MASK) + HMM_DUMMY_PGD_SIZE;
+}
+
+static inline struct page *hmm_dummy_pte_to_page(unsigned long pte)
+{
+	if (!(pte & HMM_DUMMY_PTE_VALID))
+		return NULL;
+	return pfn_to_page((pte >> HMM_DUMMY_PFN_SHIFT));
+}
+
+struct hmm_dummy_pt_map {
+	struct hmm_dummy_mirror	*dmirror;
+	struct page		*pud_page;
+	struct page		*pmd_page;
+	struct page		*pld_page;
+	unsigned long		pgd_idx;
+	unsigned long		pud_idx;
+	unsigned long		pmd_idx;
+	unsigned long		*pudp;
+	unsigned long		*pmdp;
+	unsigned long		*pldp;
+};
+
+static inline unsigned long *hmm_dummy_pt_pud_map(struct hmm_dummy_pt_map *pt_map,
+						  unsigned long addr)
+{
+	struct hmm_dummy_mirror *dmirror = pt_map->dmirror;
+	unsigned long *pdep;
+
+	if (!dmirror->pgdp)
+		return NULL;
+
+	if (!pt_map->pud_page || pt_map->pgd_idx != hmm_dummy_pgd_index(addr)) {
+		if (pt_map->pud_page) {
+			kunmap(pt_map->pud_page);
+			pt_map->pud_page = NULL;
+			pt_map->pudp = NULL;
+		}
+		pt_map->pgd_idx = hmm_dummy_pgd_index(addr);
+		pdep = &dmirror->pgdp[pt_map->pgd_idx];
+		if (!((*pdep) & HMM_DUMMY_PTE_VALID))
+			return NULL;
+		pt_map->pud_page = pfn_to_page((*pdep) >> HMM_DUMMY_PFN_SHIFT);
+		pt_map->pudp = kmap(pt_map->pud_page);
+	}
+	return pt_map->pudp;
+}
+
+static inline unsigned long *hmm_dummy_pt_pmd_map(struct hmm_dummy_pt_map *pt_map,
+						  unsigned long addr)
+{
+	unsigned long *pdep;
+
+	if (!hmm_dummy_pt_pud_map(pt_map, addr))
+		return NULL;
+
+	if (!pt_map->pmd_page || pt_map->pud_idx != hmm_dummy_pud_index(addr)) {
+		if (pt_map->pmd_page) {
+			kunmap(pt_map->pmd_page);
+			pt_map->pmd_page = NULL;
+			pt_map->pmdp = NULL;
+		}
+		pt_map->pud_idx = hmm_dummy_pud_index(addr);
+		pdep = &pt_map->pudp[pt_map->pud_idx];
+		if (!((*pdep) & HMM_DUMMY_PTE_VALID))
+			return NULL;
+		pt_map->pmd_page = pfn_to_page((*pdep) >> HMM_DUMMY_PFN_SHIFT);
+		pt_map->pmdp = kmap(pt_map->pmd_page);
+	}
+	return pt_map->pmdp;
+}
+
+static inline unsigned long *hmm_dummy_pt_pld_map(struct hmm_dummy_pt_map *pt_map,
+						  unsigned long addr)
+{
+	unsigned long *pdep;
+
+	if (!hmm_dummy_pt_pmd_map(pt_map, addr))
+		return NULL;
+
+	if (!pt_map->pld_page || pt_map->pmd_idx != hmm_dummy_pmd_index(addr)) {
+		if (pt_map->pld_page) {
+			kunmap(pt_map->pld_page);
+			pt_map->pld_page = NULL;
+			pt_map->pldp = NULL;
+		}
+		pt_map->pmd_idx = hmm_dummy_pmd_index(addr);
+		pdep = &pt_map->pmdp[pt_map->pmd_idx];
+		if (!((*pdep) & HMM_DUMMY_PTE_VALID))
+			return NULL;
+		pt_map->pld_page = pfn_to_page((*pdep) >> HMM_DUMMY_PFN_SHIFT);
+		pt_map->pldp = kmap(pt_map->pld_page);
+	}
+	return pt_map->pldp;
+}
+
+static inline void hmm_dummy_pt_pld_unmap(struct hmm_dummy_pt_map *pt_map)
+{
+	if (pt_map->pld_page) {
+		kunmap(pt_map->pld_page);
+		pt_map->pld_page = NULL;
+		pt_map->pldp = NULL;
+	}
+}
+
+static inline void hmm_dummy_pt_pmd_unmap(struct hmm_dummy_pt_map *pt_map)
+{
+	hmm_dummy_pt_pld_unmap(pt_map);
+	if (pt_map->pmd_page) {
+		kunmap(pt_map->pmd_page);
+		pt_map->pmd_page = NULL;
+		pt_map->pmdp = NULL;
+	}
+}
+
+static inline void hmm_dummy_pt_pud_unmap(struct hmm_dummy_pt_map *pt_map)
+{
+	hmm_dummy_pt_pmd_unmap(pt_map);
+	if (pt_map->pud_page) {
+		kunmap(pt_map->pud_page);
+		pt_map->pud_page = NULL;
+		pt_map->pudp = NULL;
+	}
+}
+
+static inline void hmm_dummy_pt_unmap(struct hmm_dummy_pt_map *pt_map)
+{
+	hmm_dummy_pt_pud_unmap(pt_map);
+}
+
+static int hmm_dummy_pt_alloc(struct hmm_dummy_mirror *dmirror,
+			      unsigned long start,
+			      unsigned long end)
+{
+	unsigned long *pgdp, *pudp, *pmdp;
+
+	if (dmirror->stop)
+		return -EINVAL;
+
+	if (dmirror->pgdp == NULL) {
+		dmirror->pgdp = kzalloc(PAGE_SIZE, GFP_KERNEL);
+		if (dmirror->pgdp == NULL)
+			return -ENOMEM;
+	}
+
+	for (; start < end; start = hmm_dummy_pld_next(start)) {
+		struct page *pud_page, *pmd_page;
+
+		pgdp = &dmirror->pgdp[hmm_dummy_pgd_index(start)];
+		if (!((*pgdp) & HMM_DUMMY_PTE_VALID)) {
+			pud_page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+			if (!pud_page)
+				return -ENOMEM;
+			*pgdp  = (page_to_pfn(pud_page)<<HMM_DUMMY_PFN_SHIFT);
+			*pgdp |= HMM_DUMMY_PTE_VALID;
+		}
+
+		pud_page = pfn_to_page((*pgdp) >> HMM_DUMMY_PFN_SHIFT);
+		pudp = kmap(pud_page);
+		pudp = &pudp[hmm_dummy_pud_index(start)];
+		if (!((*pudp) & HMM_DUMMY_PTE_VALID)) {
+			pmd_page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+			if (!pmd_page) {
+				kunmap(pud_page);
+				return -ENOMEM;
+			}
+			*pudp  = (page_to_pfn(pmd_page)<<HMM_DUMMY_PFN_SHIFT);
+			*pudp |= HMM_DUMMY_PTE_VALID;
+		}
+
+		pmd_page = pfn_to_page((*pudp) >> HMM_DUMMY_PFN_SHIFT);
+		pmdp = kmap(pmd_page);
+		pmdp = &pmdp[hmm_dummy_pmd_index(start)];
+		if (!((*pmdp) & HMM_DUMMY_PTE_VALID)) {
+			struct page *page;
+
+			page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+			if (!page) {
+				kunmap(pmd_page);
+				kunmap(pud_page);
+				return -ENOMEM;
+			}
+			*pmdp  = (page_to_pfn(page) << HMM_DUMMY_PFN_SHIFT);
+			*pmdp |= HMM_DUMMY_PTE_VALID;
+		}
+
+		kunmap(pmd_page);
+		kunmap(pud_page);
+	}
+
+	return 0;
+}
+
+static void hmm_dummy_pt_free_pmd(struct hmm_dummy_pt_map *pt_map,
+				  unsigned long start,
+				  unsigned long end)
+{
+	for (; start < end; start = hmm_dummy_pld_next(start)) {
+		unsigned long pfn, *pmdp, next;
+		struct page *page;
+
+		next = min(hmm_dummy_pld_next(start), end);
+		if (start > hmm_dummy_pld_base(start) || end < next)
+			continue;
+		pmdp = hmm_dummy_pt_pmd_map(pt_map, start);
+		if (!pmdp)
+			continue;
+		if (!(pmdp[hmm_dummy_pmd_index(start)] & HMM_DUMMY_PTE_VALID))
+			continue;
+		pfn = pmdp[hmm_dummy_pmd_index(start)] >> HMM_DUMMY_PFN_SHIFT;
+		page = pfn_to_page(pfn);
+		pmdp[hmm_dummy_pmd_index(start)] = 0;
+		__free_page(page);
+	}
+}
+
+static void hmm_dummy_pt_free_pud(struct hmm_dummy_pt_map *pt_map,
+				  unsigned long start,
+				  unsigned long end)
+{
+	for (; start < end; start = hmm_dummy_pmd_next(start)) {
+		unsigned long pfn, *pudp, next;
+		struct page *page;
+
+		next = min(hmm_dummy_pmd_next(start), end);
+		hmm_dummy_pt_free_pmd(pt_map, start, next);
+		hmm_dummy_pt_pmd_unmap(pt_map);
+		if (start > hmm_dummy_pmd_base(start) || end < next)
+			continue;
+		pudp = hmm_dummy_pt_pud_map(pt_map, start);
+		if (!pudp)
+			continue;
+		if (!(pudp[hmm_dummy_pud_index(start)] & HMM_DUMMY_PTE_VALID))
+			continue;
+		pfn = pudp[hmm_dummy_pud_index(start)] >> HMM_DUMMY_PFN_SHIFT;
+		page = pfn_to_page(pfn);
+		pudp[hmm_dummy_pud_index(start)] = 0;
+		__free_page(page);
+	}
+}
+
+static void hmm_dummy_pt_free(struct hmm_dummy_mirror *dmirror,
+			      unsigned long start,
+			      unsigned long end)
+{
+	struct hmm_dummy_pt_map pt_map = {0};
+
+	if (!dmirror->pgdp || (end - start) < HMM_DUMMY_PLD_SIZE)
+		return;
+
+	pt_map.dmirror = dmirror;
+
+	for (; start < end; start = hmm_dummy_pud_next(start)) {
+		unsigned long pfn, *pgdp, next;
+		struct page *page;
+
+		next = min(hmm_dummy_pud_next(start), end);
+		pgdp = dmirror->pgdp;
+		hmm_dummy_pt_free_pud(&pt_map, start, next);
+		hmm_dummy_pt_pud_unmap(&pt_map);
+		if (start > hmm_dummy_pud_base(start) || end < next)
+			continue;
+		if (!(pgdp[hmm_dummy_pgd_index(start)] & HMM_DUMMY_PTE_VALID))
+			continue;
+		pfn = pgdp[hmm_dummy_pgd_index(start)] >> HMM_DUMMY_PFN_SHIFT;
+		page = pfn_to_page(pfn);
+		pgdp[hmm_dummy_pgd_index(start)] = 0;
+		__free_page(page);
+	}
+	hmm_dummy_pt_unmap(&pt_map);
+}
+
+
+
+
+/* hmm_ops - hmm callback for the hmm dummy driver.
+ *
+ * Below are the various callback that the hmm api require for a device. The
+ * implementation of the dummy device driver is necessarily simpler that what
+ * a real device driver would do. We do not have interrupt nor any kind of
+ * command buffer on to which schedule memory invalidation and updates.
+ */
+static struct hmm_mirror *hmm_dummy_mirror_ref(struct hmm_mirror *mirror)
+{
+	struct hmm_dummy_mirror *dmirror;
+
+	if (!mirror)
+		return NULL;
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	if (!kref_get_unless_zero(&dmirror->kref))
+		return NULL;
+	return mirror;
+}
+
+static void hmm_dummy_mirror_destroy(struct kref *kref)
+{
+	struct hmm_dummy_mirror *dmirror;
+
+	dmirror = container_of(kref, struct hmm_dummy_mirror, kref);
+	mutex_lock(&dmirror->ddevice->mutex);
+	dmirror->ddevice->dmirrors[dmirror->minor] = NULL;
+	mutex_unlock(&dmirror->ddevice->mutex);
+
+	hmm_mirror_unregister(&dmirror->mirror);
+
+	kfree(dmirror);
+}
+
+static struct hmm_mirror *hmm_dummy_mirror_unref(struct hmm_mirror *mirror)
+{
+	struct hmm_dummy_mirror *dmirror;
+
+	if (!mirror)
+		return NULL;
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	kref_put(&dmirror->kref, hmm_dummy_mirror_destroy);
+	return NULL;
+}
+
+static void hmm_dummy_mirror_release(struct hmm_mirror *mirror)
+{
+	struct hmm_dummy_mirror *dmirror;
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	dmirror->stop = true;
+	mutex_lock(&dmirror->mutex);
+	hmm_dummy_pt_free(dmirror, 0, HMM_DUMMY_MAX_ADDR);
+	kfree(dmirror->pgdp);
+	dmirror->pgdp = NULL;
+	mutex_unlock(&dmirror->mutex);
+}
+
+static int hmm_dummy_fence_wait(struct hmm_fence *fence)
+{
+	/* FIXME add fake fence to showcase api */
+	return 0;
+}
+
+static void hmm_dummy_fence_ref(struct hmm_fence *fence)
+{
+	/* We never allocate fence so how could we end up here ? */
+	BUG();
+}
+
+static void hmm_dummy_fence_unref(struct hmm_fence *fence)
+{
+	/* We never allocate fence so how could we end up here ? */
+	BUG();
+}
+
+static int hmm_dummy_fault(struct hmm_mirror *mirror,
+			   struct hmm_event *event,
+			   const struct hmm_range *range)
+{
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_pt_map pt_map = {0};
+	unsigned long addr, i;
+	int ret = 0;
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	pt_map.dmirror = dmirror;
+
+	mutex_lock(&dmirror->mutex);
+	for (i = 0, addr = range->start; addr < range->end; ++i, addr += PAGE_SIZE) {
+		unsigned long *pldp, pld_idx;
+		struct page *page;
+		bool write;
+
+		pldp = hmm_dummy_pt_pld_map(&pt_map, addr);
+		if (!pldp) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		if (!hmm_pte_is_valid_smem(&range->pte[i])) {
+			ret = -ENOENT;
+			break;
+		}
+		write = hmm_pte_is_write(&range->pte[i]);
+		page = pfn_to_page(hmm_pte_pfn(range->pte[i]));
+		if (event->etype == HMM_WFAULT && !write) {
+			ret = -EACCES;
+			break;
+		}
+
+		pr_info("%16s %4d [0x%016lx] pfn 0x%016lx write %d\n",
+			__func__, __LINE__, addr, page_to_pfn(page), write);
+		pld_idx = hmm_dummy_pld_index(addr);
+		pldp[pld_idx]  = (page_to_pfn(page) << HMM_DUMMY_PFN_SHIFT);
+		pldp[pld_idx] |= write ? HMM_DUMMY_PTE_WRITE : 0;
+		pldp[pld_idx] |= HMM_DUMMY_PTE_VALID | HMM_DUMMY_PTE_READ;
+	}
+	hmm_dummy_pt_unmap(&pt_map);
+	mutex_unlock(&dmirror->mutex);
+	return ret;
+}
+
+static struct hmm_fence *hmm_dummy_update(struct hmm_mirror *mirror,
+					  struct hmm_event *event,
+					  const struct hmm_range *range)
+{
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_pt_map pt_map = {0};
+	unsigned long addr, i, mask;
+	int ret;
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	pt_map.dmirror = dmirror;
+
+	/* Debugging hmm real device driver do not have to do that. */
+	switch (event->etype) {
+	case HMM_MIGRATE:
+	case HMM_MUNMAP:
+		mask = 0;
+		break;
+	case HMM_ISDIRTY:
+		mask = -1UL;
+		break;
+	case HMM_WRITE_PROTECT:
+		mask = ~HMM_DUMMY_PTE_WRITE;
+		break;
+	case HMM_RFAULT:
+	case HMM_WFAULT:
+		ret = hmm_dummy_fault(mirror, event, range);
+		if (ret)
+			return ERR_PTR(ret);
+		return NULL;
+	default:
+		return ERR_PTR(-EIO);
+	}
+
+	mutex_lock(&dmirror->mutex);
+	for (i = 0, addr = range->start; addr < range->end; ++i, addr += PAGE_SIZE) {
+		unsigned long *pldp;
+
+		pldp = hmm_dummy_pt_pld_map(&pt_map, addr);
+		if (!pldp)
+			continue;
+		if (((*pldp) & HMM_DUMMY_PTE_DIRTY)) {
+			hmm_pte_mk_dirty(&range->pte[i]);
+		}
+		*pldp &= ~HMM_DUMMY_PTE_DIRTY;
+		*pldp &= mask;
+	}
+	hmm_dummy_pt_unmap(&pt_map);
+
+	if (event->etype == HMM_MUNMAP)
+		hmm_dummy_pt_free(dmirror, range->start, range->end);
+	mutex_unlock(&dmirror->mutex);
+	return NULL;
+}
+
+static const struct hmm_device_ops hmm_dummy_ops = {
+	.mirror_ref		= &hmm_dummy_mirror_ref,
+	.mirror_unref		= &hmm_dummy_mirror_unref,
+	.mirror_release		= &hmm_dummy_mirror_release,
+	.fence_wait		= &hmm_dummy_fence_wait,
+	.fence_ref		= &hmm_dummy_fence_ref,
+	.fence_unref		= &hmm_dummy_fence_unref,
+	.update			= &hmm_dummy_update,
+};
+
+
+/* hmm_dummy_mmap - hmm dummy device file mmap operations.
+ *
+ * The hmm dummy driver does not allow mmap of its device file. The main reason
+ * is because the kernel lack the ability to insert page with specific custom
+ * protections inside a vma.
+ */
+static int hmm_dummy_mmap_fault(struct vm_area_struct *vma,
+				struct vm_fault *vmf)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+static void hmm_dummy_mmap_open(struct vm_area_struct *vma)
+{
+	/* nop */
+}
+
+static void hmm_dummy_mmap_close(struct vm_area_struct *vma)
+{
+	/* nop */
+}
+
+static const struct vm_operations_struct mmap_mem_ops = {
+	.fault			= hmm_dummy_mmap_fault,
+	.open			= hmm_dummy_mmap_open,
+	.close			= hmm_dummy_mmap_close,
+};
+
+
+/* hmm_dummy_fops - hmm dummy device file operations.
+ *
+ * The hmm dummy driver allow to read/write to the mirrored process through
+ * the device file. Below are the read and write and others device file
+ * callback that implement access to the mirrored address space.
+ */
+#define DUMMY_WINDOW		4
+
+static int hmm_dummy_mirror_fault(struct hmm_dummy_mirror *dmirror,
+				  unsigned long addr,
+				  bool write)
+{
+	struct hmm_mirror *mirror = &dmirror->mirror;
+	struct hmm_event event;
+	unsigned long start, end;
+	int ret;
+
+	event.start = start = addr > ((DUMMY_WINDOW >> 1) << PAGE_SHIFT) ?
+			      addr - ((DUMMY_WINDOW >> 1) << PAGE_SHIFT) : 0;
+	event.end = end = start + (DUMMY_WINDOW << PAGE_SHIFT);
+	event.etype = write ? HMM_WFAULT : HMM_RFAULT;
+
+	/* Pre-allocate device page table. */
+	mutex_lock(&dmirror->mutex);
+	ret = hmm_dummy_pt_alloc(dmirror, start, end);
+	mutex_unlock(&dmirror->mutex);
+	if (ret)
+		return ret;
+
+	while (1) {
+		ret = hmm_mirror_fault(mirror, &event);
+		/* Ignore any error that do not concern the fault address. */
+		if (addr >= event.end) {
+			event.start = event.end;
+			event.end = end;
+			continue;
+		}
+		break;
+	}
+
+	return ret;
+}
+
+static ssize_t hmm_dummy_fops_read(struct file *filp,
+				   char __user *buf,
+				   size_t count,
+				   loff_t *ppos)
+{
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_pt_map pt_map = {0};
+	struct hmm_mirror *mirror;
+	unsigned long start, end, offset;
+	unsigned minor;
+	ssize_t retval = 0;
+	void *tmp;
+	long r;
+
+	tmp = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
+
+	/* Check if we are mirroring anything */
+	minor = iminor(file_inode(filp));
+	ddevice = filp->private_data;
+	mutex_lock(&ddevice->mutex);
+	if (ddevice->dmirrors[minor] == NULL) {
+		mutex_unlock(&ddevice->mutex);
+		kfree(tmp);
+		return 0;
+	}
+	mirror = hmm_mirror_ref(&ddevice->dmirrors[minor]->mirror);
+	mutex_unlock(&ddevice->mutex);
+
+	if (!mirror) {
+		kfree(tmp);
+		return 0;
+	}
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	if (dmirror->stop) {
+		kfree(tmp);
+		hmm_mirror_unref(mirror);
+		return 0;
+	}
+
+	/* The range of address to lookup. */
+	start = (*ppos) & PAGE_MASK;
+	offset = (*ppos) - start;
+	end = PAGE_ALIGN(start + count);
+	BUG_ON(start == end);
+	pt_map.dmirror = dmirror;
+
+	for (; count; start += PAGE_SIZE, offset = 0) {
+		unsigned long *pldp, pld_idx;
+		unsigned long size = min(PAGE_SIZE - offset, count);
+		struct page *page;
+		char *ptr;
+
+		mutex_lock(&dmirror->mutex);
+		pldp = hmm_dummy_pt_pld_map(&pt_map, start);
+		pld_idx = hmm_dummy_pld_index(start);
+		if (!pldp || !(pldp[pld_idx] & HMM_DUMMY_PTE_VALID)) {
+			hmm_dummy_pt_unmap(&pt_map);
+			mutex_unlock(&dmirror->mutex);
+			goto fault;
+		}
+		page = hmm_dummy_pte_to_page(pldp[pld_idx]);
+		if (!page) {
+			mutex_unlock(&dmirror->mutex);
+			BUG();
+			kfree(tmp);
+			hmm_mirror_unref(mirror);
+			return -EFAULT;
+		}
+		ptr = kmap(page);
+		memcpy(tmp, ptr + offset, size);
+		kunmap(page);
+		hmm_dummy_pt_unmap(&pt_map);
+		mutex_unlock(&dmirror->mutex);
+
+		r = copy_to_user(buf, tmp, size);
+		if (r) {
+			kfree(tmp);
+			hmm_mirror_unref(mirror);
+			return -EFAULT;
+		}
+		retval += size;
+		*ppos += size;
+		count -= size;
+		buf += size;
+	}
+
+	kfree(tmp);
+	hmm_mirror_unref(mirror);
+	return retval;
+
+fault:
+	kfree(tmp);
+	r = hmm_dummy_mirror_fault(dmirror, start, false);
+	hmm_mirror_unref(mirror);
+	if (r)
+		return r;
+
+	/* Force userspace to retry read if nothing was read. */
+	return retval ? retval : -EINTR;
+}
+
+static ssize_t hmm_dummy_fops_write(struct file *filp,
+				    const char __user *buf,
+				    size_t count,
+				    loff_t *ppos)
+{
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_pt_map pt_map = {0};
+	struct hmm_mirror *mirror;
+	unsigned long start, end, offset;
+	unsigned minor;
+	ssize_t retval = 0;
+	void *tmp;
+	long r;
+
+	tmp = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
+
+	/* Check if we are mirroring anything */
+	minor = iminor(file_inode(filp));
+	ddevice = filp->private_data;
+	mutex_lock(&ddevice->mutex);
+	if (ddevice->dmirrors[minor] == NULL) {
+		mutex_unlock(&ddevice->mutex);
+		kfree(tmp);
+		return 0;
+	}
+	mirror = hmm_mirror_ref(&ddevice->dmirrors[minor]->mirror);
+	mutex_unlock(&ddevice->mutex);
+
+	if (!mirror) {
+		kfree(tmp);
+		return 0;
+	}
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	if (dmirror->stop) {
+		kfree(tmp);
+		hmm_mirror_unref(mirror);
+		return 0;
+	}
+
+	/* The range of address to lookup. */
+	start = (*ppos) & PAGE_MASK;
+	offset = (*ppos) - start;
+	end = PAGE_ALIGN(start + count);
+	BUG_ON(start == end);
+	pt_map.dmirror = dmirror;
+
+	for (; count; start += PAGE_SIZE, offset = 0) {
+		unsigned long *pldp, pld_idx;
+		unsigned long size = min(PAGE_SIZE - offset, count);
+		struct page *page;
+		char *ptr;
+
+		r = copy_from_user(tmp, buf, size);
+		if (r) {
+			kfree(tmp);
+			hmm_mirror_unref(mirror);
+			return -EFAULT;
+		}
+
+		mutex_lock(&dmirror->mutex);
+
+		pldp = hmm_dummy_pt_pld_map(&pt_map, start);
+		pld_idx = hmm_dummy_pld_index(start);
+		if (!pldp || !(pldp[pld_idx] & HMM_DUMMY_PTE_VALID)) {
+			hmm_dummy_pt_unmap(&pt_map);
+			mutex_unlock(&dmirror->mutex);
+			goto fault;
+		}
+		if (!(pldp[pld_idx] & HMM_DUMMY_PTE_WRITE)) {
+			hmm_dummy_pt_unmap(&pt_map);
+			mutex_unlock(&dmirror->mutex);
+			goto fault;
+		}
+		pldp[pld_idx] |= HMM_DUMMY_PTE_DIRTY;
+		page = hmm_dummy_pte_to_page(pldp[pld_idx]);
+		if (!page) {
+			mutex_unlock(&dmirror->mutex);
+			BUG();
+			kfree(tmp);
+			hmm_mirror_unref(mirror);
+			return -EFAULT;
+		}
+		ptr = kmap(page);
+		memcpy(ptr + offset, tmp, size);
+		kunmap(page);
+		hmm_dummy_pt_unmap(&pt_map);
+		mutex_unlock(&dmirror->mutex);
+
+		retval += size;
+		*ppos += size;
+		count -= size;
+		buf += size;
+	}
+
+	kfree(tmp);
+	hmm_mirror_unref(mirror);
+	return retval;
+
+fault:
+	kfree(tmp);
+	r = hmm_dummy_mirror_fault(dmirror, start, true);
+	hmm_mirror_unref(mirror);
+	if (r)
+		return r;
+
+	/* Force userspace to retry write if nothing was writen. */
+	return retval ? retval : -EINTR;
+}
+
+static int hmm_dummy_fops_mmap(struct file *filp, struct vm_area_struct *vma)
+{
+	return -EINVAL;
+}
+
+static int hmm_dummy_fops_open(struct inode *inode, struct file *filp)
+{
+	struct hmm_dummy_device *ddevice;
+	struct cdev *cdev = inode->i_cdev;
+	const int minor = iminor(inode);
+
+	/* No exclusive opens */
+	if (filp->f_flags & O_EXCL)
+		return -EINVAL;
+
+	ddevice = container_of(cdev, struct hmm_dummy_device, cdev);
+	filp->private_data = ddevice;
+	ddevice->fmapping[minor] = &inode->i_data;
+
+	return 0;
+}
+
+static int hmm_dummy_fops_release(struct inode *inode,
+				  struct file *filp)
+{
+#if 0
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_mirror *dmirror;
+	struct cdev *cdev = inode->i_cdev;
+	const int minor = iminor(inode);
+
+	ddevice = container_of(cdev, struct hmm_dummy_device, cdev);
+	mutex_lock(&ddevice->mutex);
+	dmirror = ddevice->dmirrors[minor];
+	if (dmirror && dmirror->filp == filp) {
+		struct hmm_mirror *mirror = hmm_mirror_ref(&dmirror->mirror);
+		ddevice->dmirrors[minor] = NULL;
+		mutex_unlock(&ddevice->mutex);
+
+		if (mirror) {
+			hmm_mirror_release(mirror);
+			hmm_mirror_unref(mirror);
+		}
+	} else
+		mutex_unlock(&ddevice->mutex);
+#endif
+
+	return 0;
+}
+
+static long hmm_dummy_fops_unlocked_ioctl(struct file *filp,
+					  unsigned int command,
+					  unsigned long arg)
+{
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_mirror *dmirror;
+	unsigned minor;
+	int ret;
+
+	minor = iminor(file_inode(filp));
+	ddevice = filp->private_data;
+	switch (command) {
+	case HMM_DUMMY_EXPOSE_MM:
+		mutex_lock(&ddevice->mutex);
+		dmirror = ddevice->dmirrors[minor];
+		if (dmirror) {
+			mutex_unlock(&ddevice->mutex);
+			return -EBUSY;
+		}
+		/* Mirror this process address space */
+		dmirror = kzalloc(sizeof(*dmirror), GFP_KERNEL);
+		if (dmirror == NULL) {
+			mutex_unlock(&ddevice->mutex);
+			return -ENOMEM;
+		}
+		kref_init(&dmirror->kref);
+		dmirror->mm = NULL;
+		dmirror->stop = false;
+		dmirror->pid = task_pid_nr(current);
+		dmirror->ddevice = ddevice;
+		dmirror->minor = minor;
+		dmirror->filp = filp;
+		dmirror->pgdp = NULL;
+		mutex_init(&dmirror->mutex);
+		ddevice->dmirrors[minor] = dmirror;
+		mutex_unlock(&ddevice->mutex);
+
+		ret = hmm_mirror_register(&dmirror->mirror,
+					  &ddevice->device,
+					  current->mm);
+		if (ret) {
+			mutex_lock(&ddevice->mutex);
+			ddevice->dmirrors[minor] = NULL;
+			mutex_unlock(&ddevice->mutex);
+			kfree(dmirror);
+			return ret;
+		}
+		/* Success. */
+		pr_info("mirroring address space of %d\n", dmirror->pid);
+		hmm_mirror_unref(&dmirror->mirror);
+		return 0;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static const struct file_operations hmm_dummy_fops = {
+	.read		= hmm_dummy_fops_read,
+	.write		= hmm_dummy_fops_write,
+	.mmap		= hmm_dummy_fops_mmap,
+	.open		= hmm_dummy_fops_open,
+	.release	= hmm_dummy_fops_release,
+	.unlocked_ioctl = hmm_dummy_fops_unlocked_ioctl,
+	.llseek		= default_llseek,
+	.owner		= THIS_MODULE,
+};
+
+
+/*
+ * char device driver
+ */
+static int hmm_dummy_device_init(struct hmm_dummy_device *ddevice)
+{
+	int ret, i;
+
+	ret = alloc_chrdev_region(&ddevice->dev, 0,
+				  HMM_DUMMY_MAX_DEVICES,
+				  ddevice->name);
+	if (ret < 0)
+		goto error;
+	ddevice->major = MAJOR(ddevice->dev);
+
+	cdev_init(&ddevice->cdev, &hmm_dummy_fops);
+	ret = cdev_add(&ddevice->cdev, ddevice->dev, HMM_DUMMY_MAX_DEVICES);
+	if (ret) {
+		unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_DEVICES);
+		goto error;
+	}
+
+	/* Register the hmm device. */
+	for (i = 0; i < HMM_DUMMY_MAX_DEVICES; i++)
+		ddevice->dmirrors[i] = NULL;
+	mutex_init(&ddevice->mutex);
+	ddevice->device.ops = &hmm_dummy_ops;
+	ddevice->device.name = ddevice->name;
+
+	ret = hmm_device_register(&ddevice->device);
+	if (ret) {
+		cdev_del(&ddevice->cdev);
+		unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_DEVICES);
+		goto error;
+	}
+
+	return 0;
+
+error:
+	return ret;
+}
+
+static void hmm_dummy_device_fini(struct hmm_dummy_device *ddevice)
+{
+	unsigned i;
+
+	/* First finish hmm. */
+	mutex_lock(&ddevice->mutex);
+	for (i = 0; i < HMM_DUMMY_MAX_DEVICES; i++) {
+		struct hmm_mirror *mirror = NULL;
+
+		if (ddevices->dmirrors[i]) {
+			mirror = hmm_mirror_ref(&ddevices->dmirrors[i]->mirror);
+			ddevices->dmirrors[i] = NULL;
+		}
+		if (!mirror)
+			continue;
+
+		mutex_unlock(&ddevice->mutex);
+		hmm_mirror_release(mirror);
+		hmm_mirror_unref(mirror);
+		mutex_lock(&ddevice->mutex);
+	}
+	mutex_unlock(&ddevice->mutex);
+
+	if (hmm_device_unregister(&ddevice->device))
+		BUG();
+
+	cdev_del(&ddevice->cdev);
+	unregister_chrdev_region(ddevice->dev,
+				 HMM_DUMMY_MAX_DEVICES);
+}
+
+static int __init hmm_dummy_init(void)
+{
+	int ret;
+
+	snprintf(ddevices[0].name, sizeof(ddevices[0].name),
+		 "%s%d", HMM_DUMMY_DEVICE_NAME, 0);
+	ret = hmm_dummy_device_init(&ddevices[0]);
+	if (ret)
+		return ret;
+
+	snprintf(ddevices[1].name, sizeof(ddevices[1].name),
+		 "%s%d", HMM_DUMMY_DEVICE_NAME, 1);
+	ret = hmm_dummy_device_init(&ddevices[1]);
+	if (ret) {
+		hmm_dummy_device_fini(&ddevices[0]);
+		return ret;
+	}
+
+	pr_info("hmm_dummy loaded THIS IS A DANGEROUS MODULE !!!\n");
+	return 0;
+}
+
+static void __exit hmm_dummy_exit(void)
+{
+	hmm_dummy_device_fini(&ddevices[1]);
+	hmm_dummy_device_fini(&ddevices[0]);
+}
+
+module_init(hmm_dummy_init);
+module_exit(hmm_dummy_exit);
+MODULE_LICENSE("GPL");
diff --git a/include/uapi/linux/hmm_dummy.h b/include/uapi/linux/hmm_dummy.h
new file mode 100644
index 0000000..20eb98f
--- /dev/null
+++ b/include/uapi/linux/hmm_dummy.h
@@ -0,0 +1,30 @@
+/*
+ * Copyright 2013 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/* This is a dummy driver made to exercice the HMM (hardware memory management)
+ * API of the kernel. It allow an userspace program to map its whole address
+ * space through the hmm dummy driver file.
+ */
+#ifndef _UAPI_LINUX_HMM_DUMMY_H
+#define _UAPI_LINUX_HMM_DUMMY_H
+
+#include <linux/types.h>
+#include <linux/ioctl.h>
+#include <linux/irqnr.h>
+
+/* Expose the address space of the calling process through hmm dummy dev file */
+#define HMM_DUMMY_EXPOSE_MM	_IO('R', 0x00)
+
+#endif /* _UAPI_LINUX_RANDOM_H */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

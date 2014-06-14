Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9207A6B0039
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 20:49:10 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so4588275qac.25
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 17:49:10 -0700 (PDT)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id p6si6245756qak.129.2014.06.13.17.49.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 17:49:09 -0700 (PDT)
Received: by mail-qc0-f176.google.com with SMTP id w7so3877082qcr.35
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 17:49:09 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <j.glisse@gmail.com>
Subject: [PATCH 5/5] hmm/dummy: dummy driver to showcase the hmm api v2
Date: Fri, 13 Jun 2014 20:48:33 -0400
Message-Id: <1402706913-7432-6-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1402706913-7432-5-git-send-email-j.glisse@gmail.com>
References: <1402706913-7432-1-git-send-email-j.glisse@gmail.com>
 <1402706913-7432-2-git-send-email-j.glisse@gmail.com>
 <1402706913-7432-3-git-send-email-j.glisse@gmail.com>
 <1402706913-7432-4-git-send-email-j.glisse@gmail.com>
 <1402706913-7432-5-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, torvalds@linux-foundation.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

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
 drivers/char/hmm_dummy.c       | 1075 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/hmm_dummy.h |   30 ++
 4 files changed, 1115 insertions(+)
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
index 0000000..e5431a7
--- /dev/null
+++ b/drivers/char/hmm_dummy.c
@@ -0,0 +1,1075 @@
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
+			      unsigned long faddr,
+			      unsigned long laddr)
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
+	for (; faddr < laddr; faddr = hmm_dummy_pld_next(faddr)) {
+		struct page *pud_page, *pmd_page;
+
+		pgdp = &dmirror->pgdp[hmm_dummy_pgd_index(faddr)];
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
+		pudp = &pudp[hmm_dummy_pud_index(faddr)];
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
+		pmdp = &pmdp[hmm_dummy_pmd_index(faddr)];
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
+				  unsigned long faddr,
+				  unsigned long laddr)
+{
+	for (; faddr < laddr; faddr = hmm_dummy_pld_next(faddr)) {
+		unsigned long pfn, *pmdp, next;
+		struct page *page;
+
+		next = min(hmm_dummy_pld_next(faddr), laddr);
+		if (faddr > hmm_dummy_pld_base(faddr) || laddr < next)
+			continue;
+		pmdp = hmm_dummy_pt_pmd_map(pt_map, faddr);
+		if (!pmdp)
+			continue;
+		if (!(pmdp[hmm_dummy_pmd_index(faddr)] & HMM_DUMMY_PTE_VALID))
+			continue;
+		pfn = pmdp[hmm_dummy_pmd_index(faddr)] >> HMM_DUMMY_PFN_SHIFT;
+		page = pfn_to_page(pfn);
+		pmdp[hmm_dummy_pmd_index(faddr)] = 0;
+		__free_page(page);
+	}
+}
+
+static void hmm_dummy_pt_free_pud(struct hmm_dummy_pt_map *pt_map,
+				  unsigned long faddr,
+				  unsigned long laddr)
+{
+	for (; faddr < laddr; faddr = hmm_dummy_pmd_next(faddr)) {
+		unsigned long pfn, *pudp, next;
+		struct page *page;
+
+		next = min(hmm_dummy_pmd_next(faddr), laddr);
+		hmm_dummy_pt_free_pmd(pt_map, faddr, next);
+		hmm_dummy_pt_pmd_unmap(pt_map);
+		if (faddr > hmm_dummy_pmd_base(faddr) || laddr < next)
+			continue;
+		pudp = hmm_dummy_pt_pud_map(pt_map, faddr);
+		if (!pudp)
+			continue;
+		if (!(pudp[hmm_dummy_pud_index(faddr)] & HMM_DUMMY_PTE_VALID))
+			continue;
+		pfn = pudp[hmm_dummy_pud_index(faddr)] >> HMM_DUMMY_PFN_SHIFT;
+		page = pfn_to_page(pfn);
+		pudp[hmm_dummy_pud_index(faddr)] = 0;
+		__free_page(page);
+	}
+}
+
+static void hmm_dummy_pt_free(struct hmm_dummy_mirror *dmirror,
+			      unsigned long faddr,
+			      unsigned long laddr)
+{
+	struct hmm_dummy_pt_map pt_map = {0};
+
+	if (!dmirror->pgdp || (laddr - faddr) < HMM_DUMMY_PLD_SIZE)
+		return;
+
+	pt_map.dmirror = dmirror;
+
+	for (; faddr < laddr; faddr = hmm_dummy_pud_next(faddr)) {
+		unsigned long pfn, *pgdp, next;
+		struct page *page;
+
+		next = min(hmm_dummy_pud_next(faddr), laddr);
+		pgdp = dmirror->pgdp;
+		hmm_dummy_pt_free_pud(&pt_map, faddr, next);
+		hmm_dummy_pt_pud_unmap(&pt_map);
+		if (faddr > hmm_dummy_pud_base(faddr) || laddr < next)
+			continue;
+		if (!(pgdp[hmm_dummy_pgd_index(faddr)] & HMM_DUMMY_PTE_VALID))
+			continue;
+		pfn = pgdp[hmm_dummy_pgd_index(faddr)] >> HMM_DUMMY_PFN_SHIFT;
+		page = pfn_to_page(pfn);
+		pgdp[hmm_dummy_pgd_index(faddr)] = 0;
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
+static void hmm_dummy_device_destroy(struct hmm_device *device)
+{
+	/* No-op for the dummy driver. */
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
+static void hmm_dummy_mirror_destroy(struct hmm_mirror *mirror)
+{
+	/* No-op for the dummy driver. */
+}
+
+static int hmm_dummy_fence_wait(struct hmm_fence *fence)
+{
+	/* FIXME add fake fence to showcase api */
+	return 0;
+}
+
+static void hmm_dummy_fence_destroy(struct hmm_fence *fence)
+{
+	/* We never allocate fence so how could we have to free one ? */
+	BUG();
+}
+
+static struct hmm_fence *hmm_dummy_update(struct hmm_mirror *mirror,
+					  struct vm_area_struct *vma,
+					  unsigned long faddr,
+					  unsigned long laddr,
+					  enum hmm_etype etype)
+{
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_pt_map pt_map = {0};
+	unsigned long addr, i, mask;
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	pt_map.dmirror = dmirror;
+
+	/* Debugging hmm real device driver do not have to do that. */
+	switch (etype) {
+	case HMM_UNREGISTER:
+	case HMM_MUNMAP:
+	case HMM_MPROT_NONE:
+		mask = 0;
+		break;
+	case HMM_MPROT_RONLY:
+		mask = ~HMM_DUMMY_PTE_WRITE;
+		break;
+	default:
+		return ERR_PTR(-EIO);
+	}
+
+	mutex_lock(&dmirror->mutex);
+	for (i = 0, addr = faddr; addr < laddr; ++i, addr += PAGE_SIZE) {
+		unsigned long *pldp;
+
+		pldp = hmm_dummy_pt_pld_map(&pt_map, addr);
+		if (!pldp)
+			continue;
+		if (((*pldp) & HMM_DUMMY_PTE_DIRTY)) {
+			struct page *page;
+
+			page = hmm_dummy_pte_to_page(*pldp);
+			if (page)
+				set_page_dirty(page);
+		}
+		*pldp &= ~HMM_DUMMY_PTE_DIRTY;
+		*pldp &= mask;
+	}
+	hmm_dummy_pt_unmap(&pt_map);
+
+	switch (etype) {
+	case HMM_UNREGISTER:
+	case HMM_MUNMAP:
+		hmm_dummy_pt_free(dmirror, faddr, laddr);
+		break;
+	default:
+		break;
+	}
+	mutex_unlock(&dmirror->mutex);
+	return NULL;
+}
+
+static int hmm_dummy_fault(struct hmm_mirror *mirror,
+			   unsigned long faddr,
+			   unsigned long laddr,
+			   pte_t *ptep,
+			   struct hmm_event *event)
+{
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_pt_map pt_map = {0};
+	unsigned long i;
+	int ret = 0;
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	pt_map.dmirror = dmirror;
+
+	mutex_lock(&dmirror->mutex);
+	for (i = 0; faddr < laddr; ++i, ++ptep, faddr += PAGE_SIZE) {
+		unsigned long *pldp, pld_idx;
+		struct page *page;
+		bool write;
+
+		event->iaddr = faddr;
+		pldp = hmm_dummy_pt_pld_map(&pt_map, faddr);
+		if (!pldp) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		page = hmm_pte_to_page(*ptep, &write);
+		if (!page) {
+			ret = -ENOENT;
+			break;
+		}
+		if (event->etype == HMM_WFAULT && !write) {
+			ret = -EACCES;
+			break;
+		}
+
+		pld_idx = hmm_dummy_pld_index(faddr);
+		pldp[pld_idx]  = (page_to_pfn(page) << HMM_DUMMY_PFN_SHIFT);
+		pldp[pld_idx] |= write ? HMM_DUMMY_PTE_WRITE : 0;
+		pldp[pld_idx] |= HMM_DUMMY_PTE_VALID | HMM_DUMMY_PTE_READ;
+	}
+	hmm_dummy_pt_unmap(&pt_map);
+	mutex_unlock(&dmirror->mutex);
+	return ret;
+}
+
+static const struct hmm_device_ops hmm_dummy_ops = {
+	.device_destroy		= &hmm_dummy_device_destroy,
+	.mirror_release		= &hmm_dummy_mirror_release,
+	.mirror_destroy		= &hmm_dummy_mirror_destroy,
+	.fence_wait		= &hmm_dummy_fence_wait,
+	.fence_destroy		= &hmm_dummy_fence_destroy,
+	.update			= &hmm_dummy_update,
+	.fault			= &hmm_dummy_fault,
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
+static int hmm_dummy_mirror_fault(struct hmm_dummy_mirror *dmirror,
+				  unsigned long addr,
+				  bool write)
+{
+	struct hmm_mirror *mirror = &dmirror->mirror;
+	struct hmm_event event;
+	unsigned long faddr, laddr, npages = 4;
+	int ret;
+
+	/* Showcase hmm api fault a 64k range centered on the address. */
+	event.faddr = faddr = addr > (npages << 8) ? addr - (npages << 8) : 0;
+	event.laddr = laddr = faddr + (npages << 10);
+	event.etype = write ? HMM_WFAULT : HMM_RFAULT;
+
+	/* Pre-allocate device page table. */
+	mutex_lock(&dmirror->mutex);
+	ret = hmm_dummy_pt_alloc(dmirror, faddr, laddr);
+	mutex_unlock(&dmirror->mutex);
+	if (ret)
+		return ret;
+
+	for (; faddr < laddr; faddr = event.faddr) {
+		ret = hmm_mirror_fault(mirror, &event);
+		/* Ignore any error that do not concern the fault address. */
+		if (addr >= event.laddr) {
+			event.faddr = event.laddr;
+			event.laddr = laddr;
+			continue;
+		}
+		if (addr < event.laddr) {
+			/* The address was faulted successfully ignore error
+			 * for address above the one we were interested in.
+			 */
+			ret = 0;
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
+	unsigned long faddr, laddr, offset;
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
+	dmirror = ddevice->dmirrors[minor];
+	mutex_unlock(&ddevice->mutex);
+	if (dmirror->stop) {
+		kfree(tmp);
+		return 0;
+	}
+
+	/* The range of address to lookup. */
+	faddr = (*ppos) & PAGE_MASK;
+	offset = (*ppos) - faddr;
+	laddr = PAGE_ALIGN(faddr + count);
+	BUG_ON(faddr == laddr);
+	pt_map.dmirror = dmirror;
+
+	for (; count; faddr += PAGE_SIZE, offset = 0) {
+		unsigned long *pldp, pld_idx;
+		unsigned long size = min(PAGE_SIZE - offset, count);
+		struct page *page;
+		char *ptr;
+
+		mutex_lock(&dmirror->mutex);
+		pldp = hmm_dummy_pt_pld_map(&pt_map, faddr);
+		pld_idx = hmm_dummy_pld_index(faddr);
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
+			return -EFAULT;
+		}
+		retval += size;
+		*ppos += size;
+		count -= size;
+		buf += size;
+	}
+
+	return retval;
+
+fault:
+	kfree(tmp);
+	r = hmm_dummy_mirror_fault(dmirror, faddr, false);
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
+	unsigned long faddr, laddr, offset;
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
+	dmirror = ddevice->dmirrors[minor];
+	mutex_unlock(&ddevice->mutex);
+	if (dmirror->stop) {
+		kfree(tmp);
+		return 0;
+	}
+
+	/* The range of address to lookup. */
+	faddr = (*ppos) & PAGE_MASK;
+	offset = (*ppos) - faddr;
+	laddr = PAGE_ALIGN(faddr + count);
+	BUG_ON(faddr == laddr);
+	pt_map.dmirror = dmirror;
+
+	for (; count; faddr += PAGE_SIZE, offset = 0) {
+		unsigned long *pldp, pld_idx;
+		unsigned long size = min(PAGE_SIZE - offset, count);
+		struct page *page;
+		char *ptr;
+
+		r = copy_from_user(tmp, buf, size);
+		if (r) {
+			kfree(tmp);
+			return -EFAULT;
+		}
+
+		mutex_lock(&dmirror->mutex);
+
+		pldp = hmm_dummy_pt_pld_map(&pt_map, faddr);
+		pld_idx = hmm_dummy_pld_index(faddr);
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
+	return retval;
+
+fault:
+	kfree(tmp);
+	r = hmm_dummy_mirror_fault(dmirror, faddr, true);
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
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_mirror *dmirror;
+	struct cdev *cdev = inode->i_cdev;
+	const int minor = iminor(inode);
+
+	ddevice = container_of(cdev, struct hmm_dummy_device, cdev);
+	dmirror = ddevice->dmirrors[minor];
+	if (dmirror && dmirror->filp == filp) {
+		if (!dmirror->stop)
+			hmm_mirror_unregister(&dmirror->mirror);
+		ddevice->dmirrors[minor] = NULL;
+		kfree(dmirror);
+	}
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
+
+	ret = hmm_device_register(&ddevice->device,
+				  ddevice->name);
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
+	for (i = 0; i < HMM_DUMMY_MAX_DEVICES; i++) {
+		struct hmm_dummy_mirror *dmirror;
+
+		dmirror = ddevices->dmirrors[i];
+		if (!dmirror)
+			continue;
+		hmm_mirror_unregister(&dmirror->mirror);
+		kfree(dmirror);
+	}
+	hmm_device_unref(&ddevice->device);
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
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

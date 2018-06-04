Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDE796B0273
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 19:22:36 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b7-v6so101705pgv.5
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 16:22:36 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e9-v6si6300333pff.30.2018.06.04.16.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 16:22:35 -0700 (PDT)
Subject: [PATCH v3 11/12] mm,
 memory_failure: Teach memory_failure() about dev_pagemap pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 04 Jun 2018 16:12:37 -0700
Message-ID: <152815395775.39010.9355109660470832490.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.orgjack@suse.cz

    mce: Uncorrected hardware memory error in user-access at af34214200
    {1}[Hardware Error]: It has been corrected by h/w and requires no further action
    mce: [Hardware Error]: Machine check events logged
    {1}[Hardware Error]: event severity: corrected
    Memory failure: 0xaf34214: reserved kernel page still referenced by 1 users
    [..]
    Memory failure: 0xaf34214: recovery action for reserved kernel page: Failed
    mce: Memory error not recovered

In contrast to typical memory, dev_pagemap pages may be dax mapped. With
dax there is no possibility to map in another page dynamically since dax
establishes 1:1 physical address to file offset associations. Also
dev_pagemap pages associated with NVDIMM / persistent memory devices can
internal remap/repair addresses with poison. While memory_failure()
assumes that it can discard typical poisoned pages and keep them
unmapped indefinitely, dev_pagemap pages may be returned to service
after the error is cleared.

Teach memory_failure() to detect and handle MEMORY_DEVICE_HOST
dev_pagemap pages that have poison consumed by userspace. Mark the
memory as UC instead of unmapping it completely to allow ongoing access
via the device driver (nd_pmem). Later, nd_pmem will grow support for
marking the page back to WB when the error is cleared.

Cc: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>
Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h  |    1 
 mm/memory-failure.c |  145 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 146 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06a4be6..566c972e03e7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2669,6 +2669,7 @@ enum mf_action_page_type {
 	MF_MSG_TRUNCATED_LRU,
 	MF_MSG_BUDDY,
 	MF_MSG_BUDDY_2ND,
+	MF_MSG_DAX,
 	MF_MSG_UNKNOWN,
 };
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index b6efb78ba49b..de0bc897d6e7 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -55,6 +55,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
+#include <linux/memremap.h>
 #include <linux/kfifo.h>
 #include <linux/ratelimit.h>
 #include "internal.h"
@@ -531,6 +532,7 @@ static const char * const action_page_types[] = {
 	[MF_MSG_TRUNCATED_LRU]		= "already truncated LRU page",
 	[MF_MSG_BUDDY]			= "free buddy page",
 	[MF_MSG_BUDDY_2ND]		= "free buddy page (2nd try)",
+	[MF_MSG_DAX]			= "dax page",
 	[MF_MSG_UNKNOWN]		= "unknown page",
 };
 
@@ -1132,6 +1134,144 @@ static int memory_failure_hugetlb(unsigned long pfn, int flags)
 	return res;
 }
 
+static unsigned long dax_mapping_size(struct address_space *mapping,
+		struct page *page)
+{
+	pgoff_t pgoff = page_to_pgoff(page);
+	struct vm_area_struct *vma;
+	unsigned long size = 0;
+
+	i_mmap_lock_read(mapping);
+	xa_lock_irq(&mapping->i_pages);
+	/* validate that @page is still linked to @mapping */
+	if (page->mapping != mapping) {
+		xa_unlock_irq(&mapping->i_pages);
+		i_mmap_unlock_read(mapping);
+			return 0;
+	}
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long address = vma_address(page, vma);
+		pgd_t *pgd;
+		p4d_t *p4d;
+		pud_t *pud;
+		pmd_t *pmd;
+		pte_t *pte;
+
+		pgd = pgd_offset(vma->vm_mm, address);
+		if (!pgd_present(*pgd))
+			continue;
+		p4d = p4d_offset(pgd, address);
+		if (!p4d_present(*p4d))
+			continue;
+		pud = pud_offset(p4d, address);
+		if (!pud_present(*pud))
+			continue;
+		if (pud_devmap(*pud)) {
+			size = PUD_SIZE;
+			break;
+		}
+		pmd = pmd_offset(pud, address);
+		if (!pmd_present(*pmd))
+			continue;
+		if (pmd_devmap(*pmd)) {
+			size = PMD_SIZE;
+			break;
+		}
+		pte = pte_offset_map(pmd, address);
+		if (!pte_present(*pte))
+			continue;
+		if (pte_devmap(*pte)) {
+			size = PAGE_SIZE;
+			break;
+		}
+	}
+	xa_unlock_irq(&mapping->i_pages);
+	i_mmap_unlock_read(mapping);
+
+	return size;
+}
+
+static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
+		struct dev_pagemap *pgmap)
+{
+	struct page *page = pfn_to_page(pfn);
+	const bool unmap_success = true;
+	struct address_space *mapping;
+	unsigned long size;
+	LIST_HEAD(tokill);
+	int rc = -EBUSY;
+	loff_t start;
+
+	/*
+	 * Prevent the inode from being freed while we are interrogating
+	 * the address_space, typically this would be handled by
+	 * lock_page(), but dax pages do not use the page lock.
+	 */
+	rcu_read_lock();
+	mapping = page->mapping;
+	if (!mapping) {
+		rcu_read_unlock();
+		goto out;
+	}
+	if (!igrab(mapping->host)) {
+		mapping = NULL;
+		rcu_read_unlock();
+		goto out;
+	}
+	rcu_read_unlock();
+
+	if (hwpoison_filter(page)) {
+		rc = 0;
+		goto out;
+	}
+
+	switch (pgmap->type) {
+	case MEMORY_DEVICE_PRIVATE:
+	case MEMORY_DEVICE_PUBLIC:
+		/*
+		 * TODO: Handle HMM pages which may need coordination
+		 * with device-side memory.
+		 */
+		goto out;
+	default:
+		break;
+	}
+
+	/*
+	 * If the page is not mapped in userspace then report it as
+	 * unhandled.
+	 */
+	size = dax_mapping_size(mapping, page);
+	if (!size) {
+		pr_err("Memory failure: %#lx: failed to unmap page\n", pfn);
+		goto out;
+	}
+
+	SetPageHWPoison(page);
+
+	/*
+	 * Unlike System-RAM there is no possibility to swap in a
+	 * different physical page at a given virtual address, so all
+	 * userspace consumption of ZONE_DEVICE memory necessitates
+	 * SIGBUS (i.e. MF_MUST_KILL)
+	 */
+	flags |= MF_ACTION_REQUIRED | MF_MUST_KILL;
+	collect_procs(mapping, page, &tokill, flags & MF_ACTION_REQUIRED);
+
+	start = (page->index << PAGE_SHIFT) & ~(size - 1);
+	unmap_mapping_range(page->mapping, start, start + size, 0);
+
+	kill_procs(&tokill, flags & MF_MUST_KILL, !unmap_success, ilog2(size),
+			mapping, page, flags);
+	rc = 0;
+out:
+	if (mapping)
+		iput(mapping->host);
+	put_dev_pagemap(pgmap);
+	action_result(pfn, MF_MSG_DAX, rc ? MF_FAILED : MF_RECOVERED);
+	return rc;
+}
+
 /**
  * memory_failure - Handle memory failure of a page.
  * @pfn: Page Number of the corrupted page
@@ -1154,6 +1294,7 @@ int memory_failure(unsigned long pfn, int flags)
 	struct page *p;
 	struct page *hpage;
 	struct page *orig_head;
+	struct dev_pagemap *pgmap;
 	int res;
 	unsigned long page_flags;
 
@@ -1166,6 +1307,10 @@ int memory_failure(unsigned long pfn, int flags)
 		return -ENXIO;
 	}
 
+	pgmap = get_dev_pagemap(pfn, NULL);
+	if (pgmap)
+		return memory_failure_dev_pagemap(pfn, flags, pgmap);
+
 	p = pfn_to_page(pfn);
 	if (PageHuge(p))
 		return memory_failure_hugetlb(pfn, flags);

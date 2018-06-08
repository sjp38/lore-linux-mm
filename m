Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B70D36B0275
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 20:01:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e16-v6so6972242pfn.5
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 17:01:18 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 84-v6si15919364pfa.60.2018.06.08.17.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 17:01:17 -0700 (PDT)
Subject: [PATCH v4 11/12] mm,
 memory_failure: Teach memory_failure() about dev_pagemap pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 08 Jun 2018 16:51:19 -0700
Message-ID: <152850187949.38390.1012249765651998342.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 mm/memory-failure.c |  127 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 128 insertions(+)

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
index 42a193ee14d3..a5912b27fea7 100644
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
@@ -513,6 +514,7 @@ static const char * const action_page_types[] = {
 	[MF_MSG_TRUNCATED_LRU]		= "already truncated LRU page",
 	[MF_MSG_BUDDY]			= "free buddy page",
 	[MF_MSG_BUDDY_2ND]		= "free buddy page (2nd try)",
+	[MF_MSG_DAX]			= "dax page",
 	[MF_MSG_UNKNOWN]		= "unknown page",
 };
 
@@ -1112,6 +1114,126 @@ static int memory_failure_hugetlb(unsigned long pfn, int flags)
 	return res;
 }
 
+static unsigned long dax_mapping_size(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page_to_pgoff(page);
+	struct vm_area_struct *vma;
+	unsigned long size = 0;
+
+	i_mmap_lock_read(mapping);
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
+	i_mmap_unlock_read(mapping);
+
+	return size;
+}
+
+static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
+		struct dev_pagemap *pgmap)
+{
+	const bool unmap_success = true;
+	unsigned long size;
+	struct page *page;
+	LIST_HEAD(tokill);
+	int rc = -EBUSY;
+	loff_t start;
+
+	/*
+	 * Prevent the inode from being freed while we are interrogating
+	 * the address_space, typically this would be handled by
+	 * lock_page(), but dax pages do not use the page lock.
+	 */
+	page = dax_lock_page(pfn);
+	if (!page)
+		goto out;
+
+	if (hwpoison_filter(page)) {
+		rc = 0;
+		goto unlock;
+	}
+
+	switch (pgmap->type) {
+	case MEMORY_DEVICE_PRIVATE:
+	case MEMORY_DEVICE_PUBLIC:
+		/*
+		 * TODO: Handle HMM pages which may need coordination
+		 * with device-side memory.
+		 */
+		goto unlock;
+	default:
+		break;
+	}
+
+	/*
+	 * If the page is not mapped in userspace then report it as
+	 * unhandled.
+	 */
+	size = dax_mapping_size(page);
+	if (!size) {
+		pr_err("Memory failure: %#lx: failed to unmap page\n", pfn);
+		goto unlock;
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
+	collect_procs(page, &tokill, flags & MF_ACTION_REQUIRED);
+
+	start = (page->index << PAGE_SHIFT) & ~(size - 1);
+	unmap_mapping_range(page->mapping, start, start + size, 0);
+
+	kill_procs(&tokill, flags & MF_MUST_KILL, !unmap_success, ilog2(size),
+			pfn, flags);
+	rc = 0;
+unlock:
+	dax_unlock_page(page);
+out:
+	put_dev_pagemap(pgmap);
+	action_result(pfn, MF_MSG_DAX, rc ? MF_FAILED : MF_RECOVERED);
+	return rc;
+}
+
 /**
  * memory_failure - Handle memory failure of a page.
  * @pfn: Page Number of the corrupted page
@@ -1134,6 +1256,7 @@ int memory_failure(unsigned long pfn, int flags)
 	struct page *p;
 	struct page *hpage;
 	struct page *orig_head;
+	struct dev_pagemap *pgmap;
 	int res;
 	unsigned long page_flags;
 
@@ -1146,6 +1269,10 @@ int memory_failure(unsigned long pfn, int flags)
 		return -ENXIO;
 	}
 
+	pgmap = get_dev_pagemap(pfn, NULL);
+	if (pgmap)
+		return memory_failure_dev_pagemap(pfn, flags, pgmap);
+
 	p = pfn_to_page(pfn);
 	if (PageHuge(p))
 		return memory_failure_hugetlb(pfn, flags);

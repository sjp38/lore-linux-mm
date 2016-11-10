Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC836B0038
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 17:15:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so106951090pfx.1
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:15:04 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id fn7si5837430pab.115.2016.11.10.14.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 14:14:59 -0800 (PST)
Subject: [PATCH] mm: add ZONE_DEVICE statistics to smaps
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 10 Nov 2016 14:11:57 -0800
Message-ID: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave.hansen@intel.com>, linux-nvdimm@lists.01.org, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

ZONE_DEVICE pages are mapped into a process via the filesystem-dax and
device-dax mechanisms.  There are also proposals to use ZONE_DEVICE
pages for other usages outside of dax.  Add statistics to smaps so
applications can debug that they are obtaining the mappings they expect,
or otherwise accounting them.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/proc/task_mmu.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 35b92d81692f..6765cafcf057 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -445,6 +445,8 @@ struct mem_size_stats {
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
+	unsigned long device;
+	unsigned long device_huge;
 	u64 pss;
 	u64 swap_pss;
 	bool check_shmem_swap;
@@ -458,6 +460,8 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 
 	if (PageAnon(page))
 		mss->anonymous += size;
+	else if (is_zone_device_page(page))
+		mss->device += size;
 
 	mss->resident += size;
 	/* Accumulate the size in pages that have been accessed. */
@@ -575,7 +579,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	else if (PageSwapBacked(page))
 		mss->shmem_thp += HPAGE_PMD_SIZE;
 	else if (is_zone_device_page(page))
-		/* pass */;
+		mss->device_huge += HPAGE_PMD_SIZE;
 	else
 		VM_BUG_ON_PAGE(1, page);
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
@@ -774,6 +778,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "ShmemPmdMapped: %8lu kB\n"
 		   "Shared_Hugetlb: %8lu kB\n"
 		   "Private_Hugetlb: %7lu kB\n"
+		   "Device:         %8lu kB\n"
+		   "DeviceHugePages: %7lu kB\n"
 		   "Swap:           %8lu kB\n"
 		   "SwapPss:        %8lu kB\n"
 		   "KernelPageSize: %8lu kB\n"
@@ -792,6 +798,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.shmem_thp >> 10,
 		   mss.shared_hugetlb >> 10,
 		   mss.private_hugetlb >> 10,
+		   mss.device >> 10,
+		   mss.device_huge >> 10,
 		   mss.swap >> 10,
 		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
 		   vma_kernel_pagesize(vma) >> 10,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

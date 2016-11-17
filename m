Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8B96B0313
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 19:28:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so174080293pgc.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 16:28:54 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y127si387373pgb.79.2016.11.16.16.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 16:28:52 -0800 (PST)
Subject: [PATCH] proc: mm: export PTE sizes directly in smaps (v2)
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Nov 2016 16:28:51 -0800
Message-Id: <20161117002851.C7BACB98@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, khandual@linux.vnet.ibm.com, linux-mm@kvack.org


Changes from v1:
 * Do one 'Pte' line per pte size instead of mashing on one line
 * Use PMD_SIZE for pmds instead of PAGE_SIZE, whoops
 * Wrote some Documentation/

--

/proc/$pid/smaps has a number of fields that are intended to imply the
kinds of PTEs used to map memory.  "AnonHugePages" obviously tells you
how many PMDs are being used.  "MMUPageSize" along with the "Hugetlb"
fields tells you how many PTEs you have for a huge page.

The current mechanisms work fine when we have one or two page sizes.
But, they start to get a bit muddled when we mix page sizes inside
one VMA.  For instance, the DAX folks were proposing adding a set of
fields like:

	DevicePages:
	DeviceHugePages:
	DeviceGiganticPages:
	DeviceGinormousPages:

to unmuddle things when page sizes get mixed.  That's fine, but
it does require userspace know the mapping from our various
arbitrary names to hardware page sizes on each architecture and
kernel configuration.  That seems rather suboptimal.

What folks really want is to know how much memory is mapped with
each page size.  How about we just do *that*?

Patch attached.  Seems harmless enough.  Seems to compile on a
bunch of random architectures.  Makes smaps look like this:

Private_Hugetlb:       0 kB
Swap:                  0 kB
SwapPss:               0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB
Ptes@4kB:	      32 kB
Ptes@2MB:	    2048 kB

The format I used here should be unlikely to break smaps parsers
unless they're looking for "kB" and now match the 'Ptes@4kB' instead
of the one at the end of the line.

1. I'd like to thank Dan Williams for showing me a mirror as I
   complained about the bozo that introduced 'AnonHugePages'.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

---

 b/Documentation/filesystems/proc.txt |    6 ++
 b/fs/proc/task_mmu.c                 |   81 ++++++++++++++++++++++++++++++++++-
 2 files changed, 85 insertions(+), 2 deletions(-)

diff -puN fs/proc/task_mmu.c~smaps-pte-sizes fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~smaps-pte-sizes	2016-11-16 15:43:56.756991084 -0800
+++ b/fs/proc/task_mmu.c	2016-11-16 16:19:47.354789912 -0800
@@ -445,6 +445,9 @@ struct mem_size_stats {
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
+	unsigned long rss_pte;
+	unsigned long rss_pmd;
+	unsigned long rss_pud;
 	u64 pss;
 	u64 swap_pss;
 	bool check_shmem_swap;
@@ -519,6 +522,7 @@ static void smaps_pte_entry(pte_t *pte,
 
 	if (pte_present(*pte)) {
 		page = vm_normal_page(vma, addr, *pte);
+		mss->rss_pte += PAGE_SIZE;
 	} else if (is_swap_pte(*pte)) {
 		swp_entry_t swpent = pte_to_swp_entry(*pte);
 
@@ -578,6 +582,7 @@ static void smaps_pmd_entry(pmd_t *pmd,
 		/* pass */;
 	else
 		VM_BUG_ON_PAGE(1, page);
+	mss->rss_pmd += PMD_SIZE;
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
 }
 #else
@@ -702,11 +707,13 @@ static int smaps_hugetlb_range(pte_t *pt
 	}
 	if (page) {
 		int mapcount = page_mapcount(page);
+		unsigned long hpage_size = huge_page_size(hstate_vma(vma));
 
+		mss->rss_pud += hpage_size;
 		if (mapcount >= 2)
-			mss->shared_hugetlb += huge_page_size(hstate_vma(vma));
+			mss->shared_hugetlb += hpage_size;
 		else
-			mss->private_hugetlb += huge_page_size(hstate_vma(vma));
+			mss->private_hugetlb += hpage_size;
 	}
 	return 0;
 }
@@ -716,6 +723,75 @@ void __weak arch_show_smap(struct seq_fi
 {
 }
 
+/*
+ * What units should we use for a given number?  We want
+ * 2048 to be 2k, so we return 'k'.  1048576 should be
+ * 1M, so we return 'M'.
+ */
+static char size_unit(unsigned long long nr)
+{
+	/*
+	 * This ' ' might look a bit goofy in the output.  But, why
+	 * bother doing anything.  Do we even have a <1k page size?
+	 */
+	if (nr < (1ULL<<10))
+		return ' ';
+	if (nr < (1ULL<<20))
+		return 'k';
+	if (nr < (1ULL<<30))
+		return 'M';
+	if (nr < (1ULL<<40))
+		return 'G';
+	if (nr < (1ULL<<50))
+		return 'T';
+	if (nr < (1ULL<<60))
+		return 'P';
+	return 'E';
+}
+
+/*
+ * How should we shift down a a given number to scale it
+ * with the units we are printing it as? 2048 to be 2k,
+ * so we want it shifted down by 10.  1048576 should be
+ * 1M, so we want it shifted down by 20.
+ */
+static int size_shift(unsigned long long nr)
+{
+	if (nr < (1ULL<<10))
+		return 0;
+	if (nr < (1ULL<<20))
+		return 10;
+	if (nr < (1ULL<<30))
+		return 20;
+	if (nr < (1ULL<<40))
+		return 30;
+	if (nr < (1ULL<<50))
+		return 40;
+	if (nr < (1ULL<<60))
+		return 50;
+	return 60;
+}
+
+static void show_one_smap_pte(struct seq_file *m, unsigned long bytes_rss,
+		unsigned long pte_size)
+{
+	seq_printf(m, "Ptes@%ld%cB:	%8lu kB\n",
+			pte_size >> size_shift(pte_size),
+			size_unit(pte_size),
+			bytes_rss >> 10);
+}
+
+static void show_smap_ptes(struct seq_file *m, struct mem_size_stats *mss)
+{
+	/* Only print the entries for page sizes present in the VMA */
+	if (mss->rss_pte)
+		show_one_smap_pte(m, mss->rss_pte, PAGE_SIZE);
+	if (mss->rss_pmd)
+		show_one_smap_pte(m, mss->rss_pmd, PMD_SIZE);
+	if (mss->rss_pud)
+		show_one_smap_pte(m, mss->rss_pud, PUD_SIZE);
+}
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -799,6 +875,7 @@ static int show_smap(struct seq_file *m,
 		   (vma->vm_flags & VM_LOCKED) ?
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
 
+	show_smap_ptes(m, &mss);
 	arch_show_smap(m, vma);
 	show_smap_vma_flags(m, vma);
 	m_cache_vma(m, vma);
diff -puN Documentation/filesystems/proc.txt~smaps-pte-sizes Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt~smaps-pte-sizes	2016-11-16 16:10:48.707307044 -0800
+++ b/Documentation/filesystems/proc.txt	2016-11-16 16:10:52.172464547 -0800
@@ -418,6 +418,9 @@ SwapPss:               0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:                0 kB
+Ptes@4kB:	       4 kB
+Ptes@2MB:	    8192 kB
+
 VmFlags: rd ex mr mw me dw
 
 the first of these lines shows the same information as is displayed for the
@@ -450,6 +453,9 @@ replaced by copy-on-write) part of the u
 "SwapPss" shows proportional swap share of this mapping. Unlike "Swap", this
 does not take into account swapped out page of underlying shmem objects.
 "Locked" indicates whether the mapping is locked in memory or not.
+"Ptes@..." lines show how many page table entries are currently in place and
+pointing to memory.  There is an entry for each size present in the hardware
+page tables for this mapping.
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

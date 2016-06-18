Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EEE76B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 06:12:47 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id n63so242295144ywf.3
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 03:12:47 -0700 (PDT)
Received: from smtp-fw-2101.amazon.com (smtp-fw-2101.amazon.com. [72.21.196.25])
        by mx.google.com with ESMTPS id n28si35963921qkh.29.2016.06.18.03.12.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 18 Jun 2016 03:12:46 -0700 (PDT)
From: KarimAllah Ahmed <karahmed@amazon.de>
Subject: [PATCH] sparse: Track the boundaries of memory sections for accurate checks
Date: Sat, 18 Jun 2016 12:11:19 +0200
Message-Id: <1466244679-23824-1-git-send-email-karahmed@amazon.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KarimAllah Ahmed <karahmed@amazon.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dan Williams <dan.j.williams@intel.com>, Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>, Anthony Liguori <aliguori@amazon.com>, =?UTF-8?q?Jan=20H=20=2E=20Sch=C3=B6nherr?= <jschoenh@amazon.de>

When sparse memory model is used an array of memory sections is created to
track each block of contiguous physical pages. Each element of this array
contains PAGES_PER_SECTION pages. During the creation of this array the actual
boundaries of the memory block is lost, so the whole block is either considered
as present or not.

pfn_valid() in the sparse memory configuration checks which memory sections the
pfn belongs to then checks whether it's present or not. This yields sub-optimal
results when the available memory doesn't cover the whole memory section,
because pfn_valid will return 'true' even for the unavailable pfns at the
boundaries of the memory section.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Joe Perches <joe@perches.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Anthony Liguori <aliguori@amazon.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: KarimAllah Ahmed <karahmed@amazon.de>
Signed-off-by: Jan H. SchA?nherr <jschoenh@amazon.de>
---
 include/linux/mmzone.h | 22 ++++++++++++++++------
 mm/sparse.c            | 37 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 52 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02069c2..f76a0e1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1067,8 +1067,12 @@ struct mem_section {
 	 * section. (see page_ext.h about this.)
 	 */
 	struct page_ext *page_ext;
-	unsigned long pad;
+	unsigned long pad[3];
 #endif
+
+	unsigned long first_pfn;
+	unsigned long last_pfn;
+
 	/*
 	 * WARNING: mem_section must be a power-of-2 in size for the
 	 * calculation and use of SECTION_ROOT_MASK to make sense.
@@ -1140,23 +1144,29 @@ static inline int valid_section_nr(unsigned long nr)
 
 static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 {
+	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+		return NULL;
+
 	return __nr_to_section(pfn_to_section_nr(pfn));
 }
 
 #ifndef CONFIG_HAVE_ARCH_PFN_VALID
 static inline int pfn_valid(unsigned long pfn)
 {
-	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+	struct mem_section *ms;
+
+	ms = __pfn_to_section(pfn);
+
+	if (ms && !(ms->first_pfn <= pfn && ms->last_pfn >= pfn))
 		return 0;
-	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
+
+	return valid_section(ms);
 }
 #endif
 
 static inline int pfn_present(unsigned long pfn)
 {
-	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
-		return 0;
-	return present_section(__nr_to_section(pfn_to_section_nr(pfn)));
+	return present_section(__pfn_to_section(pfn));
 }
 
 /*
diff --git a/mm/sparse.c b/mm/sparse.c
index 5d0cf45..3c91837 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -166,24 +166,59 @@ void __meminit mminit_validate_memmodel_limits(unsigned long *start_pfn,
 	}
 }
 
+static int __init
+overlaps(u64 start1, u64 end1, u64 start2, u64 end2)
+{
+	u64 start, end;
+
+	start = max(start1, start2);
+	end = min(end1, end2);
+	return start <= end;
+}
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
+	unsigned long first_pfn = start;
 	unsigned long pfn;
 
 	start &= PAGE_SECTION_MASK;
 	mminit_validate_memmodel_limits(&start, &end);
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
 		unsigned long section = pfn_to_section_nr(pfn);
+		unsigned long last_pfn = min(pfn + PAGES_PER_SECTION, end) - 1;
 		struct mem_section *ms;
 
 		sparse_index_init(section, nid);
 		set_section_nid(section, nid);
 
 		ms = __nr_to_section(section);
-		if (!ms->section_mem_map)
+		if (!ms->section_mem_map) {
 			ms->section_mem_map = sparse_encode_early_nid(nid) |
 							SECTION_MARKED_PRESENT;
+		} else {
+			/* Merge the two regions */
+			WARN_ON(sparse_early_nid(ms) != nid);
+
+			/*
+			 * If they don't overlap there will be a hole in
+			 * between where meta-data says it's valid even though
+			 * it's not.
+			 */
+			if (!overlaps(first_pfn, last_pfn + 1,
+				      ms->first_pfn, ms->last_pfn + 1))	{
+				pr_info("Merging non-contiguous pfn ranges 0x%lx-0x%lx and 0x%lx-0x%lx\n",
+					ms->first_pfn, ms->last_pfn,
+					first_pfn, last_pfn);
+			}
+			first_pfn = min(first_pfn, ms->first_pfn);
+			last_pfn = max(last_pfn, ms->last_pfn);
+		}
+
+		ms->first_pfn = first_pfn;
+		ms->last_pfn = last_pfn;
+
+		first_pfn = pfn + PAGES_PER_SECTION;
 	}
 }
 
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

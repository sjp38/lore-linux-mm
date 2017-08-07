Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 686D06B0292
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:15:03 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w187so5168634pgb.10
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:15:03 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b6si5581263pll.83.2017.08.07.07.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 07:15:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 01/13] mm, sparsemem: Allocate mem_section at runtime for SPARSEMEM_EXTREME
Date: Mon,  7 Aug 2017 17:14:39 +0300
Message-Id: <20170807141451.80934-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
References: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Size of mem_section array depends on size of physical address space.

In preparation for boot-time switching between paging modes on x86-64
we need to make allocation of mem_section dynamic.

The patch allocates the array on the first call to
sparse_memory_present_with_active_regions().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 10 ++++++++++
 mm/sparse.c            |  3 +--
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc14b8b3f6ce..c8eb668eab79 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1137,7 +1137,7 @@ struct mem_section {
 #define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
-extern struct mem_section *mem_section[NR_SECTION_ROOTS];
+extern struct mem_section **mem_section;
 #else
 extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d30e914afb6..639fd2dce0c4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5681,6 +5681,16 @@ void __init sparse_memory_present_with_active_regions(int nid)
 	unsigned long start_pfn, end_pfn;
 	int i, this_nid;
 
+#ifdef CONFIG_SPARSEMEM_EXTREME
+	if (!mem_section) {
+		unsigned long size, align;
+
+		size = sizeof(struct mem_section) * NR_SECTION_ROOTS;
+		align = 1 << (INTERNODE_CACHE_SHIFT);
+		mem_section = memblock_virt_alloc(size, align);
+	}
+#endif
+
 	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, &this_nid)
 		memory_present(this_nid, start_pfn, end_pfn);
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index 7b4be3fd5cac..3a226a8c1968 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -22,8 +22,7 @@
  * 1) mem_section	- memory sections, mem_map's for valid memory
  */
 #ifdef CONFIG_SPARSEMEM_EXTREME
-struct mem_section *mem_section[NR_SECTION_ROOTS]
-	____cacheline_internodealigned_in_smp;
+struct mem_section **mem_section;
 #else
 struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT]
 	____cacheline_internodealigned_in_smp;
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id C77076B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:09:34 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v70so11487041ywc.6
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:09:34 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n2si2943363ywd.96.2018.04.16.19.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:09:33 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/3] mm: change type of free_contig_range(nr_pages) to unsigned long
Date: Mon, 16 Apr 2018 19:09:13 -0700
Message-Id: <20180417020915.11786-2-mike.kravetz@oracle.com>
In-Reply-To: <20180417020915.11786-1-mike.kravetz@oracle.com>
References: <20180417020915.11786-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

free_contig_range() is currently defined as:
void free_contig_range(unsigned long pfn, unsigned nr_pages);
change to,
void free_contig_range(unsigned long pfn, unsigned long nr_pages);

Some callers are passing a truncated unsigned long today.  It is
highly unlikely that these values will overflow an unsigned int.
However, this should be changed to an unsigned long to be consistent
with other page counts.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/gfp.h | 2 +-
 mm/cma.c            | 2 +-
 mm/hugetlb.c        | 2 +-
 mm/page_alloc.c     | 6 +++---
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b44d32..86a0d06463ab 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -572,7 +572,7 @@ static inline bool pm_suspended_storage(void)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
-extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
+extern void free_contig_range(unsigned long pfn, unsigned long nr_pages);
 #endif
 
 #ifdef CONFIG_CMA
diff --git a/mm/cma.c b/mm/cma.c
index aa40e6c7b042..f473fc2b7cbd 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -563,7 +563,7 @@ bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
 
 	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
 
-	free_contig_range(pfn, count);
+	free_contig_range(pfn, (unsigned long)count);
 	cma_clear_bitmap(cma, pfn, count);
 	trace_cma_release(pfn, pages, count);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 218679138255..c81072ce7510 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1055,7 +1055,7 @@ static void destroy_compound_gigantic_page(struct page *page,
 
 static void free_gigantic_page(struct page *page, unsigned int order)
 {
-	free_contig_range(page_to_pfn(page), 1 << order);
+	free_contig_range(page_to_pfn(page), 1UL << order);
 }
 
 static int __alloc_gigantic_page(unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d7962f..0fd5e8e2456e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7937,9 +7937,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	return ret;
 }
 
-void free_contig_range(unsigned long pfn, unsigned nr_pages)
+void free_contig_range(unsigned long pfn, unsigned long nr_pages)
 {
-	unsigned int count = 0;
+	unsigned long count = 0;
 
 	for (; nr_pages--; pfn++) {
 		struct page *page = pfn_to_page(pfn);
@@ -7947,7 +7947,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 		count += page_count(page) != 1;
 		__free_page(page);
 	}
-	WARN(count != 0, "%d pages are still in use!\n", count);
+	WARN(count != 0, "%ld pages are still in use!\n", count);
 }
 #endif
 
-- 
2.13.6

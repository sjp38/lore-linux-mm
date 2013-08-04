Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id D9ABF6B004D
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:32 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 12/23] thp, mm: add event counters for huge page alloc on file write or read
Date: Sun,  4 Aug 2013 05:17:14 +0300
Message-Id: <1375582645-29274-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Existing stats specify source of thp page: fault or collapse. We're
going allocate a new huge page with write(2) and read(2). It's nither
fault nor collapse.

Let's introduce new events for that.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt | 7 +++++++
 include/linux/huge_mm.h        | 5 +++++
 include/linux/vm_event_item.h  | 4 ++++
 mm/vmstat.c                    | 4 ++++
 4 files changed, 20 insertions(+)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 4cc15c4..a78f738 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -202,6 +202,10 @@ thp_collapse_alloc is incremented by khugepaged when it has found
 	a range of pages to collapse into one huge page and has
 	successfully allocated a new huge page to store the data.
 
+thp_write_alloc and thp_read_alloc are incremented every time a huge
+	page is	successfully allocated to handle write(2) to a file or
+	read(2) from file.
+
 thp_fault_fallback is incremented if a page fault fails to allocate
 	a huge page and instead falls back to using small pages.
 
@@ -209,6 +213,9 @@ thp_collapse_alloc_failed is incremented if khugepaged found a range
 	of pages that should be collapsed into one huge page but failed
 	the allocation.
 
+thp_write_alloc_failed and thp_read_alloc_failed are incremented if
+	huge page allocation failed when tried on write(2) or read(2).
+
 thp_split is incremented every time a huge page is split into base
 	pages. This can happen for a variety of reasons but a common
 	reason is that a huge page is old and is being reclaimed.
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4dc66c9..9a0a114 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -183,6 +183,11 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
+#define THP_WRITE_ALLOC		({ BUILD_BUG(); 0; })
+#define THP_WRITE_ALLOC_FAILED	({ BUILD_BUG(); 0; })
+#define THP_READ_ALLOC		({ BUILD_BUG(); 0; })
+#define THP_READ_ALLOC_FAILED	({ BUILD_BUG(); 0; })
+
 #define hpage_nr_pages(x) 1
 
 #define transparent_hugepage_enabled(__vma) 0
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 1855f0a..8e071bb 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -66,6 +66,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_FAULT_FALLBACK,
 		THP_COLLAPSE_ALLOC,
 		THP_COLLAPSE_ALLOC_FAILED,
+		THP_WRITE_ALLOC,
+		THP_WRITE_ALLOC_FAILED,
+		THP_READ_ALLOC,
+		THP_READ_ALLOC_FAILED,
 		THP_SPLIT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ffe3fbd..a80ea59 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -815,6 +815,10 @@ const char * const vmstat_text[] = {
 	"thp_fault_fallback",
 	"thp_collapse_alloc",
 	"thp_collapse_alloc_failed",
+	"thp_write_alloc",
+	"thp_write_alloc_failed",
+	"thp_read_alloc",
+	"thp_read_alloc_failed",
 	"thp_split",
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

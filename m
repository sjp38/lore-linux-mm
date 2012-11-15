Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 80F426B007B
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 14:26:10 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v6 11/12] thp, vmstat: implement HZP_ALLOC and HZP_ALLOC_FAILED events
Date: Thu, 15 Nov 2012 21:27:01 +0200
Message-Id: <1353007622-18393-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

hzp_alloc is incremented every time a huge zero page is successfully
	allocated. It includes allocations which where dropped due
	race with other allocation. Note, it doesn't count every map
	of the huge zero page, only its allocation.

hzp_alloc_failed is incremented if kernel fails to allocate huge zero
	page and falls back to using small pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt | 8 ++++++++
 include/linux/vm_event_item.h  | 2 ++
 mm/huge_memory.c               | 5 ++++-
 mm/vmstat.c                    | 2 ++
 4 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 8f5b41d..60aeedd 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -197,6 +197,14 @@ thp_split is incremented every time a huge page is split into base
 	pages. This can happen for a variety of reasons but a common
 	reason is that a huge page is old and is being reclaimed.
 
+thp_zero_page_alloc is incremented every time a huge zero page is
+	successfully allocated. It includes allocations which where
+	dropped due race with other allocation. Note, it doesn't count
+	every map of the huge zero page, only its allocation.
+
+thp_zero_page_alloc_failed is incremented if kernel fails to allocate
+	huge zero page and falls back to using small pages.
+
 As the system ages, allocating huge pages may be expensive as the
 system uses memory compaction to copy data around memory to free a
 huge page for use. There are some counters in /proc/vmstat to help
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 3d31145..fe786f0 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -58,6 +58,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_COLLAPSE_ALLOC,
 		THP_COLLAPSE_ALLOC_FAILED,
 		THP_SPLIT,
+		THP_ZERO_PAGE_ALLOC,
+		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
 		NR_VM_EVENT_ITEMS
 };
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 923ea75..b104718 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -183,8 +183,11 @@ retry:
 
 	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
 			HPAGE_PMD_ORDER);
-	if (!zero_page)
+	if (!zero_page) {
+		count_vm_event(THP_ZERO_PAGE_ALLOC_FAILED);
 		return 0;
+	}
+	count_vm_event(THP_ZERO_PAGE_ALLOC);
 	preempt_disable();
 	if (cmpxchg(&huge_zero_pfn, 0, page_to_pfn(zero_page))) {
 		preempt_enable();
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c737057..5da4b19 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -801,6 +801,8 @@ const char * const vmstat_text[] = {
 	"thp_collapse_alloc",
 	"thp_collapse_alloc_failed",
 	"thp_split",
+	"thp_zero_page_alloc",
+	"thp_zero_page_alloc_failed",
 #endif
 
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

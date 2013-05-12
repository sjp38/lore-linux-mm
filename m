Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 11F286B004D
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:38 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 18/39] thp, mm: add event counters for huge page alloc on write to a file
Date: Sun, 12 May 2013 04:23:15 +0300
Message-Id: <1368321816-17719-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Existing stats specify source of thp page: fault or collapse. We're
going allocate a new huge page with write(2). It's nither fault nor
collapse.

Let's introduce new events for that.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/vm_event_item.h |    2 ++
 mm/vmstat.c                   |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index d4b7a18..584c71c 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -71,6 +71,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_FAULT_FALLBACK,
 		THP_COLLAPSE_ALLOC,
 		THP_COLLAPSE_ALLOC_FAILED,
+		THP_WRITE_ALLOC,
+		THP_WRITE_ALLOC_FAILED,
 		THP_SPLIT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7945285..df8dcda 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -821,6 +821,8 @@ const char * const vmstat_text[] = {
 	"thp_fault_fallback",
 	"thp_collapse_alloc",
 	"thp_collapse_alloc_failed",
+	"thp_write_alloc",
+	"thp_write_alloc_failed",
 	"thp_split",
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

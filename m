Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFA346B0265
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:01:17 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id lp2so147517711igb.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:01:17 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id g10si32695264pac.240.2016.06.07.04.01.01
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 07/32] thp, vmstats: add counters for huge file pages
Date: Tue,  7 Jun 2016 14:00:21 +0300
Message-Id: <1465297246-98985-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

THP_FILE_ALLOC: how many times huge page was allocated and put page
cache.

THP_FILE_MAPPED: how many times file huge page was mapped.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/vm_event_item.h | 7 +++++++
 mm/memory.c                   | 1 +
 mm/vmstat.c                   | 2 ++
 3 files changed, 10 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index ec084321fe09..42604173f122 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -70,6 +70,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_FAULT_FALLBACK,
 		THP_COLLAPSE_ALLOC,
 		THP_COLLAPSE_ALLOC_FAILED,
+		THP_FILE_ALLOC,
+		THP_FILE_MAPPED,
 		THP_SPLIT_PAGE,
 		THP_SPLIT_PAGE_FAILED,
 		THP_DEFERRED_SPLIT_PAGE,
@@ -100,4 +102,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		NR_VM_EVENT_ITEMS
 };
 
+#ifndef CONFIG_TRANSPARENT_HUGEPAGE
+#define THP_FILE_ALLOC ({ BUILD_BUG(); 0; })
+#define THP_FILE_MAPPED ({ BUILD_BUG(); 0; })
+#endif
+
 #endif		/* VM_EVENT_ITEM_H_INCLUDED */
diff --git a/mm/memory.c b/mm/memory.c
index ebcec3f9ca06..7f2e16e9f0cb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2969,6 +2969,7 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 
 	/* fault is handled */
 	ret = 0;
+	count_vm_event(THP_FILE_MAPPED);
 out:
 	spin_unlock(fe->ptl);
 	return ret;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 076c39e3ba09..68693857397c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -829,6 +829,8 @@ const char * const vmstat_text[] = {
 	"thp_fault_fallback",
 	"thp_collapse_alloc",
 	"thp_collapse_alloc_failed",
+	"thp_file_alloc",
+	"thp_file_mapped",
 	"thp_split_page",
 	"thp_split_page_failed",
 	"thp_deferred_split_page",
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

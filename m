Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3DCCC6B0268
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:39 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bx7so25475841pad.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id by4si2256824pad.130.2016.04.06.15.51.31
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 07/30] thp, vmstats: add counters for huge file pages
Date: Thu,  7 Apr 2016 01:50:57 +0300
Message-Id: <1459983080-106718-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index f9054d5f7775..c41804c0d524 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2914,6 +2914,7 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 
 	/* fault is handled */
 	ret = 0;
+	count_vm_event(THP_FILE_MAPPED);
 out:
 	spin_unlock(fe->ptl);
 	return ret;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5e4300482897..b898bc35b214 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -846,6 +846,8 @@ const char * const vmstat_text[] = {
 	"thp_fault_fallback",
 	"thp_collapse_alloc",
 	"thp_collapse_alloc_failed",
+	"thp_file_alloc",
+	"thp_file_mapped",
 	"thp_split_page",
 	"thp_split_page_failed",
 	"thp_deferred_split_page",
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

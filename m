Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D98F8294C
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 10:08:21 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w9so90579833oia.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 07:08:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 4si19998679paf.244.2016.06.06.07.08.14
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 07:08:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 07/32] thp, vmstats: add counters for huge file pages
Date: Mon,  6 Jun 2016 17:06:44 +0300
Message-Id: <1465222029-45942-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index ed4aa61f6471..a6744be151b6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2954,6 +2954,7 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 
 	/* fault is handled */
 	ret = 0;
+	count_vm_event(THP_FILE_MAPPED);
 out:
 	spin_unlock(fe->ptl);
 	return ret;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6629944ea820..0b57cd0a844e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -827,6 +827,8 @@ const char * const vmstat_text[] = {
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

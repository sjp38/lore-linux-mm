Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46D106B0265
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:07:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so63721448pfa.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:07:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f6si962682pfc.249.2016.06.15.13.06.59
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:06:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 12/37] thp, vmstats: add counters for huge file pages
Date: Wed, 15 Jun 2016 23:06:17 +0300
Message-Id: <1466021202-61880-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 6c0ebbc680d4..843ddd7bcf3d 100644
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
index 2a0f26bdae39..cff2f4ec9cce 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -817,6 +817,8 @@ const char * const vmstat_text[] = {
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7346B039B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 06:54:23 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 2so8766408oif.7
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 03:54:23 -0800 (PST)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id k3si709914oib.42.2017.02.28.03.54.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Feb 2017 03:54:22 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] mm/vmstats: add thp_split_pud event for clarify
Date: Tue, 28 Feb 2017 19:46:20 +0800
Message-ID: <1488282380-5076-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, hannes@cmpxchg.org, mhocko@suse.com, iamjoonsoo.kim@lge.com, bigeasy@linutronix.de, hughd@google.com, cl@linux.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, ebru.akagunduz@gmail.com, willy@linux.intel.com, rientjes@google.com, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We added supporting for PUD-sized transparent hugepages, however count
the event "thp split pud" into thp_split_pmd event.

To clarify the event count of thp split pud from pmd, this patch add a
new event named thp_split_pud.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 include/linux/vm_event_item.h | 3 +++
 mm/huge_memory.c              | 2 +-
 mm/vmstat.c                   | 3 +++
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 6aa1b6c..a80b7b5 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -79,6 +79,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_SPLIT_PAGE_FAILED,
 		THP_DEFERRED_SPLIT_PAGE,
 		THP_SPLIT_PMD,
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+		THP_SPLIT_PUD,
+#endif
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 71e3ded..0bfcd72 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1826,7 +1826,7 @@ static void __split_huge_pud_locked(struct vm_area_struct *vma, pud_t *pud,
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PUD_SIZE, vma);
 	VM_BUG_ON(!pud_trans_huge(*pud) && !pud_devmap(*pud));
 
-	count_vm_event(THP_SPLIT_PMD);
+	count_vm_event(THP_SPLIT_PUD);
 
 	pudp_huge_clear_flush_notify(vma, haddr, pud);
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 69f9aff..b1947f0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1065,6 +1065,9 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"thp_split_page_failed",
 	"thp_deferred_split_page",
 	"thp_split_pmd",
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	"thp_split_pud",
+#endif
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

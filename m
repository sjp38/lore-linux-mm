Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4466B0036
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 19:57:30 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wo20so121343obc.17
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 16:57:29 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id n4si15170686oew.90.2014.04.14.16.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 16:57:28 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 2/3] mm,vmacache: add debug data
Date: Mon, 14 Apr 2014 16:57:20 -0700
Message-Id: <1397519841-24847-3-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
References: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, davidlohr@hp.com, aswin@hp.com

Introduce a CONFIG_DEBUG_VM_VMACACHE option to enable
counting the cache hit rate -- exported in /proc/vmstat.

Any updates to the caching scheme needs this kind of data,
thus it can save some work re-implementing the counting
all the time.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/vm_event_item.h |  4 ++++
 include/linux/vmstat.h        |  6 ++++++
 lib/Kconfig.debug             | 10 ++++++++++
 mm/vmacache.c                 |  9 ++++++++-
 mm/vmstat.c                   |  4 ++++
 5 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 486c397..ced9234 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -80,6 +80,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		NR_TLB_LOCAL_FLUSH_ALL,
 		NR_TLB_LOCAL_FLUSH_ONE,
 #endif /* CONFIG_DEBUG_TLBFLUSH */
+#ifdef CONFIG_DEBUG_VM_VMACACHE
+		VMACACHE_FIND_CALLS,
+		VMACACHE_FIND_HITS,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 45c9cd1..82e7db7 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -95,6 +95,12 @@ static inline void vm_events_fold_cpu(int cpu)
 #define count_vm_tlb_events(x, y) do { (void)(y); } while (0)
 #endif
 
+#ifdef CONFIG_DEBUG_VM_VMACACHE
+#define count_vm_vmacache_event(x) count_vm_event(x)
+#else
+#define count_vm_vmacache_event(x) do {} while (0)
+#endif
+
 #define __count_zone_vm_events(item, zone, delta) \
 		__count_vm_events(item##_NORMAL - ZONE_NORMAL + \
 		zone_idx(zone), delta)
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 819ac51..9ed3d9b 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -501,6 +501,16 @@ config DEBUG_VM
 
 	  If unsure, say N.
 
+config DEBUG_VM_VMACACHE
+	bool "Debug VMA caching"
+	depends on DEBUG_VM
+	help
+	  Enable this to turn on VMA caching debug information. Doing so
+	  can cause significant overhead, so only enable it in non-production
+	  environments.
+
+	  If unsure, say N.
+
 config DEBUG_VM_RB
 	bool "Debug VM red-black trees"
 	depends on DEBUG_VM
diff --git a/mm/vmacache.c b/mm/vmacache.c
index d4224b3..e167da2 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -78,11 +78,14 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
 	if (!vmacache_valid(mm))
 		return NULL;
 
+	count_vm_vmacache_event(VMACACHE_FIND_CALLS);
+
 	for (i = 0; i < VMACACHE_SIZE; i++) {
 		struct vm_area_struct *vma = current->vmacache[i];
 
 		if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
 			BUG_ON(vma->vm_mm != mm);
+			count_vm_vmacache_event(VMACACHE_FIND_HITS);
 			return vma;
 		}
 	}
@@ -100,11 +103,15 @@ struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
 	if (!vmacache_valid(mm))
 		return NULL;
 
+	count_vm_vmacache_event(VMACACHE_FIND_CALLS);
+
 	for (i = 0; i < VMACACHE_SIZE; i++) {
 		struct vm_area_struct *vma = current->vmacache[i];
 
-		if (vma && vma->vm_start == start && vma->vm_end == end)
+		if (vma && vma->vm_start == start && vma->vm_end == end) {
+			count_vm_vmacache_event(VMACACHE_FIND_HITS);
 			return vma;
+		}
 	}
 
 	return NULL;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 302dd07..82ce17c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -866,6 +866,10 @@ const char * const vmstat_text[] = {
 	"nr_tlb_local_flush_one",
 #endif /* CONFIG_DEBUG_TLBFLUSH */
 
+#ifdef CONFIG_DEBUG_VM_VMACACHE
+	"vmacache_find_calls",
+	"vmacache_find_hits",
+#endif
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

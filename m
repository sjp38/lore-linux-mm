Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DDFD6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 19:37:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l87so5637485pfj.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 16:37:24 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m1si673836pgm.668.2017.08.31.16.37.22
        for <linux-mm@kvack.org>;
        Thu, 31 Aug 2017 16:37:23 -0700 (PDT)
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Subject: [PATCH] mm/vmstats: add counters for the page frag cache
Date: Fri,  1 Sep 2017 08:37:11 +0900
Message-Id: <1504222631-2635-1-git-send-email-kyeongdon.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, sfr@canb.auug.org.au
Cc: ying.huang@intel.com, vbabka@suse.cz, hannes@cmpxchg.org, xieyisheng1@huawei.com, khlebnikov@yandex-team.ru, luto@kernel.org, shli@fb.com, mhocko@suse.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, kemi.wang@intel.com, rientjes@google.com, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, bongkyu.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyeongdon Kim <kyeongdon.kim@lge.com>

There was a memory leak problem when we did stressful test
on Android device.
The root cause of this was from page_frag_cache alloc
and it was very hard to find out.

We add to count the page frag allocation and free with function call.
The gap between pgfrag_alloc and pgfrag_free is good to to calculate
for the amount of page.
The gap between pgfrag_alloc_calls and pgfrag_free_calls is for
sub-indicator.
They can see trends of memory usage during the test.
Without it, it's difficult to check page frag usage so I believe we
should add it.

Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
---
 include/linux/vm_event_item.h | 4 ++++
 mm/page_alloc.c               | 9 +++++++--
 mm/vmstat.c                   | 4 ++++
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index d77bc35..75425d4 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -110,6 +110,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		SWAP_RA,
 		SWAP_RA_HIT,
 #endif
+		PGFRAG_ALLOC,
+		PGFRAG_FREE,
+		PGFRAG_ALLOC_CALLS,
+		PGFRAG_FREE_CALLS,
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index db2d25f..b3ddd76 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4322,6 +4322,7 @@ void __page_frag_cache_drain(struct page *page, unsigned int count)
 			free_hot_cold_page(page, false);
 		else
 			__free_pages_ok(page, order);
+		__count_vm_events(PGFRAG_FREE, 1 << order);
 	}
 }
 EXPORT_SYMBOL(__page_frag_cache_drain);
@@ -4338,7 +4339,7 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		page = __page_frag_cache_refill(nc, gfp_mask);
 		if (!page)
 			return NULL;
-
+		__count_vm_events(PGFRAG_ALLOC, 1 << compound_order(page));
 #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
 		/* if size can vary use size else just use PAGE_SIZE */
 		size = nc->size;
@@ -4375,6 +4376,7 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 
 	nc->pagecnt_bias--;
 	nc->offset = offset;
+	__count_vm_event(PGFRAG_ALLOC_CALLS);
 
 	return nc->va + offset;
 }
@@ -4387,8 +4389,11 @@ void page_frag_free(void *addr)
 {
 	struct page *page = virt_to_head_page(addr);
 
-	if (unlikely(put_page_testzero(page)))
+	if (unlikely(put_page_testzero(page))) {
+		__count_vm_events(PGFRAG_FREE, 1 << compound_order(page));
 		__free_pages_ok(page, compound_order(page));
+	}
+	__count_vm_event(PGFRAG_FREE_CALLS);
 }
 EXPORT_SYMBOL(page_frag_free);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4bb13e7..c00fe05 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1217,6 +1217,10 @@ const char * const vmstat_text[] = {
 	"swap_ra",
 	"swap_ra_hit",
 #endif
+	"pgfrag_alloc",
+	"pgfrag_free",
+	"pgfrag_alloc_calls",
+	"pgfrag_free_calls",
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

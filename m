Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB3396B0269
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:19:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so83111384wma.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:58 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 65si77183141wmo.84.2017.01.04.02.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 02:19:57 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id l2so65330601wml.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:57 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate tracepoint
Date: Wed,  4 Jan 2017 11:19:39 +0100
Message-Id: <20170104101942.4860-5-mhocko@kernel.org>
In-Reply-To: <20170104101942.4860-1-mhocko@kernel.org>
References: <20170104101942.4860-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
from is file or anonymous but we do not know which LRU this is.

It is useful to know whether the list is active or inactive, since we
are using the same function to isolate pages from both of them and it's
hard to distinguish otherwise.

Chaneges since v1
- drop LRU_ prefix from names and use lowercase as per Vlastimil
- move and convert show_lru_name to mmflags.h EM magic as per Vlastimil

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/mmflags.h |  8 ++++++++
 include/trace/events/vmscan.h  | 12 ++++++------
 mm/vmscan.c                    |  2 +-
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index aa4caa6914a9..6172afa2fd82 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -240,6 +240,13 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
 				EMe(ZONE_MOVABLE,"Movable")
 
+#define LRU_NAMES		\
+		EM (LRU_INACTIVE_ANON, "inactive_anon") \
+		EM (LRU_ACTIVE_ANON, "active_anon") \
+		EM (LRU_INACTIVE_FILE, "inactive_file") \
+		EM (LRU_ACTIVE_FILE, "active_file") \
+		EMe(LRU_UNEVICTABLE, "unevictable")
+
 /*
  * First define the enums in the above macros to be exported to userspace
  * via TRACE_DEFINE_ENUM().
@@ -253,6 +260,7 @@ COMPACTION_STATUS
 COMPACTION_PRIORITY
 COMPACTION_FEEDBACK
 ZONE_TYPE
+LRU_NAMES
 
 /*
  * Now redefine the EM() and EMe() macros to map the enums to the strings
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 36c999f806bf..7ec59e0432c4 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -277,9 +277,9 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		unsigned long nr_skipped,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
-		int file),
+		int lru),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, file),
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, lru),
 
 	TP_STRUCT__entry(
 		__field(int, classzone_idx)
@@ -289,7 +289,7 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		__field(unsigned long, nr_skipped)
 		__field(unsigned long, nr_taken)
 		__field(isolate_mode_t, isolate_mode)
-		__field(int, file)
+		__field(int, lru)
 	),
 
 	TP_fast_assign(
@@ -300,10 +300,10 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		__entry->nr_skipped = nr_skipped;
 		__entry->nr_taken = nr_taken;
 		__entry->isolate_mode = isolate_mode;
-		__entry->file = file;
+		__entry->lru = lru;
 	),
 
-	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_skipped=%lu nr_taken=%lu file=%d",
+	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_skipped=%lu nr_taken=%lu lru=%s",
 		__entry->isolate_mode,
 		__entry->classzone_idx,
 		__entry->order,
@@ -311,7 +311,7 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		__entry->nr_scanned,
 		__entry->nr_skipped,
 		__entry->nr_taken,
-		__entry->file)
+		__print_symbolic(__entry->lru, LRU_NAMES))
 );
 
 TRACE_EVENT(mm_vmscan_writepage,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 31c623d5acb4..13758aaed78b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1500,7 +1500,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	}
 	*nr_scanned = scan + total_skipped;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
-				    skipped, nr_taken, mode, is_file_lru(lru));
+				    skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);
 	return nr_taken;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

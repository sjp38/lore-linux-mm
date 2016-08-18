Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD296B025F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 01:40:10 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so16234242pad.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 22:40:10 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id w8si664278paj.25.2016.08.17.22.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 22:40:07 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id y134so1104941pfg.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 22:40:06 -0700 (PDT)
Date: Thu, 18 Aug 2016 01:38:29 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH v2 1/2] include: trace: Display names of shrinker callbacks
Message-ID: <fef90fda665f7865ce0f6a3cfebb2cd659a48e5d.1471496833.git.janani.rvchndrn@gmail.com>
References: <cover.1471496832.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1471496832.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

This patch enables the names of callbacks in mm_shrink_slab_start and
mm_shrink_slab_end to be seen by userspace tools.
This should give some information regarding the identity of the
shrinkers being run.

Signed-off-by: Janani Ravichandran <janani.rvchndrn@gmail.com>
---
 include/trace/events/vmscan.h | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c88fd09..7091c29 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -16,6 +16,8 @@
 #define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim async */
 #define RECLAIM_WB_ASYNC	0x0008u
 
+#define SHRINKER_NAME_LEN	(size_t)32
+
 #define show_reclaim_flags(flags)				\
 	(flags) ? __print_flags(flags, "|",			\
 		{RECLAIM_WB_ANON,	"RECLAIM_WB_ANON"},	\
@@ -196,6 +198,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
 		__field(void *, shrink)
+		__array(char, shrinker_name, SHRINKER_NAME_LEN)
 		__field(int, nid)
 		__field(long, nr_objects_to_shrink)
 		__field(gfp_t, gfp_flags)
@@ -207,8 +210,12 @@ TRACE_EVENT(mm_shrink_slab_start,
 	),
 
 	TP_fast_assign(
+		char sym[KSYM_SYMBOL_LEN];
+
 		__entry->shr = shr;
 		__entry->shrink = shr->scan_objects;
+		sprint_symbol(sym, (unsigned long)__entry->shrink);
+		strlcpy(__entry->shrinker_name, sym, SHRINKER_NAME_LEN);
 		__entry->nid = sc->nid;
 		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
 		__entry->gfp_flags = sc->gfp_mask;
@@ -219,9 +226,10 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+	TP_printk("%pF %p name:%s nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
 		__entry->shrink,
 		__entry->shr,
+		__entry->shrinker_name,
 		__entry->nid,
 		__entry->nr_objects_to_shrink,
 		show_gfp_flags(__entry->gfp_flags),
@@ -242,6 +250,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
 		__field(int, nid)
+		__array(char, shrinker_name, SHRINKER_NAME_LEN)
 		__field(void *, shrink)
 		__field(long, unused_scan)
 		__field(long, new_scan)
@@ -250,18 +259,23 @@ TRACE_EVENT(mm_shrink_slab_end,
 	),
 
 	TP_fast_assign(
+		char sym[KSYM_SYMBOL_LEN];
+
 		__entry->shr = shr;
 		__entry->nid = nid;
 		__entry->shrink = shr->scan_objects;
+		sprint_symbol(sym, (unsigned long)__entry->shrink);
+		strlcpy(__entry->shrinker_name, sym, SHRINKER_NAME_LEN);
 		__entry->unused_scan = unused_scan_cnt;
 		__entry->new_scan = new_scan_cnt;
 		__entry->retval = shrinker_retval;
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pF %p name:%s nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
 		__entry->shrink,
 		__entry->shr,
+		__entry->shrinker_name,
 		__entry->nid,
 		__entry->unused_scan,
 		__entry->new_scan,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

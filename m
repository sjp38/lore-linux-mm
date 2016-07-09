Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2BE66B025E
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 05:06:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so141134038pfa.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 02:06:53 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id uq7si22299pac.217.2016.07.09.02.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 02:06:53 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t190so9974706pfb.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 02:06:53 -0700 (PDT)
Date: Sat, 9 Jul 2016 05:05:33 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH 3/3] Add name fields in shrinker tracepoint definitions
Message-ID: <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1468051277.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

Currently, the mm_shrink_slab_start and mm_shrink_slab_end
tracepoints tell us how much time was spent in a shrinker, the number of
objects scanned, etc. But there is no information about the identity of
the shrinker. This patch enables the trace output to display names of
shrinkers.

---
 include/trace/events/vmscan.h | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 0101ef3..be4c5b0 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -189,6 +189,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 		cache_items, delta, total_scan),
 
 	TP_STRUCT__entry(
+		__field(char *, name)
 		__field(struct shrinker *, shr)
 		__field(void *, shrink)
 		__field(int, nid)
@@ -202,6 +203,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 	),
 
 	TP_fast_assign(
+		__entry->name = shr->name;
 		__entry->shr = shr;
 		__entry->shrink = shr->scan_objects;
 		__entry->nid = sc->nid;
@@ -214,7 +216,8 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+	TP_printk("name: %s %pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+		__entry->name,
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
@@ -235,6 +238,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 		total_scan),
 
 	TP_STRUCT__entry(
+		__field(char *, name)
 		__field(struct shrinker *, shr)
 		__field(int, nid)
 		__field(void *, shrink)
@@ -245,6 +249,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 	),
 
 	TP_fast_assign(
+		__entry->name = shr->name;
 		__entry->shr = shr;
 		__entry->nid = nid;
 		__entry->shrink = shr->scan_objects;
@@ -254,7 +259,8 @@ TRACE_EVENT(mm_shrink_slab_end,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("name: %s %pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+		__entry->name,
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

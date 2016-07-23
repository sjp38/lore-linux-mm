Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA646B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 00:05:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so45672929wma.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 21:05:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si7782422wmd.29.2016.07.22.21.05.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 21:05:39 -0700 (PDT)
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <9c67941f-05f0-0d3e-ecc8-dcea60254c8b@suse.de>
From: Tony Jones <tonyj@suse.de>
Message-ID: <8663a3c5-7b9b-c5b5-cddd-224e97171921@suse.de>
Date: Fri, 22 Jul 2016 21:05:31 -0700
MIME-Version: 1.0
In-Reply-To: <9c67941f-05f0-0d3e-ecc8-dcea60254c8b@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/22/2016 06:27 PM, Tony Jones wrote:
> On 07/20/2016 07:54 AM, Michal Hocko wrote:
> 
>>> Michal, just to make sure I understand you correctly, do you mean that we
>>> could infer the names of the shrinkers by looking at the names of their callbacks?
>>
>> Yes, %ps can then be used for the name of the shrinker structure
>> (assuming it is available).
> 
> This is fine for emitting via the ftrace /sys interface,  but in order to have the data [name] get 
> marshalled thru to perf (for example) you need to add it to the TP_fast_assign entry.
> 
> tony

Unfortunately, %ps/%pF doesn't do much (re:  Michal's comment "assuming it is available"):

-       TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+       TP_printk("%pF %p(%ps): nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
                __entry->shrink,
                __entry->shr,
+               __entry->shr,
                __entry->nid,
                __entry->nr_objects_to_shrink,

# cat trace_pipe
            bash-1917  [003] ...1  2925.941062: mm_shrink_slab_start: super_cache_scan+0x0/0x1a0 ffff88042bb60cc0(0xffff88042bb60cc0): nid: 0 objects to shrink 0 gfp_flags GFP_KERNEL pgs_scanned 1000 lru_pgs 1000 cache items 4 delta 7 total_scan 7


Otherwise what I was suggesting was something like this to ensure it was correctly marshaled for perf/etc:

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -16,6 +16,8 @@
 #define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim async */
 #define RECLAIM_WB_ASYNC	0x0008u
 
+#define SHRINKER_NAME_LEN 	(size_t)32
+
 #define show_reclaim_flags(flags)				\
 	(flags) ? __print_flags(flags, "|",			\
 		{RECLAIM_WB_ANON,	"RECLAIM_WB_ANON"},	\
@@ -191,6 +193,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
 		__field(void *, shrink)
+		__array(char, name, SHRINKER_NAME_LEN);
 		__field(int, nid)
 		__field(long, nr_objects_to_shrink)
 		__field(gfp_t, gfp_flags)
@@ -202,6 +205,11 @@ TRACE_EVENT(mm_shrink_slab_start,
 	),
 
 	TP_fast_assign(
+		char sym[KSYM_SYMBOL_LEN];
+
+		sprint_symbol(sym, (unsigned long)shr);
+		strlcpy(__entry->name, sym, SHRINKER_NAME_LEN);
+
 		__entry->shr = shr;
 		__entry->shrink = shr->scan_objects;
 		__entry->nid = sc->nid;
@@ -214,9 +222,10 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+	TP_printk("%pF %p(%s): nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
 		__entry->shrink,
 		__entry->shr,
+		__entry->name,
 		__entry->nid,
 		__entry->nr_objects_to_shrink,
 		show_gfp_flags(__entry->gfp_flags),
@@ -236,6 +245,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
+		__array(char, name, SHRINKER_NAME_LEN);
 		__field(int, nid)
 		__field(void *, shrink)
 		__field(long, unused_scan)
@@ -245,6 +255,11 @@ TRACE_EVENT(mm_shrink_slab_end,
 	),
 
 	TP_fast_assign(
+		char sym[KSYM_SYMBOL_LEN];
+
+		sprint_symbol(sym, (unsigned long)shr);
+		strlcpy(__entry->name, sym, SHRINKER_NAME_LEN);
+
 		__entry->shr = shr;
 		__entry->nid = nid;
 		__entry->shrink = shr->scan_objects;
@@ -254,9 +269,10 @@ TRACE_EVENT(mm_shrink_slab_end,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pF %p(%pF): nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
 		__entry->shrink,
 		__entry->shr,
+		__entry->shr,
 		__entry->nid,
 		__entry->unused_scan,
 		__entry->new_scan,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

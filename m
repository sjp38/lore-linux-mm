Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF166B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 20:35:36 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so20827236lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 17:35:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m204si6944645wmd.45.2016.07.12.17.35.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 17:35:35 -0700 (PDT)
Subject: Re: [PATCH 3/3] Add name fields in shrinker tracepoint definitions
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com>
 <447d8214-3c3d-cc4a-2eff-a47923fbe45f@suse.cz>
From: Tony Jones <tonyj@suse.de>
Message-ID: <ed4c8fa0-d727-c014-58c5-efe3a191f2ec@suse.de>
Date: Tue, 12 Jul 2016 17:35:28 -0700
MIME-Version: 1.0
In-Reply-To: <447d8214-3c3d-cc4a-2eff-a47923fbe45f@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/11/2016 07:18 AM, Vlastimil Babka wrote:
> On 07/09/2016 11:05 AM, Janani Ravichandran wrote:
>> Currently, the mm_shrink_slab_start and mm_shrink_slab_end
>> tracepoints tell us how much time was spent in a shrinker, the number of
>> objects scanned, etc. But there is no information about the identity of
>> the shrinker. This patch enables the trace output to display names of
>> shrinkers.
>>
>> ---
>>  include/trace/events/vmscan.h | 10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
>> index 0101ef3..be4c5b0 100644
>> --- a/include/trace/events/vmscan.h
>> +++ b/include/trace/events/vmscan.h
>> @@ -189,6 +189,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>>  		cache_items, delta, total_scan),
>>
>>  	TP_STRUCT__entry(
>> +		__field(char *, name)
>>  		__field(struct shrinker *, shr)
>>  		__field(void *, shrink)
>>  		__field(int, nid)
>> @@ -202,6 +203,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>>  	),
>>
>>  	TP_fast_assign(
>> +		__entry->name = shr->name;
>>  		__entry->shr = shr;
>>  		__entry->shrink = shr->scan_objects;
>>  		__entry->nid = sc->nid;
>> @@ -214,7 +216,8 @@ TRACE_EVENT(mm_shrink_slab_start,
>>  		__entry->total_scan = total_scan;
>>  	),
>>
>> -	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
>> +	TP_printk("name: %s %pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
>> +		__entry->name,
> 
> Is this legal to do when printing is not done via the /sys ... file 
> itself, but raw data is collected and then printed by e.g. trace-cmd? 
> How can it possibly interpret the "char *" kernel pointer?

I actually had a similar patch set to this,  I was going to post it but Janani beat me to it ;-)

Vlastimil is correct,  I'll attach my patch below so you can see the difference.  Otherwise you won't get correct behavior passing through perf.   

I also have a patch which adds a similar latency script (python) but interfaces it into the perf script setup.

Tony

---

Pass shrinker name in shrink slab tracepoints

Signed-off-by: Tony Jones <tonyj@suse.de>
---
 include/trace/events/vmscan.h | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 0101ef3..0a15948 100644
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
@@ -190,6 +192,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
+		__array(char, name, SHRINKER_NAME_LEN)
 		__field(void *, shrink)
 		__field(int, nid)
 		__field(long, nr_objects_to_shrink)
@@ -203,6 +206,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 	TP_fast_assign(
 		__entry->shr = shr;
+		strlcpy(__entry->name, shr->name, SHRINKER_NAME_LEN);
 		__entry->shrink = shr->scan_objects;
 		__entry->nid = sc->nid;
 		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
@@ -214,9 +218,10 @@ TRACE_EVENT(mm_shrink_slab_start,
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
@@ -236,6 +241,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
+		__array(char, name, SHRINKER_NAME_LEN)
 		__field(int, nid)
 		__field(void *, shrink)
 		__field(long, unused_scan)
@@ -246,6 +252,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 	TP_fast_assign(
 		__entry->shr = shr;
+		strlcpy(__entry->name, shr->name, SHRINKER_NAME_LEN);
 		__entry->nid = nid;
 		__entry->shrink = shr->scan_objects;
 		__entry->unused_scan = unused_scan_cnt;
@@ -254,9 +261,10 @@ TRACE_EVENT(mm_shrink_slab_end,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pF %p(%s): nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
 		__entry->shrink,
 		__entry->shr,
+		__entry->name,
 		__entry->nid,
 		__entry->unused_scan,
 		__entry->new_scan,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

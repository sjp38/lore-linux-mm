Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26A246B0260
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 09:25:15 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so75283876lfg.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:25:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p7si31359076wjm.211.2016.08.01.06.25.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 06:25:13 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: compaction.c: Add/Modify direct compaction
 tracepoints
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
 <7d2c2beef96e76cb01a21eee85ba5611bceb4307.1469629027.git.janani.rvchndrn@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7ab4a23a-1311-9579-2d58-263bbcdcd725@suse.cz>
Date: Mon, 1 Aug 2016 15:25:09 +0200
MIME-Version: 1.0
In-Reply-To: <7d2c2beef96e76cb01a21eee85ba5611bceb4307.1469629027.git.janani.rvchndrn@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org

On 07/27/2016 04:51 PM, Janani Ravichandran wrote:
> Add zone information to an existing tracepoint in compact_zone(). Also,
> add a new tracepoint at the end of the compaction code so that latency
> information can be derived.
>
> Signed-off-by: Janani Ravichandran <janani.rvchndrn@gmail.com>
> ---
>  include/trace/events/compaction.h | 38 +++++++++++++++++++++++++++++++++-----
>  mm/compaction.c                   |  6 ++++--
>  2 files changed, 37 insertions(+), 7 deletions(-)
>
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index 36e2d6f..4d86769 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -158,12 +158,15 @@ TRACE_EVENT(mm_compaction_migratepages,
>  );
>
>  TRACE_EVENT(mm_compaction_begin,
> -	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
> -		unsigned long free_pfn, unsigned long zone_end, bool sync),
> +	TP_PROTO(struct zone *zone, unsigned long zone_start,
> +		unsigned long migrate_pfn, unsigned long free_pfn,
> +		unsigned long zone_end, bool sync),
>
> -	TP_ARGS(zone_start, migrate_pfn, free_pfn, zone_end, sync),
> +	TP_ARGS(zone, zone_start, migrate_pfn, free_pfn, zone_end, sync),
>
>  	TP_STRUCT__entry(
> +		__field(int, nid)
> +		__field(int, zid)
>  		__field(unsigned long, zone_start)
>  		__field(unsigned long, migrate_pfn)
>  		__field(unsigned long, free_pfn)
> @@ -172,6 +175,8 @@ TRACE_EVENT(mm_compaction_begin,
>  	),
>
>  	TP_fast_assign(
> +		__entry->nid = zone_to_nid(zone);
> +		__entry->zid = zone_idx(zone);
>  		__entry->zone_start = zone_start;
>  		__entry->migrate_pfn = migrate_pfn;
>  		__entry->free_pfn = free_pfn;
> @@ -179,7 +184,9 @@ TRACE_EVENT(mm_compaction_begin,
>  		__entry->sync = sync;
>  	),
>
> -	TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s",
> +	TP_printk("nid=%d zid=%d zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s",

Yea, this tracepoint has been odd in not printing node/zone in a 
friendly way (it's possible to determine it from zone_start/zone_end 
though, so this is good in general. But instead of printing nid and zid 
like this, it would be nice to unify the output with the other 
tracepoints, e.g.:

DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
[...]
         TP_printk("node=%d zone=%-8s order=%d ret=%s",
                 __entry->nid,
                 __print_symbolic(__entry->idx, ZONE_TYPE),

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

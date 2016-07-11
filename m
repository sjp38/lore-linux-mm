Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B145E6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:18:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so27231725wme.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:18:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bh4si52285wjb.42.2016.07.11.07.18.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 07:18:37 -0700 (PDT)
Subject: Re: [PATCH 3/3] Add name fields in shrinker tracepoint definitions
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <447d8214-3c3d-cc4a-2eff-a47923fbe45f@suse.cz>
Date: Mon, 11 Jul 2016 16:18:35 +0200
MIME-Version: 1.0
In-Reply-To: <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/09/2016 11:05 AM, Janani Ravichandran wrote:
> Currently, the mm_shrink_slab_start and mm_shrink_slab_end
> tracepoints tell us how much time was spent in a shrinker, the number of
> objects scanned, etc. But there is no information about the identity of
> the shrinker. This patch enables the trace output to display names of
> shrinkers.
>
> ---
>  include/trace/events/vmscan.h | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 0101ef3..be4c5b0 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -189,6 +189,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>  		cache_items, delta, total_scan),
>
>  	TP_STRUCT__entry(
> +		__field(char *, name)
>  		__field(struct shrinker *, shr)
>  		__field(void *, shrink)
>  		__field(int, nid)
> @@ -202,6 +203,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>  	),
>
>  	TP_fast_assign(
> +		__entry->name = shr->name;
>  		__entry->shr = shr;
>  		__entry->shrink = shr->scan_objects;
>  		__entry->nid = sc->nid;
> @@ -214,7 +216,8 @@ TRACE_EVENT(mm_shrink_slab_start,
>  		__entry->total_scan = total_scan;
>  	),
>
> -	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
> +	TP_printk("name: %s %pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
> +		__entry->name,

Is this legal to do when printing is not done via the /sys ... file 
itself, but raw data is collected and then printed by e.g. trace-cmd? 
How can it possibly interpret the "char *" kernel pointer?

>  		__entry->shrink,
>  		__entry->shr,
>  		__entry->nid,
> @@ -235,6 +238,7 @@ TRACE_EVENT(mm_shrink_slab_end,
>  		total_scan),
>
>  	TP_STRUCT__entry(
> +		__field(char *, name)
>  		__field(struct shrinker *, shr)
>  		__field(int, nid)
>  		__field(void *, shrink)
> @@ -245,6 +249,7 @@ TRACE_EVENT(mm_shrink_slab_end,
>  	),
>
>  	TP_fast_assign(
> +		__entry->name = shr->name;
>  		__entry->shr = shr;
>  		__entry->nid = nid;
>  		__entry->shrink = shr->scan_objects;
> @@ -254,7 +259,8 @@ TRACE_EVENT(mm_shrink_slab_end,
>  		__entry->total_scan = total_scan;
>  	),
>
> -	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
> +	TP_printk("name: %s %pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
> +		__entry->name,
>  		__entry->shrink,
>  		__entry->shr,
>  		__entry->nid,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

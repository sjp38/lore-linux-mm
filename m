Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C32B66B0260
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:16:24 -0500 (EST)
Received: by wmww144 with SMTP id w144so30177974wmw.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:16:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b186si5482658wmd.88.2015.11.13.05.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 05:16:23 -0800 (PST)
Subject: Re: [PATCH] mm: change mm_vmscan_lru_shrink_inactive() proto types
References: <1447314896-24849-1-git-send-email-yalin.wang2010@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5645E2A4.3010509@suse.cz>
Date: Fri, 13 Nov 2015 14:16:20 +0100
MIME-Version: 1.0
In-Reply-To: <1447314896-24849-1-git-send-email-yalin.wang2010@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, rostedt@goodmis.org, mingo@redhat.com, namhyung@kernel.org, acme@redhat.com, akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@techsingularity.net, bywxiaobai@163.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/12/2015 08:54 AM, yalin wang wrote:
> Move node_id zone_idx shrink flags into trace function,
> so thay we don't need caculate these args if the trace is disabled,
> and will make this function have less arguments.
>
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> ---
>   include/trace/events/vmscan.h | 14 +++++++-------
>   mm/vmscan.c                   |  7 ++-----
>   2 files changed, 9 insertions(+), 12 deletions(-)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index dae7836..f8d6b34 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -352,11 +352,11 @@ TRACE_EVENT(mm_vmscan_writepage,
>
>   TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>
> -	TP_PROTO(int nid, int zid,
> -			unsigned long nr_scanned, unsigned long nr_reclaimed,
> -			int priority, int reclaim_flags),
> +	TP_PROTO(struct zone *zone,
> +		unsigned long nr_scanned, unsigned long nr_reclaimed,
> +		int priority, int file),
>
> -	TP_ARGS(nid, zid, nr_scanned, nr_reclaimed, priority, reclaim_flags),
> +	TP_ARGS(zone, nr_scanned, nr_reclaimed, priority, file),
>
>   	TP_STRUCT__entry(
>   		__field(int, nid)
> @@ -368,12 +368,12 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>   	),
>
>   	TP_fast_assign(
> -		__entry->nid = nid;
> -		__entry->zid = zid;
> +		__entry->nid = zone->zone_pgdat->node_id;

While at it, convert it to zone_to_nid()? It's not just encapsulation, 
but also one less pointer dereference.

Then you can add my Acked-by.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

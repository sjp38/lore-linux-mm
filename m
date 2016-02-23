Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8B982F69
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 04:18:50 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id c200so209995777wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 01:18:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uo5si43504888wjc.221.2016.02.23.01.18.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 01:18:49 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: compact memory from kswapd when lots of memory
 free already
References: <20160222225054.1f6ab286@annuminas.surriel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56CC23F7.8010709@suse.cz>
Date: Tue, 23 Feb 2016 10:18:47 +0100
MIME-Version: 1.0
In-Reply-To: <20160222225054.1f6ab286@annuminas.surriel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org, mgorman@suse.de

On 02/23/2016 04:50 AM, Rik van Riel wrote:
> If kswapd is woken up for a higher order allocation, for example
> from alloc_skb, but the system already has lots of memory free,
> kswapd_shrink_zone will rightfully decide kswapd should not free
> any more memory.
>
> However, at that point kswapd should proceed to compact memory, on
> behalf of alloc_skb or others.
>
> Currently kswapd will only compact memory if it first freed memory,
> leading kswapd to never compact memory when there is already lots of
> memory free.
>
> On my home system, that lead to kswapd occasionally using up to 5%
> CPU time, with many man wakeups from alloc_skb, and kswapd never
> doing anything to relieve the situation that caused it to be woken
> up.

Hi,

I've proposed replacing kswapd compaction with kcompactd, so this hunk 
is gone completely in mmotm. This imperfect comparison was indeed one of 
the things I've noted, but it's not all:

http://marc.info/?l=linux-kernel&m=145493881908394&w=2

> Going ahead with compaction when kswapd did not attempt to reclaim
> any memory, and as a consequence did not reclaim any memory, is the
> right thing to do in this situation.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>   mm/vmscan.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 71b1c29948db..9566a04b9759 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3343,7 +3343,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>   		 * Compact if necessary and kswapd is reclaiming at least the
>   		 * high watermark number of pages as requsted
>   		 */
> -		if (pgdat_needs_compaction && sc.nr_reclaimed > nr_attempted)
> +		if (pgdat_needs_compaction && sc.nr_reclaimed >= nr_attempted)
>   			compact_pgdat(pgdat, order);
>
>   		/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

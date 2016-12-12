Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 053906B0260
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 04:21:27 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so11048773wme.5
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 01:21:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sc5si43609946wjb.155.2016.12.12.01.21.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 01:21:25 -0800 (PST)
Subject: Re: [PATCH] mm: fadvise: avoid expensive remote LRU cache draining
 after FADV_DONTNEED
References: <20161210172658.5182-1-hannes@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5cc0eb6f-bede-a34a-522b-e30d06723ffa@suse.cz>
Date: Mon, 12 Dec 2016 10:21:24 +0100
MIME-Version: 1.0
In-Reply-To: <20161210172658.5182-1-hannes@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 12/10/2016 06:26 PM, Johannes Weiner wrote:
> When FADV_DONTNEED cannot drop all pages in the range, it observes
> that some pages might still be on per-cpu LRU caches after recent
> instantiation and so initiates remote calls to all CPUs to flush their
> local caches. However, in most cases, the fadvise happens from the
> same context that instantiated the pages, and any pre-LRU pages in the
> specified range are most likely sitting on the local CPU's LRU cache,
> and so in many cases this results in unnecessary remote calls, which,
> in a loaded system, can hold up the fadvise() call significantly.

Got any numbers for this part?

> Try to avoid the remote call by flushing the local LRU cache before
> even attempting to invalidate anything. It's a cheap operation, and
> the local LRU cache is the most likely to hold any pre-LRU pages in
> the specified fadvise range.

Anyway it looks like things can't be worse after this patch, so...

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/fadvise.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index 6c707bfe02fd..a43013112581 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -139,7 +139,20 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>  		}
>
>  		if (end_index >= start_index) {
> -			unsigned long count = invalidate_mapping_pages(mapping,
> +			unsigned long count;
> +
> +			/*
> +			 * It's common to FADV_DONTNEED right after
> +			 * the read or write that instantiates the
> +			 * pages, in which case there will be some
> +			 * sitting on the local LRU cache. Try to
> +			 * avoid the expensive remote drain and the
> +			 * second cache tree walk below by flushing
> +			 * them out right away.
> +			 */
> +			lru_add_drain();
> +
> +			count = invalidate_mapping_pages(mapping,
>  						start_index, end_index);
>
>  			/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

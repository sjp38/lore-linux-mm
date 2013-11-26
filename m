Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id E92746B0039
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 05:16:22 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so2449140bkj.38
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 02:16:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id yl6si10631040bkb.245.2013.11.26.02.16.21
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 02:16:21 -0800 (PST)
Date: Tue, 26 Nov 2013 10:16:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/5] mm: compaction: encapsulate defer reset logic
Message-ID: <20131126101618.GE5285@suse.de>
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
 <1385389570-11393-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1385389570-11393-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Mon, Nov 25, 2013 at 03:26:06PM +0100, Vlastimil Babka wrote:
> Currently there are several functions to manipulate the deferred compaction
> state variables. The remaining case where the variables are touched directly
> is when a successful allocation occurs in direct compaction, or is expected
> to be successful in the future by kswapd. Here, the lowest order that is
> expected to fail is updated, and in the case of direct compaction, the deferred
> status is reset completely.
> 
> Create a new function compaction_defer_reset() to encapsulate this
> functionality and make it easier to understand the code. No functional change.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/compaction.h | 12 ++++++++++++
>  mm/compaction.c            |  9 ++++-----
>  mm/page_alloc.c            |  5 +----
>  3 files changed, 17 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 091d72e..da39978 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -62,6 +62,18 @@ static inline bool compaction_deferred(struct zone *zone, int order)
>  	return zone->compact_considered < defer_limit;
>  }
>  
> +/* Update defer tracking counters after successful allocation of given order */
> +static inline void compaction_defer_reset(struct zone *zone, int order,
> +		bool reset_shift)
> +{
> +	if (reset_shift) {
> +		zone->compact_considered = 0;
> +		zone->compact_defer_shift = 0;
> +	}
> +	if (order >= zone->compact_order_failed)
> +		zone->compact_order_failed = order + 1;
> +}
> +

Nit pick

The comment says this is called after a successful allocation but that
is only true in one case. s/allocation/compaction/ ?

reset_shift says what it does but not why and exposes an unnecessary. If
this sees a second revision, maybe consider renaming it to something like
alloc_success?

With or without changes;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 675586B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 16:18:48 -0400 (EDT)
Message-ID: <51AF9D1D.6030709@redhat.com>
Date: Wed, 05 Jun 2013 16:18:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] mm: compaction: increase the high order pages in
 the watermarks
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-6-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On 06/05/2013 11:10 AM, Andrea Arcangeli wrote:
> Require more high order pages in the watermarks, to give more margin
> for concurrent allocations. If there are too few pages, they can
> disappear too soon.

Not sure what to do with this patch.

Not scaling min for pageblock_order-2 allocations seems like
it could be excessive.

Presumably this scaling was introduced for a good reason.

Why is that reason no longer valid?

Why is it safe to make this change?

Would it be safer to simply scale min less steeply?

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>   mm/page_alloc.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3931d16..c13e062 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1646,7 +1646,8 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>   		free_pages -= z->free_area[o].nr_free << o;
>
>   		/* Require fewer higher order pages to be free */
> -		min >>= 1;
> +		if (o >= pageblock_order-1)
> +			min >>= 1;

Why this and not this?

		if (order & 1)
			min >>=1;

Not saying my idea is any better than yours, just saying that
a change like this needs more justification than provided by
your changelog...

>
>   		if (free_pages <= min)
>   			return false;
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

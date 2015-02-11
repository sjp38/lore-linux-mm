Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3236B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 04:58:17 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id u56so2244032wes.10
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 01:58:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id da1si2657466wib.25.2015.02.11.01.58.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 01:58:15 -0800 (PST)
Message-ID: <54DB27B5.9060207@suse.cz>
Date: Wed, 11 Feb 2015 10:58:13 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix negative nr_isolated counts
References: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/11/2015 08:06 AM, Hugh Dickins wrote:
> The vmstat interfaces are good at hiding negative counts (at least
> when CONFIG_SMP); but if you peer behind the curtain, you find that
> nr_isolated_anon and nr_isolated_file soon go negative, and grow ever
> more negative: so they can absorb larger and larger numbers of isolated
> pages, yet still appear to be zero.
>
> I'm happy to avoid a congestion_wait() when too_many_isolated() myself;
> but I guess it's there for a good reason, in which case we ought to get
> too_many_isolated() working again.
>
> The imbalance comes from isolate_migratepages()'s ISOLATE_ABORT case:
> putback_movable_pages() decrements the NR_ISOLATED counts, but we forgot
> to call acct_isolated() to increment them.
>
> Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up from isolate_migratepages_range()")

Ccing Joonsoo for completeness, as it seems he contributed to this part 
[1] (to fix another bug of mine, not trying to dismiss responsibility)

But yeah it looks correct. Thanks for finding and fixing!

Acked-by: Vlastimil Babka <vbabka@suse.cz>

[1] https://lkml.org/lkml/2014/9/29/60

> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # v3.18+
> ---
>
>   mm/compaction.c |    4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> --- v3.19/mm/compaction.c	2015-02-08 18:54:22.000000000 -0800
> +++ linux/mm/compaction.c	2015-02-10 22:25:04.613907871 -0800
> @@ -1015,8 +1015,10 @@ static isolate_migrate_t isolate_migrate
>   		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
>   								isolate_mode);
>
> -		if (!low_pfn || cc->contended)
> +		if (!low_pfn || cc->contended) {
> +			acct_isolated(zone, cc);
>   			return ISOLATE_ABORT;
> +		}
>
>   		/*
>   		 * Either we isolated something and proceed with migration. Or
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

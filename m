Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5558B6B0039
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 09:21:06 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so328727eek.18
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 06:21:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id i1si14869246eev.236.2013.12.06.06.21.05
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 06:21:05 -0800 (PST)
Message-ID: <52A1DD4B.7020003@suse.cz>
Date: Fri, 06 Dec 2013 15:20:59 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/compaction: respect ignore_skip_hint in update_pageblock_skip
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com> <1386319310-28016-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386319310-28016-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/06/2013 09:41 AM, Joonsoo Kim wrote:
> update_pageblock_skip() only fits to compaction which tries to isolate by
> pageblock unit. If isolate_migratepages_range() is called by CMA, it try to
> isolate regardless of pageblock unit and it don't reference
> get_pageblock_skip() by ignore_skip_hint. We should also respect it on
> update_pageblock_skip() to prevent from setting the wrong information.

Yeah, this will also prevent updating cached migrate scanner pfn, which 
makes perfect sense, as cma doesn't read them.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 805165b..f58bcd0 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -134,6 +134,10 @@ static void update_pageblock_skip(struct compact_control *cc,
>   			bool migrate_scanner)
>   {
>   	struct zone *zone = cc->zone;
> +
> +	if (cc->ignore_skip_hint)
> +		return;
> +
>   	if (!page)
>   		return;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

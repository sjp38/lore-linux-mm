Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2AA86B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:55:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u93so3905344wrc.10
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 04:55:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a20si107906wrh.532.2017.08.29.04.55.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 04:55:27 -0700 (PDT)
Subject: Re: [PATCH] mm, madvise: Ensure poisoned pages are removed from
 per-cpu lists
References: <20170828133414.7qro57jbepdcyz5x@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <26785aab-caa8-bbdd-dbce-28cd826a9359@suse.cz>
Date: Tue, 29 Aug 2017 13:55:26 +0200
MIME-Version: 1.0
In-Reply-To: <20170828133414.7qro57jbepdcyz5x@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/28/2017 03:34 PM, Mel Gorman wrote:
> Wendy Wang reported off-list that a RAS HWPOISON-SOFT test case failed and
> bisected it to the commit 479f854a207c ("mm, page_alloc: defer debugging
> checks of pages allocated from the PCP"). The problem is that a page that
> was poisoned with madvise() is reused. The commit removed a check that
> would trigger if DEBUG_VM was enabled but re-enabling the check only
> fixes the problem as a side-effect by printing a bad_page warning and
> recovering.
> 
> The root of the problem is that a madvise() can leave a poisoned on
> the per-cpu list.  This patch drains all per-cpu lists after pages are
> poisoned so that they will not be reused. Wendy reports that the test case
> in question passes with this patch applied.  While this could be done in
> a targeted fashion, it is over-complicated for such a rare operation.
> 
> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
> Reported-and-tested-by: Wang, Wendy <wendy.wang@intel.com>
> Cc: stable@kernel.org
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/madvise.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 23ed525bc2bc..4d7d1e5ddba9 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -613,6 +613,7 @@ static int madvise_inject_error(int behavior,
>  		unsigned long start, unsigned long end)
>  {
>  	struct page *page;
> +	struct zone *zone;
>  
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> @@ -646,6 +647,11 @@ static int madvise_inject_error(int behavior,
>  		if (ret)
>  			return ret;
>  	}
> +
> +	/* Ensure that all poisoned pages are removed from per-cpu lists */
> +	for_each_populated_zone(zone)
> +		drain_all_pages(zone);
> +
>  	return 0;
>  }
>  #endif
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

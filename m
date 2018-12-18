Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3188E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:06:35 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so11661904edt.23
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:06:35 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k25si3285527edf.61.2018.12.18.01.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:06:33 -0800 (PST)
Subject: Re: [PATCH 06/14] mm, migrate: Immediately fail migration of a page
 with no migration handler
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-7-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0ef5c1d0-1853-8fdb-1a68-7482297cb802@suse.cz>
Date: Tue, 18 Dec 2018 10:06:31 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-7-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:03 AM, Mel Gorman wrote:
> Pages with no migration handler use a fallback hander which sometimes
> works and sometimes persistently fails such as blockdev pages. Migration
> will retry a number of times on these persistent pages which is wasteful
> during compaction. This patch will fail migration immediately unless the
> caller is in MIGRATE_SYNC mode which indicates the caller is willing to
> wait while being persistent.

Right.

> This is not expected to help THP allocation success rates but it does
> reduce latencies slightly.
> 
> 1-socket thpfioscale
>                                     4.20.0-rc6             4.20.0-rc6
>                                noreserved-v1r4          failfast-v1r4
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      2276.15 (   0.00%)     3867.54 * -69.92%*

This is rather weird.

> Amean     fault-both-5      4992.20 (   0.00%)     5313.20 (  -6.43%)
> Amean     fault-both-7      7373.30 (   0.00%)     7039.11 (   4.53%)
> Amean     fault-both-12    11911.52 (   0.00%)    11328.29 (   4.90%)
> Amean     fault-both-18    17209.42 (   0.00%)    16455.34 (   4.38%)
> Amean     fault-both-24    20943.71 (   0.00%)    20448.94 (   2.36%)
> Amean     fault-both-30    22703.00 (   0.00%)    21655.07 (   4.62%)
> Amean     fault-both-32    22461.41 (   0.00%)    21415.35 (   4.66%)
> 
> The 2-socket results are not materially different. Scan rates are
> similar as expected.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index df17a710e2c7..0e27a10429e2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -885,7 +885,7 @@ static int fallback_migrate_page(struct address_space *mapping,
>  	 */
>  	if (page_has_private(page) &&
>  	    !try_to_release_page(page, GFP_KERNEL))
> -		return -EAGAIN;
> +		return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
>  
>  	return migrate_page(mapping, newpage, page, mode);
>  }
> 

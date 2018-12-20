Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABE128E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:45:11 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so3052184qte.0
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:45:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r93sor4290647qkr.27.2018.12.20.11.45.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 11:45:10 -0800 (PST)
MIME-Version: 1.0
References: <20181214230310.572-1-mgorman@techsingularity.net> <20181214230310.572-7-mgorman@techsingularity.net>
In-Reply-To: <20181214230310.572-7-mgorman@techsingularity.net>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 20 Dec 2018 11:44:57 -0800
Message-ID: <CAHbLzko6jXSikw-4LQXi6KfNR9=U4XJnB_OaaZ4XcNHUj4NLUQ@mail.gmail.com>
Subject: Re: [PATCH 06/14] mm, migrate: Immediately fail migration of a page
 with no migration handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net
Cc: Linux MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Dec 14, 2018 at 3:03 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> Pages with no migration handler use a fallback hander which sometimes
> works and sometimes persistently fails such as blockdev pages. Migration

A minor correction. The above statement sounds not accurate anymore
since Jan Kara had patch series (blkdev: avoid migration stalls for
blkdev pages) have blockdev use its own migration handler.

Thanks,
Yang

> will retry a number of times on these persistent pages which is wasteful
> during compaction. This patch will fail migration immediately unless the
> caller is in MIGRATE_SYNC mode which indicates the caller is willing to
> wait while being persistent.
>
> This is not expected to help THP allocation success rates but it does
> reduce latencies slightly.
>
> 1-socket thpfioscale
>                                     4.20.0-rc6             4.20.0-rc6
>                                noreserved-v1r4          failfast-v1r4
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      2276.15 (   0.00%)     3867.54 * -69.92%*
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
> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index df17a710e2c7..0e27a10429e2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -885,7 +885,7 @@ static int fallback_migrate_page(struct address_space *mapping,
>          */
>         if (page_has_private(page) &&
>             !try_to_release_page(page, GFP_KERNEL))
> -               return -EAGAIN;
> +               return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
>
>         return migrate_page(mapping, newpage, page, mode);
>  }
> --
> 2.16.4
>

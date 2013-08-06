Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 083986B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 05:16:40 -0400 (EDT)
Message-ID: <5200BEEF.7060904@oracle.com>
Date: Tue, 06 Aug 2013 17:16:31 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] mm: reclaim zbud pages on migration and compaction
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
In-Reply-To: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 08/06/2013 02:42 PM, Krzysztof Kozlowski wrote:
> Hi,
> 
> Currently zbud pages are not movable and they cannot be allocated from CMA
> region. These patches try to address the problem by:
> 1. Adding a new form of reclaim of zbud pages.
> 2. Reclaiming zbud pages during migration and compaction.
> 3. Allocating zbud pages with __GFP_RECLAIMABLE flag.
> 
> This reclaim process is different than zbud_reclaim_page(). It acts more
> like swapoff() by trying to unuse pages stored in zbud page and bring
> them back to memory. The standard zbud_reclaim_page() on the other hand
> tries to write them back.

I prefer to migrate zbud pages directly if it's possible than reclaiming
them during compaction.

> 
> One of patches introduces a new flag: PageZbud. This flag is used in
> isolate_migratepages_range() to grab zbud pages and pass them later
> for reclaim. Probably this could be replaced with something
> smarter than a flag used only in one case.
> Any ideas for a better solution are welcome.
> 
> This patch set is based on Linux 3.11-rc4.
> 
> TODOs:
> 1. Replace PageZbud flag with other solution.
> 
> Best regards,
> Krzysztof Kozlowski
> 
> 
> Krzysztof Kozlowski (4):
>   zbud: use page ref counter for zbud pages
>   mm: split code for unusing swap entries from try_to_unuse
>   mm: add zbud flag to page flags
>   mm: reclaim zbud pages on migration and compaction
> 
>  include/linux/page-flags.h |   12 ++
>  include/linux/swapfile.h   |    2 +
>  include/linux/zbud.h       |   11 +-
>  mm/compaction.c            |   20 ++-
>  mm/internal.h              |    1 +
>  mm/page_alloc.c            |    9 ++
>  mm/swapfile.c              |  354 +++++++++++++++++++++++---------------------
>  mm/zbud.c                  |  301 +++++++++++++++++++++++++------------
>  mm/zswap.c                 |   57 ++++++-
>  9 files changed, 499 insertions(+), 268 deletions(-)
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

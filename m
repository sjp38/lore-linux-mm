Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A07386B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 04:13:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so20233452pfa.2
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 01:13:07 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id xm3si18459764pac.158.2016.06.28.01.13.06
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 01:13:06 -0700 (PDT)
Date: Tue, 28 Jun 2016 17:16:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 4/6] mm/cma: remove ALLOC_CMA
Message-ID: <20160628081600.GB19731@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-5-git-send-email-iamjoonsoo.kim@lge.com>
 <5848e9f2-fd49-059e-fe57-aee6cd70c371@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5848e9f2-fd49-059e-fe57-aee6cd70c371@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 27, 2016 at 11:30:52AM +0200, Vlastimil Babka wrote:
> On 05/26/2016 08:22 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Now, all reserved pages for CMA region are belong to the ZONE_CMA
> >and it only serves for GFP_HIGHUSER_MOVABLE. Therefore, we don't need to
> >consider ALLOC_CMA at all.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> > mm/internal.h   |  3 +--
> > mm/page_alloc.c | 27 +++------------------------
> > 2 files changed, 4 insertions(+), 26 deletions(-)
> >
> 
> [...]
> 
> >@@ -2833,10 +2827,8 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
> > 		}
> >
> > #ifdef CONFIG_CMA
> >-		if ((alloc_flags & ALLOC_CMA) &&
> >-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
> >+		if (!list_empty(&area->free_list[MIGRATE_CMA]))
> > 			return true;
> >-		}
> > #endif
> 
> Nitpick: it would be more logical to remove the whole block in this
> patch, as removing ALLOC_CMA means it's effectively false? Also less
> churn.

No, all freepages on ZONE_CMA is attached on area->free_list[MIGRATE_CMA].
We need to check whether there is a freepage on it or not to pass watermark
check for high-order allocation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

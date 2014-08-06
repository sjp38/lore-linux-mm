Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 551436B00A1
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 11:12:29 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so9770419wiv.2
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 08:12:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ck20si2206036wjb.112.2014.08.06.08.12.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 08:12:27 -0700 (PDT)
Message-ID: <53E245D4.9080506@suse.cz>
Date: Wed, 06 Aug 2014 17:12:20 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/8] mm/isolation: change pageblock isolation logic
 to fix freepage counting bugs
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/06/2014 09:18 AM, Joonsoo Kim wrote:
> Overall design of changed pageblock isolation logic is as following.

I'll reply here since the overall design part is described in this patch 
(would be worth to have it in cover letter as well IMHO).

> 1. ISOLATION
> - check pageblock is suitable for pageblock isolation.
> - change migratetype of pageblock to MIGRATE_ISOLATE.
> - disable pcp list.

Is it needed to disable the pcp list? Shouldn't drain be enough? After 
the drain you already are sure that future freeing will see 
MIGRATE_ISOLATE and skip pcp list anyway, so why disable it completely?

> - drain pcp list.
> - pcp couldn't have any freepage at this point.
> - synchronize all cpus to see correct migratetype.

This synchronization should already happen through the drain, no?

> - freed pages on this pageblock will be handled specially and
> not added to buddy list from here. With this way, there is no
> possibility of merging pages on different buddy list.
> - move freepages on normal buddy list to isolate buddy list.

Is there any advantage of moving the pages to isolate buddy list at this 
point, when we already have the new PageIsolated marking? Maybe not 
right now, but could this be later replaced by just splitting and 
marking PageIsolated the pages from normal buddy list? I guess memory 
hot-remove does not benefit from having buddy-merged pages and CMA 
probably also doesn't?

> There is no page on isolate buddy list so move_freepages_block()
> returns number of moved freepages correctly.
> - enable pcp list.
>
> 2. TEST-ISOLATION
> - activates freepages marked as PageIsolated() and add to isolate
> buddy list.
> - test if pageblock is properly isolated.
>
> 3. UNDO-ISOLATION
> - move freepages from isolate buddy list to normal buddy list.
> There is no page on normal buddy list so move_freepages_block()
> return number of moved freepages correctly.
> - change migratetype of pageblock to normal migratetype
> - synchronize all cpus.
> - activate isolated freepages and add to normal buddy list.

The lack of pcp list deactivation in the undo part IMHO suggests that it 
is indeed not needed.

> With this patch, most of freepage counting bugs are solved and
> exceptional handling for freepage count is done in pageblock isolation
> logic rather than allocator.

\o/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

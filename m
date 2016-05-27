Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4317B6B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 01:27:24 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 85so168986619ioq.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 22:27:24 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id kp2si10170601igc.102.2016.05.26.22.27.22
        for <linux-mm@kvack.org>;
        Thu, 26 May 2016 22:27:23 -0700 (PDT)
Date: Fri, 27 May 2016 14:28:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
Message-ID: <20160527052820.GA13661@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160526080454.GA11823@shbuild888>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160526080454.GA11823@shbuild888>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Feng Tang <feng.tang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, May 26, 2016 at 04:04:54PM +0800, Feng Tang wrote:
> On Thu, May 26, 2016 at 02:22:22PM +0800, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hi Joonsoo,
> 
> Nice work!

Thanks!

> > FYI, there is another attempt [3] trying to solve this problem in lkml.
> > And, as far as I know, Qualcomm also has out-of-tree solution for this
> > problem.
> 
> This may be a little off-topic :) Actually, we have used another way in
> our products, that we disable the fallback from MIGRATETYE_MOVABLE to
> MIGRATETYPE_CMA completely, and only allow free CMA memory to be used
> by file page cache (which is easy to be reclaimed by its nature). 
> We did it by adding a GFP_PAGE_CACHE to every allocation request for
> page cache, and the MM will try to pick up an available free CMA page
> first, and goes to normal path when fail. 

Just wonder, why do you allow CMA memory to file page cache rather
than anonymous page? I guess that anonymous pages would be more easily
migrated/reclaimed than file page cache. In fact, some of our product
uses anonymous page adaptation to satisfy similar requirement by
introducing GFP_CMA. AFAIK, some of chip vendor also uses "anonymous
page first adaptation" to get better success rate.

> It works fine on our products, though we still see some cases that
> some page can't be reclaimed. 
> 
> Our product has a special user case of CMA, that sometimes it will
> need to use the whole CMA memory (say 256MB on a phone), then all

I don't think this usecase is so special. Our product also has similar
usecase. And, I already knows one another.

> share out CMA pages need to be reclaimed all at once. Don't know if
> this new ZONE_CMA approach could meet this request? (our page cache
> solution can't ganrantee to meet this request all the time).

This ZONE_CMA approach would be better than before, since CMA memory
is not be used for blockdev page cache. Blockdev page cache is one of
the frequent failure points in my experience.

I'm not sure that ZONE_CMA works better than your GFP_PAGE_CACHE
adaptation for your system. In ZONE_CMA, CMA memory is used for file
page cache or anonymous pages. If my assumption that anonymous pages
are easier to be migrated/reclaimed is correct, ZONE_CMA would work
better than your adaptation since there is less file page cache pages
in CMA memory.

Anyway, it also doesn't guarantee to succeed all the time. There is
different kind of problem that prevents CMA allocation success and we
need to solve it. I will try it after problems that this patchset try
to fix is solved.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6FD6B0072
	for <linux-mm@kvack.org>; Mon, 12 May 2014 22:23:59 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so377538pbc.24
        for <linux-mm@kvack.org>; Mon, 12 May 2014 19:23:58 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id hb8si7210216pbc.239.2014.05.12.19.23.57
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 19:23:58 -0700 (PDT)
Date: Tue, 13 May 2014 11:26:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/3] Aggressively allocate the pages on cma reserved
 memory
Message-ID: <20140513022603.GF23803@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <536CCC78.6050806@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <536CCC78.6050806@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>

On Fri, May 09, 2014 at 02:39:20PM +0200, Marek Szyprowski wrote:
> Hello,
> 
> On 2014-05-08 02:32, Joonsoo Kim wrote:
> >This series tries to improve CMA.
> >
> >CMA is introduced to provide physically contiguous pages at runtime
> >without reserving memory area. But, current implementation works like as
> >reserving memory approach, because allocation on cma reserved region only
> >occurs as fallback of migrate_movable allocation. We can allocate from it
> >when there is no movable page. In that situation, kswapd would be invoked
> >easily since unmovable and reclaimable allocation consider
> >(free pages - free CMA pages) as free memory on the system and free memory
> >may be lower than high watermark in that case. If kswapd start to reclaim
> >memory, then fallback allocation doesn't occur much.
> >
> >In my experiment, I found that if system memory has 1024 MB memory and
> >has 512 MB reserved memory for CMA, kswapd is mostly invoked around
> >the 512MB free memory boundary. And invoked kswapd tries to make free
> >memory until (free pages - free CMA pages) is higher than high watermark,
> >so free memory on meminfo is moving around 512MB boundary consistently.
> >
> >To fix this problem, we should allocate the pages on cma reserved memory
> >more aggressively and intelligenetly. Patch 2 implements the solution.
> >Patch 1 is the simple optimization which remove useless re-trial and patch 3
> >is for removing useless alloc flag, so these are not important.
> >See patch 2 for more detailed description.
> >
> >This patchset is based on v3.15-rc4.
> 
> Thanks for posting those patches. It basically reminds me the
> following discussion:
> http://thread.gmane.org/gmane.linux.kernel/1391989/focus=1399524
> 
> Your approach is basically the same. I hope that your patches can be
> improved
> in such a way that they will be accepted by mm maintainers. I only
> wonder if the
> third patch is really necessary. Without it kswapd wakeup might be
> still avoided
> in some cases.

Hello,

Oh... I didn't know that patch and discussion, because I have no interest
on CMA at that time. Your approach looks similar to #1
approach of mine and could have same problem of #1 approach which I mentioned
in patch 2/3. Please refer that patch description. :)
And, there is different purpose between this and yours. This patch is
intended to better use of CMA pages and so get maximum performance.
Just to not trigger oom, it can be possible to put this logic on reclaim path.
But that is sub-optimal to get higher performance, because it needs
migration in some cases.

If second patch works as intended, there are just a few of cma free pages
when we are toward on the watermark. So benefit of third patch would
be marginal and we can remove ALLOC_CMA.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

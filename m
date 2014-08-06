Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id DD5236B0078
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:30:00 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so2841630pdj.0
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:30:00 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id mk5si151050pab.93.2014.08.06.00.29.58
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 00:29:59 -0700 (PDT)
Date: Wed, 6 Aug 2014 16:37:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCHv2] CMA/HOTPLUG: clear buffer-head lru before page
 migration
Message-ID: <20140806073719.GA3590@js1304-P5Q-DELUXE>
References: <53D9A86B.20208@lge.com>
 <20140731155703.a8bc3b77af913c8b3a63090a@linux-foundation.org>
 <53DADB56.3050103@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53DADB56.3050103@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Laura Abbott <lauraa@codeaurora.org>, Michal Nazarewicz <mina86@mina86.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ????????? <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

On Fri, Aug 01, 2014 at 09:12:06AM +0900, Gioh Kim wrote:
> 
> 
> 2014-08-01 i??i ? 7:57, Andrew Morton i?' e,?:
> >On Thu, 31 Jul 2014 11:22:35 +0900 Gioh Kim <gioh.kim@lge.com> wrote:
> >
> >>The previous PATCH inserts invalidate_bh_lrus() only into CMA code.
> >>HOTPLUG needs also dropping bh of lru.
> >>So v2 inserts invalidate_bh_lrus() into both of CMA and HOTPLUG.
> >>
> >>
> >>---------------------------- 8< ----------------------------
> >>The bh must be free to migrate a page at which bh is mapped.
> >>The reference count of bh is increased when it is installed
> >>into lru so that the bh of lru must be freed before migrating the page.
> >>
> >>This frees every bh of lru. We could free only bh of migrating page.
> >>But searching lru sometimes costs more than invalidating entire lru.
> >>
> >>Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> >>Acked-by: Michal Nazarewicz <mina86@mina86.com>
> >>---
> >>  mm/memory_hotplug.c |    1 +
> >>  mm/page_alloc.c     |    2 ++
> >>  2 files changed, 3 insertions(+)
> >>
> >>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >>index a3797d3..1c5454f 100644
> >>--- a/mm/memory_hotplug.c
> >>+++ b/mm/memory_hotplug.c
> >>@@ -1672,6 +1672,7 @@ repeat:
> >>                 lru_add_drain_all();
> >>                 cond_resched();
> >>                 drain_all_pages();
> >>+               invalidate_bh_lrus();
> >
> >Both of these calls should have a comment explaining why
> >invalidate_bh_lrus() is being called.
> >
> >>         }
> >>
> >>         pfn = scan_movable_pages(start_pfn, end_pfn);
> >>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>index b99643d4..c00dedf 100644
> >>--- a/mm/page_alloc.c
> >>+++ b/mm/page_alloc.c
> >>@@ -6369,6 +6369,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
> >>         if (ret)
> >>                 return ret;
> >>
> >>+       invalidate_bh_lrus();
> >>+
> >>         ret = __alloc_contig_migrate_range(&cc, start, end);
> >>         if (ret)
> >>                 goto done;
> >
> >I do feel that this change is likely to be beneficial, but I don't want
> >to apply such a patch until I know what its effects are upon all
> >alloc_contig_range() callers.  Especially hugetlb.
> 
> I'm very sorry to hear that.
> How can I check the effects?
> 

Hello, Gioh.

As you know, I generally agree this patch, but, I want to know that
this patch really fixes your problem. There is some time difference
between invalidate_bh_lrus() and migrate_page() so that the bh of the
migrating page could be re-installed on bh lru again. Any
remarkable success rate changes? If this time gap is critical, we
should put this invalidation logic on other place.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

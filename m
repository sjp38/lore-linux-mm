Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 5 Feb 2013 13:13:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-Id: <20130205131304.82a5c4cb.akpm@linux-foundation.org>
In-Reply-To: <511077E7.4040605@cn.fujitsu.com>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
	<1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
	<20130204160624.5c20a8a0.akpm@linux-foundation.org>
	<511077E7.4040605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Tang chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>

On Tue, 05 Feb 2013 11:09:27 +0800
Lin Feng <linfeng@cn.fujitsu.com> wrote:

> > 
> >>  struct kvec;
> >>  int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
> >>  			struct page **pages);
> >> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >> index 73b64a3..5db811e 100644
> >> --- a/include/linux/mmzone.h
> >> +++ b/include/linux/mmzone.h
> >> @@ -838,6 +838,10 @@ static inline int is_normal_idx(enum zone_type idx)
> >>  	return (idx == ZONE_NORMAL);
> >>  }
> >>  
> >> +static inline int is_movable(struct zone *zone)
> >> +{
> >> +	return zone == zone->zone_pgdat->node_zones + ZONE_MOVABLE;
> >> +}
> > 
> > A better name would be zone_is_movable().  We haven't been very
> > consistent about this in mmzone.h, but zone_is_foo() is pretty common.
> > 
> Yes, zone_is_xxx() should be a better name, but there are some analogous
> definition like is_dma32() and is_normal() etc, if we only use zone_is_movable()
> for movable zone it will break such naming rules.
> Should we update other ones in a separate patch later or just keep the old style?

I do think the old names were poorly chosen.  Yes, we could fix them up
sometime but it's hardly a pressing issue.

> > And a neater implementation would be
> > 
> > 	return zone_idx(zone) == ZONE_MOVABLE;
> > 
> OK. After your change, should we also update for other ones such as is_normal()..?

Sure.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: include-linux-mmzoneh-cleanups-fix

use zone_idx() some more, further simplify is_highmem()

Cc: Lin Feng <linfeng@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mmzone.h |   15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff -puN include/linux/mmzone.h~include-linux-mmzoneh-cleanups-fix include/linux/mmzone.h
--- a/include/linux/mmzone.h~include-linux-mmzoneh-cleanups-fix
+++ a/include/linux/mmzone.h
@@ -859,25 +859,18 @@ static inline int is_normal_idx(enum zon
  */
 static inline int is_highmem(struct zone *zone)
 {
-#ifdef CONFIG_HIGHMEM
-	enum zone_type idx = zone_idx(zone);
-
-	return idx == ZONE_HIGHMEM ||
-	       (idx == ZONE_MOVABLE && zone_movable_is_highmem());
-#else
-	return 0;
-#endif
+	return is_highmem_idx(zone_idx(zone));
 }
 
 static inline int is_normal(struct zone *zone)
 {
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
+	return zone_idx(zone) == ZONE_NORMAL;
 }
 
 static inline int is_dma32(struct zone *zone)
 {
 #ifdef CONFIG_ZONE_DMA32
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
+	return zone_idx(zone) == ZONE_DMA32;
 #else
 	return 0;
 #endif
@@ -886,7 +879,7 @@ static inline int is_dma32(struct zone *
 static inline int is_dma(struct zone *zone)
 {
 #ifdef CONFIG_ZONE_DMA
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
+	return zone_idx(zone) == ZONE_DMA;
 #else
 	return 0;
 #endif
_

> >> +	/* All pages are non movable, we are done :) */
> >> +	if (i == ret && list_empty(&pagelist))
> >> +		return ret;
> >> +
> >> +put_page:
> >> +	/* Undo the effects of former get_user_pages(), we won't pin anything */
> >> +	for (i = 0; i < ret; i++)
> >> +		put_page(pages[i]);
> >> +
> >> +	if (migrate_pre_flag && !isolate_err) {
> >> +		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
> >> +					false, MIGRATE_SYNC, MR_SYSCALL);
> >> +		/* Steal pages from non-movable zone successfully? */
> >> +		if (!ret)
> >> +			goto retry;
> > 
> > This is buggy.  migrate_pages() doesn't empty its `from' argument, so
> > page_list must be reinitialised here (or, better, at the start of the loop).
> migrate_pages()
>   list_for_each_entry_safe()
>      unmap_and_move()
>        if (rc != -EAGAIN) {
>          list_del(&page->lru);
>        }

ah, OK, there it is.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A42B660021B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 18:00:15 -0500 (EST)
Date: Fri, 8 Jan 2010 14:59:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm : add check for the return value
Message-Id: <20100108145945.d3d5eed6.akpm@linux-foundation.org>
In-Reply-To: <28c262361001032206m6b102f85wed64ae31fd5b06d5@mail.gmail.com>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com>
	<20100104122138.f54b7659.minchan.kim@barrios-desktop>
	<4B416A28.70806@gmail.com>
	<20100104134827.ce642c11.minchan.kim@barrios-desktop>
	<4B417A37.7060001@gmail.com>
	<28c262361001032206m6b102f85wed64ae31fd5b06d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Huang Shijie <shijie8@gmail.com>, mel@csn.ul.ie, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010 15:06:54 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Mon, Jan 4, 2010 at 2:18 PM, Huang Shijie <shijie8@gmail.com> wrote:
> >
> >> I think the branch itself could not a big deal but 'likely'.
> >>
> >> Why I suggest is that now 'if (!page)' don't have 'likely'.
> >> As you know, 'likely' make the code relocate for reducing code footprint.
> >>
> >> Why? It was just mistake or doesn't need it?
> >>
> >>
> >
> > I think the CPU will CACHE the `likely' code, and make it runs fast.
> 
> I think so.
> 
> >
> > IMHO, "if (unlikely(page == NULL)) " is better then "if (!page)" ,just like
> > the
> > code in rmqueue_bulk().
> >> I think Mel does know it.
> >>
> >>
> >
> > wait for Mel's response.
> 
> Yes.
> Regardless of Kosaki's patch, there is a issue about likely/unlinkely usage.
> 

All of this code is in the (order != 0) path, so it's relatively rarely
executed.  We've added a small expense to a rarely-executed code
path.  I think I'll apply the original patch as-is.


From: Huang Shijie <shijie8@gmail.com>

When the `page' returned by __rmqueue() is NULL, the origin code still
adds -(1 << order) to zone's NR_FREE_PAGES item.

The patch fixes it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff -puN mm/page_alloc.c~mm-add-check-for-the-return-value mm/page_alloc.c
--- a/mm/page_alloc.c~mm-add-check-for-the-return-value
+++ a/mm/page_alloc.c
@@ -1219,10 +1219,14 @@ again:
 		}
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
-		spin_unlock(&zone->lock);
-		if (!page)
+		if (likely(page)) {
+			__mod_zone_page_state(zone, NR_FREE_PAGES,
+						-(1 << order));
+			spin_unlock(&zone->lock);
+		} else {
+			spin_unlock(&zone->lock);
 			goto failed;
+		}
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id F12096B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:58:21 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hm5so769337pac.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 22:58:21 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id eo16si635030pab.233.2016.10.25.22.58.20
        for <linux-mm@kvack.org>;
        Tue, 25 Oct 2016 22:58:21 -0700 (PDT)
Date: Wed, 26 Oct 2016 14:59:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/5] mm/page_alloc: always add freeing page at the
 tail of the buddy list
Message-ID: <20161026055929.GD2901@js1304-P5Q-DELUXE>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-2-git-send-email-iamjoonsoo.kim@lge.com>
 <58049832.6000007@huawei.com>
 <20161026043740.GB2901@js1304-P5Q-DELUXE>
 <5810442D.2090903@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5810442D.2090903@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 26, 2016 at 01:50:37PM +0800, Xishi Qiu wrote:
> On 2016/10/26 12:37, Joonsoo Kim wrote:
> 
> > On Mon, Oct 17, 2016 at 05:21:54PM +0800, Xishi Qiu wrote:
> >> On 2016/10/13 16:08, js1304@gmail.com wrote:
> >>
> >>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >>>
> >>> Currently, freeing page can stay longer in the buddy list if next higher
> >>> order page is in the buddy list in order to help coalescence. However,
> >>> it doesn't work for the simplest sequential free case. For example, think
> >>> about the situation that 8 consecutive pages are freed in sequential
> >>> order.
> >>>
> >>> page 0: attached at the head of order 0 list
> >>> page 1: merged with page 0, attached at the head of order 1 list
> >>> page 2: attached at the tail of order 0 list
> >>> page 3: merged with page 2 and then merged with page 0, attached at
> >>>  the head of order 2 list
> >>> page 4: attached at the head of order 0 list
> >>> page 5: merged with page 4, attached at the tail of order 1 list
> >>> page 6: attached at the tail of order 0 list
> >>> page 7: merged with page 6 and then merged with page 4. Lastly, merged
> >>>  with page 0 and we get order 3 freepage.
> >>>
> >>> With excluding page 0 case, there are three cases that freeing page is
> >>> attached at the head of buddy list in this example and if just one
> >>> corresponding ordered allocation request comes at that moment, this page
> >>> in being a high order page will be allocated and we would fail to make
> >>> order-3 freepage.
> >>>
> >>> Allocation usually happens in sequential order and free also does. So, it
> >>> would be important to detect such a situation and to give some chance
> >>> to be coalesced.
> >>>
> >>> I think that simple and effective heuristic about this case is just
> >>> attaching freeing page at the tail of the buddy list unconditionally.
> >>> If freeing isn't merged during one rotation, it would be actual
> >>> fragmentation and we don't need to care about it for coalescence.
> >>>
> >>
> >> Hi Joonsoo,
> >>
> >> I find another two places to reduce fragmentation.
> >>
> >> 1)
> >> __rmqueue_fallback
> >> 	steal_suitable_fallback
> >> 		move_freepages_block
> >> 			move_freepages
> >> 				list_move
> >> If we steal some free pages, we will add these page at the head of start_migratetype list,
> >> this will cause more fixed migratetype, because this pages will be allocated more easily.
> >> So how about use list_move_tail instead of list_move?
> > 
> > Yeah... I don't think deeply but, at a glance, it would be helpful.
> > 
> >>
> >> 2)
> >> __rmqueue_fallback
> >> 	expand
> >> 		list_add
> >> How about use list_add_tail instead of list_add? If add the tail, then the rest of pages
> >> will be hard to be allocated and we can merge them again as soon as the page freed.
> > 
> > I guess that it has no effect. When we do __rmqueue_fallback() and
> > expand(), we don't have any freepage on this or more order. So,
> > list_add or list_add_tail will show the same result.
> > 
> 
> Hi Joonsoo,
> 
> Usually this list is empty, but in the following case, the list is not empty.
> 
> __rmqueue_fallback
> 	steal_suitable_fallback
> 		move_freepages_block  // move to the list of start_migratetype
> 	expand  // split the largest order first
> 		list_add  // add to the list of start_migratetype

In this case, stealed freepage on steal_suitable_fallback() and
splitted freepage would come from the same pageblock. So, it doen't
matter to use whatever list_add* function.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

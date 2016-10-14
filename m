Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA2796B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:01:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so94877663pfg.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 18:01:10 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k67si12996718pga.217.2016.10.13.18.01.09
        for <linux-mm@kvack.org>;
        Thu, 13 Oct 2016 18:01:09 -0700 (PDT)
Date: Fri, 14 Oct 2016 10:01:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/5] mm/page_alloc: always add freeing page at the
 tail of the buddy list
Message-ID: <20161014010134.GA4993@js1304-P5Q-DELUXE>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-2-git-send-email-iamjoonsoo.kim@lge.com>
 <15d0cf1a-4b73-470d-208f-be7b0ebb48ba@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15d0cf1a-4b73-470d-208f-be7b0ebb48ba@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 13, 2016 at 11:04:39AM +0200, Vlastimil Babka wrote:
> On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Currently, freeing page can stay longer in the buddy list if next higher
> >order page is in the buddy list in order to help coalescence. However,
> >it doesn't work for the simplest sequential free case. For example, think
> >about the situation that 8 consecutive pages are freed in sequential
> >order.
> >
> >page 0: attached at the head of order 0 list
> >page 1: merged with page 0, attached at the head of order 1 list
> >page 2: attached at the tail of order 0 list
> >page 3: merged with page 2 and then merged with page 0, attached at
> > the head of order 2 list
> >page 4: attached at the head of order 0 list
> >page 5: merged with page 4, attached at the tail of order 1 list
> >page 6: attached at the tail of order 0 list
> >page 7: merged with page 6 and then merged with page 4. Lastly, merged
> > with page 0 and we get order 3 freepage.
> >
> >With excluding page 0 case, there are three cases that freeing page is
> >attached at the head of buddy list in this example and if just one
> >corresponding ordered allocation request comes at that moment, this page
> >in being a high order page will be allocated and we would fail to make
> >order-3 freepage.
> >
> >Allocation usually happens in sequential order and free also does. So, it
> 
> Are you sure this is true except after the system is freshly booted?
> As soon as it becomes fragmented, a stream of order-0 allocations
> will likely grab them randomly from all over the place and it's
> unlikely to recover except small orders.

What we should really focus on is just a small order page
(non-costly order page) and this patch would help to make them. Even
if the system runs for a long time, I saw that there are many small
order freepages so there would be enough chance to alloc/free in
sequential order.

> 
> >would be important to detect such a situation and to give some chance
> >to be coalesced.
> >
> >I think that simple and effective heuristic about this case is just
> >attaching freeing page at the tail of the buddy list unconditionally.
> >If freeing isn't merged during one rotation, it would be actual
> >fragmentation and we don't need to care about it for coalescence.
> 
> I'm not against removing this heuristic, but not without some
> benchmarks. The disadvantage of putting pages to tail lists is that

I can do more test. But, I'd like to say that it is not removing the
heuristic but expanding the heuristic. Before adding this heuristic,
all freed page are added at the head of the buddy list.

> they become cache-cold until allocated again. We should check how
> large that problem is.

Yes, your concern is fair enough. There are some reasons to justify
this patch but it should be checked.

If merging happens, we cannot make sure whether this merged page is
cache-hot or not. There is a possibility that part of merged page stay
in the buddy list for a long time and is cache-cold. I guess that we
can apply above heuristic only for merged page which we cannot make
sure if it is cache-hot or not.

And, there is no guarantee that freed page is cache-hot. If it is used
for file-cache and reclaimed, it would be cache-cold. And, if
next allocation is requested by file-cache, it requires cache-cold
page. Benefit of maintaining cache-hot page at the head of the buddy
list would weaken.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

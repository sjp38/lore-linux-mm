Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5E96B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 06:17:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g32so128192464qta.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 03:17:03 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t4si17503462qkh.216.2016.10.17.03.17.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 03:17:02 -0700 (PDT)
Message-ID: <58049832.6000007@huawei.com>
Date: Mon, 17 Oct 2016 17:21:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/5] mm/page_alloc: always add freeing page at the
 tail of the buddy list
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com> <1476346102-26928-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476346102-26928-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2016/10/13 16:08, js1304@gmail.com wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Currently, freeing page can stay longer in the buddy list if next higher
> order page is in the buddy list in order to help coalescence. However,
> it doesn't work for the simplest sequential free case. For example, think
> about the situation that 8 consecutive pages are freed in sequential
> order.
> 
> page 0: attached at the head of order 0 list
> page 1: merged with page 0, attached at the head of order 1 list
> page 2: attached at the tail of order 0 list
> page 3: merged with page 2 and then merged with page 0, attached at
>  the head of order 2 list
> page 4: attached at the head of order 0 list
> page 5: merged with page 4, attached at the tail of order 1 list
> page 6: attached at the tail of order 0 list
> page 7: merged with page 6 and then merged with page 4. Lastly, merged
>  with page 0 and we get order 3 freepage.
> 
> With excluding page 0 case, there are three cases that freeing page is
> attached at the head of buddy list in this example and if just one
> corresponding ordered allocation request comes at that moment, this page
> in being a high order page will be allocated and we would fail to make
> order-3 freepage.
> 
> Allocation usually happens in sequential order and free also does. So, it
> would be important to detect such a situation and to give some chance
> to be coalesced.
> 
> I think that simple and effective heuristic about this case is just
> attaching freeing page at the tail of the buddy list unconditionally.
> If freeing isn't merged during one rotation, it would be actual
> fragmentation and we don't need to care about it for coalescence.
> 

Hi Joonsoo,

I find another two places to reduce fragmentation.

1)
__rmqueue_fallback
	steal_suitable_fallback
		move_freepages_block
			move_freepages
				list_move
If we steal some free pages, we will add these page at the head of start_migratetype list,
this will cause more fixed migratetype, because this pages will be allocated more easily.
So how about use list_move_tail instead of list_move?

2)
__rmqueue_fallback
	expand
		list_add
How about use list_add_tail instead of list_add? If add the tail, then the rest of pages
will be hard to be allocated and we can merge them again as soon as the page freed.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

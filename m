Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L4tFJB028018 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 13:55:15 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L4tEPV026976 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 13:55:14 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100]) by s6.gw.fujitsu.co.jp (8.12.11)
	id i7L4tEWI028276 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 13:55:14 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2S00J4C5O18U@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 13:55:14 +0900 (JST)
Date: Sat, 21 Aug 2004 14:00:21 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC]  free_area[]  bitmap elimination [0/3]
In-reply-to: <20040821025543.GS11200@holomorphy.com>
Message-id: <4126D6E5.9070804@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <20040821025543.GS11200@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

> On Sat, Aug 21, 2004 at 11:31:21AM +0900, Hiroyuki KAMEZAWA wrote:
> 
>>This patch removes bitmap from buddy allocator used in
>>alloc_pages()/free_pages() in the kernel 2.6.8.1.
<snip>
> 
> Complexity maybe. But one serious issue this addresses beyond the needs
> of hotplug memory is that the buddy bitmaps are a heavily random-access
> data structures not used elsewhere. Consolidating them into the page
> structures should improve cache locality and motivate this patch beyond
> just the needs of hotplug memory. Furthermore, the patch also reduces
> the kernel's overall memory footprint by a small amount.
> 
> However, I'm concerned about the effectiveness of this specific
> algorithm for coalescing. A more detailed description may help explain
> why the effectiveness of coalescing is preserved.
> 

Thanks for your comment, William-san.
I'd like to add detailed description on my patch.
I'm now afraid of the case of memory-hole, I should add page_is_valid(buddy1) before
accessing buddy1.


I wrote a draft of description, does this explain what you want to know?

==
What my patch does is,

1) when expand() is called, there are allocated half of pages and
    not-allocated half of pages.
    The top page of not-allocated half of pages is connected to free_area[order].free_list.
    At the same time, my newly added code record the order into
    page->private of the top page.
    Currently,in 2.6.8.1, this is done by MARK_USED with free_area[order]->bitmap[].

2) when __free_pages_bulk(page,order) is called,the buddy of the page is calclated by
    buddy = page_idx ^ (1 << order) ! this is used in current 2.6.8.1 code.
    For coalessing, we must check the buddy is free and the order of it.
    In 2.6.8.1, those two facts can be checked by
    !__test_and_change_bit(index, area->map)
    only one call.

    In my patch, this check is separated into 2 calls,
    (page_count(page) == 0) && (page_order(page) == order)
    Because expand() records the order of page, when pages are divided,
    __free_page_bulk() can use recorded information.
    In 2.6.8.1, the information "page is free ?" and " order of page? " are both recorded
    in bitmap.

3) why this patch records the page's order by page->private = ~order ?
    Because CPU LOCAL PAGES and some other codes use pages whose page_count(page)== 0,
    on the outside of buddy allocator.
    Mostly, thses pages' page->private is 0.
    This patch has to record order=0 in page->private, so using ~order for avoiding
    to coaless a page which is on the outside of buddy allocator.

   The Algorythm of this patch is not different from using bitmap,
   but "where to record order" is different.
==

Thanks
KAME

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

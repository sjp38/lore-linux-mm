Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i82NnI9B009887 for <linux-mm@kvack.org>; Fri, 3 Sep 2004 08:49:18 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i82NnHqA004323 for <linux-mm@kvack.org>; Fri, 3 Sep 2004 08:49:17 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A757A7CCA
	for <linux-mm@kvack.org>; Fri,  3 Sep 2004 08:49:17 +0900 (JST)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F924A7CCC
	for <linux-mm@kvack.org>; Fri,  3 Sep 2004 08:49:17 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3F00FUDU63KT@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri,  3 Sep 2004 08:49:16 +0900 (JST)
Date: Fri, 03 Sep 2004 08:54:31 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap(3) [1/3]
In-reply-to: <4136D318.9060102@jp.fujitsu.com>
Message-id: <4137B2B7.8080109@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <4136D318.9060102@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> New function: calculate_aligned_end()
> 
> calculate_aligned_end() removes some pages from system for removing invalid
> mem_map access from __free_pages_bulk() main loop.(This is in 4th patch)
> 
This is an illustration of the effects of calculate_aligned_end().

Examples for MAX_ORDER=4 is here.
In this case, an alignment of memmap is (1 << (4-1))=8

[unaligned end address case]

Consider contiguous mem_map from index 0 to index 19.
mem_map[16-19] is unaligned.

pfn     0           4           8          12            16 17 18 19
         -------------------------------------------------------------
order 0 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  -- out of range --
         -------------------------------------------------------------
order 1 |     |     |     |     |     |     |     |     |     |     |
         -------------------------------------------------------------
order 2 |           |           |           |           |           |
         ------------------------------------------------------------
order 3 |                       |                       |
         -------------------------------------------------
         <----------------------> <---------------------> <---------??? ---->
In this case, invalid mem_map access will occur during

(1) coalescing page 16 with page 20 in order=2. <- this means memory access to page 20.

calculate_aligned_end() removes page 19.

  pfn     0           4           8          12            16 17 18 19
         -------------------------------------------------------------
order 0 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | X|   -- out of range --
         -------------------------------------------------------------
order 1 |     |     |     |     |     |     |     |     |     |
         -------------------------------------------------------
order 2 |           |           |           |           |
         -------------------------------------------------
order 3 |                       |                       |
         -------------------------------------------------
         <----------------------> <--------------------->

         page 19 is removed.
         -> page 18 and page 19 cannot be coalesced.
         -> page 16 - page 19 cannot be coalesced.
         -> accessing invalid page 20 will not occur.


[unaligned start address case]
Consider a mem_map begins from index 2.

pfn     0     2     4           8          12           16
               -------------------------------------------------------------------
order 0       |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
               -------------------------------------------------------------------
order 1       |     |     |     |     |     |     |     |     |     |     |     |
               --------------------------------------------------------------------
order 2             |           |           |           |           |           |
                     -------------------------------------------------------------
order 3                         |                       |                       |
                                 -------------------------------------------------

In this case, invalid mem_map access will occur during
	(1) coalescing page 2 and page 0 in order=1
	(2) coalescing page 4 and page 0 in order=2

calculate_aligned_end() removes page 2 and 4.

pfn     0     2     4           8          12           16
               -------------------------------------------------------------------
order 0       |x |  |x |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
               -------------------------------------------------------------------
order 1                   |     |     |     |     |     |     |     |     |     |
                           --------------------------------------------------------
order 2                         |           |           |           |           |
                                 -------------------------------------------------
order 3                         |                       |                       |
                                 -------------------------------------------------

	page 2 is removed.
	-> page 2 and page 3 cannot be coalesced in order=0
	-> accessing invalid page 0 in order=1 will not occur.
	
	page 4 is removed.
	-> page 4 and page 5 cannot be coalesced in order=0.
	-> page 4 and page 6 cannot be coalesced in order=1.
	-> accessing invalid page 0 in order=2 will not occur.

Thanks.
--Kame
-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i942X1UI026383 for <linux-mm@kvack.org>; Mon, 4 Oct 2004 11:33:01 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i942X0ND026978 for <linux-mm@kvack.org>; Mon, 4 Oct 2004 11:33:00 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ADFCF216FC1
	for <linux-mm@kvack.org>; Mon,  4 Oct 2004 11:33:00 +0900 (JST)
Received: from fjmail504.fjmail.jp.fujitsu.com (fjmail504-0.fjmail.jp.fujitsu.com [10.59.80.102])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49C71216F54
	for <linux-mm@kvack.org>; Mon,  4 Oct 2004 11:33:00 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail504.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5100A8AGEYNX@fjmail504.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Mon,  4 Oct 2004 11:32:59 +0900 (JST)
Date: Mon, 04 Oct 2004 11:38:32 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
In-reply-to: <20041001182221.GA3191@logos.cnet>
Message-id: <4160B7A8.7010607@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <20041001182221.GA3191@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, Nick Piggin <piggin@cyberone.com.au>, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

how about inserting this if-sentense ?

-- Kame

Marcelo Tosatti wrote:
> +int coalesce_memory(unsigned int order, struct zone *zone)
> +{
<snip>

> +		while (entry != &area->free_list) {
> +			int ret;
> +			page = list_entry(entry, struct page, lru);
> +			entry = entry->next;
> +

   +              if (((page_to_pfn(page) - zone->zone_start_pfn) & (1 << toorder)) {

> +			pwalk = page;
> +
> +			/* Look backwards */
> +
> +			for (walkcount = 1; walkcount<nr_pages; walkcount++) {
                         ..................
> +			}
> +
   +               } else {
> +forward:
> +
> +			pwalk = page;
> +
> +			/* Look forward, skipping the page frames from this 
> +			  high order page we are looking at */
> +
> +			for (walkcount = (1UL << torder); walkcount<nr_pages; 
> +					walkcount++) {
> +				pwalk = page+walkcount;
> +
> +				ret = can_move_page(pwalk);
> +
> +				if (ret) 
> +					nr_freed_pages++;
> +				else
> +					goto loopey;
> +
> +				if (nr_freed_pages == nr_pages)
> +					goto success;
> +			}
> +
   +                }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

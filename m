Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7NNsqJB001798 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 08:54:52 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7NNspti002956 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 08:54:51 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail505.fjmail.jp.fujitsu.com (fjmail505-0.fjmail.jp.fujitsu.com [10.59.80.104]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7NNspJZ015966 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 08:54:51 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail505.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2X00I02BRDFF@fjmail505.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 24 Aug 2004 08:54:50 +0900 (JST)
Date: Tue, 24 Aug 2004 09:00:00 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC]  free_area[]  bitmap elimination [0/3]
In-reply-to: <1093271785.3153.754.camel@nighthawk>
Message-id: <412A8500.1010605@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <1093271785.3153.754.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Fri, 2004-08-20 at 19:31, Hiroyuki KAMEZAWA wrote: 
> 
>>This patch removes bitmap from buddy allocator used in
>>alloc_pages()/free_pages() in the kernel 2.6.8.1.
> 
> 
> Looks very interesting.  The most mysterious thing about it that I can
> think of right now would be its cache behavior.  Since struct pages are
> at least 1/2 a cacheline on most architectures, you're going to dirty
> quite a few more cachelines than if you were accessing a quick bitmap. 
> However, if the page was recently accessed you might get *better*
> cacheline performance because the struct page itself may have been
> hotter than its bitmap.  
> 

> The use of page_count()==0 is a little worrisome.  There's almost
> certainly some race conditions where a page can be mistaken for free
> while it's page_count()==0, but before it's reached free_pages_bulk().
> 
> BTW, even if page_count()==0 isn't a valid check like you fear, you
> could always steal a bit in the page->flags.  Check out 
> free_pages_check() in mm/page_alloc.c for a nice summary of what state
> pages have to be in before they're freed.  
> 
Thanks for your comment.

In this patch, "whether a page is free and in buddy allocator ?" is confirmed by
page_count(page) == 0 and  page_order(page) == valid_order.
A valid_order is a value between (unsigned long)~0 - (unsigned long)~(MAX_ORDER)

But there may be pages which have vague page->private and conflict with my
buddy page checking.
I'd like to read free_pages_check() more and take page->flags into account.

-- KAME


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

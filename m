Date: Tue, 24 Aug 2004 11:28:47 +0900 (JST)
Message-Id: <20040824.112847.133993345.taka@valinux.co.jp>
Subject: Re: [Lhms-devel] [RFC] free_area[] bitmap elimination [0/3]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <412A8500.1010605@jp.fujitsu.com>
References: <4126B3F9.90706@jp.fujitsu.com>
	<1093271785.3153.754.camel@nighthawk>
	<412A8500.1010605@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: haveblue@us.ibm.com, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi,

Your approach seems much better than mine for hotplug-memory.

> > The use of page_count()==0 is a little worrisome.  There's almost
> > certainly some race conditions where a page can be mistaken for free
> > while it's page_count()==0, but before it's reached free_pages_bulk().
> > 
> > BTW, even if page_count()==0 isn't a valid check like you fear, you
> > could always steal a bit in the page->flags.  Check out 
> > free_pages_check() in mm/page_alloc.c for a nice summary of what state
> > pages have to be in before they're freed.  
> > 
> Thanks for your comment.
> 
> In this patch, "whether a page is free and in buddy allocator ?" is confirmed by
> page_count(page) == 0 and  page_order(page) == valid_order.
> A valid_order is a value between (unsigned long)~0 - (unsigned long)~(MAX_ORDER)
> 
> But there may be pages which have vague page->private and conflict with my
> buddy page checking.
> I'd like to read free_pages_check() more and take page->flags into account.

This may have a good side effect.

If we can distinguish pages in the free_area lists from others precisely
and we can know order of the pages, we could capture pages without
traversing all pages in the free_area lists when removing a memory-section.
remove_page_freearea() Bradley Christiansen wrote would work more 
effectively.


Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

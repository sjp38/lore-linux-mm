Subject: Re: [Lhms-devel] [RFC]  free_area[]  bitmap elimination [0/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412A8500.1010605@jp.fujitsu.com>
References: <4126B3F9.90706@jp.fujitsu.com>
	 <1093271785.3153.754.camel@nighthawk>  <412A8500.1010605@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093315763.3153.1222.camel@nighthawk>
Mime-Version: 1.0
Date: Mon, 23 Aug 2004 19:49:23 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Mon, 2004-08-23 at 17:00, Hiroyuki KAMEZAWA wrote:
> In this patch, "whether a page is free and in buddy allocator ?" is confirmed by
> page_count(page) == 0 and  page_order(page) == valid_order.
> A valid_order is a value between (unsigned long)~0 - (unsigned long)~(MAX_ORDER)
> 
> But there may be pages which have vague page->private and conflict with my
> buddy page checking.
> I'd like to read free_pages_check() more and take page->flags into account.

I'm not saying that there *is* a bug with your code, just that
page->private has no *guarantees* about its contents, and there *can* be
a bug under certain conditions.  You rely on it not having particular
values but, since there are no checks and no zeroing, you really can't
assume anything.  Try setting page->private to random values just before
the free pages check, and I bet you'll eventually get some oopses.  

So, either don't rely on page->private for page_order(), or zero out
page->private before you zero the count.  Also, since you might
effectively be using one of these fields as a pseudo lock, make sure to
take memory ordering into account.  Unless it's an atomic function with
a test, things can get reordered quite easily.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7O3QOJB007584 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 12:26:24 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7O3QOqA004801 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 12:26:24 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail504.fjmail.jp.fujitsu.com (fjmail504-0.fjmail.jp.fujitsu.com [10.59.80.102]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7O3QNxi022137 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 12:26:23 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail504.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2X00KWLLJYA7@fjmail504.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 24 Aug 2004 12:26:23 +0900 (JST)
Date: Tue, 24 Aug 2004 12:31:31 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC]  free_area[]  bitmap elimination [0/3]
In-reply-to: <1093315763.3153.1222.camel@nighthawk>
Message-id: <412AB693.8030500@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <1093271785.3153.754.camel@nighthawk> <412A8500.1010605@jp.fujitsu.com>
 <1093315763.3153.1222.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>>But there may be pages which have vague page->private and conflict with my
>>buddy page checking.
>>I'd like to read free_pages_check() more and take page->flags into account.
> 
> 
> I'm not saying that there *is* a bug with your code, just that
> page->private has no *guarantees* about its contents, and there *can* be
> a bug under certain conditions.  You rely on it not having particular
> values but, since there are no checks and no zeroing, you really can't
> assume anything.  Try setting page->private to random values just before
> the free pages check, and I bet you'll eventually get some oopses.  
>
you are right.
my patches doesn't check and clear page->private before calling
free_pages_bulk().

> So, either don't rely on page->private for page_order(), or zero out
> page->private before you zero the count.  Also, since you might
> effectively be using one of these fields as a pseudo lock, make sure to
> take memory ordering into account.  Unless it's an atomic function with
> a test, things can get reordered quite easily.  
> 

I'd like to fix problems in the next patch, thank you for your advise :).


--Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

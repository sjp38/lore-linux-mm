Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7QN0TwH028879 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 08:00:29 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7QN0S0B013443 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 08:00:28 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98]) by s7.gw.fujitsu.co.jp (8.12.11)
	id i7QN0SUh012296 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 08:00:28 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I32003CET8R53@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 08:00:27 +0900 (JST)
Date: Fri, 27 Aug 2004 08:05:39 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
In-reply-to: <1093535402.2984.11.camel@nighthawk>
Message-id: <412E6CC3.8060908@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <412DD1AA.8080408@jp.fujitsu.com>
 <1093535402.2984.11.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi

I understand using these macros cleans up codes as I used them in my previous
version.

In the previous version, I used SetPagePrivate()/ClearPagePrivate()/PagePrivate().
But these are "atomic" operation and looks very slow.
This is why I doesn't used these macros in this version.

My previous version, which used set_bit/test_bit/clear_bit, shows very bad performance
on my test, and I replaced it.

If I made a mistake on measuring the performance and set_bit/test_bit/clear_bit
is faster than what I think, I'd like to replace them.

-- Kame

Dave Hansen wrote:
> On Thu, 2004-08-26 at 05:03, Hiroyuki KAMEZAWA wrote:
> 
>>-		MARK_USED(index + size, high, area);
>>+		page[size].flags |= (1 << PG_private);
>>+		page[size].private = high;
>>  	}
>>  	return page;
>>  }
> 
> ...
> 
>>+		/* Atomic operation is needless here */
>>+		page->flags &= ~(1 << PG_private);
> 
> 
> See linux/page_flags.h:
> 
> #define SetPagePrivate(page)    set_bit(PG_private, &(page)->flags)
> #define ClearPagePrivate(page)  clear_bit(PG_private, &(page)->flags)
> #define PagePrivate(page)       test_bit(PG_private, &(page)->flags)
> 
> -- Dave
> 
> 


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

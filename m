Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7P0CCwH022149 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 09:12:12 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7P0CCqA008991 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 09:12:12 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96]) by s7.gw.fujitsu.co.jp (8.12.11)
	id i7P0CBAf022825 for <linux-mm@kvack.org>; Wed, 25 Aug 2004 09:12:11 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2Z00DGG78AHG@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed, 25 Aug 2004 09:12:11 +0900 (JST)
Date: Wed, 25 Aug 2004 09:17:20 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC/PATCH] free_area[] bitmap elimination [3/3]
In-reply-to: <1093367129.1009.63.camel@nighthawk>
Message-id: <412BDA90.9040103@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <412B3785.30300@jp.fujitsu.com> <1093367129.1009.63.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> On Tue, 2004-08-24 at 05:41, Hiroyuki KAMEZAWA wrote:
> 
>>+static inline int page_is_buddy(struct page *page, int order)
>>+{
>>+       if (page_count(page) == 0 &&
>>+           PagePrivate(page) &&
>>+           !PageReserved(page) &&
>>+            page_order(page) == order) {
>>+               /* check, check... see free_pages_check() */
>>+               if (page_mapped(page) ||
>>+                   page->mapping != NULL ||
>>+                   (page->flags & (
>>+                           1 << PG_lru |
>>+                           1 << PG_locked      |
>>+                           1 << PG_active      |
>>+                           1 << PG_reclaim     |
>>+                           1 << PG_slab        |
>>+                           1 << PG_swapcache |
>>+                           1 << PG_writeback )))
>>+                       bad_page(__FUNCTION__, page);
>>+               return 1;
>>+       }
>>+       return 0;
>>+}
> 
> 
> Please share some code with the free_pages_check() that you stole this
> from.  It's nasty enough to have one copy of it around. :)
Hmm... this part is different from free_pages_check() even if I stoled it from.
Becasuse PG_private bit check is not done here. Sharing some code with
frees_page_check() would make free_pages_check() complex to read.

And this is only a bug checking code and bad_page( __FUNCTION__ , page) is useful
to test this buddy system.

>>+#ifdef CONFIG_VIRTUAL_MEM_MAP  
>>+                       /* This check is necessary when
>>+                          1. there may be holes in zone.
>>+                          2. a hole is not aligned in this order.
>>+                          currently, VIRTUAL_MEM_MAP case, is only case.
>>+                          Is there better call than pfn_valid ?
>>+                       */
>>+                       if (!pfn_valid(zone->zone_start_pfn + (page_idx ^ (1 << order))))
>>+                               break;
>>+#endif         
> 
> 
> This should be hidden in a header somewhere.  We don't want to have to
> see ia64-specific ifdefs in generic code.  
> 
Hmm, I understand what you say. I'll consider better another way.
But why #ifdef is inserted here is that this is RFC and
I want to make it clear this is IA64 specific.

Thank you for your all comments.

-- Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

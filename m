Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7R002wH020212 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:00:02 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7R000qA015274 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:00:00 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail504.fjmail.jp.fujitsu.com (fjmail504-0.fjmail.jp.fujitsu.com [10.59.80.102]) by s2.gw.fujitsu.co.jp (8.12.10)
	id i7QNxxcr028671 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 08:59:59 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail504.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3200B6VVZY20@fjmail504.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 08:59:58 +0900 (JST)
Date: Fri, 27 Aug 2004 09:05:10 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap [3/4]
In-reply-to: <1093535709.2984.24.camel@nighthawk>
Message-id: <412E7AB6.8020707@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <412DD34A.70802@jp.fujitsu.com> <1093535709.2984.24.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>>+                       if (zone->nr_mem_map > 1) {
>>+                               /*
>>+                                * there may be hole in zone's memmap &&
>>+                                * hole is not aligned in this order.
>>+                                * currently, I think CONFIG_VIRTUAL_MEM_MAP
>>+                                * case is only case to reach here.
>>+                                * Is there any other case ?
>>+                                */
>>+                               /*
>>+                                * Is there better call than pfn_valid ?
>>+                                */
>>+                               if (!pfn_valid(zone->zone_start_pfn
>>+                                              + (page_idx ^ (1 << order))))
>>+                                       break;
>>+                       }
> 
> 
> Nice try.  How about putting the ia64 code in a macro or header function
> that you can #ifdef out on all the other architectures?  We used to be
> able to see that entire while loop on one screen.  That's a bit harder
> now.  
> 
Currently, I think zone->nr_mem_map itself is very vague.
I'm now looking for another way to remove this part entirely.

I think mem_section approarch may be helpful to remove this part,
but to implement full feature of CONFIG_NONLINEAR,
I'll need lots of different kind of patches.
(If mem_map is guaranteed to be contiguous in one mem_section)

1. Now, I think some small parts, some essence of mem_section which
   makes pfn_valid() faster may be good.

And another way,

2. A method which enables page -> page's max_order calculation
   may be good and consistent way in this no-bitmap approach.

But this problem would be my week-end homework :).

--Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7VNVC9B015191 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 08:31:12 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7VNVC0B018940 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 08:31:12 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96]) by s7.gw.fujitsu.co.jp (8.12.11)
	id i7VNVBFd014285 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 08:31:11 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3C00IDL3ZY3S@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  1 Sep 2004 08:31:11 +0900 (JST)
Date: Wed, 01 Sep 2004 08:36:25 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap(2) [1/3]
In-reply-to: <1093993935.28787.416.camel@nighthawk>
Message-id: <41350B79.1070305@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <413455BE.6010302@jp.fujitsu.com>
 <1093969857.26660.4816.camel@nighthawk> <413501DC.2050409@jp.fujitsu.com>
 <1093993935.28787.416.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> On Tue, 2004-08-31 at 15:55, Hiroyuki KAMEZAWA wrote:
> 
>>Dave Hansen wrote:
>>
>>
>>>On Tue, 2004-08-31 at 03:41, Hiroyuki KAMEZAWA wrote:
>>>
>>>
>>>>+static void __init calculate_aligned_end(struct zone *zone,
>>>>+					 unsigned long start_pfn,
>>>>+					 int nr_pages)
>>>
>>>...
>>>
>>>
>>>>+		end_address = (zone->zone_start_pfn + end_idx) << PAGE_SHIFT;
>>>>+#ifndef CONFIG_DISCONTIGMEM
>>>>+		reserve_bootmem(end_address,PAGE_SIZE);
>>>>+#else
>>>>+		reserve_bootmem_node(zone->zone_pgdat,end_address,PAGE_SIZE);
>>>>+#endif
>>>>+	}
>>>>+	return;
>>>>+}
>>>
>>>
>>>What if someone has already reserved that address?  You might not be
>>>able to grow the zone, right?
>>>
>>
>>1) If someone has already reserved that address,  it (the page) will not join to
>>   buddy allocator and it's no problem.
>>
>>2) No, I can grow the zone.
>>   A reserved page is the last page of "not aligned contiguous mem_map", not zone.
>>
>>I answer your question ?
> 
> 
> If the end of the zone isn't aligned, you simply waste memory until it becomes aligned, right?
> 
No. I waste just one page, the end page of mem_map.
When the end of mem_map is not aligned, there are 2 cases.

case 1) length of mem_map is even number.
 -------------------------------
 |  |  |  |  |C |  |B |  |A | X|  no-page-area    order=0
 -------------------------------
 |     |     |C    |B    |                        order=1
 -------------------------
 |           |C          |                        order=2
 -------------------------
X is reserved and will not join to buddy system.
By doing this,
page "A" has no boddy in order=0, "X" is reserved.
page "B" has no buddy in order=1, "A" is order 0.
page "C" has no buddy in order=2, "A" is order 0.
..........

case 2) length of mem_map is odd number.
-----------------------------
 |  |  |  |  |C |  |B |  |X |    no-page-area    order=0
 ----------------------------
 |     |     |C    |B    |                       order=1
 -------------------------
 |           |C          |                       order=2
 -------------------------
page "B" has no buddy in order=1, X is reserved.
.........

Access to no-page-area in buddy system does not occur.

-- Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

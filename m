Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7VMoB9B032495 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:50:11 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7VMoBTM019587 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:50:11 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail504.fjmail.jp.fujitsu.com (fjmail504-0.fjmail.jp.fujitsu.com [10.59.80.102]) by s3.gw.fujitsu.co.jp (8.12.10)
	id i7VMoAkO029599 for <linux-mm@kvack.org>; Wed, 1 Sep 2004 07:50:10 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail504.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3C0062O23L92@fjmail504.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  1 Sep 2004 07:50:10 +0900 (JST)
Date: Wed, 01 Sep 2004 07:55:24 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap(2) [1/3]
In-reply-to: <1093969857.26660.4816.camel@nighthawk>
Message-id: <413501DC.2050409@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <413455BE.6010302@jp.fujitsu.com>
 <1093969857.26660.4816.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> On Tue, 2004-08-31 at 03:41, Hiroyuki KAMEZAWA wrote:
> 
>>+static void __init calculate_aligned_end(struct zone *zone,
>>+					 unsigned long start_pfn,
>>+					 int nr_pages)
> 
> ...
> 
>>+		end_address = (zone->zone_start_pfn + end_idx) << PAGE_SHIFT;
>>+#ifndef CONFIG_DISCONTIGMEM
>>+		reserve_bootmem(end_address,PAGE_SIZE);
>>+#else
>>+		reserve_bootmem_node(zone->zone_pgdat,end_address,PAGE_SIZE);
>>+#endif
>>+	}
>>+	return;
>>+}
> 
> 
> What if someone has already reserved that address?  You might not be
> able to grow the zone, right?
> 
1) If someone has already reserved that address,  it (the page) will not join to
   buddy allocator and it's no problem.

2) No, I can grow the zone.
   A reserved page is the last page of "not aligned contiguous mem_map", not zone.

I answer your question ?

I know this patch contains some BUG, if a page is allocateed when calculate_alinged_end()
is called, and is freed after calling this, it is never reserved and join to buddy system.

> 
>>+	/* Because memmap_init_zone() is called in suitable way
>>+	 * even if zone has memory holes,
>>+	 * calling calculate_aligned_end(zone) here is reasonable
>>+	 */
>>+	calculate_aligned_end(zonep, saved_start_pfn, size);
> 
> 
> Could you please elaborate on "suitable way".  That comment really
> doesn't say anything. 
I'll rewrite this.
/*
 *  calculate_aligned_end() has to be called by each contiguous mem_map.
 */




-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

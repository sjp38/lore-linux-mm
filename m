Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i97059UI028254 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 09:05:09 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i97059lr028033 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 09:05:09 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp (s3 [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 48BAD43F16
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 09:05:09 +0900 (JST)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D151F43F18
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 09:05:08 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5600FOXTKI7R@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Thu,  7 Oct 2004 09:05:08 +0900 (JST)
Date: Thu, 07 Oct 2004 09:10:44 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
In-reply-to: <1209350000.1097075647@[10.10.2.4]>
Message-id: <41648984.1080904@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <416392BF.1020708@jp.fujitsu.com>
 <1209350000.1097075647@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

>>This is generic parts.
>>
>>Boot-time routine:
>>At first, information of valid pages is gathered into a list.
>>After gathering all information, 2 level table are created.
>>Why I create table instead of using a list is only for good cache hit.
>>
>>pfn_valid_init()  <- initilize some structures
>>validate_pages(start,size) <- gather valid pfn information
>>pfn_valid_setup() <- create 1st and 2nd table.
> 
> 
> 
> Boggle. what on earth are you trying to do?
> 
I just want to test whether a struct page for that pfn exists or not.
ia64 has holes in memmap in a zone, so ia64_pfn_valid() uses get_user() to test
whether a page struct exists or not.

In my no-bitmap buddy allocator, I must call pfn_valid() for ia64 at every loop
in free_pages_bulk()(in mm/page_alloc.c).
Beacause of holes in memmap, bad_range()(in mm/page_alloc.c) cannot work enough.

code will be like this:
while(...) {
      pfn_of_buddy = some_func(pfn);
      if( bad_range(pfn_of_buddy) )
	       break;
      if( pfn_valid(pfn_of_buddy) )   <----- only for ia64.
                                             this will disappear in other archs.
	       break;
      ....
}

Because pfn_valid() often returns 0 in inner loop of free_pages_bulk(),
I want to avoid page fault caused by using get_user() in pfn_valid().

I have 2 plan (1) modify pfn_valid or (2) modify bad_range().
this is plan(1).

In plan(2), 1st/2nd tables are attached to each zone/pgdat.


> pfn_valid does exactly one thing - it checks whether there is a struct
> page for that pfn. Nothing else. Surely that can't possibly take a tenth
> of this amount of code?
> 
> M.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i967SKR6023578 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 16:28:20 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i967SJND018203 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 16:28:19 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF0D0216FC4
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 16:28:19 +0900 (JST)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 292A4216FBF
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 16:28:19 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5500MGWJF4JT@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  6 Oct 2004 16:28:17 +0900 (JST)
Date: Wed, 06 Oct 2004 16:33:52 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : intro[0/2]
In-reply-to: <B8E391BBE9FE384DAA4C5C003888BE6F0221CC82@scsmsx401.amr.corp.intel.com>
Message-id: <41639FE0.5060409@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221CC82@scsmsx401.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Luck, Tony wrote:
>>ia64's ia64_pfn_valid() uses get_user() for checking whether a 
>>page struct is available or not. I think this is an irregular 
>>implementation and following patches
>>are a more generic replacement, careful_pfn_valid(). It uses 2 
>>level table.
> 
> 
> It is odd ... but a somewhat convenient way to make check whether
> the page struct exists, while handling the fault if it is in an
> area of virtual mem_map that doesn't exist.  I think that in practice
> we rarely call it with a pfn that generates a fault (except in error
> paths).

I understand it's rare case.
Honestly, this patch is for no-bitmap buddy allocator (I posted before).
pfn_valid() returns 0 in many case in no-bitmap buddy allocator
(because MAX_ORDER is 4GB).
So I decided to write experimental pfn_valid() which doesn't cause fault.


> How big will the pfn_validmap[] be for a very sparse physical space
> like SGI Altix?  I'm not sure I see how PFN_VALID_MAPSHIFT is 
> generated for each system.
> 
PFN_VALID_MAPSHIFT can be overwritten in each asm-xxx/page.h. (can be in config.h)
I think each special architecture can find suitable value, if it wants.
If Altrix has XXX Tbytes for each node, setting 1 cache line(64bytes=32entry) covers
each node's maximum size will be good.

1st level table.
With current configuration, 1Gbytes per 2byte, 8Tbytes per 1 page(16kpages)

2nd level table.
1 entry per 8 bytes. Entries are coalesced with each other as much as possible.
If memory layout is like a bee's nest, careful_pfn_valid() will need great amount
of memory and cannot work fine because of searching.


BTW, how sparse SGI Altix ?

> Why do we need a loop when looking in the 2nd level?  Can't the
> entry from the 1st level point us to the right place?
> 
consider this case.

a 1st level entry covers 0x1000 - 0x2000
[valid range          ]  0x1000 - 0x1100
                          0x1200 - 0x1500
                          0x1600 - 0x2000

pfn_valid(0x1501)
             -> by 1st level, we get 0x1000-0x1100
                              into loop  0x1200-0x1500
                                         0x1600-       returns 0.

walking 2nd level table can reduce size of 1st table.
I'd like to avoid cache-miss rather than avoiding small walk.


- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

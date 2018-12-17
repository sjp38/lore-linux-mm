Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D80FE8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 09:18:05 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so8972020edc.9
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 06:18:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n56sor7408347edn.7.2018.12.17.06.18.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 06:18:04 -0800 (PST)
Date: Mon, 17 Dec 2018 14:18:02 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: clear zone_movable_pfn if the node
 doesn't have ZONE_MOVABLE
Message-ID: <20181217141802.4bl4icg3mvwtmhqe@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181216125624.3416-1-richard.weiyang@gmail.com>
 <20181217102534.GF30879@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217102534.GF30879@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@techsingularity.net, osalvador@suse.de

On Mon, Dec 17, 2018 at 11:25:34AM +0100, Michal Hocko wrote:
>On Sun 16-12-18 20:56:24, Wei Yang wrote:
>> A non-zero zone_movable_pfn indicates this node has ZONE_MOVABLE, while
>> current implementation doesn't comply with this rule when kernel
>> parameter "kernelcore=" is used.
>> 
>> Current implementation doesn't harm the system, since the value in
>> zone_movable_pfn is out of the range of current zone. While user would
>> see this message during bootup, even that node doesn't has ZONE_MOVABLE.
>> 
>>     Movable zone start for each node
>>       Node 0: 0x0000000080000000
>
>I am sorry but the above description confuses me more than it helps.
>Could you start over again and describe the user visible problem, then
>follow up with the udnerlying bug and finally continue with a proposed
>fix?

Yep, how about this one:

For example, a machine with 8G RAM, 2 nodes with 4G on each, if we pass
"kernelcore=2G" as kernel parameter, the dmesg looks like:

     Movable zone start for each node
       Node 0: 0x0000000080000000
       Node 1: 0x0000000100000000

This looks like both Node 0 and 1 has ZONE_MOVABLE, while the following
dmesg shows only Node 1 has ZONE_MOVABLE.

     On node 0 totalpages: 524190
       DMA zone: 64 pages used for memmap
       DMA zone: 21 pages reserved
       DMA zone: 3998 pages, LIFO batch:0
       DMA32 zone: 8128 pages used for memmap
       DMA32 zone: 520192 pages, LIFO batch:63
     
     On node 1 totalpages: 524255
       DMA32 zone: 4096 pages used for memmap
       DMA32 zone: 262111 pages, LIFO batch:63
       Movable zone: 4096 pages used for memmap
       Movable zone: 262144 pages, LIFO batch:63

The good news is current result doesn't harm the ZONE_MOVABLE
calculation, while it confuse user and may lead to code inconsistency.
For example, in adjust_zone_range_for_zone_movable(), the comment says
"Only adjust if ZONE_MOVABLE is on this node" by check zone_movable_pfn.
But we can see this doesn't hold for all cases.

The cause of this problem is we leverage zone_movable_pfn during the
iteration to record where we have touched and reduce double account.
But after using this, those temporary data is not cleared. 

To fix this issue, we may have several ways. In this patch I propose the
one with minimal change of current code by taking advantage of the
highest bit of zone_movable_pfn. When the zone_movable_pfn is a
temporary calculation data, the highest bit is set. After the entire
calculation is complete, zone_movable_pfn with highest bit set will be
cleared.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me

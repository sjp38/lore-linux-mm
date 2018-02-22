Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52C636B0003
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 16:20:05 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r29so4219603wra.13
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 13:20:05 -0800 (PST)
Received: from mo6-p00-ob.smtp.rzone.de (mo6-p00-ob.smtp.rzone.de. [2a01:238:20a:202:5300::11])
        by mx.google.com with ESMTPS id o8si680671wrg.351.2018.02.22.13.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 13:20:03 -0800 (PST)
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
From: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>
Message-ID: <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de>
Date: Thu, 22 Feb 2018 22:19:32 +0100
MIME-Version: 1.0
In-Reply-To: <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
Content-Type: multipart/mixed;
 boundary="------------9CEF91D617786B5B5B65FD0D"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

This is a multi-part message in MIME format.
--------------9CEF91D617786B5B5B65FD0D
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 8bit

On 02/19/18 11:19, Mel Gorman wrote:
>
>> Index: linux/mm/page_alloc.c
>> ===================================================================
>> --- linux.orig/mm/page_alloc.c
>> +++ linux/mm/page_alloc.c
>> @@ -1844,7 +1844,12 @@ struct page *__rmqueue_smallest(struct z
>>   		area = &(zone->free_area[current_order]);
>>   		page = list_first_entry_or_null(&area->free_list[migratetype],
>>   							struct page, lru);
>> -		if (!page)
>> +		/*
>> +		 * Continue if no page is found or if our freelist contains
>> +		 * less than the minimum pages of that order. In that case
>> +		 * we better look for a different order.
>> +		 */
>> +		if (!page || area->nr_free < area->min)
>>   			continue;
>>   		list_del(&page->lru);
>>   		rmv_page_order(page);
> This is surprising to say the least. Assuming reservations are at order-3,
> this would refuse to split order-3 even if there was sufficient reserved
> pages at higher orders for a reserve.

Hi Mel,

I agree with you that the above code does not really do what it should.

At least, the condition needs to be changed to:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c9688b6a0a..193dfd85a6b1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1837,7 +1837,15 @@ struct page *__rmqueue_smallest(struct zone 
*zone, unsigned int order,
                 area = &(zone->free_area[current_order]);
                 page = 
list_first_entry_or_null(&area->free_list[migratetype],
                                                         struct page, lru);
-               if (!page)
+               /*
+                * Continue if no page is found or if we are about to
+                * split a truly higher order than requested.
+                * There is no limit for just _using_ exactly the right
+                * order. The limit is only for _splitting_ some
+                * higher order.
+                */
+               if (!page ||
+                   (area->nr_free < area->min && current_order > order))
                         continue;
                 list_del(&page->lru);
                 rmv_page_order(page);


The "&& current_order > order" part is _crucial_. If left out, it will 
work even counter-productive. I know this from development of my 
original patch some years ago.

Please have a look at the attached patchset for kernel 3.16 which is in 
_production_ at 1&1 Internet SE at about 20,000 servers for several 
years now, starting from kernel 3.2.x to 3.16.x (or maybe the very first 
version was for 2.6.32, I don't remember exactly).

It has collected several millions of operation hours in total, and it is 
known to work miracles for some of our workloads.

Porting to later kernels should be relatively easy. Also notice that the 
switch labels at patch #2 could need some minor tweaking, e.g. also 
including ZONE_DMA32 or similar, and also might need some 
architecture-specific tweaking. All of the tweaking is depending on the 
actual workload. I am using it only at datacenter servers (webhosting) 
and at x86_64.

Please notice that the user interface of my patchset is extremely simple 
and can be easily understood by junior sysadmins:

After running your box for several days or weeks or even months (or 
possibly, after you just got an OOM), just do
# cat /proc/sys/vm/perorder_statistics > /etc/defaults/my_perorder_reserve

Then add a trivial startup script, e.g. to systemd or to sysv init etc, 
which just does the following early during the next reboot:
# cat /etc/defaults/my_perorder_reserve > /proc/sys/vm/perorder_reserve

That's it.

No need for a deep understanding of the theory of the memory 
fragmentation problem.

Also no need for adding anything to the boot commandline. Fragmentation 
will typically occur only after some days or weeks or months of 
operation, at least in all of the practical cases I have personally seen 
at 1&1 datacenters and their workloads.

Please notice that fragmentation can be a very serious problem for 
operations if you are hurt by it. It can seriously harm your business. 
And it is _extremely_ specific to the actual workload, and to the 
hardware / chipset / etc. This is addressed by the above method of 
determining the right values from _actual_ operations (not from 
speculation) and then memoizing them.

The attached patchset tries to be very simple, but in my practical 
experience it is a very effective practical solution.

When requested, I can post the mathematical theory behind the patch, or 
I could give a presentation at some of the next conferences if I would 
be invited (or better give a practical explanation instead). But 
probably nobody on these lists wants to deal with any theories.

Just _play_ with the patchset practically, and then you will notice.

Cheers and greetings,

Yours sincerly old-school hacker Thomas


P.S. I cannot attend these lists full-time due to my workload at 1&1 
which is unfortunately not designed for upstream hacking, so please stay 
patient with me if an answer takes a few days.



--------------9CEF91D617786B5B5B65FD0D
Content-Type: text/plain; charset=utf-8;
 name="0001-mm-fix-fragmentation-by-pre-reserving-higher-order-p.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-mm-fix-fragmentation-by-pre-reserving-higher-order-p.pa";
 filename*1="tch"


--------------9CEF91D617786B5B5B65FD0D--

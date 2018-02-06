Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 190006B0294
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 13:18:47 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id x68so3083307ywx.9
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 10:18:47 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t83si1894278ywb.721.2018.02.06.10.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 10:18:46 -0800 (PST)
Subject: Re: [RFC PATCH v1 13/13] mm: splice local lists onto the front of the
 LRU
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <20180131230413.27653-14-daniel.m.jordan@oracle.com>
 <765238a2-8970-e05d-4fe3-cdcb796aa399@linux.vnet.ibm.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <a9518500-cc2a-ce15-76a4-73a31b744852@oracle.com>
Date: Tue, 6 Feb 2018 13:18:53 -0500
MIME-Version: 1.0
In-Reply-To: <765238a2-8970-e05d-4fe3-cdcb796aa399@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

On 02/02/2018 10:22 AM, Laurent Dufour wrote:
> On 01/02/2018 00:04, daniel.m.jordan@oracle.com wrote:
...snip...
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 99a54df760e3..6911626f29b2 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2077,6 +2077,7 @@ static void lock_page_lru(struct page *page, int *isolated)
>>
>>   		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>>   		ClearPageLRU(page);
>> +		smp_rmb(); /* Pairs with smp_wmb in __pagevec_lru_add */
> 
> Why not include the call to smp_rmb() in del_page_from_lru_list() instead
> of spreading smp_rmb() before calls to del_page_from_lru_list() ?

Yes, this is what I should have done.  The memory barriers came from 
another patch I squashed in and I didn't look back to see how obvious 
the encapsulation was.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

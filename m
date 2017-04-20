Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A13A36B03C4
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 06:51:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k14so5210765wrc.16
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 03:51:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m74si15173386wmh.53.2017.04.20.03.51.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 03:51:45 -0700 (PDT)
Subject: Re: [PATCH v3 6/9] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-7-mhocko@kernel.org>
 <20170410162547.GM4618@dhcp22.suse.cz>
 <49b6c3e2-0e68-b77e-31d6-f589d3b4822e@suse.cz>
 <20170420090605.GD15781@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <54f98d7c-2a7a-b81a-0e8b-85a4b55ebe9b@suse.cz>
Date: Thu, 20 Apr 2017 12:51:42 +0200
MIME-Version: 1.0
In-Reply-To: <20170420090605.GD15781@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 04/20/2017 11:06 AM, Michal Hocko wrote:
> On Thu 20-04-17 10:25:27, Vlastimil Babka wrote:
>>> + * intersection with the given zone
>>> + */
>>> +static inline bool zone_intersects(struct zone *zone,
>>> +		unsigned long start_pfn, unsigned long nr_pages)
>>> +{
>>
>> I'm looking at your current mmotm tree branch, which looks like this:
>>
>> + * Return true if [start_pfn, start_pfn + nr_pages) range has a non-mpty
>> + * intersection with the given zone
>> + */
>> +static inline bool zone_intersects(struct zone *zone,
>> +               unsigned long start_pfn, unsigned long nr_pages)
>> +{
>> +       if (zone_is_empty(zone))
>> +               return false;
>> +       if (zone->zone_start_pfn <= start_pfn && start_pfn < zone_end_pfn(zone))
>> +               return true;
>> +       if (start_pfn + nr_pages > zone->zone_start_pfn)
>> +               return true;
>>
>> A false positive is possible here, when start_pfn >= zone_end_pfn(zone)?
> 
> Ohh, right. Looks better?

Yeah.

You can add for the whole patch

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But I can't guarantee some corner case won't surface. The hotplug code
is far from straightforward :(


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

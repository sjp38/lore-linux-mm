Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECADC6B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 22:22:02 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id l20so114905145qta.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 19:22:02 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id q58si1912071qta.108.2016.11.09.19.22.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 19:22:02 -0800 (PST)
Message-ID: <5823E6AF.8040600@huawei.com>
Date: Thu, 10 Nov 2016 11:17:03 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] mem-hotplug: shall we skip unmovable node when doing numa
 balance?
References: <582157E5.8000106@huawei.com> <20161109115827.GD3614@techsingularity.net>
In-Reply-To: <20161109115827.GD3614@techsingularity.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "robert.liu@huawei.com" <robert.liu@huawei.com>

On 2016/11/9 19:58, Mel Gorman wrote:

> On Tue, Nov 08, 2016 at 12:43:17PM +0800, Xishi Qiu wrote:
>> On mem-hotplug system, there is a problem, please see the following case.
>>
>> memtester xxG, the memory will be alloced on a movable node. And after numa
>> balancing, the memory may be migrated to the other node, it may be a unmovable
>> node. This will reduce the free memory of the unmovable node, and may be oom
>> later.
>>
> 
> How would it OOM later? It's movable memmory that is moving via
> automatic NUMA balancing so at the very least it can be reclaimed. If
> the memory is mlocked or unable to migrate then it's irrelevant if
> automatic balancing put it there.
> 

Hi Mel,

memtester will mlock the memory, so we can not reclaim, then maybe oom, right?
So let the manager set some numa policies to prevent the above case, right?

Thanks,
Xishi Qiu

>> My question is that shall we skip unmovable node when doing numa balance?
>> or just let the manager set some numa policies?
>>
> 
> If the unmovable node must be protected from automatic NUMA balancing
> then policies are the appropriate step to prevent the processes running
> on that node or from allocating memory on that node.
> 
> Either way, protecting unmovable nodes in the name of hotplug is pretty
> much guaranteed to be a performance black hole because at the very
> least, page table pages will always be remote accesses for processes
> running on the unmovable node.
> 
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 057964d..f0954ac 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2334,6 +2334,13 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>>  out:
>>  	mpol_cond_put(pol);
>>  
>> +	/* Skip unmovable nodes when do numa balancing */
>> +	if (movable_node_enabled && ret != -1) {
>> +		zone = NODE_DATA(ret)->node_zones + MAX_NR_ZONES - 1;
>> +		if (!populated_zone(zone))
>> +			ret = -1;
>> +	}
>> +
>>  	return ret;
>>  }
> 
> Nak.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 5B7DC6B0069
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 04:00:05 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1199581pbb.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 01:00:04 -0700 (PDT)
Message-ID: <5034917E.2060800@gmail.com>
Date: Wed, 22 Aug 2012 15:59:58 +0800
From: qiuxishi <qiuxishi@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add build zonelists when offline pages
References: <5033843E.8000902@gmail.com> <50347906.4030101@cn.fujitsu.com>
In-Reply-To: <50347906.4030101@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, liuj97@gmail.com, paul.gortmaker@windriver.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bessel.wang@huawei.com, wujianguo@huawei.com, qiuxishi@huawei.com, jiang.liu@huawei.com, guohanjun@huawei.com, chenkeping@huawei.com, yinghai@kernel.org

On 2012-8-22 14:15, Wen Congyang wrote:
> At 08/21/2012 08:51 PM, qiuxishi Wrote:
>> From: Xishi Qiu <qiuxishi@huawei.com>
>>
>> online_pages() does build_all_zonelists() and zone_pcp_update(),
>> I think offline_pages() should do it too. The node has no memory
>> to allocate, so remove this node's zones form other nodes' zonelists.
>>
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  mm/memory_hotplug.c |    6 +++++-
>>  1 files changed, 5 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index bc7e7a2..5172bd4 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -979,7 +979,11 @@ repeat:
>>  	if (!node_present_pages(node)) {
>>  		node_clear_state(node, N_HIGH_MEMORY);
>>  		kswapd_stop(node);
>> -	}
>> +		mutex_lock(&zonelists_mutex);
>> +		build_all_zonelists(NODE_DATA(node), NULL);
> 
> The node is still onlined now, so there is no need to pass
> this node's pgdat to build_all_zonelists().
> 
> I think we should build all zonelists when the zone has no
> pages.
> 
>> +		mutex_unlock(&zonelists_mutex);
>> +	} else
>> +		zone_pcp_update(zone);
> 
> There is more than one zone in a node. So the zone can have
> no pages when the node has some pages.
> 

Yes, you are right. Here is the new patch,

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index bc7e7a2..5f6997f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -973,8 +973,13 @@ repeat:

 	init_per_zone_wmark_min();

-	if (!populated_zone(zone))
+	if (!populated_zone(zone)) {
 		zone_pcp_reset(zone);
+		mutex_lock(&zonelists_mutex);
+		build_all_zonelists(NULL, NULL);
+		mutex_unlock(&zonelists_mutex);
+	} else
+		zone_pcp_update(zone);

 	if (!node_present_pages(node)) {
 		node_clear_state(node, N_HIGH_MEMORY);
-- 
1.7.6.1

> And we have called drain_all_pages(), I think there is no need
> to call zone_pcp_update() here.
> 
> Thanks
> Wen Congyang
> 

In zone_pcp_update(), it calculates zone_batchsize() which does
not calculated in drain_all_pages().

Thanks
Xishi Qiu

>>
>>  	vm_total_pages = nr_free_pagecache_pages();
>>  	writeback_set_ratelimit();
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

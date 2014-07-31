Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 90B3E6B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 16:44:01 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so4143321pdb.17
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 13:44:01 -0700 (PDT)
Received: from USMAMAIL.TILERA.COM (usmamail.tilera.com. [12.216.194.151])
        by mx.google.com with ESMTPS id x1si7202008pad.96.2014.07.31.13.44.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 Jul 2014 13:44:00 -0700 (PDT)
Message-ID: <53DAAA8E.6000007@tilera.com>
Date: Thu, 31 Jul 2014 16:43:58 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 7/7] memory-hotplug: tile: suitable memory should go
 to ZONE_MOVABLE
References: <1405914402-66212-1-git-send-email-wangnan0@huawei.com> <1405914402-66212-8-git-send-email-wangnan0@huawei.com> <53CDD5EE.1030805@huawei.com>
In-Reply-To: <53CDD5EE.1030805@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Nan <wangnan0@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

On 7/21/2014 11:09 PM, Wang Nan wrote:
> Hi Andrew,
>
> Please drop patch 7/7 from -mm tree and keep other 6 patches.
>
> arch_add_memory() in tile is different from others: no nid parameter.
> Patch 7/7 will block compiling.
>
> I cc this mail to Chris Metcalf and hope he can look at this issue.
>
> Other 6 patches looks good.
>
> On 2014/7/21 11:46, Wang Nan wrote:
>> This patch introduces zone_for_memory() to arch_add_memory() on tile to
>> ensure new, higher memory added into ZONE_MOVABLE if movable zone has
>> already setup.
>>
>> This patch also fix a problem: on tile, new memory should be added into
>> ZONE_HIGHMEM by default, not MAX_NR_ZONES-1, which is ZONE_MOVABLE.
>>
>> Signed-off-by: Wang Nan <wangnan0@huawei.com>
>> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> ---
>>  arch/tile/mm/init.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
>> index bfb3127..22ac6c1 100644
>> --- a/arch/tile/mm/init.c
>> +++ b/arch/tile/mm/init.c
>> @@ -872,7 +872,8 @@ void __init mem_init(void)
>>  int arch_add_memory(u64 start, u64 size)
>>  {
>>  	struct pglist_data *pgdata = &contig_page_data;
>> -	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
>> +	struct zone *zone = pgdata->node_zones +
>> +		zone_for_memory(nid, start, size, ZONE_HIGHMEM);
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>>  

This code is entirely stale; it came from the initial port of Linux
2.6.15 to Tilera.  Since we have always used DISCONTIGMEM unconditionally,
which forces NEED_MULTIPLE_NODES to be true, this code never compiles.
Note the completely irrelevant comment about x86 in this ifdef block, too :-)

The cleanest thing to do is just remove those three functions in the
ifdef block.  I'll do that to our internal tree and plan to push the
change upstream later.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

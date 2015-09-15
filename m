Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id ED1856B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 19:06:10 -0400 (EDT)
Received: by iofb144 with SMTP id b144so215303226iof.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:06:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 42si15088110iok.146.2015.09.15.16.06.09
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 16:06:10 -0700 (PDT)
Subject: Re: +
 mm-memory-hot-add-memory-can-not-be-added-to-movable-zone-defaultly.patch
 added to -mm tree
References: <55f89282.Ea4OBESeo1emyCz7%akpm@linux-foundation.org>
 <20150915145232.fb74148815fa79bfeaad88bc@linux-foundation.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <55F8A461.3070309@intel.com>
Date: Tue, 15 Sep 2015 16:06:09 -0700
MIME-Version: 1.0
In-Reply-To: <20150915145232.fb74148815fa79bfeaad88bc@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, liuchangcheng@inspur.com, fandd@inspur.com, guz.fnst@cn.fujitsu.com, hutao@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, qiuxishi@huawei.com, tangchen@cn.fujitsu.com, toshi.kani@hp.com, wangnan0@huawei.com, yanxiaofeng@inspur.com, yinghai@kernel.org, zhangyanfei@cn.fujitsu.com, Linux-MM <linux-mm@kvack.org>

On 09/15/2015 02:52 PM, Andrew Morton wrote:
>>  /*
>>   * If movable zone has already been setup, newly added memory should be check.
>>   * If its address is higher than movable zone, it should be added as movable.
>> + * And if system boots up with movable_node and config CONFIG_MOVABLE_NOD and
>> + * added memory does not overlap the zone before MOVABLE_ZONE,
>> + * the memory is added as movable
>>   * Without this check, movable zone may overlap with other zone.
>>   */
>>  static int should_add_memory_movable(int nid, u64 start, u64 size)
>> @@ -1208,6 +1211,11 @@ static int should_add_memory_movable(int
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	pg_data_t *pgdat = NODE_DATA(nid);
>>  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>> +	struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
>> +
>> +	if (movable_node_is_enabled()
>> +	&& zone_end_pfn(pre_zone) <= start_pfn)
>> +		return 1;

This check seems goofy to me.  According to the description, we're
looking at a node here which has all of its zones empty.  So it
definitely has zone->spanned_pages=0.  zone_end_pfn() is looking at
zone->zone_start_pfn too, which is also 0, presumably.

So why is it bothering to look at the pfns if they're potentially
"garbage"?  It seems like we really want something like this:

	if (all_node_zones_empty(pgdat)) {
		/*
		 * We usually want a ZONE_NORMAL before we add a
		 * ZONE_MOVABLE since ZONE_MOVABLE is mildly crippled.
		 * We only want ZONE_MOVABLE first when 'movable_node'
		 * mode is on.
		 */
		return movable_node_is_enabled();
	}

Either way, this is a behavior change.  It's one that is triggered by a
config option plus a boot option, but it might surprise some users.  Is
this new behavior documented?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

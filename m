Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 84C876B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 01:33:25 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so2985594pad.1
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 22:33:25 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id fn9si13226607pdb.160.2014.10.21.22.33.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 22:33:24 -0700 (PDT)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DDE9B3EE1C1
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:33:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id C42E5AC076D
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:33:21 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7108B1DB8037
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:33:21 +0900 (JST)
Message-ID: <5447416C.5080106@jp.fujitsu.com>
Date: Wed, 22 Oct 2014 14:32:28 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: Clear pgdat which is allocated by bootmem
 in try_offline_node()
References: <5444DE75.6010206@jp.fujitsu.com> <1413910581.12798.25.camel@misato.fc.hp.com>
In-Reply-To: <1413910581.12798.25.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhenzhang.zhang@huawei.com, wangnan0@huawei.com, tangchen@cn.fujitsu.com, dave.hansen@intel.com, rientjes@google.com

(2014/10/22 1:56), Toshi Kani wrote:
> On Mon, 2014-10-20 at 19:05 +0900, Yasuaki Ishimatsu wrote:
>   :
>> When hot removing memory, pgdat is set to 0 in try_offline_node().
>> But if the pgdat is allocated by bootmem allocator, the clearing
>> step is skipped. And when hot adding the same memory, the uninitialized
>> pgdat is reused. But free_area_init_node() chacks wether pgdat is set
>

> s/chacks/checks

I'll update it.

>
>
>> to zero. As a result, free_area_init_node() hits WARN_ON().
>>
>> This patch clears pgdat which is allocated by bootmem allocator
>> in try_offline_node().
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> CC: Zhang Zhen <zhenzhang.zhang@huawei.com>
>> CC: Wang Nan <wangnan0@huawei.com>
>> CC: Tang Chen <tangchen@cn.fujitsu.com>
>> CC: Toshi Kani <toshi.kani@hp.com>
>> CC: Dave Hansen <dave.hansen@intel.com>
>> CC: David Rientjes <rientjes@google.com>
>>
>> ---
>>   mm/memory_hotplug.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 29d8693..7649f7c 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1943,7 +1943,7 @@ void try_offline_node(int nid)
>>
>>   	if (!PageSlab(pgdat_page) && !PageCompound(pgdat_page))
>>   		/* node data is allocated from boot memory */
>> -		return;
>> +		goto out;
>

> Do we still need this if-statement?  That is, do we have to skip the
> for-loop below even though it checks with is_vmalloc_addr()?

You are right. The if-statement is not necessary. So the issue can be
fixed by just removing the if-statement.

I'll post updated patch soon.

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>
>
>>   	/* free waittable in each zone */
>>   	for (i = 0; i < MAX_NR_ZONES; i++) {
>> @@ -1957,6 +1957,7 @@ void try_offline_node(int nid)
>>   			vfree(zone->wait_table);
>>   	}
>>
>> +out:
>>   	/*
>>   	 * Since there is no way to guarentee the address of pgdat/zone is not
>>   	 * on stack of any kernel threads or used by other kernel objects
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

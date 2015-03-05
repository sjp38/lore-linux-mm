Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DAAAF6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 05:03:08 -0500 (EST)
Received: by padfa1 with SMTP id fa1so41303400pad.9
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 02:03:08 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id de6si1548627pdb.184.2015.03.05.02.03.06
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 02:03:08 -0800 (PST)
Message-ID: <54F825CB.8040402@cn.fujitsu.com>
Date: Thu, 5 Mar 2015 17:45:47 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F81322.8010202@cn.fujitsu.com> <54F8243D.7020809@huawei.com>
In-Reply-To: <54F8243D.7020809@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Xishi,

On 03/05/2015 05:39 PM, Xishi Qiu wrote:

> On 2015/3/5 16:26, Gu Zheng wrote:
> 
>> Hi Xishi,
>> Could you please try the following one?
>> It postpones the reset of obsolete pgdat from try_offline_node() to
>> hotadd_new_pgdat(), and just resetting pgdat->nr_zones and
>> pgdat->classzone_idx to be 0 rather than the whole reset by memset()
>> as Kame suggested.
>>
>> Regards,
>> Gu
>>
>> ---
>>  mm/memory_hotplug.c |   13 ++++---------
>>  1 files changed, 4 insertions(+), 9 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 1778628..c17eebf 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1092,6 +1092,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>>  			return NULL;
>>  
>>  		arch_refresh_nodedata(nid, pgdat);
>> +	} else {
>> +		/* Reset the nr_zones and classzone_idx to 0 before reuse */
>> +		pgdat->nr_zones = 0;
>> +		pgdat->classzone_idx = 0;
> 
> Hi Gu,
> 
> This is just to avoid the warning, I think it's no meaning.

Can not agree.
The key point here is postponing the reset of obsolete pgdat to the time we
want to reuse it to avoid the effect(Oops: 0000 as you mentioned), and avoiding
warning is the minor benefit, though it is also important.

> Here is the changlog from the original patch:
> 
> commit 88fdf75d1bb51d85ba00c466391770056d44bc03
>     ...
>     Warn if memory-hotplug/boot code doesn't initialize pg_data_t with zero
>     when it is allocated.  Arch code and memory hotplug already initiailize
>     pg_data_t.  So this warning should never happen.  I select fields *randomly*
>     near the beginning, middle and end of pg_data_t for checking.
>     ...

There was not hot remove node that time, so it seems did not consider the *reuse*
case, but anyway, we should not break it here.

Regards,
Gu

> 
> Thanks,
> Xishi Qiu
> 
>>  	}
>>  
>>  	/* we can use NODE_DATA(nid) from here */
>> @@ -2021,15 +2025,6 @@ void try_offline_node(int nid)
>>  
>>  	/* notify that the node is down */
>>  	call_node_notify(NODE_DOWN, (void *)(long)nid);
>> -
>> -	/*
>> -	 * Since there is no way to guarentee the address of pgdat/zone is not
>> -	 * on stack of any kernel threads or used by other kernel objects
>> -	 * without reference counting or other symchronizing method, do not
>> -	 * reset node_data and free pgdat here. Just reset it to 0 and reuse
>> -	 * the memory when the node is online again.
>> -	 */
>> -	memset(pgdat, 0, sizeof(*pgdat));
>>  }
>>  EXPORT_SYMBOL(try_offline_node);
>>  
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

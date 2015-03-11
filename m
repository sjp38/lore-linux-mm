Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEC790002E
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:29:32 -0400 (EDT)
Received: by pdbfl12 with SMTP id fl12so6723757pdb.9
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 18:29:32 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id fn4si511062pab.203.2015.03.10.18.29.30
        for <linux-mm@kvack.org>;
        Tue, 10 Mar 2015 18:29:31 -0700 (PDT)
Message-ID: <54FF9662.8080303@cn.fujitsu.com>
Date: Wed, 11 Mar 2015 09:12:02 +0800
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

What is the condition of this problem now?

Regards,
Gu
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
> Here is the changlog from the original patch:
> 
> commit 88fdf75d1bb51d85ba00c466391770056d44bc03
>     ...
>     Warn if memory-hotplug/boot code doesn't initialize pg_data_t with zero
>     when it is allocated.  Arch code and memory hotplug already initiailize
>     pg_data_t.  So this warning should never happen.  I select fields *randomly*
>     near the beginning, middle and end of pg_data_t for checking.
>     ...
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

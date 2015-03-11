Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 92AFA90002E
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 22:53:58 -0400 (EDT)
Received: by oifu20 with SMTP id u20so5375336oif.11
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 19:53:58 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m6si979832oel.34.2015.03.10.19.53.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 19:53:57 -0700 (PDT)
Message-ID: <54FFADB6.60604@huawei.com>
Date: Wed, 11 Mar 2015 10:51:34 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F81322.8010202@cn.fujitsu.com> <54F8243D.7020809@huawei.com> <54FF9662.8080303@cn.fujitsu.com>
In-Reply-To: <54FF9662.8080303@cn.fujitsu.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 2015/3/11 9:12, Gu Zheng wrote:
> Hi Xishi,
> 
> What is the condition of this problem now?

Hi Gu,

I have no machine to do this test now. But I've tested the
patch "just remove memset 0" more than 20 hours last week,
it's OK.

Thanks,
	Xie XiuQi

> 
> Regards,
> Gu
> On 03/05/2015 05:39 PM, Xishi Qiu wrote:
> 
>> On 2015/3/5 16:26, Gu Zheng wrote:
>>
>>> Hi Xishi,
>>> Could you please try the following one?
>>> It postpones the reset of obsolete pgdat from try_offline_node() to
>>> hotadd_new_pgdat(), and just resetting pgdat->nr_zones and
>>> pgdat->classzone_idx to be 0 rather than the whole reset by memset()
>>> as Kame suggested.
>>>
>>> Regards,
>>> Gu
>>>
>>> ---
>>>  mm/memory_hotplug.c |   13 ++++---------
>>>  1 files changed, 4 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 1778628..c17eebf 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1092,6 +1092,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>>>  			return NULL;
>>>  
>>>  		arch_refresh_nodedata(nid, pgdat);
>>> +	} else {
>>> +		/* Reset the nr_zones and classzone_idx to 0 before reuse */
>>> +		pgdat->nr_zones = 0;
>>> +		pgdat->classzone_idx = 0;
>>
>> Hi Gu,
>>
>> This is just to avoid the warning, I think it's no meaning.
>> Here is the changlog from the original patch:
>>
>> commit 88fdf75d1bb51d85ba00c466391770056d44bc03
>>     ...
>>     Warn if memory-hotplug/boot code doesn't initialize pg_data_t with zero
>>     when it is allocated.  Arch code and memory hotplug already initiailize
>>     pg_data_t.  So this warning should never happen.  I select fields *randomly*
>>     near the beginning, middle and end of pg_data_t for checking.
>>     ...
>>
>> Thanks,
>> Xishi Qiu
>>
>>>  	}
>>>  
>>>  	/* we can use NODE_DATA(nid) from here */
>>> @@ -2021,15 +2025,6 @@ void try_offline_node(int nid)
>>>  
>>>  	/* notify that the node is down */
>>>  	call_node_notify(NODE_DOWN, (void *)(long)nid);
>>> -
>>> -	/*
>>> -	 * Since there is no way to guarentee the address of pgdat/zone is not
>>> -	 * on stack of any kernel threads or used by other kernel objects
>>> -	 * without reference counting or other symchronizing method, do not
>>> -	 * reset node_data and free pgdat here. Just reset it to 0 and reuse
>>> -	 * the memory when the node is online again.
>>> -	 */
>>> -	memset(pgdat, 0, sizeof(*pgdat));
>>>  }
>>>  EXPORT_SYMBOL(try_offline_node);
>>>  
>>
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> .
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

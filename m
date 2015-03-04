Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 885856B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 04:04:05 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so32221106pdb.3
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 01:04:05 -0800 (PST)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id hn4si4139348pbb.173.2015.03.04.01.04.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 01:04:04 -0800 (PST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 482FDAC0A2A
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 18:04:01 +0900 (JST)
Message-ID: <54F6C809.1080709@jp.fujitsu.com>
Date: Wed, 4 Mar 2015 17:53:29 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com> <54F67376.8050001@huawei.com> <54F68270.5000203@cn.fujitsu.com> <54F6BC43.3000509@huawei.com>
In-Reply-To: <54F6BC43.3000509@huawei.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Li Zefan <lizefan@huawei.com>

On 2015/03/04 17:03, Xishi Qiu wrote:
> On 2015/3/4 11:56, Gu Zheng wrote:
>
>> Hi Xishi,
>> On 03/04/2015 10:52 AM, Xishi Qiu wrote:
>>
>>> On 2015/3/4 10:22, Xishi Qiu wrote:
>>>
>>>> On 2015/3/3 18:20, Gu Zheng wrote:
>>>>
>>>>> Hi Xishi,
>>>>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>>>>
>>>>>> When hot-remove a numa node, we will clear pgdat,
>>>>>> but is memset 0 safe in try_offline_node()?
>>>>>
>>>>> It is not safe here. In fact, this is a temporary solution here.
>>>>> As you know, pgdat is accessed lock-less now, so protection
>>>>> mechanism (RCUi 1/4 ?) is needed to make it completely safe here,
>>>>> but it seems a bit over-kill.
>>>>>
>>>
>>> Hi Gu,
>>>
>>> Can we just remove "memset(pgdat, 0, sizeof(*pgdat));" ?
>>> I find this will be fine in the stress test except the warning
>>> when hot-add memory.
>>
>> As you see, it will trigger the warning in free_area_init_node().
>> Could you try the following patch? It will reset the pgdat before reuse it.
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 1778628..0717649 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1092,6 +1092,9 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>>                          return NULL;
>>
>>                  arch_refresh_nodedata(nid, pgdat);
>> +       } else {
>> +               /* Reset the pgdat to reuse */
>> +               memset(pgdat, 0, sizeof(*pgdat));
>>          }
>
> Hi Gu,
>
> If schedule last a long time, next_zone may be still access the pgdat here,
> so it is not safe enough, right?
>

How about just reseting pgdat->nr_zones and pgdat->classzone_idx to be 0 rather than
memset() ?

It seems breaking pointer information in pgdat is not a choice.
Just proper "values" should be reset.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

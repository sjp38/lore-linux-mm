Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9B56B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 05:11:21 -0500 (EST)
Received: by pdjy10 with SMTP id y10so56314917pdj.6
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 02:11:21 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id y4si4567610pdl.50.2015.03.04.02.11.17
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 02:11:20 -0800 (PST)
Message-ID: <54F6D637.6040705@cn.fujitsu.com>
Date: Wed, 4 Mar 2015 17:53:59 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com> <54F67376.8050001@huawei.com> <54F68270.5000203@cn.fujitsu.com> <54F6BC43.3000509@huawei.com> <54F6C809.1080709@jp.fujitsu.com>
In-Reply-To: <54F6C809.1080709@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Li Zefan <lizefan@huawei.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>

On 03/04/2015 04:53 PM, Kamezawa Hiroyuki wrote:

> On 2015/03/04 17:03, Xishi Qiu wrote:
>> On 2015/3/4 11:56, Gu Zheng wrote:
>>
>>> Hi Xishi,
>>> On 03/04/2015 10:52 AM, Xishi Qiu wrote:
>>>
>>>> On 2015/3/4 10:22, Xishi Qiu wrote:
>>>>
>>>>> On 2015/3/3 18:20, Gu Zheng wrote:
>>>>>
>>>>>> Hi Xishi,
>>>>>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>>>>>
>>>>>>> When hot-remove a numa node, we will clear pgdat,
>>>>>>> but is memset 0 safe in try_offline_node()?
>>>>>>
>>>>>> It is not safe here. In fact, this is a temporary solution here.
>>>>>> As you know, pgdat is accessed lock-less now, so protection
>>>>>> mechanism (RCU=EF=BC=9F) is needed to make it completely safe here,
>>>>>> but it seems a bit over-kill.
>>>>>>
>>>>
>>>> Hi Gu,
>>>>
>>>> Can we just remove "memset(pgdat, 0, sizeof(*pgdat));" ?
>>>> I find this will be fine in the stress test except the warning
>>>> when hot-add memory.
>>>
>>> As you see, it will trigger the warning in free_area_init_node().
>>> Could you try the following patch? It will reset the pgdat before reuse=
 it.
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 1778628..0717649 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1092,6 +1092,9 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid,=
 u64 start)
>>>                          return NULL;
>>>
>>>                  arch_refresh_nodedata(nid, pgdat);
>>> +       } else {
>>> +               /* Reset the pgdat to reuse */
>>> +               memset(pgdat, 0, sizeof(*pgdat));
>>>          }
>>
>> Hi Gu,
>>
>> If schedule last a long time, next_zone may be still access the pgdat he=
re,
>> so it is not safe enough, right?


Hi Xishi,

IMO, the scheduled time is rather short if compares with the time gap
between hot remove and hot re-add a node, so we can say it is safe here.

>>
>=20
> How about just reseting pgdat->nr_zones and pgdat->classzone_idx to be 0 =
rather than
> memset() ?
>=20
> It seems breaking pointer information in pgdat is not a choice.
> Just proper "values" should be reset.

Anyway, sounds reasonable.

Best regards,
Gu

>=20
> Thanks,
> -Kame
>=20
>=20
>=20
> .
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

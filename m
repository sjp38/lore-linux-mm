Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 34C866B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 02:02:40 -0500 (EST)
Received: by oifu20 with SMTP id u20so4057245oif.11
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 23:02:40 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id e7si1647219obo.17.2015.03.03.23.02.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 23:02:39 -0800 (PST)
Message-ID: <54F6ADD2.3080403@huawei.com>
Date: Wed, 4 Mar 2015 15:01:38 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com> <54F681A7.4050203@cn.fujitsu.com>
In-Reply-To: <54F681A7.4050203@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On 2015/3/4 11:53, Gu Zheng wrote:

> Hi Xishi,
> 
> On 03/04/2015 10:22 AM, Xishi Qiu wrote:
> 
>> On 2015/3/3 18:20, Gu Zheng wrote:
>>
>>> Hi Xishi,
>>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>>
>>>> When hot-remove a numa node, we will clear pgdat,
>>>> but is memset 0 safe in try_offline_node()?
>>>
>>> It is not safe here. In fact, this is a temporary solution here.
>>> As you know, pgdat is accessed lock-less now, so protection
>>> mechanism (RCUi 1/4 ?) is needed to make it completely safe here,
>>> but it seems a bit over-kill.
>>>
>>>>
>>>> process A:			offline node XX:
>>>> for_each_populated_zone()
>>>> find online node XX
>>>> cond_resched()
>>>> 				offline cpu and memory, then try_offline_node()
>>>> 				node_set_offline(nid), and memset(pgdat, 0, sizeof(*pgdat))
>>>> access node XX's pgdat
>>>> NULL pointer access error
>>>
>>> It's possible, but I did not meet this condition, did you?
>>>
>>
>> Yes, we test hot-add/hot-remove node with stress, and meet the following
>> call trace several times.
> 
> Thanks.
> 
>>
>> 	next_online_pgdat()
>> 		int nid = next_online_node(pgdat->node_id);  // it's here, pgdat is NULL
> 
> 	memset(pgdat, 0, sizeof(*pgdat));
> This memset just sets the context of pgdat to 0, but it will not free pgdat, so the *pgdat is
> NULL* is strange here.
> But anyway, the bug is real, we must fix it.

next_zone()
	pg_data_t *pgdat = zone->zone_pgdat;  // I think this pgdat is NULL, and NODE_DATA() is not NULL.
	...
	pgdat = next_online_pgdat(pgdat);
		int nid = next_online_node(pgdat->node_id);  // so here is the null pointer access

Thanks for your new patch, I'll test it.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

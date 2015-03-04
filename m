Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3515A6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 03:08:40 -0500 (EST)
Received: by obcwp18 with SMTP id wp18so5276691obc.8
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 00:08:40 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id os8si1668937oeb.103.2015.03.04.00.08.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 00:08:39 -0800 (PST)
Message-ID: <54F6BC43.3000509@huawei.com>
Date: Wed, 4 Mar 2015 16:03:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com> <54F67376.8050001@huawei.com> <54F68270.5000203@cn.fujitsu.com>
In-Reply-To: <54F68270.5000203@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Li Zefan <lizefan@huawei.com>

On 2015/3/4 11:56, Gu Zheng wrote:

> Hi Xishi,
> On 03/04/2015 10:52 AM, Xishi Qiu wrote:
> 
>> On 2015/3/4 10:22, Xishi Qiu wrote:
>>
>>> On 2015/3/3 18:20, Gu Zheng wrote:
>>>
>>>> Hi Xishi,
>>>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>>>
>>>>> When hot-remove a numa node, we will clear pgdat,
>>>>> but is memset 0 safe in try_offline_node()?
>>>>
>>>> It is not safe here. In fact, this is a temporary solution here.
>>>> As you know, pgdat is accessed lock-less now, so protection
>>>> mechanism (RCUi 1/4 ?) is needed to make it completely safe here,
>>>> but it seems a bit over-kill.
>>>>
>>
>> Hi Gu,
>>
>> Can we just remove "memset(pgdat, 0, sizeof(*pgdat));" ?
>> I find this will be fine in the stress test except the warning 
>> when hot-add memory.
> 
> As you see, it will trigger the warning in free_area_init_node().
> Could you try the following patch? It will reset the pgdat before reuse it.
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 1778628..0717649 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1092,6 +1092,9 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>                         return NULL;
>  
>                 arch_refresh_nodedata(nid, pgdat);
> +       } else {
> +               /* Reset the pgdat to reuse */
> +               memset(pgdat, 0, sizeof(*pgdat));
>         }

Hi Gu,

If schedule last a long time, next_zone may be still access the pgdat here,
so it is not safe enough, right?

Thanks
Xishi Qiu

>  
>         /* we can use NODE_DATA(nid) from here */
> @@ -2021,15 +2024,6 @@ void try_offline_node(int nid)
>  
>         /* notify that the node is down */
>         call_node_notify(NODE_DOWN, (void *)(long)nid);
> -
> -       /*
> -        * Since there is no way to guarentee the address of pgdat/zone is not
> -        * on stack of any kernel threads or used by other kernel objects
> -        * without reference counting or other symchronizing method, do not
> -        * reset node_data and free pgdat here. Just reset it to 0 and reuse
> -        * the memory when the node is online again.
> -        */
> -       memset(pgdat, 0, sizeof(*pgdat));
>  }
>  EXPORT_SYMBOL(try_offline_node);
>  
> 
>>
>> Thanks,
>> Xishi Qiu
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>> .
>>
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

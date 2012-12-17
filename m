Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C40816B005A
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 21:25:24 -0500 (EST)
Message-ID: <50CE823F.7020700@cn.fujitsu.com>
Date: Mon, 17 Dec 2012 10:23:59 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART4 Patch v2 2/2] memory_hotplug: allow online/offline memory
 to result movable node
References: <1353067090-19468-1-git-send-email-wency@cn.fujitsu.com> <1353067090-19468-3-git-send-email-wency@cn.fujitsu.com> <20121120142928.0aaf8fc8.akpm@linux-foundation.org>
In-Reply-To: <20121120142928.0aaf8fc8.akpm@linux-foundation.org>
Content-Type: multipart/mixed;
 boundary="------------080707040208070808070206"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rob Landley <rob@landley.net>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

This is a multi-part message in MIME format.
--------------080707040208070808070206
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Hi Andrew,

So sorry for such a long delay. I missed this one.
Please check the attached patch if you still need it.
All comments are followed.

Thanks. :)

On 11/21/2012 06:29 AM, Andrew Morton wrote:
> On Fri, 16 Nov 2012 19:58:10 +0800
> Wen Congyang<wency@cn.fujitsu.com>  wrote:
>
>> From: Lai Jiangshan<laijs@cn.fujitsu.com>
>>
>> Now, memory management can handle movable node or nodes which don't have
>> any normal memory, so we can dynamic configure and add movable node by:
>> 	online a ZONE_MOVABLE memory from a previous offline node
>> 	offline the last normal memory which result a non-normal-memory-node
>>
>> movable-node is very important for power-saving,
>> hardware partitioning and high-available-system(hardware fault management).
>>
>> ...
>>
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -589,11 +589,19 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>>   	return 0;
>>   }
>>
>> +#ifdef CONFIG_MOVABLE_NODE
>> +/* when CONFIG_MOVABLE_NODE, we allow online node don't have normal memory */
>
> The comment is hard to understand.  Should it read "When
> CONFIG_MOVABLE_NODE, we permit onlining of a node which doesn't have
> normal memory"?
>
>> +static bool can_online_high_movable(struct zone *zone)
>> +{
>> +	return true;
>> +}
>> +#else /* #ifdef CONFIG_MOVABLE_NODE */
>>   /* ensure every online node has NORMAL memory */
>>   static bool can_online_high_movable(struct zone *zone)
>>   {
>>   	return node_state(zone_to_nid(zone), N_NORMAL_MEMORY);
>>   }
>> +#endif /* #ifdef CONFIG_MOVABLE_NODE */
>>
>>   /* check which state of node_states will be changed when online memory */
>>   static void node_states_check_changes_online(unsigned long nr_pages,
>> @@ -1097,6 +1105,13 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
>>   	return offlined;
>>   }
>>
>> +#ifdef CONFIG_MOVABLE_NODE
>> +/* when CONFIG_MOVABLE_NODE, we allow online node don't have normal memory */
>
> Ditto, after replacing "online" with offlining".
>
>> +static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
>> +{
>> +	return true;
>> +}
>> +#else /* #ifdef CONFIG_MOVABLE_NODE */
>>   /* ensure the node has NORMAL memory if it is still online */
>>   static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
>>   {
>> @@ -1120,6 +1135,7 @@ static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
>>   	 */
>>   	return present_pages == 0;
>>   }
>> +#endif /* #ifdef CONFIG_MOVABLE_NODE */
>
> Please, spend more time over the accuracy and completeness of the
> changelog and comments?  That will result in better and more
> maintainable code.  And it results in *much* more effective code
> reviewing.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--------------080707040208070808070206
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="0002-memory_hotplug-allow-online-offline-memory-to-result.patch"
Content-Disposition: attachment;
 filename*0="0002-memory_hotplug-allow-online-offline-memory-to-result.pa";
 filename*1="tch"


--------------080707040208070808070206--

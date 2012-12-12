Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 63BC06B0068
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 04:35:01 -0500 (EST)
Message-ID: <50C84F8E.5030805@cn.fujitsu.com>
Date: Wed, 12 Dec 2012 17:34:06 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/5][RESEND] page_alloc: Make movablecore_map has higher
 priority
References: <1355193207-21797-5-git-send-email-tangchen@cn.fujitsu.com>  <1355201817-27230-1-git-send-email-tangchen@cn.fujitsu.com> <1355276008.1433.1.camel@kernel.cn.ibm.com>
In-Reply-To: <1355276008.1433.1.camel@kernel.cn.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Simon,

Thanks for reviewing. This logic is aimed at make movablecore_map
coexist with kernelcore/movablecore.

Please see below. :)

On 12/12/2012 09:33 AM, Simon Jeons wrote:
>> @@ -4839,9 +4839,17 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>>   		required_kernelcore = max(required_kernelcore, corepages);
>>   	}
>>
>> -	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
>> -	if (!required_kernelcore)
>> +	/*
>> +	 * If neither kernelcore/movablecore nor movablecore_map is specified,
>> +	 * there is no ZONE_MOVABLE. But if movablecore_map is specified, the
>> +	 * start pfn of ZONE_MOVABLE has been stored in zone_movable_limit[].
>> +	 */
>> +	if (!required_kernelcore) {
>> +		if (movablecore_map.nr_map)
>> +			memcpy(zone_movable_pfn, zone_movable_limit,
>> +				sizeof(zone_movable_pfn));

If users didn't specified kernelcore option, then zone_movable_pfn[]
and zone_movable_limit[] are all the same. We skip the logic.

>>   		goto out;
>> +	}
>>
>>   	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
>>   	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
>> @@ -4871,10 +4879,24 @@ restart:
>>   		for_each_mem_pfn_range(i, nid,&start_pfn,&end_pfn, NULL) {
>>   			unsigned long size_pages;
>>
>> +			/*
>> +			 * Find more memory for kernelcore in
>> +			 * [zone_movable_pfn[nid], zone_movable_limit[nid]).
>> +			 */
>>   			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
>>   			if (start_pfn>= end_pfn)
>>   				continue;
>>
>
> Hi Chen,
>
>> +			if (zone_movable_limit[nid]) {

If users didn't give any limitation of ZONE_MOVABLE on node i, we could
skip the logic too.

>> +				end_pfn = min(end_pfn, zone_movable_limit[nid]);

In order to reuse the original kernelcore/movablecore logic, we keep
end_pfn <= zone_movable_limit[nid]. We device [start_pfn, end_pfn) into
two parts:
[start_pfn, zone_movable_limit[nid])
and
[zone_movable_limit[nid], end_pfn).

We just remove the second part, and go on to the original logic.

>> +				/* No range left for kernelcore in this node */
>> +				if (start_pfn>= end_pfn) {

Since we re-evaluated end_pfn, if we have crossed the limitation, we
should stop.

>> +					zone_movable_pfn[nid] =
>> +							zone_movable_limit[nid];

Here, we found the real limitation. That means, the lowest pfn of
ZONE_MOVABLE is either zone_movable_limit[nid] or the value the original
logic calculates out, which is below zone_movable_limit[nid].

>> +					break;

Then we break and go on to the next node.

>> +				}
>> +			}
>> +
>
> Could you explain this part of codes? hard to understand.
>
>>   			/* Account for what is only usable for kernelcore */
>>   			if (start_pfn<  usable_startpfn) {
>>   				unsigned long kernel_pages;
>> @@ -4934,12 +4956,12 @@ restart:
>>   	if (usable_nodes&&  required_kernelcore>  usable_nodes)
>>   		goto restart;
>>
>> +out:
>>   	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
>>   	for (nid = 0; nid<  MAX_NUMNODES; nid++)
>>   		zone_movable_pfn[nid] =
>>   			roundup(zone_movable_pfn[nid], MAX_ORDER_NR_PAGES);
>>
>> -out:
>>   	/* restore the node_state */
>>   	node_states[N_HIGH_MEMORY] = saved_node_state;
>>   }
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id F0A4B6B0081
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 01:06:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4899B3EE0BD
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:06:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EC6F45DE54
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:06:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 052B245DE4F
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:06:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA37C1DB8041
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:06:56 +0900 (JST)
Received: from g01jpexchyt26.g01.fujitsu.local (g01jpexchyt26.g01.fujitsu.local [10.128.193.109])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9911D1DB803E
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 15:06:56 +0900 (JST)
Message-ID: <50AC6F60.7000201@jp.fujitsu.com>
Date: Wed, 21 Nov 2012 15:06:24 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86: Get pg_data_t's memory from other node
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com> <1353335246-9127-2-git-send-email-tangchen@cn.fujitsu.com> <50AC6AA3.8000806@jp.fujitsu.com> <50AC6D78.4060209@cn.fujitsu.com>
In-Reply-To: <50AC6D78.4060209@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, akpm@linux-foundation.org, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Tang,

2012/11/21 14:58, Tang Chen wrote:
> Hi Ishimatsu-san,
> 
> Thanks for the comments.
> 
> And I also found the some algorithm problems in patch2 ~ patch3.
> I am working on it, and a v2 patchset is coming soon. :)

O.K.
I'm waiting nwe patch-set.

Thanks,
Yasuaki Ishimatsu

> 
> Thanks.
> 
> On 11/21/2012 01:46 PM, Yasuaki Ishimatsu wrote:
>> Hi Tang,
>>
>> 2012/11/19 23:27, Tang Chen wrote:
>>> From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>>>
>>> If system can create movable node which all memory of the
>>> node is allocated as ZONE_MOVABLE, setup_node_data() cannot
>>> allocate memory for the node's pg_data_t.
>>> So when memblock_alloc_nid() fails, setup_node_data() retries
>>> memblock_alloc().
>>>
>>> Signed-off-by: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>>> Signed-off-by: Lai Jiangshan<laijs@cn.fujitsu.com>
>>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>>> Reviewed-by: Wen Congyang<wency@cn.fujitsu.com>
>>> Tested-by: Lin Feng<linfeng@cn.fujitsu.com>
>>> ---
>>>     arch/x86/mm/numa.c |    9 +++++++--
>>>     1 files changed, 7 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>>> index 2d125be..ae2e76e 100644
>>> --- a/arch/x86/mm/numa.c
>>> +++ b/arch/x86/mm/numa.c
>>> @@ -224,9 +224,14 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
>>>     	} else {
>>>     		nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
>>>     		if (!nd_pa) {
>>> -			pr_err("Cannot find %zu bytes in node %d\n",
>>
>>> +			printk(KERN_WARNING "Cannot find %zu bytes in node %d\n",
>>>     			       nd_size, nid)
>>
>> Please change to use pr_warn().
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>>> -			return;
>>> +			nd_pa = memblock_alloc(nd_size, SMP_CACHE_BYTES);
>>> +			if (!nd_pa) {
>>> +				pr_err("Cannot find %zu bytes in other node\n",
>>> +				       nd_size);
>>> +				return;
>>> +			}
>>>     		}
>>>     		nd = __va(nd_pa);
>>>     	}
>>>
>>
>>
>>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

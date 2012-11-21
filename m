Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 6B77B6B0078
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:59:24 -0500 (EST)
Message-ID: <50AC6D78.4060209@cn.fujitsu.com>
Date: Wed, 21 Nov 2012 13:58:16 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86: Get pg_data_t's memory from other node
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com> <1353335246-9127-2-git-send-email-tangchen@cn.fujitsu.com> <50AC6AA3.8000806@jp.fujitsu.com>
In-Reply-To: <50AC6AA3.8000806@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, akpm@linux-foundation.org, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Ishimatsu-san,

Thanks for the comments.

And I also found the some algorithm problems in patch2 ~ patch3.
I am working on it, and a v2 patchset is coming soon. :)

Thanks.

On 11/21/2012 01:46 PM, Yasuaki Ishimatsu wrote:
> Hi Tang,
> 
> 2012/11/19 23:27, Tang Chen wrote:
>> From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>>
>> If system can create movable node which all memory of the
>> node is allocated as ZONE_MOVABLE, setup_node_data() cannot
>> allocate memory for the node's pg_data_t.
>> So when memblock_alloc_nid() fails, setup_node_data() retries
>> memblock_alloc().
>>
>> Signed-off-by: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>> Signed-off-by: Lai Jiangshan<laijs@cn.fujitsu.com>
>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>> Reviewed-by: Wen Congyang<wency@cn.fujitsu.com>
>> Tested-by: Lin Feng<linfeng@cn.fujitsu.com>
>> ---
>>    arch/x86/mm/numa.c |    9 +++++++--
>>    1 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>> index 2d125be..ae2e76e 100644
>> --- a/arch/x86/mm/numa.c
>> +++ b/arch/x86/mm/numa.c
>> @@ -224,9 +224,14 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
>>    	} else {
>>    		nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
>>    		if (!nd_pa) {
>> -			pr_err("Cannot find %zu bytes in node %d\n",
> 
>> +			printk(KERN_WARNING "Cannot find %zu bytes in node %d\n",
>>    			       nd_size, nid)
> 
> Please change to use pr_warn().
> 
> Thanks,
> Yasuaki Ishimatsu
> 
>> -			return;
>> +			nd_pa = memblock_alloc(nd_size, SMP_CACHE_BYTES);
>> +			if (!nd_pa) {
>> +				pr_err("Cannot find %zu bytes in other node\n",
>> +				       nd_size);
>> +				return;
>> +			}
>>    		}
>>    		nd = __va(nd_pa);
>>    	}
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

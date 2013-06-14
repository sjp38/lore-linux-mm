Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BBC506B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 01:34:10 -0400 (EDT)
Message-ID: <51BAAC01.7010709@cn.fujitsu.com>
Date: Fri, 14 Jun 2013 13:37:05 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part3 PATCH v2 1/4] bootmem, mem-hotplug: Register local pagetable
 pages with LOCAL_NODE_DATA when freeing bootmem.
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com> <1371128636-9027-2-git-send-email-tangchen@cn.fujitsu.com> <xa1tli6ef63p.fsf@mina86.com>
In-Reply-To: <xa1tli6ef63p.fsf@mina86.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Michal,

Please see below.

On 06/13/2013 10:16 PM, Michal Nazarewicz wrote:
......
>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>> index a85ced9..8a38eef 100644
>> --- a/include/linux/memblock.h
>> +++ b/include/linux/memblock.h
>> @@ -131,6 +131,28 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
>>   	     i != (u64)ULLONG_MAX;					\
>>   	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid))
>>
>> +void __next_local_node_mem_range(int *idx, int nid, phys_addr_t *out_start,
>> +				 phys_addr_t *out_end, int *out_nid);
>
> Why not make it return int?

The same reason below.

>
>> +
>> +/**
>> + * for_each_local_node_mem_range - iterate memblock areas storing local node
>> + *                                 data
>> + * @i: int used as loop variable
>> + * @nid: node selector, %MAX_NUMNODES for all nodes
>> + * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
>> + * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
>> + * @p_nid: ptr to int for nid of the range, can be %NULL
>> + *
>> + * Walks over memblock areas storing local node data. Since all the local node
>> + * areas will be reserved by memblock, this iterator will only iterate
>> + * memblock.reserve. Available as soon as memblock is initialized.
>> + */
>> +#define for_each_local_node_mem_range(i, nid, p_start, p_end, p_nid)	    \
>> +	for (i = -1,							    \
>> +	     __next_local_node_mem_range(&i, nid, p_start, p_end, p_nid);   \
>> +	     i != -1;							    \
>> +	     __next_local_node_mem_range(&i, nid, p_start, p_end, p_nid))
>> +
>
> If __next_local_node_mem_range() returned int, this would be easier:
>
> +#define for_each_local_node_mem_range(i, nid, p_start, p_end, p_nid)	      \
> +	for (i = -1;
> +	     (i = __next_local_node_mem_range(i, nid, p_start, p_end, p_nid)) != -1; )

Yes, we can do it like this.

But I tried to do something similar to for_each_free_mem_range and
for_each_free_mem_range_reverse to keep the code coincident.

How do you think to change all this similar functions into your way ?

>
......
>> +void __init_memblock __next_local_node_mem_range(int *idx, int nid,
>> +					phys_addr_t *out_start,
>> +					phys_addr_t *out_end, int *out_nid)
>> +{
>> +	__next_flag_mem_range(idx, nid, MEMBLK_LOCAL_NODE,
>> +			      out_start, out_end, out_nid);
>> +}
>
> static inline in a header file perhaps?

OK, will put it in a header file in the next version.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

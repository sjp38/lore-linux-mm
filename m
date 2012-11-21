Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 5F6F66B0044
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 19:37:17 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3CD023EE0C0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:37:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 23BF645DEBE
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:37:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EDACB45DEB5
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:37:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D63961DB803C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:37:14 +0900 (JST)
Received: from g01jpexchkw01.g01.fujitsu.local (g01jpexchkw01.g01.fujitsu.local [10.0.194.40])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92463E08002
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:37:14 +0900 (JST)
Message-ID: <50AC221B.4090503@jp.fujitsu.com>
Date: Wed, 21 Nov 2012 09:36:43 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Add movablecore_map boot option.
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com> <20121119125325.ed1abba0.akpm@linux-foundation.org> <50AB646E.7040009@jp.fujitsu.com> <50AB6899.3060609@gmail.com>
In-Reply-To: <50AB6899.3060609@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Jaegeuk,

2012/11/20 20:25, Jaegeuk Hanse wrote:
> On 11/20/2012 07:07 PM, Yasuaki Ishimatsu wrote:
>> 2012/11/20 5:53, Andrew Morton wrote:
>>> On Mon, 19 Nov 2012 22:27:21 +0800
>>> Tang Chen <tangchen@cn.fujitsu.com> wrote:
>>>
>>>> This patchset provide a boot option for user to specify ZONE_MOVABLE memory
>>>> map for each node in the system.
>>>>
>>>> movablecore_map=nn[KMG]@ss[KMG]
>>>>
>>>> This option make sure memory range from ss to ss+nn is movable memory.
>>>> 1) If the range is involved in a single node, then from ss to the end of
>>>>     the node will be ZONE_MOVABLE.
>>>> 2) If the range covers two or more nodes, then from ss to the end of
>>>>     the node will be ZONE_MOVABLE, and all the other nodes will only
>>>>     have ZONE_MOVABLE.
>>>> 3) If no range is in the node, then the node will have no ZONE_MOVABLE
>>>>     unless kernelcore or movablecore is specified.
>>>> 4) This option could be specified at most MAX_NUMNODES times.
>>>> 5) If kernelcore or movablecore is also specified, movablecore_map will have
>>>>     higher priority to be satisfied.
>>>> 6) This option has no conflict with memmap option.
>>>
>>> This doesn't describe the problem which the patchset solves.  I can
>>> kinda see where it's coming from, but it would be nice to have it all
>>> spelled out, please.
>>>
>>
>>> - What is wrong with the kernel as it stands?
>>
>> If we hot remove a memroy, the memory cannot have kernel memory,
>> because Linux cannot migrate kernel memory currently. Therefore,
>> we have to guarantee that the hot removed memory has only movable
>> memoroy.
>>
>> Linux has two boot options, kernelcore= and movablecore=, for
>> creating movable memory. These boot options can specify the amount
>> of memory use as kernel or movable memory. Using them, we can
>> create ZONE_MOVABLE which has only movable memory.
>>
>> But it does not fulfill a requirement of memory hot remove, because
>> even if we specify the boot options, movable memory is distributed
>> in each node evenly. So when we want to hot remove memory which
>> memory range is 0x80000000-0c0000000, we have no way to specify
>> the memory as movable memory.
>
> Could you explain why can't specify the memory as movable memory in this case?

For creating movable memory, Linux prepares two boot options, kernelcore=
and movablecore=. These boot options specify amount of memory not memory
range use as kernel or movable memory. So when we use these boot options,
we cannot control where the movable memory is set.

>
>>
>> So we proposed a new feature which specifies memory range to use as
>> movable memory.
>>
>>> - What are the possible ways of solving this?
>>
>> I thought 2 ways to specify movable memory.
>>  1. use firmware information
>>  2. use boot option
>>
>> 1. use firmware information
>>   According to ACPI spec 5.0, SRAT table has memory affinity structure
>>   and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>>   Affinity Structure". If we use the information, we might be able to
>>   specify movable memory by firmware. For example, if Hot Pluggable
>>   Filed is enabled, Linux sets the memory as movable memory.
>>
>> 2. use boot option
>>   This is our proposal. New boot option can specify memory range to use
>>   as movable memory.
>>
>>> - Describe the chosen way, explain why it is superior to alternatives
>>
>> We chose second way, because if we use first way, users cannot change
>> memory range to use as movable memory easily. We think if we create
>> movable memory, performance regression may occur by NUMA. In this case,
>
> Could you explain why regression occur in details?

Using the boot option, we can create movable node which has only
movable memory. So if we create a new task, kernel memory and movable
memory (anonymous page and page cache) of the task are allocated by
different nodes. In this case, performance regression may occur.

Thanks,
Yasuaki Ishimatsu

>
>> user can turn off the feature easily if we prepare the boot option.
>> And if we prepare the boot optino, the user can select which memory
>> to use as movable memory easily.
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>>>
>>> The amount of manual system configuration in this proposal looks quite
>>> high.  Adding kernel boot parameters really is a last resort. Why was
>>> it unavoidable here?
>>>
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D6EC16B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 00:50:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DE66A3EE0C0
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:50:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCDB245DD74
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:50:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AAAF45DE4E
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:50:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B0EB1DB803F
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:50:41 +0900 (JST)
Received: from g01jpexchyt07.g01.fujitsu.local (g01jpexchyt07.g01.fujitsu.local [10.128.194.46])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 358321DB803A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:50:41 +0900 (JST)
Message-ID: <4FEBE280.4060107@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 13:50:08 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/12] memory-hotplug : rename remove_memory to offline_memory
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9D5C.1080508@jp.fujitsu.com> <4FEAB2E1.3090200@cn.fujitsu.com> <4FEAC891.7030808@cn.fujitsu.com> <4FEBC8EE.7040207@jp.fujitsu.com> <4FEBCE9C.7030904@cn.fujitsu.com>
In-Reply-To: <4FEBCE9C.7030904@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/06/28 12:25, Wen Congyang wrote:
> At 06/28/2012 11:01 AM, Yasuaki Ishimatsu Wrote:
>> Hi David and Wen,
>>
>> Thank you for reviewing my patch.
>>
>> 2012/06/27 17:47, Wen Congyang wrote:
>>> At 06/27/2012 03:14 PM, Wen Congyang Wrote:
>>>> At 06/27/2012 01:42 PM, Yasuaki Ishimatsu Wrote:
>>>>> remove_memory() does not remove memory but just offlines memory. The patch
>>>>> changes name of it to offline_memory().
>>>>
>>>> There are 3 functions in the kernel:
>>>> 1. add_memory()
>>>> 2. online_pages()
>>>> 3. remove_memory()
>>>>
>>>> So I think offline_pages() is better than offline_memory().
>>>
>>> There is already a function named offline_pages(). So we
>>> should call offline_pages() instead of remove_memory() in
>>> memory_block_action(), and there is no need to rename
>>> remove_memory().
>>
>> As Wen says, Linux has 4 functions for memory hotplug already.
>> In my recognition, these functions are prepared for following purpose.
>>
>> 1. add_memory     : add physical memory
>> 2. online_pages   : online logical memory
>> 3. remove_memory  : offline logical memory
>> 4. offline_pages  : offline logical memory
>>
>> add_memory() is used for adding physical memory. I think remove_memory()
>> would rather be used for removing physical memory than be used for removing
>> logical memory. So I renamed remove_memory() to offline_memory().
>> How do you think?
> 
> Hmm, remove_memory() will revert all things we do in add_memory(), so I think

I think so too.

add_memory() prepares to use physical memory. It prepares some structures
(pgdat, page table, node, etc) for using the physical memory at the system.
But it does not online the meomory. For onlining the memory, we use
online_pages().

So I think that remove_memory() should remove these structures which are
prepared by add_memory() not offline memory. But current remove_memory() code
only calls offline_pages() and offlines memory.

The patch series recreates remove_memory() for removing these structures
after [RFC PATCH 3/12]. The reason to change the name of remove_memory() is a
preparation to recreate it.

Thanks,
Yasuaki Ishimatsu

> there is no need to rename it. If we rename it to offline_memory(), we should
> also rename add_memory() to online_memory().
> 
> Thanks
> Wen Congyang
> 
>>
>> Regards,
>> Yasuaki Ishimatsu
>>
>>>
>>> Thanks
>>> Wen Congyang
>>>
>>>>
>>>> Thanks
>>>> Wen Congyang
>>>>>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

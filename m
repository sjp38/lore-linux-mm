Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 289DC6B00CF
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 06:00:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 625CF3EE0BD
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 19:00:40 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B1F245DE55
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 19:00:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3434F45DE54
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 19:00:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 25C041DB8043
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 19:00:40 +0900 (JST)
Received: from g01jpexchkw04.g01.fujitsu.local (g01jpexchkw04.g01.fujitsu.local [10.0.194.43])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D43A21DB8032
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 19:00:39 +0900 (JST)
Message-ID: <506ABB26.3020806@jp.fujitsu.com>
Date: Tue, 2 Oct 2012 19:00:06 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] memory-hotplug : notification of memoty block's state
References: <506AA4E2.7070302@jp.fujitsu.com> <506AB719.70904@gmail.com>
In-Reply-To: <506AB719.70904@gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

2012/10/02 18:42, Ni zhan Chen wrote:
> On 10/02/2012 04:25 PM, Yasuaki Ishimatsu wrote:
>> We are trying to implement a physical memory hot removing function as
>> following thread.
>>
>> https://lkml.org/lkml/2012/9/5/201
>>
>> But there is not enough review to merge into linux kernel.
>>
>> I think there are following blockades.
>>    1. no physical memory hot removable system
>>    2. huge patch-set
>>
>> If you have a KVM system, we can get rid of 1st blockade. Because
>> applying following patch, we can create memory hot removable system
>> on KVM guest.
>>
>> http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
>>
>> 2nd blockade is own problem. So we try to divide huge patch into
>> a small patch in each function as follows:
>>
>>   - bug fix
>>   - acpi framework
>>   - kernel core
>>
>> We had already sent bug fix patches.
>>
>> https://lkml.org/lkml/2012/9/27/39
>>
>> And the patch fixes following bug.
>>
>> remove_memory() offlines memory. And it is called by following two cases:
>>
>> 1. echo offline >/sys/devices/system/memory/memoryXX/state
>> 2. hot remove a memory device
>>
>> In the 1st case, the memory block's state is changed and the notification
>> that memory block's state changed is sent to userland after calling
>> offline_memory(). So user can notice memory block is changed.,
> 
> Hi Yasuaki,
> 
> Thanks for splitting the patchset, it's more easier to review this time.
> One question:
> 
> How can notify userspace? you mean function node_memory_callback or
> ...., but

When calling memory_block_change_state(), it calls kobject_uevent().
This function notifies userspace of the online/offline notification.

Thanks,
Yasuaki Ishimatsu


> this function basically do nothing.
> 
>>
>> But in the 2nd case, the memory block's state is not changed and the
>> notification is not also sent to userspcae even if calling offline_memory().
>> So user cannot notice memory block is changed.
>>
>> We should also notify to userspace at 2nd case.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

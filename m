Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 354866B0012
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 21:20:25 -0500 (EST)
Message-ID: <510B25FF.3010702@huawei.com>
Date: Fri, 1 Feb 2013 10:18:39 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>       <1359463973.1624.15.camel@kernel> <5108F2B3.3090506@cn.fujitsu.com>      <1359595344.1557.13.camel@kernel> <5109E59F.5080104@cn.fujitsu.com>     <1359613162.1587.0.camel@kernel> <510A18FA.2010107@cn.fujitsu.com>    <1359622123.1391.19.camel@kernel> <510A3CE6.202@cn.fujitsu.com>   <1359628705.2048.5.camel@kernel> <510B1B4B.5080207@huawei.com>  <1359682576.3574.1.camel@kernel> <510B20F2.20906@huawei.com> <1359684403.1303.3.camel@kernel>
In-Reply-To: <1359684403.1303.3.camel@kernel>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 2013/2/1 10:06, Simon Jeons wrote:

> Hi Jianguo,
> On Fri, 2013-02-01 at 09:57 +0800, Jianguo Wu wrote:
>> On 2013/2/1 9:36, Simon Jeons wrote:
>>
>>> On Fri, 2013-02-01 at 09:32 +0800, Jianguo Wu wrote:
>>>> On 2013/1/31 18:38, Simon Jeons wrote:
>>>>
>>>>> Hi Tang,
>>>>> On Thu, 2013-01-31 at 17:44 +0800, Tang Chen wrote:
>>>>>> Hi Simon,
>>>>>>
>>>>>> On 01/31/2013 04:48 PM, Simon Jeons wrote:
>>>>>>> Hi Tang,
>>>>>>> On Thu, 2013-01-31 at 15:10 +0800, Tang Chen wrote:
>>>>>>>
>>>>>>> 1. IIUC, there is a button on machine which supports hot-remove memory,
>>>>>>> then what's the difference between press button and echo to /sys?
>>>>>>
>>>>>> No important difference, I think. Since I don't have the machine you are
>>>>>> saying, I cannot surely answer you. :)
>>>>>> AFAIK, pressing the button means trigger the hotplug from hardware, sysfs
>>>>>> is just another entrance. At last, they will run into the same code.
>>>>>>
>>>>>>> 2. Since kernel memory is linear mapping(I mean direct mapping part),
>>>>>>> why can't put kernel direct mapping memory into one memory device, and
>>>>>>> other memory into the other devices?
>>>>>>
>>>>>> We cannot do that because in that way, we will lose NUMA performance.
>>>>>>
>>>>>> If you know NUMA, you will understand the following example:
>>>>>>
>>>>>> node0:                    node1:
>>>>>>     cpu0~cpu15                cpu16~cpu31
>>>>>>     memory0~memory511         memory512~memory1023
>>>>>>
>>>>>> cpu16~cpu31 access memory16~memory1023 much faster than memory0~memory511.
>>>>>> If we set direct mapping area in node0, and movable area in node1, then
>>>>>> the kernel code running on cpu16~cpu31 will have to access 
>>>>>> memory0~memory511.
>>>>>> This is a terrible performance down.
>>>>>
>>>>> So if config NUMA, kernel memory will not be linear mapping anymore? For
>>>>> example, 
>>>>>
>>>>> Node 0  Node 1 
>>>>>
>>>>> 0 ~ 10G 11G~14G
>>>>>
>>>>> kernel memory only at Node 0? Can part of kernel memory also at Node 1?
>>>>>
>>>>> How big is kernel direct mapping memory in x86_64? Is there max limit?
>>>>
>>>>
>>>> Max kernel direct mapping memory in x86_64 is 64TB.
>>>
>>> For example, I have 8G memory, all of them will be direct mapping for
>>> kernel? then userspace memory allocated from where?
>>
>> Direct mapping memory means you can use __va() and pa(), but not means that them
>> can be only used by kernel, them can be used by user-space too, as long as them are free.
> 
> IIUC, the benefit of va() and pa() is just for quick get
> virtual/physical address, it takes advantage of linear mapping. But mmu
> still need to go through pgd/pud/pmd/pte, correct?

Yes.

> 

>>
>>>
>>>>
>>>>> It seems that only around 896MB on x86_32. 
>>>>>
>>>>>>
>>>>>>> As you know x86_64 don't need
>>>>>>> highmem, IIUC, all kernel memory will linear mapping in this case. Is my
>>>>>>> idea available? If is correct, x86_32 can't implement in the same way
>>>>>>> since highmem(kmap/kmap_atomic/vmalloc) can map any address, so it's
>>>>>>> hard to focus kernel memory on single memory device.
>>>>>>
>>>>>> Sorry, I'm not quite familiar with x86_32 box.
>>>>>>
>>>>>>> 3. In current implementation, if memory hotplug just need memory
>>>>>>> subsystem and ACPI codes support? Or also needs firmware take part in?
>>>>>>> Hope you can explain in details, thanks in advance. :)
>>>>>>
>>>>>> We need firmware take part in, such as SRAT in ACPI BIOS, or the firmware
>>>>>> based memory migration mentioned by Liu Jiang.
>>>>>
>>>>> Is there any material about firmware based memory migration?
>>>>>
>>>>>>
>>>>>> So far, I only know this. :)
>>>>>>
>>>>>>> 4. What's the status of memory hotplug? Apart from can't remove kernel
>>>>>>> memory, other things are fully implementation?
>>>>>>
>>>>>> I think the main job is done for now. And there are still bugs to fix.
>>>>>> And this functionality is not stable.
>>>>>>
>>>>>> Thanks. :)
>>>>>
>>>>>
>>>>> --
>>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>>> see: http://www.linux-mm.org/ .
>>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>>
>>>>> .
>>>>>
>>>>
>>>>
>>>>
>>>
>>>
>>>
>>> .
>>>
>>
>>
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 5978E6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:24:33 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2536589pbb.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 07:24:32 -0700 (PDT)
Message-ID: <4FFD8C95.4060300@gmail.com>
Date: Wed, 11 Jul 2012 22:24:21 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/13] memory-hotplug : hot-remove physical memory
References: <4FFAB0A2.8070304@jp.fujitsu.com> <alpine.DEB.2.00.1207091015570.30060@router.home> <4FFBFCAC.4010007@jp.fujitsu.com> <4FFC5D43.7040206@gmail.com> <4FFCC438.4080004@jp.fujitsu.com> <4FFCC6F1.5060908@gmail.com> <4FFCCEC3.4050800@jp.fujitsu.com>
In-Reply-To: <4FFCCEC3.4050800@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On 07/11/2012 08:54 AM, Yasuaki Ishimatsu wrote:
> Hi Jiang,
> 
> 2012/07/11 9:21, Jiang Liu wrote:
>> On 07/11/2012 08:09 AM, Yasuaki Ishimatsu wrote:
>>> Hi Jiang,
>>>
>>> 2012/07/11 1:50, Jiang Liu wrote:
>>>> On 07/10/2012 05:58 PM, Yasuaki Ishimatsu wrote:
>>>>> Hi Christoph,
>>>>>
>>>>> 2012/07/10 0:18, Christoph Lameter wrote:
>>>>>>
>>>>>> On Mon, 9 Jul 2012, Yasuaki Ishimatsu wrote:
>>>>>>
>>>>>>> Even if you apply these patches, you cannot remove the physical memory
>>>>>>> completely since these patches are still under development. I want you to
>>>>>>> cooperate to improve the physical memory hot-remove. So please review these
>>>>>>> patches and give your comment/idea.
>>>>>>
>>>>>> Could you at least give a method on how you want to do physical memory
>>>>>> removal?
>>>>>
>>>>> We plan to release a dynamic hardware partitionable system. It will be
>>>>> able to hot remove/add a system board which included memory and cpu.
>>>>> But as you know, Linux does not support memory hot-remove on x86 box.
>>>>> So I try to develop it.
>>>>>
>>>>> Current plan to hot remove system board is to use container driver.
>>>>> Thus I define the system board in ACPI DSDT table as a container device.
>>>>> It have supported hot-add a container device. And if container device
>>>>> has _EJ0 ACPI method, "eject" file to remove the container device is
>>>>> prepared as follow:
>>>>>
>>>>> # ls -l /sys/bus/acpi/devices/ACPI0004\:01/eject
>>>>> --w-------. 1 root root 4096 Jul 10 18:19 /sys/bus/acpi/devices/ACPI0004:01/eject
>>>>>
>>>>> When I hot-remove the container device, I echo 1 to the file as follow:
>>>>>
>>>>> #echo 1 > /sys/bus/acpi/devices/ACPI0004\:02/eject
>>>>>
>>>>> Then acpi_bus_trim() is called. And it calls acpi_memory_device_remove()
>>>>> for removing memory device. But the code does not do nothing.
>>>>> So I developed the continuation of the function.
>>>>>
>>>>>> You would have to remove all objects from the range you want to
>>>>>> physically remove. That is only possible under special circumstances and
>>>>>> with a limited set of objects. Even if you exclusively use ZONE_MOVEABLE
>>>>>> you still may get cases where pages are pinned for a long time.
>>>>>
>>>>> I know it. So my memory hot-remove plan is as follows:
>>>>>
>>>>> 1. hot-added a system board
>>>>>      All memory which included the system board is offline.
>>>>>
>>>>> 2. online the memory as removable page
>>>>>      The function has not supported yet. It is being developed by Lai as follow:
>>>>>      http://lkml.indiana.edu/hypermail/linux/kernel/1207.0/01478.html
>>>>>      If it is supported, I will be able to create movable memory.
>>>>>
>>>>> 3. hot-remove the memory by container device's eject file
>>>> We have implemented a prototype to do physical node (mem + CPU + IOH) hotplug
>>>> for Itanium and is now porting it to x86. But with currently solution, memory
>>>> hotplug functionality may cause 10-20% performance decrease because we concentrate
>>>> all DMA/Normal memory to the first NUMA node, and all other NUMA nodes only
>>>> hosts ZONE_MOVABLE. We are working on solution to minimize the performance
>>>> drop now.
>>>
>>> Thank you for your interesting response.
>>>
>>> I have a question. How do you move all other NUMA nodes to ZONE_MOVABLE?
>>> To use ZONE_MOVABLE, we need to use boot options like kernelcore or movablecore.
>>> But it is not enough, since the requested amount is spread evenly throughout
>>> all nodes in the system. So I think we do not have way to move all other NUMA
>>> node to ZONE_MOVABLE.
>> We have modified the ZONE_MOVABLE spreading and bootmem allocation. If the kernelcore
>> or movablecore kernel parameters are present, we follow current behavior. If those
>> parameter are absent and the platform supports physical hotplug, we will concentrate
>> DMA/NORMAL memory to specific nodes.
> 
> That's interesting. I want to know more details, if you do not mind.
> Current kernel doesn't do the behavior, does it? So I think you have some
> patches for changing the behavior. Will you merge these patches into
> community kernel?
Yeah, we do have patches for that. But it's still prototype, still much work
needed before sending them to the community. 
Currently I'm trying to send out patches for an ACPI based system device
hotplug framework, which will support processor, memory, IOH and node hotplug
in a unified way. After that, I will prepare the memory hotplug code.

Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

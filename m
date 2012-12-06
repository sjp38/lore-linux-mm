Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BEC968D0001
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:40:54 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2961130dak.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:40:54 -0800 (PST)
Message-ID: <50C0CA90.7010608@gmail.com>
Date: Fri, 07 Dec 2012 00:40:48 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>    <50B5EFE9.3040206@huawei.com>   <1354128096.26955.276.camel@misato.fc.hp.com>  <50B6E936.2080308@huawei.com> <1354228028.7776.56.camel@misato.fc.hp.com>  <50BC29C6.6050706@huawei.com> <1354579848.21585.54.camel@misato.fc.hp.com>
In-Reply-To: <1354579848.21585.54.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Hanjun Guo <guohanjun@huawei.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, Huxinwei <huxinwei@huawei.com>

On 12/04/2012 08:10 AM, Toshi Kani wrote:
> On Mon, 2012-12-03 at 12:25 +0800, Hanjun Guo wrote:
>> On 2012/11/30 6:27, Toshi Kani wrote:
>>> On Thu, 2012-11-29 at 12:48 +0800, Hanjun Guo wrote:
>>>> On 2012/11/29 2:41, Toshi Kani wrote:
>>>>> On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
>>>>>> On 2012/11/24 1:50, Vasilis Liaskovitis wrote:
>>>>>> As you may know, the ACPI based hotplug framework we are working on already addressed
>>>>>> this problem, and the way we slove this problem is a bit like yours.
>>>>>>
>>>>>> We introduce hp_ops in struct acpi_device_ops:
>>>>>> struct acpi_device_ops {
>>>>>> 	acpi_op_add add;
>>>>>> 	acpi_op_remove remove;
>>>>>> 	acpi_op_start start;
>>>>>> 	acpi_op_bind bind;
>>>>>> 	acpi_op_unbind unbind;
>>>>>> 	acpi_op_notify notify;
>>>>>> #ifdef	CONFIG_ACPI_HOTPLUG
>>>>>> 	struct acpihp_dev_ops *hp_ops;
>>>>>> #endif	/* CONFIG_ACPI_HOTPLUG */
>>>>>> };
>>>>>>
>>>>>> in hp_ops, we divide the prepare_remove into six small steps, that is:
>>>>>> 1) pre_release(): optional step to mark device going to be removed/busy
>>>>>> 2) release(): reclaim device from running system
>>>>>> 3) post_release(): rollback if cancelled by user or error happened
>>>>>> 4) pre_unconfigure(): optional step to solve possible dependency issue
>>>>>> 5) unconfigure(): remove devices from running system
>>>>>> 6) post_unconfigure(): free resources used by devices
>>>>>>
>>>>>> In this way, we can easily rollback if error happens.
>>>>>> How do you think of this solution, any suggestion ? I think we can achieve
>>>>>> a better way for sharing ideas. :)
>>>>>
>>>>> Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
>>>>> have not looked at all your changes yet..), but in my mind, a hot-plug
>>>>> operation should be composed with the following 3 phases.
>>>>
>>>> Good idea ! we also implement a hot-plug operation in 3 phases:
>>>> 1) acpihp_drv_pre_execute
>>>> 2) acpihp_drv_execute
>>>> 3) acpihp_drv_post_execute
>>>> you may refer to :
>>>> https://lkml.org/lkml/2012/11/4/79
>>>
>>> Great.  Yes, I will take a look.
>>
>> Thanks, any comments are welcomed :)
> 
> If I read the code right, the framework calls ACPI drivers differently
> at boot-time and hot-add as follows.  That is, the new entry points are
> called at hot-add only, but .add() is called at both cases.  This
> requires .add() to work differently.
> 
> Boot    : .add()
> Hot-Add : .add(), .pre_configure(), configure(), etc.
> 
> I think the boot-time and hot-add initialization should be done
> consistently.  While there is difficulty with the current boot sequence,
> the framework should be designed to allow them consistent, not make them
> diverged.
Hi Toshi,
	We have separated hotplug operations from driver binding/unbinding interface
due to following considerations.
1) Physical CPU and memory devices are initialized/used before the ACPI subsystem
   is initialized. So under normal case, .add() of processor and acpi_memhotplug only
   figures out information about device already in working state instead of starting
   the device.
2) It's impossible to rmmod the processor and acpi_memhotplug driver at runtime 
   if .remove() of CPU and memory drivers do really remove the CPU/memory device
   from the system. And the ACPI processor driver also implements CPU PM funcitonality
   other than hotplug.

And recently Rafael has mentioned that he has a long term view to get rid of the
concept of "ACPI device". If that happens, we could easily move the hotplug
logic from ACPI device drivers into the hotplug framework if the hotplug logic
is separated from the .add()/.remove() callbacks. Actually we could even move all
hotplug only logic into the hotplug framework and don't rely on any ACPI device
driver any more. So we could get rid of all these messy things. We could achieve
that by:
1) moving code shared by ACPI device drivers and the hotplug framework into the core.
2) moving hotplug only code to the framework.

Hi Rafael, what's your thoughts here?

> 
>>>>> 1. Validate phase - Verify if the request is a supported operation.  All
>>>>> known restrictions are verified at this phase.  For instance, if a
>>>>> hot-remove request involves kernel memory, it is failed in this phase.
>>>>> Since this phase makes no change, no rollback is necessary to fail. 
>>>>
>>>> Yes, we have done this in acpihp_drv_pre_execute, and check following things:
>>>>
>>>> 1) Hot-plugble or not. the instance kernel memory you mentioned is also checked
>>>>    when memory device remove;
>>>
>>> Agreed.
>>>
>>>> 2) Dependency check involved. For instance, if hot-add a memory device,
>>>>    processor should be added first, otherwise it's not valid to this operation.
>>>
>>> I think FW should be the one that assures such dependency.  That is,
>>> when a memory device object is marked as present/enabled/functioning, it
>>> should be ready for the OS to use.
>>
>> Yes, BIOS should do something for the dependency, because BIOS knows the
>> actual hardware topology. 
> 
> Right.
> 
>> The ACPI specification provides _EDL method to
>> tell OS the eject device list, but still has no method to tell OS the add device
>> list now.
> 
> Yes, but I do not think the OS needs special handling for add...
We have a plan to support triggering hot-adding events from OS provided interfaces,
so we also need to solve dependency issues when handling requests from those interfaces.
For need to power on the physical processor before powering on a memory device if
the memory device is attached to a physical processor.

> 
>> For some cases, OS should analyze the dependency in the validate phase. For example,
>> when hot remove a node (container device), OS should analyze the dependency to get
>> the remove order as following:
>> 1) Host bridge;
>> 2) Memory devices;
>> 3) Processor devices;
>> 4) Container device itself;
> 
> This may be off-topic, but how do you plan to delete I/O devices under a
> node?  Are you planning to delete all I/O devices along with the node?
> 
> On other OS, we made a separate step called I/O chassis delete, which
> off-lines all I/O devices under the node, and is required before a node
> hot-remove.  It basically triggers PCIe hot-remove to detach drivers
> from all devices.  It does not eject the devices so that they do not
> have to be on hot-plug slots.  This step runs user-space scripts to
> verify if the devices can be off-lined without disrupting user's
> applications, and provides comprehensive reports if any of them are in
> use.  Not sure if Linux's PCI hot-remove has such check, but I thought
> I'd mention it. :)
Yinghai is working on PCI host bridge hotplug, which just stops all PCI devices
under the host bridge. That's really a little dangerous and we do need help
from userspace to check whether the hot-removal operaitons is fatal, 
e.g. removing PCI device hosting the rootfs.

So in our framework, we have an option to relay hotplug event from firmware
to userspace, so the userspace has a chance to reject the hotplug operations
if it may cause unacceptable disturbance to userspace services.

> 
>> In this way, we can check that all the devices are hot-plugble or not under the
>> container device before execute phase, and further more, we can remove devices
>> in order to avoid some crash problems.
> 
> Yes, we should check if all the resources under the node can be
> off-lined at validate phase.  (note, all the devices do not have to have
> _EJ0 if that's what you meant by hot-pluggable.)
>  
>>>> 3) Race condition check. if the device and its dependent device is in hot-plug
>>>>    process, another request will be denied.
>>>
>>> I agree that hot-plug operation should be serialized.  I think another
>>> request should be either queued or denied based on the caller's intent
>>> (i.e. wait-ok or no-wait). 
>>>
>>>> No rollback is needed for the above checks.
>>>
>>> Great.
>>>
>>>>> 2. Execute phase - Perform hot-add / hot-remove operation that can be
>>>>> rolled-back in case of error or cancel.
>>>>
>>>> In this phase, we introduce a state machine for the hot-plugble device,
>>>> please refer to:
>>>> https://lkml.org/lkml/2012/11/4/79
>>>>
>>>> I think we have the same idea for the major framework, but the ACPI based
>>>> hot-plug framework implement it differently in detail, right ?
>>>
>>> Yes, I am surprised with the similarity.  What I described is something
>>> we had implemented for other OS.  I am still studying how best we can
>>> improve the Linux hotplug code. :)
>>
>> Great! your experience is very appreciable for me. I think we can share ideas
>> to achieve a better solution for Linux hotplug code. :)
> 
> Sounds great.
> 
> Thanks,
> -Toshi
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

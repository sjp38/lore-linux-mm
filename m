Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A97FB6B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 07:10:51 -0500 (EST)
Message-ID: <50BF399B.7010404@huawei.com>
Date: Wed, 5 Dec 2012 20:10:03 +0800
From: Hanjun Guo <guohanjun@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>     <50B5EFE9.3040206@huawei.com>    <1354128096.26955.276.camel@misato.fc.hp.com>   <50B6E936.2080308@huawei.com> <1354228028.7776.56.camel@misato.fc.hp.com>   <50BC29C6.6050706@huawei.com> <1354579848.21585.54.camel@misato.fc.hp.com>  <50BDBF5A.8040407@huawei.com> <1354663411.21585.135.camel@misato.fc.hp.com>
In-Reply-To: <1354663411.21585.135.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, Huxinwei <huxinwei@huawei.com>

On 2012/12/5 7:23, Toshi Kani wrote:
> On Tue, 2012-12-04 at 17:16 +0800, Hanjun Guo wrote:
>> On 2012/12/4 8:10, Toshi Kani wrote:
>>> On Mon, 2012-12-03 at 12:25 +0800, Hanjun Guo wrote:
>>>> On 2012/11/30 6:27, Toshi Kani wrote:
>>>>> On Thu, 2012-11-29 at 12:48 +0800, Hanjun Guo wrote:
>>>>>> On 2012/11/29 2:41, Toshi Kani wrote:
>>>>>>> On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
>>>>>>>> On 2012/11/24 1:50, Vasilis Liaskovitis wrote:
>>>>>>>> As you may know, the ACPI based hotplug framework we are working on already addressed
>>>>>>>> this problem, and the way we slove this problem is a bit like yours.
>>>>>>>>
>>>>>>>> We introduce hp_ops in struct acpi_device_ops:
>>>>>>>> struct acpi_device_ops {
>>>>>>>> 	acpi_op_add add;
>>>>>>>> 	acpi_op_remove remove;
>>>>>>>> 	acpi_op_start start;
>>>>>>>> 	acpi_op_bind bind;
>>>>>>>> 	acpi_op_unbind unbind;
>>>>>>>> 	acpi_op_notify notify;
>>>>>>>> #ifdef	CONFIG_ACPI_HOTPLUG
>>>>>>>> 	struct acpihp_dev_ops *hp_ops;
>>>>>>>> #endif	/* CONFIG_ACPI_HOTPLUG */
>>>>>>>> };
>>>>>>>>
>>>>>>>> in hp_ops, we divide the prepare_remove into six small steps, that is:
>>>>>>>> 1) pre_release(): optional step to mark device going to be removed/busy
>>>>>>>> 2) release(): reclaim device from running system
>>>>>>>> 3) post_release(): rollback if cancelled by user or error happened
>>>>>>>> 4) pre_unconfigure(): optional step to solve possible dependency issue
>>>>>>>> 5) unconfigure(): remove devices from running system
>>>>>>>> 6) post_unconfigure(): free resources used by devices
>>>>>>>>
>>>>>>>> In this way, we can easily rollback if error happens.
>>>>>>>> How do you think of this solution, any suggestion ? I think we can achieve
>>>>>>>> a better way for sharing ideas. :)
>>>>>>>
>>>>>>> Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
>>>>>>> have not looked at all your changes yet..), but in my mind, a hot-plug
>>>>>>> operation should be composed with the following 3 phases.
>>>>>>
>>>>>> Good idea ! we also implement a hot-plug operation in 3 phases:
>>>>>> 1) acpihp_drv_pre_execute
>>>>>> 2) acpihp_drv_execute
>>>>>> 3) acpihp_drv_post_execute
>>>>>> you may refer to :
>>>>>> https://lkml.org/lkml/2012/11/4/79
>>>>>
>>>>> Great.  Yes, I will take a look.
>>>>
>>>> Thanks, any comments are welcomed :)
>>>
>>> If I read the code right, the framework calls ACPI drivers differently
>>> at boot-time and hot-add as follows.  That is, the new entry points are
>>> called at hot-add only, but .add() is called at both cases.  This
>>> requires .add() to work differently.
>>
>> Hi Toshi,
>> Thanks for your comments!
>>
>>>
>>> Boot    : .add()
>>
>> Actually, at boot time: .add(), .start()
> 
> Right.
> 
>>> Hot-Add : .add(), .pre_configure(), configure(), etc.
>>
>> Yes, we did it as you said in the framework. We use .pre_configure(), configure(),
>> and post_configure() to instead of .start() for better error handling and recovery.
> 
> I think we should have hot-plug interfaces at the module level, not at
> the ACPI-internal level.  In this way, the interfaces can be
> platform-neutral and allow any modules to register, which makes it more
> consistent with the boot-up sequence.  It can also allow ordering of the
> sequence among the registered modules.  Right now, we initiate all
> procedures from ACPI during hot-plug, which I think is inflexible and
> steps into other module's role.
> 
> I am also concerned about the slot handling, which is the core piece of
> the infrastructure and only allows hot-plug operations on ACPI objects
> where slot objects are previously created by checking _EJ0.  The
> infrastructure should allow hot-plug operations on any objects, and it
> should not be dependent on the slot design.
> 
> I have some rough idea, and it may be easier to review / explain if I
> make some code changes.  So, let me prototype it, and send it you all if
> that works out.  Hopefully, it won't take too long.

Great! If any thing I can do, please let me know it.

> 
>>> I think the boot-time and hot-add initialization should be done
>>> consistently.  While there is difficulty with the current boot sequence,
>>> the framework should be designed to allow them consistent, not make them
>>> diverged.
>>>
>>>>>>> 1. Validate phase - Verify if the request is a supported operation.  All
>>>>>>> known restrictions are verified at this phase.  For instance, if a
>>>>>>> hot-remove request involves kernel memory, it is failed in this phase.
>>>>>>> Since this phase makes no change, no rollback is necessary to fail. 
>>>>>>
>>>>>> Yes, we have done this in acpihp_drv_pre_execute, and check following things:
>>>>>>
>>>>>> 1) Hot-plugble or not. the instance kernel memory you mentioned is also checked
>>>>>>    when memory device remove;
>>>>>
>>>>> Agreed.
>>>>>
>>>>>> 2) Dependency check involved. For instance, if hot-add a memory device,
>>>>>>    processor should be added first, otherwise it's not valid to this operation.
>>>>>
>>>>> I think FW should be the one that assures such dependency.  That is,
>>>>> when a memory device object is marked as present/enabled/functioning, it
>>>>> should be ready for the OS to use.
>>>>
>>>> Yes, BIOS should do something for the dependency, because BIOS knows the
>>>> actual hardware topology. 
>>>
>>> Right.
>>>
>>>> The ACPI specification provides _EDL method to
>>>> tell OS the eject device list, but still has no method to tell OS the add device
>>>> list now.
>>>
>>> Yes, but I do not think the OS needs special handling for add...
>>
>> Hmm, how about trigger a hot add operation by OS ? we have eject interface for OS, but
>> have no add interface now, do you think this feature is useful? If it is, I think OS
>> should analyze the dependency first and tell the user.
> 
> The OS can eject an ACPI device because a target device is owned by the
> OS (i.e. enabled).  For hot-add, a target ACPI device is not owned by
> the OS (i.e. disabled).  Therefore, the OS is not supposed to change its
> state.  So, I do not think we should support a hot-add operation by the
> OS.
>  
>>>> For some cases, OS should analyze the dependency in the validate phase. For example,
>>>> when hot remove a node (container device), OS should analyze the dependency to get
>>>> the remove order as following:
>>>> 1) Host bridge;
>>>> 2) Memory devices;
>>>> 3) Processor devices;
>>>> 4) Container device itself;
>>>
>>> This may be off-topic, but how do you plan to delete I/O devices under a
>>> node?  Are you planning to delete all I/O devices along with the node?
>>
>> Yes, we delete all I/O devices under the node. we delete I/O devices as
>> following steps:
>> 1) Offline PCI devices;
>> 2) Offline IOAPIC and IOMMU;
>> and offline I/O devices no matter in use or not.
> 
> Oh, off-lining no matter what would be problematic for enterprise
> customers... 

Agreed. I think we should do more in user space to check such things, not in the kernel.

Thanks
Hanjun




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

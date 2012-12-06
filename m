Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 54D438D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 12:01:54 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2968864dak.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 09:01:53 -0800 (PST)
Message-ID: <50C0CF7C.7010006@gmail.com>
Date: Fri, 07 Dec 2012 01:01:48 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>  <50B5EFE9.3040206@huawei.com> <1354128096.26955.276.camel@misato.fc.hp.com>  <75241306.UQIr1RW8Qh@vostro.rjw.lan> <1354208592.26955.429.camel@misato.fc.hp.com>
In-Reply-To: <1354208592.26955.429.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

On 11/30/2012 01:03 AM, Toshi Kani wrote:
> On Thu, 2012-11-29 at 11:15 +0100, Rafael J. Wysocki wrote:
>> On Wednesday, November 28, 2012 11:41:36 AM Toshi Kani wrote:
>>> On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
>>>> On 2012/11/24 1:50, Vasilis Liaskovitis wrote:
>>>>> As discussed in https://patchwork.kernel.org/patch/1581581/
>>>>> the driver core remove function needs to always succeed. This means we need
>>>>> to know that the device can be successfully removed before acpi_bus_trim / 
>>>>> acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
>>>>> or SCI-initiated eject of memory devices fail e.g with:
>>>>> echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>>>>>
>>>>> since the ACPI core goes ahead and ejects the device regardless of whether the
>>>>> the memory is still in use or not.
>>>>>
>>>>> For this reason a new acpi_device operation called prepare_remove is introduced.
>>>>> This operation should be registered for acpi devices whose removal (from kernel
>>>>> perspective) can fail.  Memory devices fall in this category.
>>>>>
>>>>> acpi_bus_remove() is changed to handle removal in 2 steps:
>>>>> - preparation for removal i.e. perform part of removal that can fail. Should
>>>>>   succeed for device and all its children.
>>>>> - if above step was successfull, proceed to actual device removal
>>>>
>>>> Hi Vasilis,
>>>> We met the same problem when we doing computer node hotplug, It is a good idea
>>>> to introduce prepare_remove before actual device removal.
>>>>
>>>> I think we could do more in prepare_remove, such as rollback. In most cases, we can
>>>> offline most of memory sections except kernel used pages now, should we rollback
>>>> and online the memory sections when prepare_remove failed ?
>>>
>>> I think hot-plug operation should have all-or-nothing semantics.  That
>>> is, an operation should either complete successfully, or rollback to the
>>> original state.
>>
>> That's correct.
>>
>>>> As you may know, the ACPI based hotplug framework we are working on already addressed
>>>> this problem, and the way we slove this problem is a bit like yours.
>>>>
>>>> We introduce hp_ops in struct acpi_device_ops:
>>>> struct acpi_device_ops {
>>>> 	acpi_op_add add;
>>>> 	acpi_op_remove remove;
>>>> 	acpi_op_start start;
>>>> 	acpi_op_bind bind;
>>>> 	acpi_op_unbind unbind;
>>>> 	acpi_op_notify notify;
>>>> #ifdef	CONFIG_ACPI_HOTPLUG
>>>> 	struct acpihp_dev_ops *hp_ops;
>>>> #endif	/* CONFIG_ACPI_HOTPLUG */
>>>> };
>>>>
>>>> in hp_ops, we divide the prepare_remove into six small steps, that is:
>>>> 1) pre_release(): optional step to mark device going to be removed/busy
>>>> 2) release(): reclaim device from running system
>>>> 3) post_release(): rollback if cancelled by user or error happened
>>>> 4) pre_unconfigure(): optional step to solve possible dependency issue
>>>> 5) unconfigure(): remove devices from running system
>>>> 6) post_unconfigure(): free resources used by devices
>>>>
>>>> In this way, we can easily rollback if error happens.
>>>> How do you think of this solution, any suggestion ? I think we can achieve
>>>> a better way for sharing ideas. :)
>>>
>>> Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
>>> have not looked at all your changes yet..), but in my mind, a hot-plug
>>> operation should be composed with the following 3 phases.
>>>
>>> 1. Validate phase - Verify if the request is a supported operation.  All
>>> known restrictions are verified at this phase.  For instance, if a
>>> hot-remove request involves kernel memory, it is failed in this phase.
>>> Since this phase makes no change, no rollback is necessary to fail.  
>>
>> Actually, we can't do it this way, because the conditions may change between
>> the check and the execution.  So the first phase needs to involve execution
>> to some extent, although only as far as it remains reversible.
> 
> For memory hot-remove, we can check if the target memory ranges are
> within ZONE_MOVABLE.  We should not allow user to change this setup
> during hot-remove operation.  Other things may be to check if a target
> node contains cpu0 (until it is supported), the console UART (assuming
> we cannot delete it), etc.  We should avoid doing rollback as much as we
> can.
Fengguang from Intel is working on a patchset to hot-remove CPU0(BSP)
on x86 platforms and he has posted several versions. Maybe we could eventually
remove CPU0 on x86.

> 
> Thanks,
> -Toshi
> 
> 
>>> 2. Execute phase - Perform hot-add / hot-remove operation that can be
>>> rolled-back in case of error or cancel.
>>
>> I would just merge 1 and 2.
>>
>>> 3. Commit phase - Perform the final hot-add / hot-remove operation that
>>> cannot be rolled-back.  No error / cancel is allowed in this phase.  For
>>> instance, eject operation is performed at this phase.  
>>
>> Yup.
>>
>> Thanks,
>> Rafael
>>
>>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

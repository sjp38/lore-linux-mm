Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 44C416B005D
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 15:10:48 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so3866228obc.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 12:10:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50727984.20401@cn.fujitsu.com>
References: <506C0AE8.40702@jp.fujitsu.com> <506C0C53.60205@jp.fujitsu.com>
 <CAHGf_=p7PaQs-kpnyB8uC1MntHQfL-CXhhq4QQP54mYiqOswqQ@mail.gmail.com> <50727984.20401@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 12 Oct 2012 15:10:27 -0400
Message-ID: <CAHGf_=pCrx8AkL9eiSYVgwvT1v0SW2__P_DW-1Wwj_zskqcLXw@mail.gmail.com>
Subject: Re: [PATCH 1/4] acpi,memory-hotplug : add memory offline code to acpi_memory_device_remove()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

>>> -static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
>>> +static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>>>  {
>>>         int result;
>>>         struct acpi_memory_info *info, *n;
>>>
>>> +       list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
>>
>> Which lock protect this loop?
>
> There is no any lock to protect it now...

When iterate an item removal list, you should use lock for protecting from
memory corruption.




>>> +static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
>>> +{
>>> +       int result;
>>>
>>>         /*
>>>          * Ask the VM to offline this memory range.
>>>          * Note: Assume that this function returns zero on success
>>>          */
>>
>> Write function comment instead of this silly comment.
>>
>>> -       list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
>>> -               if (info->enabled) {
>>> -                       result = remove_memory(info->start_addr, info->length);
>>> -                       if (result)
>>> -                               return result;
>>> -               }
>>> -               kfree(info);
>>> -       }
>>> +       result = acpi_memory_remove_memory(mem_device);
>>> +       if (result)
>>> +               return result;
>>>
>>>         /* Power-off and eject the device */
>>>         result = acpi_memory_powerdown_device(mem_device);
>>
>> This patch move acpi_memory_powerdown_device() from ACPI_NOTIFY_EJECT_REQUEST
>> to release callback, but don't explain why.
>
> Hmm, it doesn't move the code. It just reuse the code in acpi_memory_powerdown_device().

Even if reuse or not reuse, you changed the behavior. If any changes
has no good rational, you cannot get an ack.




>>> @@ -473,12 +486,23 @@ static int acpi_memory_device_add(struct
>>>  static int acpi_memory_device_remove(struct acpi_device *device, int type)
>>>  {
>>>         struct acpi_memory_device *mem_device = NULL;
>>> -
>>> +       int result;
>>>
>>>         if (!device || !acpi_driver_data(device))
>>>                 return -EINVAL;
>>>
>>>         mem_device = acpi_driver_data(device);
>>> +
>>> +       if (type == ACPI_BUS_REMOVAL_EJECT) {
>>> +               /*
>>> +                * offline and remove memory only when the memory device is
>>> +                * ejected.
>>> +                */
>>
>> This comment explain nothing. A comment should describe _why_ should we do.
>> e.g. Why REMOVAL_NORMAL and REMOVEL_EJECT should be ignored. Why
>> we need remove memory here instead of ACPI_NOTIFY_EJECT_REQUEST.
>
> Hmm, we have 2 ways to remove a memory:
> 1. SCI
> 2. echo 1 >/sys/bus/acpi/devices/PNP0C80:XX/eject
>
> In the 2nd case, there is no ACPI_NOTIFY_EJECT_REQUEST. We should offline
> the memory and remove it from kernel in the release callback. We will poweroff
> the memory device in acpi_bus_hot_remove_device(), so we must offline
> and remove it if the type is ACPI_BUS_REMOVAL_EJECT.
>
> I guess we should not poweroff the memory device when we fail to offline it.
> But device_release_driver() doesn't returns any error...

1) I think /sys/bus/acpi/devices/PNP0C80:XX/eject should emulate acpi
eject. Can't
you make a pseudo acpi eject event and detach device by acpi regular path?

2) Your explanation didn't explain why we should ignore REMOVAL_NORMAL
and REMOVEL_EJECT. As far as reviewers can't track your intention, we
can't maintain
the code and can't ack them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 82F276B006C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 04:52:17 -0500 (EST)
Message-ID: <50B3323E.7020907@cn.fujitsu.com>
Date: Mon, 26 Nov 2012 17:11:26 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <1353693037-21704-4-git-send-email-vasilis.liaskovitis@profitbricks.com> <50B0F3DF.4000802@gmail.com> <20121126083634.GA4574@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20121126083634.GA4574@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: Wen Congyang <wencongyang@gmail.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

At 11/26/2012 04:36 PM, Vasilis Liaskovitis Wrote:
> On Sun, Nov 25, 2012 at 12:20:47AM +0800, Wen Congyang wrote:
>> At 2012/11/24 1:50, Vasilis Liaskovitis Wrote:
>>> Consider the following sequence of operations for a hotplugged memory device:
>>>
>>> 1. echo "PNP0C80:XX">  /sys/bus/acpi/drivers/acpi_memhotplug/unbind
>>> 2. echo "PNP0C80:XX">  /sys/bus/acpi/drivers/acpi_memhotplug/bind
>>> 3. echo 1>/sys/bus/pci/devices/PNP0C80:XX/eject
>>>
>>> The driver is successfully re-bound to the device in step 2. However step 3 will
>>> not attempt to remove the memory. This is because the acpi_memory_info enabled
>>> bit for the newly bound driver has not been set to 1. This bit needs to be set
>>> in the case where the memory is already used by the kernel (add_memory returns
>>> -EEXIST)
>>
>> Hmm, I think the reason is that we don't offline/remove memory when
>> unbinding it
>> from the driver. I have sent a patch to fix this problem, and this patch
>> is in
>> pm tree now. With this patch, we will offline/remove memory when
>> unbinding it from
>> the drriver.
> 
> ok. Which patch is this? Does it require driver-core changes?

https://lkml.org/lkml/2012/11/15/21

Patch 1-6 is in pm tree now.

> 
>>
>> Consider the following sequence of operations for a hotplugged memory
>> device:
>>
>> 1. echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
>> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>>
>> If we don't offline/remove the memory, we have no chance to do it in
>> step 2. After
>> step2, the memory is used by the kernel, but we have powered off it. It
>> is very
>> dangerous.
> 
> How does power-off happen after unbind? acpi_eject_store checks for existing
> driver before taking any action:
> 
> #ifndef FORCE_EJECT
> 	if (acpi_device->driver == NULL) {
> 		ret = -ENODEV;
> 		goto err;
> 	}
> #endif
> 
> FORCE_EJECT is not defined afaict, so the function returns without scheduling
> acpi_bus_hot_remove_device. Is there another code path that calls power-off?

Consider the following case:

We hotremove the memory device by SCI and unbind it from the driver at the same time:

CPUa                                                  CPUb
acpi_memory_device_notify()
                                       unbind it from the driver
    acpi_bus_hot_remove_device()

Thanks
Wen Congyang

> 
> thanks,
> 
> - Vasilis
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

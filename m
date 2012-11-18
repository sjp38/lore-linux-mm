Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A8A3E6B004D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 11:16:51 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so3157224pbc.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 08:16:50 -0800 (PST)
Message-ID: <50A909E1.9030708@gmail.com>
Date: Mon, 19 Nov 2012 00:16:33 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device operation
References: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>  <1446291.TgLDtXqY7q@vostro.rjw.lan>  <1353105943.12509.60.camel@misato.fc.hp.com>  <20121116230143.GA15338@kroah.com>  <1353107684.12509.65.camel@misato.fc.hp.com>  <20121116233355.GA21144@kroah.com>  <1353108906.10624.5.camel@misato.fc.hp.com>  <20121117000250.GA4425@kroah.com>  <1353110933.10939.6.camel@misato.fc.hp.com>  <20121117002232.GA22543@kroah.com> <1353111905.10939.12.camel@misato.fc.hp.com>
In-Reply-To: <1353111905.10939.12.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/17/2012 08:25 AM, Toshi Kani wrote:
> On Fri, 2012-11-16 at 16:22 -0800, Greg Kroah-Hartman wrote:
>> On Fri, Nov 16, 2012 at 05:08:53PM -0700, Toshi Kani wrote:
>>>>>>>>>> So the question is, does the ACPI core have to do that and if so, then why?
>>>>>>>>>
>>>>>>>>> The problem is that acpi_memory_devcie_remove() can fail.  However,
>>>>>>>>> device_release_driver() is a void function, so it cannot report its
>>>>>>>>> error.  Here are function flows for SCI, sysfs eject and unbind.
>>>>>>>>
>>>>>>>> Then don't ever let acpi_memory_device_remove() fail.  If the user wants
>>>>>>>> it gone, it needs to go away.  Just like any other device in the system
>>>>>>>> that can go away at any point in time, you can't "fail" that.
>>>>>>>
>>>>>>> That would be ideal, but we cannot delete a memory device that contains
>>>>>>> kernel memory.  I am curious, how do you deal with a USB device that is
>>>>>>> being mounted in this case?
>>>>>>
>>>>>> As the device is physically gone now, we deal with it and clean up
>>>>>> properly.
>>>>>>
>>>>>> And that's the point here, what happens if the memory really is gone?
>>>>>> You will still have to handle it now being removed, you can't "fail" a
>>>>>> physical removal of a device.
>>>>>>
>>>>>> If you remove a memory device that has kernel memory on it, well, you
>>>>>> better be able to somehow remap it before the kernel needs it :)
>>>>>
>>>>> :)
>>>>>
>>>>> Well, we are not trying to support surprise removal here.  All three
>>>>> use-cases (SCI, eject, and unbind) are for graceful removal.  Therefore
>>>>> they should fail if the removal operation cannot complete in graceful
>>>>> way.
>>>>
>>>> Then handle that in the ACPI bus code, it isn't anything that the driver
>>>> core should care about, right?
>>>
>>> Unfortunately not.  Please take a look at the function flow for the
>>> unbind case in my first email.  This request directly goes to
>>> driver_unbind(), which is a driver core function.
>>
>> Yes, and as the user asked for the driver to be unbound from the device,
>> it can not fail.
>>
>> And that is WAY different from removing the memory from the system
>> itself.  Don't think that this is the "normal" way that memory should be
>> removed, that is what stuff like "eject" was created for the PCI slots.
>>
>> Don't confuse the two things here, unbinding a driver from a device
>> should not remove the memory from the system, it doesn't do that for any
>> other type of 'unbind' call for any other bus.  The device is still
>> present, just that specific driver isn't controlling it anymore.
>>
>> In other words, you should NEVER have a normal userspace flow that is
>> trying to do unbind.  unbind is only for radical things like
>> disconnecting a driver from a device if a userspace driver wants to
>> control it, or a hacked up way to implement revoke() for a device.
>>
>> Again, no driver core changes are needed here.
> 
> Okay, we might be able to make the eject case to fail if an ACPI driver
> is not bound to a device.  This way, the unbind case may be harmless to
> proceed.  Let us think about this further on this (but we may come up
> again :). 
Hi all,
	The ACPI based system device hotplug framework project I'm working
on has already provided a solution for this issue.
	We have added several callbacks to struct acpi_device_ops to support
ACPI system device hotplug. By that way, we could guarantee unbinding ACPI
CPU/memory/PCI host bridge drivers will always success. And we have a plan
to implement the existing "eject" interface with the new hotplug framework.

	For more information, please take a look at:
http://www.spinics.net/lists/linux-acpi/msg39487.html
http://www.spinics.net/lists/linux-acpi/msg39490.html

Thanks!
Gerry

> 
> Thanks,
> -Toshi 
> 
> 
> 
> 
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

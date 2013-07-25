Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id BB0096B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 20:44:54 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf11so1300962pab.38
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 17:44:53 -0700 (PDT)
Message-ID: <51F074FA.3010703@gmail.com>
Date: Thu, 25 Jul 2013 08:44:42 +0800
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>   <20130722083721.GC25976@gmail.com>   <1374513120.16322.21.camel@misato.fc.hp.com>   <20130723080101.GB15255@gmail.com>  <1374612301.16322.136.camel@misato.fc.hp.com> <51EF1D38.60503@gmail.com> <1374681742.16322.180.camel@misato.fc.hp.com>
In-Reply-To: <1374681742.16322.180.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On 07/25/2013 12:02 AM, Toshi Kani wrote:
> On Wed, 2013-07-24 at 08:18 +0800, Hush Bensen wrote:
>> On 07/24/2013 04:45 AM, Toshi Kani wrote:
>>> On Tue, 2013-07-23 at 10:01 +0200, Ingo Molnar wrote:
>>>> * Toshi Kani <toshi.kani@hp.com> wrote:
>>>>
>>>>>> Could we please also fix it to never crash the kernel, even if stupid
>>>>>> ranges are provided?
>>>>> Yes, this probe interface can be enhanced to verify the firmware
>>>>> information before adding a given memory address.  However, such change
>>>>> would interfere its test use of "fake" hotplug, which is only the known
>>>>> use-case of this interface on x86.
>>>> Not crashing the kernel is not a novel concept even for test interfaces...
>>> Agreed.
>>>
>>>> Where does the possible crash come from - from using invalid RAM ranges,
>>>> right? I.e. on x86 to fix the crash we need to check the RAM is present in
>>>> the e820 maps, is marked RAM there, and is not already registered with the
>>>> kernel, or so?
>>> Yes, the crash comes from using invalid RAM ranges.  How to check if the
>>> RAM is present is different if the system supports hotplug or not.
>> Could you explain different methods to check the RAM is present if the
>> system supports hotplkug or not?
> e820 and UEFI memory descriptor tables are the boot-time interfaces.
> These interfaces are not required to reflect any run-time changes.
>
> ACPI memory device objects can be used at both boot-time and run-time,
> which reflect any run-time changes.  But they are optional to implement.
> They typically are not implemented unless the system supports hotplug.
>
>>>>> In order to verify if a given memory address is enabled at run-time (as
>>>>> opposed to boot-time), we need to check with ACPI memory device objects
>>>>> on x86.  However, system vendors tend to not implement memory device
>>>>> objects unless their systems support memory hotplug.  Dave Hansen is
>>>>> using this interface for his testing as a way to fake a hotplug event on
>>>>> a system that does not support memory hotplug.
>>>> All vendors implement e820 maps for the memory present at boot time.
>>> Yes for boot time.  At run-time, e820 is not guaranteed to represent a
>>> new memory added.  Here is a quote from ACPI spec.
>>>
>>> ===
>>> 15.1 INT 15H, E820H - Query System Address Map
>>>    :
>>> The memory map conveyed by this interface is not required to reflect any
>>> changes in available physical memory that have occurred after the BIOS
>>> has initially passed control to the operating system. For example, if
>>> memory is added dynamically, this interface is not required to reflect
>>> the new system memory configuration.
>>> ===
>>>
>>> By definition, the "probe" interface is used for the kernel to recognize
>>> a new memory added at run-time.  So, it should check ACPI memory device
>>> objects (which represents run-time state) for the verification.  On x86,
>>> however, ACPI also sends a hotplug event to the kernel, which triggers
>>> the kernel to recognize the new physical memory properly.  Hence, users
>>> do not need this "probe" interface.
>>>
>>>> How is the testing done by Dave Hansen? If it's done by booting with less
>>>> RAM than available (via say the mem=1g boot parameter), and then
>>>> hot-adding some of the missing RAM, then this could be made safe via the
>>>> e820 maps and by consultig the physical memory maps (to avoid double
>>>> registry), right?
>>> If we focus on this test scenario on a system that does not support
>>> hotplug, yes, I agree that we can check with e820 since it is safe to
>>> assume that the system has no change after boot.  IOW, it is unsafe to
>>> check with e820 if the system supports hotplug, but there is no use in
>>> this interface for testing if the system supports hotplug.  So, this may
>>> be a good idea.
>>>
>>> Dave, is this how you are testing?  Do you always specify a valid memory
>>> address for your testing?
>>>
>>>> How does the hotplug event based approach solve double adds? Relies on the
>>>> hardware not sending a hot-add event twice for the same memory area or for
>>>> an invalid memory area, or does it include fail-safes and double checks as
>>>> well to avoid double adds and adding invalid memory? If yes then that
>>>> could be utilized here as well.
>>> In high-level, here is how ACPI memory hotplug works:
>>>
>>> 1. ACPI sends a hotplug event to a new ACPI memory device object that is
>>> hot-added.
>>> 2. The kernel is notified, and verifies if the new memory device object
>>> has not been attached by any handler yet.
>>> 3. The memory handler is called, and obtains a new memory range from the
>>> ACPI memory device object.
>>> 4. The memory handler calls add_memory() with the new address range.
>>>
>>> The above step 1-4 proceeds automatically within the kernel.  No user
>>> input (nor sysfs interface) is necessary.  Step 2 prevents double adds
>>> and step 3 gets a valid address range from the firmware directly.  Step
>>> 4 is basically the same as the "probe" interface, but with all the
>>> verification up front, this step is safe.
>> This is hot-added part, could you also explain how ACPI memory hotplug
>> works for hot-remove?
> Sure.  Here is high-level.
>
> 1. ACPI sends a hotplug event to an ACPI memory device object that is
> requested to hot-remove.
> 2. The kernel is notified, and verifies if the memory device object is
> attached by a handler.
> 3. The memory handler is called (which is being attached), and obtains
> its memory range.
> 4. The memory handler calls remove_memory() with the address range.
> 5. The kernel calls eject method of the ACPI memory device object.

Could you give me the calltrace of add_memory and remove_memory? I don't 
have machine support hotplug, but I hope to investigate how ACPI part 
works for memory hotplug. ;-)

>
> Thanks,
> -Toshi
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

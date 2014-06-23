Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E9EF76B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 06:50:25 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so5759242pad.27
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 03:50:25 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id sr7si21376927pab.202.2014.06.23.03.50.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 03:50:25 -0700 (PDT)
Message-ID: <53A80663.90603@huawei.com>
Date: Mon, 23 Jun 2014 18:50:11 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: Why we echo a invalid  start_address_of_new_memory succeeded
 ?
References: <53A3DD82.3070208@huawei.com> <alpine.DEB.2.02.1406200317420.29234@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406200317420.29234@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: wangnan0@huawei.com, xiaofeng.yan@huawei.com, linux-mm@kvack.org

On 2014/6/20 18:30, David Rientjes wrote:
> On Fri, 20 Jun 2014, Zhang Zhen wrote:
> 
>> Hi,
>>
>> I am testing mem-hotplug on a qemu virtual machine. I executed the following command
>> to notify memory hot-add event by hand.
>>
>> % echo start_address_of_new_memory > /sys/devices/system/memory/probe
>>
>> To a different start_address_of_new_memory I got different results.
>> The results are as follows:
>>
>> MBSC-x86_64 /sys/devices/system/memory # ls
>> block_size_bytes  memory2           memory5           power
>> memory0           memory3           memory6           probe
>> memory1           memory4           memory7           uevent
>> MBSC-x86_64 /sys/devices/system/memory # echo 0x70000000 > probe
> 
> Since block_size_bytes is 0x8000000 == 128MB, this is 0x70000000 / 
> 0x8000000 = section number 14.  Successfully hot added.  Presumably you're 
> reporting that there is no physical memory there, so this would default to 
> the online node of the first memory block, probably node 0.
> 
>> MBSC-x86_64 /sys/devices/system/memory # echo 0x78000000 > probe
>> -sh: echo: write error: File exists
> 
> EEXIST gets returned when the resource already exists, mostly likely 
> system RAM or reserved memory as reported by your BIOS.  You report this 
> is a 2GB machine, no reason to believe memory at 1920MB isn't already 
> online (including reserved).
> 
>> MBSC-x86_64 /sys/devices/system/memory # echo 0x80000000 > probe
>> -sh: echo: write error: File exists
>> MBSC-x86_64 /sys/devices/system/memory # echo 0x88000000 > probe
>> -sh: echo: write error: File exists
> 
> Same.
> 
>> MBSC-x86_64 /sys/devices/system/memory # echo 0x8f000000 > probe
>> -sh: echo: write error: Invalid argument
> 
> Returns EINVAL because it's not a multiple of block_size_bytes, it's not 
> aligned properly.
> 
>> MBSC-x86_64 /sys/devices/system/memory # echo 0x90000000 > probe
>> -sh: echo: write error: File exists
> 
> See above, the resoure already exists.  Check your e820 your dmesg, which 
> is missing from this report, to determine what already exists and may be 
> already online or reserved.
> 
>> MBSC-x86_64 /sys/devices/system/memory # echo 0xff0000000 > probe
> 
> 0xff0000000 / 0x8000000 is section 510, successfully onlined.
> 
>> MBSC-x86_64 /sys/devices/system/memory # ls
>> block_size_bytes  memory2           memory510         probe
>> memory0           memory3           memory6           uevent
>> memory1           memory4           memory7
>> memory14          memory5           power
> 
> Looks good, you onlined sections 14 and 510 above.
> 
>> MBSC-x86_64 /sys/devices/system/memory # echo 0xfff0000000 > probe
> 
> Same for section 8190.
> 
>> MBSC-x86_64 /sys/devices/system/memory # ls
>> block_size_bytes  memory2           memory510         power
>> memory0           memory3           memory6           probe
>> memory1           memory4           memory7           uevent
>> memory14          memory5           memory8190
>>
> 
> Confirmed it's onlined.
> 
>> The qemu virtual machine's physical memory size is 2048M, and the boot memory is 1024M.
>>
>> MBSC-x86_64 / # cat /proc/meminfo
>> MemTotal:        1018356 kB
>> MBSC-x86_64 / # cat /sys/devices/system/memory/block_size_bytes
>> 8000000
>>
> 
> That's irrelevant, you've explicitly onlined memory that doesn't exist.  
> Not sure why you're using the probe interface unless you need it for x86, 
> is ACPI not registering it correctly?
> 
>> Three questions:
>> 1. The machine's physical memory size is 2048M, why echo 0x78000000 as the start_address_of_new_memory failed ?
>>
> 
> Copy your e820 map from your dmesg, it's probably reserved or already 
> online, this is lower than 2048M.
> 

Hi David,

You are right, if we echo 0x78000000 as the start_address_of_new_memory, the end_address_of_new_memory is exceeded
the usable range.
Thank you for your comments.

My e820 map as follows:

[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000007fffe000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] e820: remove [mem 0x40000000-0xfffffffffffffffe] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] e820: user-defined physical RAM map:
[    0.000000] user: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] user: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] user: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] user: [mem 0x0000000000100000-0x000000003fffffff] usable
[    0.000000] user: [mem 0x000000007fffe000-0x000000007fffffff] reserved
[    0.000000] user: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved

>> 2. Why echo 0x8f000000 as the start_address_of_new_memory, the error message is different ?
>>
> 
> Not properly aligned to block_size_bytes.  It's a nuance, but 
> block_size_bytes is exported in hex, not decimal.

You are right, it's not properly aligned to block_size_bytes. I have made a mistake.

> 
>> 3. Why echo 0xfff0000000 as the start_address_of_new_memory succeeded ? 0xfff0000000 has exceeded the machine's physical memory size.
>>
> 
> You're telling the kernel differently.
> 

I'm not clearly here,  0xfff0000000 is exceeded the usable range [mem 0x0000000000100000-0x000000007fffdfff] usable.
So i think here should return "File exists", but it succeeded.

Is it properly ?

Best regards!

> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

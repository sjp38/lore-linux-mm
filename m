Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9092E6B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 09:51:44 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id p61so1559229wes.31
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 06:51:43 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id j11si2661548wiw.64.2014.01.08.06.51.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 06:51:43 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id hq4so2172285wib.8
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 06:51:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJrk0BsiQ6R5utmvQ4NLUKkVg40NtiP2oMStZk-ejt8thbUTdA@mail.gmail.com>
References: <CAJrk0BuA2OTfMhmqZ-OFvtbdf_8+O3V77L0mDsoixN+t4A0ASA@mail.gmail.com>
	<20140106171324.GA6963@cmpxchg.org>
	<CAJrk0BsiQ6R5utmvQ4NLUKkVg40NtiP2oMStZk-ejt8thbUTdA@mail.gmail.com>
Date: Thu, 9 Jan 2014 01:51:43 +1100
Message-ID: <CAJrk0BuksDgE7UqF1knfNoxbvtm_-zrjw2M85tE49gT-M9bX9A@mail.gmail.com>
Subject: Re: [REGRESSION] [BISECTED] MM patch causes kernel lockup with 3.12
 and acpi_backlight=vendor
From: Bradley Baetz <bbaetz@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Hans De Goede <hdegoede@redhat.com>

On Tue, Jan 7, 2014 at 11:06 PM, Bradley Baetz <bbaetz@gmail.com> wrote:
> Hi,
>
> On Tue, Jan 7, 2014 at 4:13 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> Hi Bradley,
>>
>> On Fri, Dec 27, 2013 at 02:21:21PM +1100, Bradley Baetz wrote:
>>> Hi,
>>>
>>> I have a Dell laptop (Vostro 3560). When I boot Fedora 20 with the
>>> acpi_backlight=vendor option, the kernel locks up hard during the boot
>>> proces, when systemd runs udevadm trigger. This is a hard lockup -
>>> magic-sysrq doesn't work, and neither does caps lock/vt-change/etc.
>>>
>>> I've bisected this to:
>>>
>>> commit 81c0a2bb515fd4daae8cab64352877480792b515
>>> Author: Johannes Weiner <hannes@cmpxchg.org>
>>> Date:   Wed Sep 11 14:20:47 2013 -0700
>>>
>>>     mm: page_alloc: fair zone allocator policy
>>>
>>> which seemed really unrelated, but I've confirmed that:
>>>
>>>  - the commit before this patch doesn't cause the problem, and the commit
>>> afterwrads does
>>>  - reverting that patch from 3.12.0 fixes the problem
>>>  - reverting that patch (and the partial revert
>>> fff4068cba484e6b0abe334ed6b15d5a215a3b25) from master also fixes the problem
>>>  - reverting that patch from the fedora 3.12.5-302.fc20 kernel fixes the
>>> problem
>>>  - applying that patch to 3.11.0 causes the problem
>>>
>>> so I'm pretty sure that that is the patch that causes (or at least
>>> triggers) this issue
>>>
>>> I'm using the acpi_backlight option to get the backlight working - without
>>> this the backlight doesn't work at all. Removing 'acpi_backlight=vendor'
>>> (or blacklisting the dell-laptop module, which is effectively the same
>>> thing) fixes the issue.
>>>
>>> The lockup happens when systemd runs "udevadm trigger", not when the module
>>> is loaded - I can reproduce the issue by booting into emergency mode,
>>> remounting the filesystem as rw, starting up systemd-udevd and running
>>> udevadm trigger manually. It dies a few seconds after loading the
>>> dell-laptop module.
>>>
>>> This happens even if I don't boot into X (using
>>> systemd.unit=multi-user.target)
>>>
>>> Triggering udev individually for each item doesn't trigger the issue ie:
>>>
>>> for i in `udevadm --debug trigger --type=devices --action=add --dry-run
>>> --verbose`; do echo $i; udevadm --debug trigger --type=devices --action=add
>>> --verbose --parent-match=$i; sleep 1; done
>>>
>>> works, so I haven't been able to work out what specific combination of
>>> actions are causing this.
>>>
>>> With the acpi_backlight option, I can manually read/write to the sysfs
>>> dell-laptop backlight file, and it works (and changes the backlight as
>>> expected)
>>>
>>> This is 100% reproducible. I've also tested by powering off the laptop and
>>> pulling the battery just in case one of the previous boots with the bisect
>>> left the hardware in a strange state - no change.
>>
>> My patch aggressively spreads allocations over all zones in the
>> system, but it should still respect dell-laptop's requirements for
>> DMA32 memory.
>>
>> I wonder if the drastic change in allocation placement exposes an
>> existing memory corruption.  In fact, the dell-laptop module is
>> confused when it comes to the page allocator interface, it does
>>
>>   free_page((unsigned long)bufferpage);
>>
>> in the error path, where bufferpage is a page pointer that came out of
>> alloc_page(), which will cause the page allocator to try to free the
>> mem_map(!) page that backs the bufferpage page struct.  So one failed
>> load attempt of the module could plausibly corrupt internal state.
>>
>> Does the following resolve the problem?  And if not, what are the
>> "dell-laptop:" lines in the good and the bad kernel, and does the bad
>> kernel trigger the WARNING?
>
> Nope, no luck. I added some more printk's arround the use of SMI. I've
> transcribed the logs from a screenshot for the failing kernel (ie
> master+your patch) ("Sending command" logs class, select, and
> &command.ebx (with the %pa format string):
>
> dell-laptop: bufferpage (ffffea000263c680) in node 0 zone 1 (DMA32)
> Sending command: 0, 2, 0x4253493198f1a000
> Command sent
> dell-laptop: getting intensity
> Sending command: 0, 2, 0x4253493198f1a000
> Command sent
> dell-laptop: got intensity
> dell-laptop: Setting intensity
> Sending command: 1, 2, 0x4253493198f1a000
>
> and then it locks up before returning from the SMI
>
> So some of the commands work, and they also return the same value for
> the brightness, AND have parsed the same value from the SMBIOS table
> for the ioport/value to use. (I added that later, but didn't take a
> photo - they all return brightness of 2, which is the at-boot default
> value)
>
> Without acpi_backlight=vendor:
>
> dell-laptop: bufferpage (ffffea0000fa0dc0) in node 0 zone 1 (DMA32)
>
> (no other logs, because the module's backlight interface isn't used
> without that boot param)
>
> With your mm patches reverted:
>
> [   12.773884] dell-laptop: bufferpage (ffffea0000fe0180) in node 0
> zone 1 (DMA32)
> [   12.775502] Sending command: 0, 2, 0x425349313f806000
> [   12.777293] Command sent
> [   12.778950] dell-laptop: getting intensity
> [   12.780589] Sending command: 0, 2, 0x425349313f806000
> [   12.782185] Command sent
> [   12.783679] dell-laptop: got intensity
> [   12.785202] dell-laptop: Setting intensity
> [   12.786715] Sending command: 1, 2, 0x425349313f806000
> [   12.788892] Command sent
> [   12.790379] dell-laptop: set intensity
>
> (with the get/set repeated a bit later when X starts up)
>
> And on the broken kernel, when I boot into 'emergency' mode, manually
> load dell-laptop, I get the same logs as the 'working' bit (including
> the getting/got/setting/set lines).
>
> Looking at the code, I notice a few things odd with the dcdbas code,
> although I don't think that they're the issue here
>
> 1. dcdbas_smi_request does outb/inb, and marks eax as an input, but
> doesn't mark it as clobbered (I think; I don't have much experience
> with gcc's asm). In practice, I can't see that being an issue
> 2. dcdbas_smi_request says that it is "Called with smi_data_lock" but
> that's only true for the calls *within* dcdbas.c. I think that that's
> only a documentation issue, since is protecting a buffer that isn't
> used here. (Dell-laptop has its own buffer and mutex).
>
> I'm still unable to manually reproduce this - the only way to repro is
> 'try to boot normally', and while that's 100% reliable, it makes it a
> bit hard to narrow a trigger down...

So if I boot into 'emergency' mode and modprobe dell-laptop, it only
locks up about 50% of the time. And if I boot with init=/bin/bash, and
then load the module, it doesn't lock up at all (tried 5 times)

I also tried making dell-laptop use the DMA zone (instead of DMA32),
and that didn't help.

Bradley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

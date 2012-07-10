Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 0D0436B0078
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 05:58:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0E6233EE0B5
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:58:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC56345DE58
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:58:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC34A45DE56
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:58:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA1241DB804D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:58:32 +0900 (JST)
Received: from g01jpexchyt05.g01.fujitsu.local (g01jpexchyt05.g01.fujitsu.local [10.128.194.44])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 69BB41DB8047
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:58:32 +0900 (JST)
Message-ID: <4FFBFCAC.4010007@jp.fujitsu.com>
Date: Tue, 10 Jul 2012 18:58:04 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/13] memory-hotplug : hot-remove physical memory
References: <4FFAB0A2.8070304@jp.fujitsu.com> <alpine.DEB.2.00.1207091015570.30060@router.home>
In-Reply-To: <alpine.DEB.2.00.1207091015570.30060@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

Hi Christoph,

2012/07/10 0:18, Christoph Lameter wrote:
>
> On Mon, 9 Jul 2012, Yasuaki Ishimatsu wrote:
>
>> Even if you apply these patches, you cannot remove the physical memory
>> completely since these patches are still under development. I want you to
>> cooperate to improve the physical memory hot-remove. So please review these
>> patches and give your comment/idea.
>
> Could you at least give a method on how you want to do physical memory
> removal?

We plan to release a dynamic hardware partitionable system. It will be
able to hot remove/add a system board which included memory and cpu.
But as you know, Linux does not support memory hot-remove on x86 box.
So I try to develop it.

Current plan to hot remove system board is to use container driver.
Thus I define the system board in ACPI DSDT table as a container device.
It have supported hot-add a container device. And if container device
has _EJ0 ACPI method, "eject" file to remove the container device is
prepared as follow:

# ls -l /sys/bus/acpi/devices/ACPI0004\:01/eject
--w-------. 1 root root 4096 Jul 10 18:19 /sys/bus/acpi/devices/ACPI0004:01/eject

When I hot-remove the container device, I echo 1 to the file as follow:

#echo 1 > /sys/bus/acpi/devices/ACPI0004\:02/eject

Then acpi_bus_trim() is called. And it calls acpi_memory_device_remove()
for removing memory device. But the code does not do nothing.
So I developed the continuation of the function.

> You would have to remove all objects from the range you want to
> physically remove. That is only possible under special circumstances and
> with a limited set of objects. Even if you exclusively use ZONE_MOVEABLE
> you still may get cases where pages are pinned for a long time.

I know it. So my memory hot-remove plan is as follows:

1. hot-added a system board
    All memory which included the system board is offline.

2. online the memory as removable page
    The function has not supported yet. It is being developed by Lai as follow:
    http://lkml.indiana.edu/hypermail/linux/kernel/1207.0/01478.html
    If it is supported, I will be able to create movable memory.

3. hot-remove the memory by container device's eject file

Thanks,
Yasuaki Ishimatsu

>
> I am not sure that these patches are useful unless we know where you are
> going with this. If we end up with a situation where we still cannot
> remove physical memory then this patchset is not helpful.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

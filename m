Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id F16F46B0070
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 05:53:24 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D950D3EE0B6
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:53:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C262E45DE52
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:53:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A957945DD74
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:53:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CE211DB802C
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:53:22 +0900 (JST)
Received: from g01jpexchkw02.g01.fujitsu.local (g01jpexchkw02.g01.fujitsu.local [10.0.194.41])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A2681DB803E
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:53:22 +0900 (JST)
Message-ID: <506C0AE8.40702@jp.fujitsu.com>
Date: Wed, 3 Oct 2012 18:52:40 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 0/4] acpi,memory-hotplug : implement framework for hot removing
 memory
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

We are trying to implement a physical memory hot removing function as
following thread.

https://lkml.org/lkml/2012/9/5/201

But there is not enough review to merge into linux kernel.

I think there are following blockades.
  1. no physical memory hot removable system
  2. huge patch-set

If you have a KVM system, we can get rid of 1st blockade. Because
applying following patch, we can create memory hot removable system
on KVM guest.

http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html

2nd blockade is own problem. So we try to divide huge patch into
a small patch in each function as follows: 

 - bug fix
 - acpi framework
 - kernel core

We had already sent bug fix patches.
https://lkml.org/lkml/2012/9/27/39
https://lkml.org/lkml/2012/10/2/83

The patch-set implements a framework for hot removing memory.

The memory device can be removed by 2 ways:
1. send eject request by SCI
2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

In the 1st case, acpi_memory_disable_device() will be called.
In the 2nd case, acpi_memory_device_remove() will be called.
acpi_memory_device_remove() will also be called when we unbind the
memory device from the driver acpi_memhotplug.

acpi_memory_disable_device() has already implemented a code which
offlines memory and releases acpi_memory_info struct . But
acpi_memory_device_remove() has not implemented it yet.

So the patch prepares the framework for hot removing memory and
adds the framework intoacpi_memory_device_remove(). And it prepares
remove_memory(). But the function does nothing because we cannot
support memory hot remove.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

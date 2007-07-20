Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l6K6qBR8030798
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Jul 2007 15:52:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E10DA1B801F
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 15:52:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B32682DC0BC
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 15:52:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A6DC133C01D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 15:52:10 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 135D0133C01F
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 15:52:10 +0900 (JST)
Received: from fjmscan502.ms.jp.fujitsu.com (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm504.ms.jp.fujitsu.com with ESMTP id l6K6pZ9l022380
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 15:51:35 +0900
Date: Fri, 20 Jul 2007 15:53:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][Doc] memory hotplug documentaion
Message-Id: <20070720155346.33ca523b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, 

I'm considering to add text file for memory hotplug to -mm kernel to which memory
unplug base patches are merged now. like Documentation/vm/memory_hotplug
This is not patch style yet.

I wrote this. But I know I'm not a good writer (even in Japanese...) and
I have no skilled reviewer.

This is RFC for memory hotplug documentation. This documentation describes 
how-to-use and current development status. (Of course, I'll update this when
I post patches.) If development status is unnecessary, I'll remove them.

Any comments and questions are helpful. 

Thanks,
-Kame
==
Memory Hotplug
--------------

Last Updated: Jul 20 2007

This document is about memory hotplug including how-to-use and current status.
Because Memory Hotplug is still under development, contents of this text will
be changed often.



1. Introduction
2. SPARSEMEM and Section
3. Hardware(Firmware) Support.
4. Notify memory hotplug event by hand
5. State of memory
6. How to online memory
7. Memory offline and ZONE_MOVABLE
8. How to offline memory
9. Future Work List

Note(1): x86_64's special memory hotplug is not described.
Note(2): This text assumes that sysfs is mounted at /sys.


1. Introduction
------------
Memory Hotplug allows users to increase/decrease the amount of memory.
Generally, there are two purposes.

(A) For changing the amount of memory
(B) For installing/removing DIMM or for helping hardware support of memory
  power consumption reduction or DIMM exchanges, and dynamic hardware
  reconfiguration like NUMA-node-hotadd.

(A) is required by highly virtualized environment and (B) is required by
hardwares which support memory power management.

Linux's memory hotplug divides the memory into a logical group of "section".
Memory Hotplug allows onlining/offlining of sections.

When a user onlines a secion, the whole memory in it are installed into the
system. When a user offlines a section, the whole memory in it is removed from
the system.


2. SPARSEMEM and Section
------------
Memory hotplug uses SPARSEMEM memory model. SPARSEMEM divides the whole memory
into chunks of the same size. The chunk is called as "section". The size of
section is architecture dependent. For example, power uses 16MiB, ia64 uses
1GiB.

Memory hotplug onlines/offlines this "section".

To know the size of section, please read this file
/sys/devices/system/memory/block_size_bytes

This file shows the size of section in byte.

All section has its device information under /sys/devices/system/memory as

/sys/devices/system/memory/memoryXXX/
(XXX is section id.)

Now, XXX is defined as "start_address_of_section/secion_size".

Under each section, you can see 3 files.

/sys/devices/system/memory/memoryXXX/phys_index
/sys/devices/system/memory/memoryXXX/phys_device
/sys/devices/system/memory/memoryXXX/state

'phys_index' : read-only and contains section id, same as XXX.
'state'      : read-write
               at read:  contains online/offline state of memory.
               at write: user can specify "online", "offline" command
'phys_device': read-only: designed to show the name of physical memory device.
               This is not well implemented now.

3. Hardware(Firmware) Support
------------
On x86_64/ia64 platform, memory hotplug by ACPI is supported.

In general, the firmware (ACPI), which supports memory hotplug, defines
memory class object of _HID "PNP0C80". When a notify is asserted to PNP0C80,
Linux's acpi handler does hotadd memory to the system and call hotplug udev
script.This sequence will be done in automatically.

But scripts for memory hotplug is not contained in generic udev package(now).
You may have to write it by yourself or online/offline memory by hand.
Please see "How to online memory", "How to offline memory" in this text.


4. Notify memory hotplug event by hand
------------
In some environment, especially virtualized environment, firmware will not
notify memory hotplug event to the kernel. For such environment, "probe"
interface is supported. This interface depends on CONFIG_ARCH_MEMORY_PROBE.

Now, CONFIG_ARCH_MEMORY_PROBE is supported only by powerpc but it does not
includes highly architecture codes. Please add config if you need "probe"
interface.

Probe interface is located at
/sys/devices/system/memory/probe

You can tell the physical address of new memory to the kernel by

%echo start_address_of_new_memory > /sys/devices/system/memory/probe

Then, [start_address_of_new_memory, start_address_of_new_memory + section_size)
memory range is hot-added. In this case, hotplug script is not called (in
current implementation.). You'll have to online memory by yourself.
Please see "How to online memory" in this text.

5. State of memory
------------
To see (online/offline) state of memory section, read 'state' file.

%cat /sys/device/system/memory/memoryXXX/state


If the memory section is online, you'll read "online".
If the memory section is offline, you'll read "offline".


6. How to online memory
------------
Even if the memory is hot-added, it is not at ready-to-use state.
For using newly added memory, you have to "online" memory section.

For onlining, you have to write "online" to section's state file as:

%echo online > /sys/devices/system/memory/memoryXXX/state

After this, section memoryXXX's state will be 'online'. And the amount of
available memory will be increased.

Currently, newly added memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA).
This may be changed in future.


7. Memory offline and ZONE_MOVABLE
------------
Memory offlining is complicated than memory online. Because memory offline
has to make the whole memory section to be unused, memory offline can be
failed if the section includes memory which is never freed.

In general, memory offline can use 2 techniques.

(1) reclaim and free all memory in the section.
(2) migrate all pages in the section.

In current implementation, Linux's memory offline uses method (2), freeing
the whole pages in the section by page migration. But not all pages are
migratable. Under current Linux, migratable pages are anonymous pages and
page caches. For offlining a section by migration, the kernel has to guarantee
that the section contains just only migratable pages.

Now, a boot option for making a section which consists of migratable pages is
supported. By specifying "kernelcore=" or "movablecore=" boot option, you can
create ZONE_MOVABLE...a zone which is just used for movable pages.
(See also Documentation/kernel-parameters.txt)

Assume the system has "TOTAL" amount of memory at boot time, this boot option
creates ZONE_MOVABLE as following.

1) When kernelcore=YYYY boot option is used,
  Size of memory not for movable pages (not for offline) is YYYY.
  Size of memory for movable pages (for offline) is TOTAL-YYYY.

2) When movablecore=ZZZZ boot option is used,
  Size of memory not for movable pages (not for offline) is TOTAL - YYYY.
  Size of memory for movable pages (for offline) is YYYY.


Note) Unfortunately, there is no information to show which section is belongs
to ZONE_MOVABLE. This is TBD.


8. How to offline memory
------------
You can offline section by sysfs interface as memory onlining.

%echo offline > /sys/devices/system/memory/memoryXXX/state

If offline succeed, state of memory section is changed to be "offline".
If fail, some error core (like -EBUSY) will be returned be the kernel.
Even if a section is not belongs to ZONE_MOVABLE, you can try to offline it.
If it doesn't contain 'unmovable' memory, you'll get success.

A section under ZONE_MOVABLE is considered to be able to be offlined easily.
But under some buzy state, it may return -EBUSY. Even if a memory section
cannot be offlined with -EBUSY, you can retry offline and will be able to
offline (soon?). (For example, a page is referred by some kernel internal call.)

Consideration:
Memory hotplug's design direction is to make possibility of memory offlining
bigger and to guarantee unplugging memory under any situation. But it needs
more work. Returning -EBUSY under some situation may be good because the user
can decide to retry more or not by himself. Currently, memory offlining code
does some amount of retry with 120 secs timeout.

9. Future Work
------------
  - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
    sysctl or new control file.
  - showing memory section and physical device relation ship.
  - showing memory section and node relation ship (maybe good for NUMA)
  - showing memory section is under ZONE_MOVABLE or not
  - test and make it better memory offlining.
  - support HugeTLB page migration and offlining.
  - memmap removing at memory offline.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

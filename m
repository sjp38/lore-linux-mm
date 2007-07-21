Date: Sat, 21 Jul 2007 10:51:19 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC][Doc] memory hotplug documentaion
Message-Id: <20070721105119.761d6a2b.randy.dunlap@oracle.com>
In-Reply-To: <20070720155346.33ca523b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070720155346.33ca523b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Jul 2007 15:53:46 +0900 KAMEZAWA Hiroyuki wrote:

> Hi, 
> 
> I'm considering to add text file for memory hotplug to -mm kernel to which memory
> unplug base patches are merged now. like Documentation/vm/memory_hotplug
> This is not patch style yet.
> 
> I wrote this. But I know I'm not a good writer (even in Japanese...) and
> I have no skilled reviewer.
> 
> This is RFC for memory hotplug documentation. This documentation describes 
> how-to-use and current development status. (Of course, I'll update this when
> I post patches.) If development status is unnecessary, I'll remove them.
> 
> Any comments and questions are helpful. 

I have some typo-like corrections for you below.
Use at your own discretion.


> Thanks,
> -Kame
> ==
> Memory Hotplug
> --------------
> 
> Last Updated: Jul 20 2007
> 
> This document is about memory hotplug including how-to-use and current status.
> Because Memory Hotplug is still under development, contents of this text will
> be changed often.
> 
> 
> 
> 1. Introduction
> 2. SPARSEMEM and Section

                   Sections

> 3. Hardware(Firmware) Support.
> 4. Notify memory hotplug event by hand
> 5. State of memory
> 6. How to online memory
> 7. Memory offline and ZONE_MOVABLE
> 8. How to offline memory
> 9. Future Work List
> 
> Note(1): x86_64's special memory hotplug is not described.
> Note(2): This text assumes that sysfs is mounted at /sys.
> 
> 
> 1. Introduction
> ------------
> Memory Hotplug allows users to increase/decrease the amount of memory.
> Generally, there are two purposes.
> 
> (A) For changing the amount of memory
> (B) For installing/removing DIMM or for helping hardware support of memory

                              DIMMs

>   power consumption reduction or DIMM exchanges, and dynamic hardware
>   reconfiguration like NUMA-node-hotadd.

                         NUMA-node hot-add.

> (A) is required by highly virtualized environment and (B) is required by

                                        environments

> hardwares which support memory power management.

  hardware which supports


> Linux's memory hotplug divides the memory into a logical group of "section".

                                            into logical groups, where
  each group is called a "section".

> Memory Hotplug allows onlining/offlining of sections.
> 
> When a user onlines a secion, the whole memory in it are installed into the

                        section, all memory in it is installed into the

> system. When a user offlines a section, the whole memory in it is removed
 from

                                          all memory in it is removed from

> the system.
> 
> 
> 2. SPARSEMEM and Section

                   Sections

> ------------
> Memory hotplug uses SPARSEMEM memory model. SPARSEMEM divides the whole memory

                 uses the SPARSEMEM                                 entire

> into chunks of the same size. The chunk is called as "section". The size of

                                                    a

> section is architecture dependent. For example, power uses 16MiB, ia64 uses

  a section

> 1GiB.
> 
> Memory hotplug onlines/offlines this "section".
> 
> To know the size of section, please read this file

                      sections, please read this file:

> /sys/devices/system/memory/block_size_bytes
> 
> This file shows the size of section in byte.

                              sections in bytes.

> All section has its device information under /sys/devices/system/memory as

      sections have their device information ...
> 
> /sys/devices/system/memory/memoryXXX/
> (XXX is section id.)
> 
> Now, XXX is defined as "start_address_of_section/secion_size".

                                                   section_size".

Eh?  The "memoryXXX" part contains a slash character?
I hope not.  Can you give an example or be more explicit?


> Under each section, you can see 3 files.
> 
> /sys/devices/system/memory/memoryXXX/phys_index
> /sys/devices/system/memory/memoryXXX/phys_device
> /sys/devices/system/memory/memoryXXX/state
> 
> 'phys_index' : read-only and contains section id, same as XXX.
> 'state'      : read-write
>                at read:  contains online/offline state of memory.
>                at write: user can specify "online", "offline" command
> 'phys_device': read-only: designed to show the name of physical memory device.
>                This is not well implemented now.
> 
> 3. Hardware(Firmware) Support
> ------------
> On x86_64/ia64 platform, memory hotplug by ACPI is supported.
> 
> In general, the firmware (ACPI), which supports memory hotplug, defines

                                drop both commas above

> memory class object of _HID "PNP0C80". When a notify is asserted to PNP0C80,
> Linux's acpi handler does hotadd memory to the system and call hotplug udev

          ACPI                                              calls a

> script.This sequence will be done in automatically.

  script.  This

> But scripts for memory hotplug is not contained in generic udev package(now).

                                 are not
> You may have to write it by yourself or online/offline memory by hand.
> Please see "How to online memory", "How to offline memory" in this text.
> 
> 
> 4. Notify memory hotplug event by hand
> ------------
> In some environment, especially virtualized environment, firmware will not

          environments,

> notify memory hotplug event to the kernel. For such environment, "probe"
> interface is supported. This interface depends on CONFIG_ARCH_MEMORY_PROBE.
> 
> Now, CONFIG_ARCH_MEMORY_PROBE is supported only by powerpc but it does not
> includes highly architecture codes. Please add config if you need "probe"

  contain highly architecture-specific code.

> interface.
> 
> Probe interface is located at
> /sys/devices/system/memory/probe
> 
> You can tell the physical address of new memory to the kernel by
> 
> %echo start_address_of_new_memory > /sys/devices/system/memory/probe

  % echo

> Then, [start_address_of_new_memory, start_address_of_new_memory + section_size)
> memory range is hot-added. In this case, hotplug script is not called (in
> current implementation.). You'll have to online memory by yourself.

          implementation).

> Please see "How to online memory" in this text.
> 
> 5. State of memory
> ------------
> To see (online/offline) state of memory section, read 'state' file.

                                of a memory section, read its 'state' file.

> %cat /sys/device/system/memory/memoryXXX/state

  % cat


> If the memory section is online, you'll read "online".
> If the memory section is offline, you'll read "offline".
> 
> 
> 6. How to online memory
> ------------
> Even if the memory is hot-added, it is not at ready-to-use state.
> For using newly added memory, you have to "online" memory section.

                                                     the memory section.

> For onlining, you have to write "online" to section's state file as:

                                           to the section's

> %echo online > /sys/devices/system/memory/memoryXXX/state

  % echo


> After this, section memoryXXX's state will be 'online'. And the amount of

                                                'online' and the

> available memory will be increased.
> 
> Currently, newly added memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA).
> This may be changed in future.
> 
> 
> 7. Memory offline and ZONE_MOVABLE
> ------------
> Memory offlining is complicated than memory online. Because memory offline

                   is more complicated

> has to make the whole memory section to be unused, memory offline can be

                                       be unused, memory offline can fail

> failed if the section includes memory which is never freed.

  drop 'failed'

> In general, memory offline can use 2 techniques.
> 
> (1) reclaim and free all memory in the section.
> (2) migrate all pages in the section.
> 
> In current implementation, Linux's memory offline uses method (2), freeing

  In the current

> the whole pages in the section by page migration. But not all pages are

  all pages in the section

> migratable. Under current Linux, migratable pages are anonymous pages and
> page caches. For offlining a section by migration, the kernel has to guarantee
> that the section contains just only migratable pages.

                            drop "just"

> Now, a boot option for making a section which consists of migratable pages is
> supported. By specifying "kernelcore=" or "movablecore=" boot option, you can
> create ZONE_MOVABLE...a zone which is just used for movable pages.
> (See also Documentation/kernel-parameters.txt)
> 
> Assume the system has "TOTAL" amount of memory at boot time, this boot option
> creates ZONE_MOVABLE as following.
> 
> 1) When kernelcore=YYYY boot option is used,
>   Size of memory not for movable pages (not for offline) is YYYY.
>   Size of memory for movable pages (for offline) is TOTAL-YYYY.
> 
> 2) When movablecore=ZZZZ boot option is used,
>   Size of memory not for movable pages (not for offline) is TOTAL - YYYY.

                                                                      ZZZZ.

>   Size of memory for movable pages (for offline) is YYYY.

                                                      ZZZZ.


> Note) Unfortunately, there is no information to show which section is belongs

                                                                 drop "is"

> to ZONE_MOVABLE. This is TBD.
> 
> 
> 8. How to offline memory
> ------------
> You can offline section by sysfs interface as memory onlining.

          offline a section by using the same sysfs interface that was
  used in memory onlining.


> %echo offline > /sys/devices/system/memory/memoryXXX/state

  % echo

> If offline succeed, state of memory section is changed to be "offline".

             succeeds, the state of the memory section

> If fail, some error core (like -EBUSY) will be returned be the kernel.

  If it fails, some error code

> Even if a section is not belongs to ZONE_MOVABLE, you can try to offline it.

                    does not belong to

> If it doesn't contain 'unmovable' memory, you'll get success.
> 
> A section under ZONE_MOVABLE is considered to be able to be offlined easily.
> But under some buzy state, it may return -EBUSY. Even if a memory section

                 busy
> cannot be offlined with -EBUSY, you can retry offline and will be able to

                     due to -EBUSY, you can retry offlining it and may be
able to offline it (or not).  (For example, a page is referred to by some


> offline (soon?). (For example, a page is referred by some kernel internal call.)
> 
> Consideration:
> Memory hotplug's design direction is to make possibility of memory offlining

                                          make the possibility

> bigger and to guarantee unplugging memory under any situation. But it needs

  higher (larger)

> more work. Returning -EBUSY under some situation may be good because the user
> can decide to retry more or not by himself. Currently, memory offlining code
> does some amount of retry with 120 secs timeout.

                                     seconds

> 9. Future Work
> ------------
>   - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
>     sysctl or new control file.
>   - showing memory section and physical device relation ship.

                                                 relationship.

>   - showing memory section and node relation ship (maybe good for NUMA)

                                      relationship

>   - showing memory section is under ZONE_MOVABLE or not
>   - test and make it better memory offlining.
>   - support HugeTLB page migration and offlining.
>   - memmap removing at memory offline.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 27 Jul 2007 10:18:46 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC][Doc] memory hotplug documentaion take 2.
Message-Id: <20070727101846.19f01671.randy.dunlap@oracle.com>
In-Reply-To: <20070727230204.E920.Y-GOTO@jp.fujitsu.com>
References: <20070727230204.E920.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007 23:07:45 +0900 Yasunori Goto wrote:

> Change log from take 1.
> - updates against comments from Randy-san (Thanks a lot!)
> - mention about physical/logical phase of hotplug.
>   change sections for it.
> - add description of kernel config option.
> - add description of relationship against ACPI node-hotplug.
> - make patch style.
> - etc.
> 
> 
> -------
>  Documentation/memory-hotplug.txt |  322 +++++++++++++++++++++++++++++++++++++++
>  1 files changed, 322 insertions(+)
> 
> Index: makedocument/Documentation/memory-hotplug.txt
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ makedocument/Documentation/memory-hotplug.txt	2007-07-27 22:31:11.000000000 +0900
> @@ -0,0 +1,322 @@
> +==============
> +Memory Hotplug
> +==============
> +
> +Last Updated: Jul 27 2007
> +
...
> +
> +Note(1): x86_64's has special implementation for memory hotplug.
> +         This test does not describe it.

                 text (?)

> +Note(2): This text assumes that sysfs is mounted at /sys.
> +
> +
> +---------------
> +1. Introduction
> +---------------
> +
...
> +
> +
> +1.2. Phases of memory hotplug
> +---------------
> +There are 2 phases in Memory Hotplug.
> +  1) Physical Memory Hotplug phase
> +  2) Logical Memory Hotplug phase.
> +
> +The First phase is to communicate hardware/firmware and make/erase
> +environment for hotplugged memory. Basically, this phase is necessary
> +for the purpose (B), but this is good phase for communication between
> +highly virtulaized environments too.

          virtualized

> +
> +When memory is hotplugged, the kernel recognizes new memory, makes new memory
> +management tables, and makes sysfs files for new memory's operation.
> +
> +If firmware supports notification of connection of new memory to OS,
> +this phase is triggered automatically. ACPI can notify this event. If not,
> +"probe" operation by system administration works instead of it.

                                              is used instead.

> +(see Section 4.).
> +
> +Logical Memory Hotplug phase is to change memory state into
> +avaiable/unavailable for users. Amount of memory from user's view is
> +changed by this phase. The kernel makes all memory in it as free pages
> +when a memory range is into available.

                          ?? drop "into" ?
or is a memory range always available?  Confusing.

> +
> +In this document, this phase is described online/offline.

                                   described as online/offline.

> +
> +Logical Memory Hotplug phase is trigged by write of sysfs file by system

                                   triggered

> +administrator. When hot-add case, it must be executed after Physical Hotplug

                  For the hot-add case,

> +phase by hand.
> +(However, if you writes udev's hotplug scripts for memory hotplug, these
> + phases can be execute in seamless way.)
> +
> +
> +1.3. Unit of Memory online/offline operation
> +------------
> +Memory hotplug uses SPARSEMEM memory model. SPARSEMEM divides the whole memory
> +into chunks of the same size. The chunk is called a "section". The size of
> +a section is architecture dependent. For example, power uses 16MiB, ia64 uses
> +1GiB. The unit of online/offline operation is "one section". (see Section 3.)
> +
> +To know the size of sections, please read this file:

   To determine the size ...

> +
> +/sys/devices/system/memory/block_size_bytes
> +
> +This file shows the size of sections in byte.
> +
> +-----------------------
> +2. Kernel Configuration
> +-----------------------
> +To use memory hotplug feature, kernel must be compiled with following
> +config options.
> +
> +- For all memory hotplug
> +    Memory model -> Sparse Memory  (CONFIG_SPARSEMEM)
> +    Allow for memory hot-add       (CONFIG_MEMORY_HOTPLUG)
> +
> +- For using remove memory, followings are necessary too

     To enable memory removal, the following are also necessary

> +    Allow for memory hot remove    (CONFIG_MEMORY_HOTREMOVE)
> +    Page Migration                 (CONFIG_MIGRATION)
> +
> +- For ACPI memory hotplug, followings are necessary too

                              the following are also necessary

> +    Memory hotplug (under ACPI Support menu) (CONFIG_ACPI_HOTPLUG_MEMORY)
> +    This option can be kernel module.
> +
> +- As a related configuration, if your box has a feature of NUMA-node hotplug
> +  via ACPI, then this option is necessary too.
> +    ACPI0004,PNP0A05 and PNP0A06 Container Driver (under ACPI Support menu)
> +    (CONFIG_ACPI_CONTAINER).
> +    This option can be kernel module too.
> + 
> +--------------------------------
> +3 sysfs files for memory hotplug
> +--------------------------------
> +All sections have their device information under /sys/devices/system/memory as
> +
> +/sys/devices/system/memory/memoryXXX
> +(XXX is section id.)
> +
> +Now, XXX is defined as start_address_of_section / secion_size.

                                                     section_size.

> +
> +For example, assume 1GiB section size. A device for a memory starts from address

                                                   for memory starting at

> +0x100000000 is /sys/device/system/memory/memory4
> +(0x100000000 / 1Gib = 4)
> +This device covers address range [0x100000000 ... 0x140000000)
> +
> +Under each section, you can see 3 files.
> +
> +/sys/devices/system/memory/memoryXXX/phys_index
> +/sys/devices/system/memory/memoryXXX/phys_device
> +/sys/devices/system/memory/memoryXXX/state
> +
> +'phys_index' : read-only and contains section id, same as XXX.
> +'state'      : read-write
> +               at read:  contains online/offline state of memory.
> +               at write: user can specify "online", "offline" command
> +'phys_device': read-only: designed to show the name of physical memory device.
> +               This is not well implemented now.
> +
> +NOTE: 
> +  These directories/files appear after physical memory hotplug phase.
> +
> +
> +--------------------------------
> +4. Physical memory hot-add phase
> +--------------------------------
> +
> +4.1 Hardware(Firmware) Support
> +------------
> +On x86_64/ia64 platform, memory hotplug by ACPI is supported.
> +
> +In general, the firmware (ACPI) which supports memory hotplug defines
> +memory class object of _HID "PNP0C80". When a notify is asserted to PNP0C80,
> +Linux's ACPI handler does hot-add memory to the system and calls a hotplug udev
> +script. This will be done in automatically.

                             drop "in"

> +
> +But scripts for memory hotplug are not contained in generic udev package(now).
> +You may have to write it by yourself or online/offline memory by hand.
> +Please see "How to online memory", "How to offline memory" in this text.
> +
> +If firmware supports NUMA-node hotplug, and define object of _HID "ACPI0004",

                                               defines an object

> +"PNP0A05", or "PNP0A06", notification is asserted to it, and ACPI hander

                                                                     handler

> +calls hotplug code for all of objects which are defined in it.
> +If memory device is found, memory hotplug code will be called.

...

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

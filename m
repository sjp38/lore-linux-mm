Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 468E36B003A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 05:16:13 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 RESEND 00/18] Arrange hotpluggable memory as ZONE_MOVABLE.
Date: Fri, 2 Aug 2013 17:14:19 +0800
Message-Id: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Rebased to Linux 3.11-rc3, and followed some advice from Toshi Kani.
Please refer to the change log in the end of the comment.

This patch-set aims to solve some problems at system boot time
to enhance memory hotplug functionality.

[Background]

The Linux kernel cannot migrate pages used by the kernel because
of the kernel direct mapping. Since va =3D pa + PAGE=5FOFFSET, if the
physical address is changed, we cannot simply update the kernel
pagetable. On the contrary, we have to update all the pointers
pointing to the virtual address, which is very difficult to do.

In order to do memory hotplug, we should prevent the kernel to use
hotpluggable memory.

In ACPI, there is a table named SRAT(System Resource Affinity Table).
It contains system NUMA info (CPUs, memory ranges, PXM), and also a
flag field indicating which memory ranges are hotpluggable.


[Problem to be solved]

At the very early time when the system is booting, we use a bootmem
allocator, named memblock, to allocate memory for the kernel.
memblock will start to work before the kernel parse SRAT, which
means memblock won't know which memory is hotpluggable before SRAT
is parsed.

So at this time, memblock could allocate hotpluggable memory for
the kernel to use permanently. For example, the kernel may allocate
pagetables in hotpluggable memory, which cannot be freed when the
system is up.

So we have to prevent memblock allocating hotpluggable memory for
the kernel at the early boot time.


[Earlier solutions]

We have tried to parse SRAT earlier, before memblock is ready. To
do this, we also have to do ACPI=5FINITRD=5FTABLE=5FOVERRIDE earlier.
Otherwise the override tables won't be able to effect.

This is not that easy to do because memblock is ready before direct
mapping is setup. So Yinghai split the ACPI=5FINITRD=5FTABLE=5FOVERRIDE
procedure into two steps: find and copy. Please refer to the
following patch-set:
        https://lkml.org/lkml/2013/6/13/587

To this solution, tj gave a lot of comments and the following
suggestions.


[Suggestion from tj]

tj mainly gave the following suggestions:

1. Necessary reordering is OK, but we should not rely on
   reordering to achieve the goal because it makes the kernel
   too fragile.

2. Memory allocated to kernel for temporary usage is OK because
   it will be freed when the system is up. Doing relocation
   for permanent allocated hotpluggable memory will make the
   the kernel more robust.

3. Need to enhance memblock to discover and complain if any
   hotpluggable memory is allocated to kernel.

After a long thinking, we choose not to do the relocation for
the following reasons:

1. It's easy to find out the allocated hotpluggable memory. But
   memblock will merge the adjoined ranges owned by different users
   and used for different purposes. It's hard to find the owners.

2. Different memory has different way to be relocated. I think one
   function for each kind of memory will make the code too messy.

3. Pagetable could be in hotpluggable memory. Relocating pagetable
   is too difficult and risky. We have to update all PUD, PMD pages.
   And also, ACPI=5FINITRD=5FTABLE=5FOVERRIDE and parsing SRAT procedures
   are not long after pagetable is initialized. If we relocate the
   pagetable not long after it was initialized, the code will be
   very ugly.


[Solution in this patch-set]

In this patch-set, we still do the reordering, but in a new way.

1. Improve memblock with flags, so that it is able to differentiate
   memory regions for different usage. And also a MEMBLOCK=5FHOTPLUG
   flag to mark hotpluggable memory.

2. When memblock is ready (memblock=5Fx86=5Ffill() is called), initialize
   acpi=5Fgbl=5Froot=5Ftable=5Flist, fulfill all the ACPI tables' phys addr=
s.
   Now, we have all the ACPI tables' phys addrs provided by firmware.

3. Check if there is a SRAT in initrd file used to override the one
   provided by firmware. If so, get its phys addr.

4. If no override SRAT in initrd, get the phys addr of the SRAT
   provided by firmware.

   Now, we have the phys addr of the to be used SRAT, the one in
   initrd or the one in firmware.

5. Parse only the memory affinities in SRAT, find out all the
   hotpluggable memory regions and mark them in memblock.memory with
   MEMBLOCK=5FHOTPLUG flag.

6. The kernel goes through the current path. Any other related parts,
   such as ACPI=5FINITRD=5FTABLE=5FOVERRIDE path, the current parsing ACPI
   tables pathes, global variable numa=5Fmeminfo, and so on, are not
   modified. They work as before.

7. Make memblock default allocator skip hotpluggable memory.

8. Introduce movablenode boot option to allow users to enable
   and disable this functionality.


In summary, in order to get hotpluggable memory info as early as possible,
this patch-set only parse memory affinities in SRAT one more time right
after memblock is ready, and leave all the other pathes untouched. With
the hotpluggable memory info, we can arrange hotpluggable memory in
ZONE=5FMOVABLE to prevent the kernel to use it.

change log v2 -> v2 RESEND:
According to Toshi's advice:
1. Rename acpi=5Finvalid=5Ftable() to acpi=5Fverify=5Ftable().
2. Rename acpi=5Froot=5Ftable=5Finit() to early=5Facpi=5Fboot=5Ftable=5Fini=
t().
3. Rename INVALID=5FTABLE() to ACPI=5FINVALID=5FTABLE().
4. Check if ramdisk is present in early=5Facpi=5Foverride=5Fsrat().
5. Check if ACPI is disabled in acpi=5Fboot=5Ftable=5Finit().
6. Rebased to Linux 3.11-rc3.

change log v1 -> v2:
1. According to Tejun's advice, make ACPI side report which memory regions
   are hotpluggable, and memblock side handle the memory allocation.
2. Change "movablecore=3Dacpi" boot option to "movablenode" boot option.

Thanks.=20


Tang Chen (17):
  acpi: Print Hot-Pluggable Field in SRAT.
  earlycpio.c: Fix the confusing comment of find=5Fcpio=5Fdata().
  acpi: Remove "continue" in macro INVALID=5FTABLE().
  acpi: Introduce acpi=5Fverify=5Finitrd() to check if a table is invalid.
  x86, ACPICA: Split acpi=5Fboot=5Ftable=5Finit() into two parts.
  x86, acpi, ACPICA: Initialize ACPI root table list earlier.
  x86, ACPI: Also initialize signature and length when parsing root
    table.
  x86: Make get=5Framdisk=5F{image|size}() global.
  x86, acpi: Try to find if SRAT is overrided earlier.
  x86, acpi: Try to find SRAT in firmware earlier.
  x86, acpi, numa, mem=5Fhotplug: Find hotpluggable memory in SRAT memory
    affinities.
  x86, numa, mem=5Fhotplug: Skip all the regions the kernel resides in.
  memblock, numa: Introduce flag into memblock.
  memblock, mem=5Fhotplug: Introduce MEMBLOCK=5FHOTPLUG flag to mark
    hotpluggable regions.
  memblock, mem=5Fhotplug: Make memblock skip hotpluggable regions by
    default.
  mem-hotplug: Introduce movablenode boot option to {en|dis}able using
    SRAT.
  x86, numa, acpi, memory-hotplug: Make movablenode have higher
    priority.

Yasuaki Ishimatsu (1):
  x86: get pg=5Fdata=5Ft's memory from other node

 Documentation/kernel-parameters.txt |   15 ++
 arch/x86/include/asm/setup.h        |   21 +++
 arch/x86/kernel/acpi/boot.c         |   45 ++++---
 arch/x86/kernel/setup.c             |   37 +++---
 arch/x86/mm/numa.c                  |    5 +-
 arch/x86/mm/srat.c                  |   11 +-
 drivers/acpi/acpica/tbutils.c       |   47 ++++++-
 drivers/acpi/acpica/tbxface.c       |   32 +++++
 drivers/acpi/osl.c                  |  252 +++++++++++++++++++++++++++++++=
+---
 drivers/acpi/tables.c               |    7 +-
 include/acpi/acpixf.h               |    6 +
 include/linux/acpi.h                |   22 +++-
 include/linux/memblock.h            |   13 ++
 include/linux/memory=5Fhotplug.h      |    5 +
 lib/earlycpio.c                     |   27 ++--
 mm/memblock.c                       |   92 +++++++++++--
 mm/memory=5Fhotplug.c                 |  104 ++++++++++++++-
 mm/page=5Falloc.c                     |   31 ++++-
 18 files changed, 673 insertions(+), 99 deletions(-)

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

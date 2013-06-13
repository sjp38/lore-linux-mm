Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 7A21C900011
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:06 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: =?UTF-8?q?=5BPart2=20PATCH=20v4=2000/15=5D=20Arrange=20hotpluggable=20memory=20in=20SRAT=20as=20ZONE=5FMOVABLE=2E?=
Date: Thu, 13 Jun 2013 21:03:24 +0800
Message-Id: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In memory hotplug situation, the hotpluggable memory should be
arranged in ZONE=5FMOVABLE because memory in ZONE=5FNORMAL may be
used by kernel, and Linux cannot migrate pages used by kernel.

So we need a way to specify hotpluggable memory as movable. It
should be as easy as possible.

According to ACPI spec 5.0, SRAT table has memory affinity
structure and the structure has Hot Pluggable Filed.=20
See "5.2.16.2 Memory Affinity Structure".

If we use the information, we might be able to specify hotpluggable
memory by firmware. For example, if Hot Pluggable Filed is enabled,
kernel sets the memory as movable memory.

To achieve this goal, we need to do the following:
1. Prevent memblock from allocating hotpluggable memroy for kernel.
   This is done by reserving hotpluggable memory in memblock as the
   folowing steps:
   1) Parse SRAT early enough so that memblock knows which memory
      is hotpluggable.
   2) Add a "flags" member to memblock so that it is able to tell
      which memory is hotpluggable when freeing it to buddy.

2. Free hotpluggable memory to buddy system when memory initialization
   is done.

3. Arrange hotpluggable memory in ZONE=5FMOVABLE.
   (This will cause NUMA performance decreased)

4. Provide a user interface to enable/disable this functionality.
   (This is useful for those who don't use memory hotplug and who don't
    want to lose their NUMA performance.)


This patch-set does the following:
patch1:        Fix a little problem.
patch2:        Have Hot-Pluggable Field in SRAT printed when parsing SRAT.
patch4,5:      Introduce hotpluggable field to numa=5Fmeminfo.
patch6~9:      Introduce flags to memblock, and keep the public APIs protot=
ype
               unmodified.
patch10,11:      Reserve node-life-cycle memory as MEMBLK=5FLOCAL=5FNODE wi=
th memblock.
patch12,13:    Reserve hotpluggable memory as MEMBLK=5FHOTPLUGGABLE with me=
mblock,
               and free it to buddy when memory initialization is done.
patch3,14,15:  Improve "movablecore" boot option to support "movablecore=3D=
acpi".


Change log v3 -> v4:
1. Define flags in memblock as macro directly instead of bit shift.
2. Fix a bug found by Vasilis Liaskovitis, mark nodes which the=20
   kernel resides in correctly.

Change log v2 -> v3:
1. As Chen Gong <gong.chen@linux.intel.com> noticed that=20
   memblock=5Falloc=5Ftry=5Fnid() will call panic() if it fails to
   allocate memory, so remove the return value check in=20
   setup=5Fnode=5Fdata() in patch1.
2. Did not movable find=5Fusable=5Fzone=5Ffor=5Fmovable() forward=20
   to initialize movable=5Fzone. Fixed in patch12.
3. Did not transform reserved->regions[i].base to its PFN=20
   in find=5Fzone=5Fmovable=5Fpfns=5Ffor=5Fnodes(). Fixed in patch12.

Change log v1 -> v2:
1. Fix a bug in patch10: forgot to update start and end value.
2. Add new patch8: make alloc=5Flow=5Fpages be able to call
   memory=5Fadd=5Fphysaddr=5Fto=5Fnid().


This patch-set is based on Yinghai's
"x86, ACPI, numa: Parse numa info early" patch-set.
Please refer to:
v1: https://lkml.org/lkml/2013/3/7/642
v2: https://lkml.org/lkml/2013/3/10/47
v3: https://lkml.org/lkml/2013/4/4/639
v4: https://lkml.org/lkml/2013/4/11/829

And Yinghai's patch did the following things:
1) Parse SRAT early enough.
2=EF=BC=89Allocate pagetable pages in local node.

Tang Chen (14):
  acpi: Print Hot-Pluggable Field in SRAT.
  page=5Falloc, mem-hotplug: Improve movablecore to {en|dis}able using
    SRAT.
  x86, numa, acpi, memory-hotplug: Introduce hotplug info into struct
    numa=5Fmeminfo.
  x86, numa, acpi, memory-hotplug: Consider hotplug info when cleanup
    numa=5Fmeminfo.
  memblock, numa: Introduce flag into memblock.
  x86, numa: Synchronize nid info in memblock.reserve with
    numa=5Fmeminfo.
  x86, numa: Save nid when reserve memory into memblock.reserved[].
  x86, numa, mem-hotplug: Mark nodes which the kernel resides in.
  x86, numa: Move memory=5Fadd=5Fphysaddr=5Fto=5Fnid() to CONFIG=5FNUMA.
  x86, numa, memblock: Introduce MEMBLK=5FLOCAL=5FNODE to mark and reserve
    node-life-cycle data.
  x86, acpi, numa, mem-hotplug: Introduce MEMBLK=5FHOTPLUGGABLE to mark
    and reserve hotpluggable memory.
  x86, memblock, mem-hotplug: Free hotpluggable memory reserved by
    memblock.
  x86, numa, acpi, memory-hotplug: Make movablecore=3Dacpi have higher
    priority.
  doc, page=5Falloc, acpi, mem-hotplug: Add doc for movablecore=3Dacpi boot
    option.

Yasuaki Ishimatsu (1):
  x86: get pg=5Fdata=5Ft's memory from other node

 Documentation/kernel-parameters.txt |    8 ++
 arch/x86/include/asm/numa.h         |    3 +-
 arch/x86/kernel/apic/numaq=5F32.c     |    2 +-
 arch/x86/mm/amdtopology.c           |    3 +-
 arch/x86/mm/init.c                  |   16 +++-
 arch/x86/mm/numa.c                  |  118 +++++++++++++++++++++++++++++---
 arch/x86/mm/numa=5Finternal.h         |    1 +
 arch/x86/mm/srat.c                  |   13 ++--
 include/linux/memblock.h            |   13 ++++
 include/linux/memory=5Fhotplug.h      |    3 +
 include/linux/mm.h                  |    9 +++
 mm/memblock.c                       |  129 +++++++++++++++++++++++++++++++=
----
 mm/nobootmem.c                      |    3 +
 mm/page=5Falloc.c                     |   44 +++++++++++-
 14 files changed, 325 insertions(+), 40 deletions(-)

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

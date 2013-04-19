Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id EA4846B009A
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 05:29:22 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: =?UTF-8?q?=5BPATCH=20v1=2000/12=5D=20Arrange=20hotpluggable=20memory=20in=20SRAT=20as=20ZONE=5FMOVABLE=2E?=
Date: Fri, 19 Apr 2013 17:31:37 +0800
Message-Id: <1366363909-12771-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com, dhowells@redhat.com, davej@redhat.com, agordeev@redhat.com, suresh.b.siddha@intel.com, mst@redhat.com, yinghai@kernel.org, penberg@kernel.org, jacob.shin@amd.com, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, rientjes@google.com, tj@kernel.org, laijs@cn.fujitsu.com, hannes@cmpxchg.org, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com
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
patch6,7:      Introduce flags to memblock, and keep the public APIs protot=
ype
               unmodified.
patch8:        Reserve node-life-cycle memory as MEMBLK=5FLOCAL=5FNODE with=
 memblock.
patch9,10:     Reserve hotpluggable memory as MEMBLK=5FHOTPLUGGABLE with me=
mblock,
               and free it to buddy when memory initialization is done.
patch3,11,12:  Improve "movablecore" boot option to support "movablecore=3D=
acpi".


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


Tang Chen (11):
  acpi: Print Hot-Pluggable Field in SRAT.
  page=5Falloc, mem-hotplug: Improve movablecore to {en|dis}able using
    SRAT.
  x86, numa, acpi, memory-hotplug: Introduce hotplug info into struct
    numa=5Fmeminfo.
  x86, numa, acpi, memory-hotplug: Consider hotplug info when cleanup
    numa=5Fmeminfo.
  memblock, numa: Introduce flag into memblock.
  x86, numa, mem-hotplug: Mark nodes which the kernel resides in.
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
 arch/x86/mm/numa.c                  |   60 ++++++++++++++---
 arch/x86/mm/numa=5Finternal.h         |    1 +
 arch/x86/mm/srat.c                  |   11 ++-
 include/linux/memblock.h            |   16 +++++
 include/linux/memory=5Fhotplug.h      |    3 +
 mm/memblock.c                       |  127 ++++++++++++++++++++++++++++++-=
---
 mm/nobootmem.c                      |    3 +
 mm/page=5Falloc.c                     |   37 ++++++++++-
 13 files changed, 253 insertions(+), 37 deletions(-)

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

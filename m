Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8D36B03B5
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:04:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o89so824616wrc.1
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:04:16 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id s142si11637627wme.166.2017.04.10.04.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 04:04:14 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id l28so3841275wre.0
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:04:14 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH -v2 0/9] mm: make movable onlining suck less
Date: Mon, 10 Apr 2017 13:03:42 +0200
Message-Id: <20170410110351.12215-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Tobias Regnery <tobias.regnery@gmail.com>

Hi,
The last version of this series has been posted here [1]. It has seen
some more serious testing (thanks to Reza Arbab) and fixes for the found
issues. I have also decided to drop patch 1 [2] because it turned out to
be more complicated than I initially thought [3]. Few more patches were
added to deal with expectation on zone/node initialization.

I have rebased on top of the current mmotm-2017-04-07-15-53. It
conflicts with HMM because it touches memory hotplug as
well. We have discussed [4] with JA(C)rA'me and he agreed to
rebase on top of this rework [5] so I have reverted his series
before applyig mine. I will help him to resolve the resulting
conflicts. You can find the whole series including the HMM revers in
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git branch
attempts/rewrite-mem_hotplug

Motivation:
Movable onlining is a real hack with many downsides - mainly
reintroduction of lowmem/highmem issues we used to have on 32b systems -
but it is the only way to make the memory hotremove more reliable which
is something that people are asking for.

The current semantic of memory movable onlinening is really cumbersome,
however. The main reason for this is that the udev driven approach is
basically unusable because udev races with the memory probing while only
the last memory block or the one adjacent to the existing zone_movable
are allowed to be onlined movable. In short the criterion for the
successful online_movable changes under udev's feet. A reliable udev
approach would require a 2 phase approach where the first successful
movable online would have to check all the previous blocks and online
them in descending order. This is hard to be considered sane.

This patchset aims at making the onlining semantic more usable. First of
all it allows to online memory movable as long as it doesn't clash with
the existing ZONE_NORMAL. That means that ZONE_NORMAL and ZONE_MOVABLE
cannot overlap. Currently I preserve the original ordering semantic so
the zone always precedes the movable zone but I have plans to remove this
restriction in future because it is not really necessary.

First 3 patches are cleanups which should be ready to be merged right
away (unless I have missed something subtle of course).

Patch 4 deals with ZONE_DEVICE dependencies down the __add_pages path.

Patch 5 deals with implicit assumptions of register_one_node on pgdat
initialization.

Patch 6 is the core of the change. In order to make it easier to review
I have tried it to be as minimalistic as possible and the large code
removal is moved to patch 9.

Patch 7 is a trivial follow up cleanup. Patch 8 fixes sparse warnings
and finally patch 9 removes the unused code.

I have tested the patches in kvm:
# qemu-system-x86_64 -enable-kvm -monitor pty -m 2G,slots=4,maxmem=4G -numa node,mem=1G -numa node,mem=1G ...

and then probed the additional memory by
(qemu) object_add memory-backend-ram,id=mem1,size=1G
(qemu) device_add pc-dimm,id=dimm1,memdev=mem1

Then I have used this simple script to probe the memory block by hand
# cat probe_memblock.sh
#!/bin/sh

BLOCK_NR=$1

# echo $((0x100000000+$BLOCK_NR*(128<<20))) > /sys/devices/system/memory/probe

# for i in $(seq 10); do sh probe_memblock.sh $i; done
# grep . /sys/devices/system/memory/memory3?/valid_zones 2>/dev/null 
/sys/devices/system/memory/memory33/valid_zones:Normal Movable                                                                                                                                                     
/sys/devices/system/memory/memory34/valid_zones:Normal Movable                                                                                                                                                     
/sys/devices/system/memory/memory35/valid_zones:Normal Movable                                                                                                                                                     
/sys/devices/system/memory/memory36/valid_zones:Normal Movable                                                                                                                                                     
/sys/devices/system/memory/memory37/valid_zones:Normal Movable                                                                                                                                                     
/sys/devices/system/memory/memory38/valid_zones:Normal Movable                                                                                                                                                     
/sys/devices/system/memory/memory39/valid_zones:Normal Movable

The main difference to the original implementation is that all new
memblocks can be both online_kernel and online_movable initially
because there is no clash obviously. For the comparison the original
implementation would have

/sys/devices/system/memory/memory33/valid_zones:Normal                                                                                                                                                     
/sys/devices/system/memory/memory34/valid_zones:Normal                                                                                                                                                     
/sys/devices/system/memory/memory35/valid_zones:Normal                                                                                                                                                     
/sys/devices/system/memory/memory36/valid_zones:Normal                                                                                                                                                     
/sys/devices/system/memory/memory37/valid_zones:Normal                                                                                                                                                     
/sys/devices/system/memory/memory38/valid_zones:Normal                                                                                                                                                     
/sys/devices/system/memory/memory39/valid_zones:Normal Movable

Now
# echo online_movable > /sys/devices/system/memory/memory34/state                                                                                                                                      
# grep . /sys/devices/system/memory/memory3?/valid_zones 2>/dev/null                                                                                                                                   
/sys/devices/system/memory/memory33/valid_zones:Normal Movable                                                                                                                                                     
/sys/devices/system/memory/memory34/valid_zones:Movable                                                                                                                                                            
/sys/devices/system/memory/memory35/valid_zones:Movable                                                                                                                                                            
/sys/devices/system/memory/memory36/valid_zones:Movable                                                                                                                                                            
/sys/devices/system/memory/memory37/valid_zones:Movable                                                                                                                                                            
/sys/devices/system/memory/memory38/valid_zones:Movable
/sys/devices/system/memory/memory39/valid_zones:Movable

Block 33 can still be online both kernel and movable while all
the remaining can be only movable.
/proc/zonelist says
Node 0, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
--
Node 0, zone  Movable
  pages free     32753
        min      85
        low      117
        high     149
        spanned  32768
        present  32768

A new memblock at a lower address will result in a new memblock (32)
which will still allow both Normal and Movable.
# sh probe_memblock.sh 0
# grep . /sys/devices/system/memory/memory3[2-5]/valid_zones 2>/dev/null
/sys/devices/system/memory/memory32/valid_zones:Normal Movable
/sys/devices/system/memory/memory33/valid_zones:Normal Movable
/sys/devices/system/memory/memory34/valid_zones:Movable
/sys/devices/system/memory/memory35/valid_zones:Movable

and online_kernel will convert it to the zone normal properly
while 33 can be still onlined both ways.
# echo online_kernel > /sys/devices/system/memory/memory32/state
# grep . /sys/devices/system/memory/memory3[2-5]/valid_zones 2>/dev/null
/sys/devices/system/memory/memory32/valid_zones:Normal
/sys/devices/system/memory/memory33/valid_zones:Normal Movable
/sys/devices/system/memory/memory34/valid_zones:Movable
/sys/devices/system/memory/memory35/valid_zones:Movable

/proc/zoneinfo will now tell
Node 0, zone   Normal
  pages free     65441
        min      165
        low      230
        high     295
        spanned  65536
        present  65536
--
Node 0, zone  Movable
  pages free     32740
        min      82
        low      114
        high     146
        spanned  32768
        present  32768

so both zones have one memblock spanned and present.

Onlining 39 should associate this block to the movable zone
# echo online > /sys/devices/system/memory/memory39/state

/proc/zoneinfo will now tell
Node 0, zone   Normal
  pages free     32765
        min      80
        low      112
        high     144
        spanned  32768
        present  32768
--
Node 0, zone  Movable
  pages free     65501
        min      160
        low      225
        high     290
        spanned  196608
        present  65536

so we will have a movable zone which spans 6 memblocks, 2 present and 4
representing a hole.

Offlining both movable blocks will lead to the zone with no present
pages which is the expected behavior I believe.
# echo offline > /sys/devices/system/memory/memory39/state
# echo offline > /sys/devices/system/memory/memory34/state
# grep -A6 "Movable\|Normal" /proc/zoneinfo 
Node 0, zone   Normal
  pages free     32735
        min      90
        low      122
        high     154
        spanned  32768
        present  32768
--
Node 0, zone  Movable
  pages free     0
        min      0
        low      0
        high     0
        spanned  196608
        present  0

Any thoughts, complains, suggestions?

As a bonus we will get a nice cleanup in the memory hotplug codebase
 arch/ia64/mm/init.c            |  11 +-
 arch/powerpc/mm/mem.c          |  12 +-
 arch/s390/mm/init.c            |  32 +--
 arch/sh/mm/init.c              |  10 +-
 arch/x86/mm/init_32.c          |   7 +-
 arch/x86/mm/init_64.c          |  11 +-
 drivers/base/memory.c          |  74 ++++---
 drivers/base/node.c            |  58 ++----
 include/linux/memory_hotplug.h |  19 +-
 include/linux/mmzone.h         |  16 +-
 include/linux/node.h           |  35 +++-
 kernel/memremap.c              |   6 +-
 mm/memory_hotplug.c            | 451 ++++++++++++++---------------------------
 mm/page_alloc.c                |   8 +-
 mm/sparse.c                    |   3 +-
 15 files changed, 284 insertions(+), 469 deletions(-)

Shortlog says:
Michal Hocko (9):
      mm: remove return value from init_currently_empty_zone
      mm, memory_hotplug: use node instead of zone in can_online_high_movable
      mm: drop page_initialized check from get_nid_for_pfn
      mm, memory_hotplug: get rid of is_zone_device_section
      mm, memory_hotplug: split up register_one_node
      mm, memory_hotplug: do not associate hotadded memory to zones until online
      mm, memory_hotplug: replace for_device by want_memblock in arch_add_memory
      mm, memory_hotplug: fix the section mismatch warning
      mm, memory_hotplug: remove unused cruft after memory hotplug rework

[1] http://lkml.kernel.org/r/20170330115454.32154-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170331073954.GF27098@dhcp22.suse.cz
[3] http://lkml.kernel.org/r/20170405081400.GE6035@dhcp22.suse.cz
[4] http://lkml.kernel.org/r/20170407121349.GB16392@dhcp22.suse.cz
[5] http://lkml.kernel.org/r/20170407182752.GA17852@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

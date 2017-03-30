Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 980E06B0397
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:55:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u18so9786919wrc.10
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:02 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id q3si3615471wma.147.2017.03.30.04.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 04:55:00 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id k6so10132876wre.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:00 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/6] mm: make movable onlining suck less
Date: Thu, 30 Mar 2017 13:54:48 +0200
Message-Id: <20170330115454.32154-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michal Hocko <mhocko@suse.com>

Hi,
I have posted a crude RFC for this rework [1] and there didn't seem any
objections so I have split up the patch into smaller chunks which will
make the review easier hopefully.

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

The series consists of 4 cleanup patches which should be ready to be
merged right away (unless I have missed something subtle of course).

Patch 5 is the core of the change. In order to make it easier to review
I have tried it to be as minimalistic as possible and the large code
removal is moved to patch 6.

I would appreciate if s390 folks could take a look at patch 4 and the
arch_add_memory because I am not sure I've grokked what they wanted to
achieve there completely.

I have tested the patches in kvm:
# qemu-system-x86_64 -enable-kvm -monitor pty -m 2G,slots=4,maxmem=4G -numa node,mem=1G -numa node,mem=1G ...

and then probed the additional memory by
(qemu) object_add memory-backend-ram,id=mem1,size=1G
(qemu) device_add pc-dimm,id=dimm1,memdev=mem1

Then I have used this simple script to probe the memory block by hand
# cat probe_memblock.sh
#!/bin/sh

BLOCK_NR=$1

echo $((0x100000000+$BLOCK_NR*(128<<20))) > /sys/devices/system/memory/probe

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
 arch/ia64/mm/init.c            |  10 +-
 arch/powerpc/mm/mem.c          |  12 +-
 arch/s390/mm/init.c            |  32 +---
 arch/sh/mm/init.c              |  10 +-
 arch/tile/mm/init.c            |  30 ---
 arch/x86/mm/init_32.c          |   7 +-
 arch/x86/mm/init_64.c          |  11 +-
 drivers/base/memory.c          |  52 ++---
 include/linux/memory_hotplug.h |  17 +-
 include/linux/mmzone.h         |  13 +-
 kernel/memremap.c              |   5 +-
 mm/memory_hotplug.c            | 423 ++++++++++++-----------------------------
 mm/page_alloc.c                |  11 +-
 mm/sparse.c                    |   3 +-
 14 files changed, 186 insertions(+), 450 deletions(-)

Shortlog says:
Michal Hocko (6):
      mm: get rid of zone_is_initialized
      mm, tile: drop arch_{add,remove}_memory
      mm: remove return value from init_currently_empty_zone
      mm, memory_hotplug: use node instead of zone in can_online_high_movable
      mm, memory_hotplug: do not associate hotadded memory to zones until online
      mm, memory_hotplug: remove unused cruft after memory hotplug rework

[1] http://lkml.kernel.org/r/20170315091347.GA32626@dhcp22.suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

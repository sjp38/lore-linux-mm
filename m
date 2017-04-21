Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFD06B0038
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:05:42 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 19so127347372ioo.9
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:05:42 -0700 (PDT)
Received: from mail-io0-f195.google.com (mail-io0-f195.google.com. [209.85.223.195])
        by mx.google.com with ESMTPS id y82si11025247ioi.73.2017.04.21.05.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:05:40 -0700 (PDT)
Received: by mail-io0-f195.google.com with SMTP id x86so29646709ioe.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:05:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH -v3 0/13] mm: make movable onlining suck less
Date: Fri, 21 Apr 2017 14:05:03 +0200
Message-Id: <20170421120512.23960-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Tobias Regnery <tobias.regnery@gmail.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Hi,
The last version of this series has been posted here [1]. It has seen
some more testing (thanks to Reza Arbab and Igor Mammedov[2]), Jerome's
and Vlastimil's review resulted in few fixes mostly folded in their
respected patches.
There are 4 more patches (patch 6+ in this series).  I have checked the
most prominent pfn walkers to skip over offline holes and now and I feel
more comfortable to have this merged. All the reported issues should be
fixed

There is still a lot of work on top - namely this implementation doesn't
support reonlining to a different zone on the zones boundaries but I
will do that in a separate series because this one is getting quite
large already and it should work reasonably well now.

Joonsoo had some worries about pfn_valid and suggested to change its
semantic to return false on offline holes but I would be rally worried
to change a established semantic used by a lot of code and so I have
introuduced pfn_to_online_page helper instead. If this is seen as a
controversial point I would rather drop pfn_to_online_page and related
patches as they are not stictly necessary because the code would be
similarly broken as now wrt. offline holes.

This is a rebase on top of linux-next (next-20170418) and the full
series is in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
try attempts/rewrite-mem_hotplug branch.

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

Patches 6-10 deal with offline holes in the zone for pfn walkers. I
hope I got all of them right but people familiar with compaction should
double check this.

Patch 11 is the core of the change. In order to make it easier to review
I have tried it to be as minimalistic as possible and the large code
removal is moved to patch 14.

Patch 12 is a trivial follow up cleanup. Patch 13 fixes sparse warnings
and finally patch 14 removes the unused code.

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

As a bonus we will get a nice cleanup in the memory hotplug codebase.
 arch/ia64/mm/init.c            |  11 +-
 arch/powerpc/mm/mem.c          |  12 +-
 arch/s390/mm/init.c            |  32 +--
 arch/sh/mm/init.c              |  10 +-
 arch/x86/mm/init_32.c          |   7 +-
 arch/x86/mm/init_64.c          |  11 +-
 drivers/base/memory.c          |  79 +++----
 drivers/base/node.c            |  58 ++----
 include/linux/memory_hotplug.h |  40 +++-
 include/linux/mmzone.h         |  44 +++-
 include/linux/node.h           |  35 +++-
 kernel/memremap.c              |   6 +-
 mm/compaction.c                |   5 +-
 mm/memory_hotplug.c            | 455 ++++++++++++++---------------------------
 mm/page_alloc.c                |  13 +-
 mm/page_isolation.c            |  26 ++-
 mm/sparse.c                    |  48 ++++-
 17 files changed, 407 insertions(+), 485 deletions(-)

Shortlog says:
Michal Hocko (13):
      mm: remove return value from init_currently_empty_zone
      mm, memory_hotplug: use node instead of zone in can_online_high_movable
      mm: drop page_initialized check from get_nid_for_pfn
      mm, memory_hotplug: get rid of is_zone_device_section
      mm, memory_hotplug: split up register_one_node
      mm, memory_hotplug: consider offline memblocks removable
      mm: consider zone which is not fully populated to have holes
      mm, compaction: skip over holes in __reset_isolation_suitable
      mm: __first_valid_page skip over offline pages
      mm, memory_hotplug: do not associate hotadded memory to zones until online
      mm, memory_hotplug: replace for_device by want_memblock in arch_add_memory
      mm, memory_hotplug: fix the section mismatch warning
      mm, memory_hotplug: remove unused cruft after memory hotplug rework

[1] http://lkml.kernel.org/r/20170410110351.12215-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170410162749.7d7f31c1@nial.brq.redhat.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

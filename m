Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 078F56B000A
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:12:08 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w201-v6so16067305qkb.16
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:12:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s29-v6si4830711qth.44.2018.05.23.08.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 08:12:06 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by device driver
Date: Wed, 23 May 2018 17:11:41 +0200
Message-Id: <20180523151151.6730-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

This is now the !RFC version. I did some additional tests and inspected
all memory notifiers. At least page_ext and kasan need fixes.

==========

I am right now working on a paravirtualized memory device ("virtio-mem").
These devices control a memory region and the amount of memory available
via it. Memory will not be indicated/added/onlined via ACPI and friends,
the device driver is responsible for it.

When the device driver starts up, it will add and online the requested
amount of memory from its assigned physical memory region. On request, it
can add (online) either more memory or try to remove (offline) memory. As
it will be a virtio module, we also want to be able to have it as a loadable
kernel module.

Such a device can be thought of like a "resizable DIMM" or a "huge
number of 4MB DIMMS" that can be automatically managed.

As we want to be able to add/remove small chunks of memory to a VM without
fragmenting guest memory ("it's not what the guest pays for" and "what if
the hypervisor wants to use huge pages"), it looks like we can do that
under Linux in a 4MB granularity by using online_pages()/offline_pages()

We add a segment and online only 4MB blocks of it on demand. So the other
memory might not be accessible. For kdump and onlining/offlining code, we
have to mark pages as offline before a new segment is visible to the system
(e.g. as these pages might not be backed by real memory in the hypervisor).

This is not a balloon driver. Main differences:
- We can add more memory to a VM without having to use mixture of
  technologies - e.g. ACPI for plugging, balloon for unplugging (in contrast
  to virtio-balloon).
- The device is responsible for its own memory only - will not inflate on
  any system memory. (in contrast to all balloons)
- Works on a coarser granularity (e.g. 4MB because that's what we can
  online/offline in Linux). We are not using the buddy allocator when
  unplugging but really search for chunks of memory we can offline. We
  actually can support arbitrary block sizes. (in contrast to all balloons)
- That's why we don't fragment guest memory.
- A device can belong to exactly one NUMA node. This way we can online/
  offline memory in a fine granularity NUMA aware. Even if the guest does
  not even know how to spell NUMA. (in contrast to all balloons)
- Architectures that don't have proper memory hotplug interfaces (e.g. s390x)
  get memory hotplug support. I have a prototype for s390x.
- Once all 4MB chunks of a memory block are offline, we can remove the
  memory block and therefore the struct pages. (in contrast to all balloons)

This essentially allows us to add/remove 4MB chunks to/from a VM. Especially
without caring about the future when adding memory ("If I add a 128GB DIMM
I can only unplug 128GB again") or running into limits ("If I want my VM to
grow to 4TB, I have to plug at least 16GB per DIMM").

Future work:
 - Performance improvements
 - Be smarter about which blocks to offline first (e.g. free ones)
 - Automatically manage assignemnt to NORMAL/MOVABLE zone to make
   unplug more likely to succeed.

I will post the next prototype of virtio-mem shortly. This time for real :)

==========

RFCv2 -> v1:
- "mm: introduce and use PageOffline()"
-- fix set_page_address() handling for WANT_PAGE_VIRTUAL
- Include "mm/page_ext.c: support online/offline of memory < section size"
- Include "kasan: prepare for online/offline of different start/size"
- Include "mm/memory_hotplug: onlining pages can only fail due to notifiers"


David Hildenbrand (10):
  mm: introduce and use PageOffline()
  mm/page_ext.c: support online/offline of memory < section size
  kasan: prepare for online/offline of different start/size
  kdump: include PAGE_OFFLINE_MAPCOUNT_VALUE in VMCOREINFO
  mm/memory_hotplug: limit offline_pages() to sizes we can actually
    handle
  mm/memory_hotplug: onlining pages can only fail due to notifiers
  mm/memory_hotplug: print only with DEBUG_VM in online/offline_pages()
  mm/memory_hotplug: allow to control onlining/offlining of memory by a
    driver
  mm/memory_hotplug: teach offline_pages() to not try forever
  mm/memory_hotplug: allow online/offline memory by a kernel module

 arch/powerpc/platforms/powernv/memtrace.c |   2 +-
 drivers/base/memory.c                     |  25 +--
 drivers/base/node.c                       |   1 -
 drivers/xen/balloon.c                     |   2 +-
 include/linux/memory.h                    |   2 +-
 include/linux/memory_hotplug.h            |  20 ++-
 include/linux/mm.h                        |  10 ++
 include/linux/page-flags.h                |   9 ++
 kernel/crash_core.c                       |   1 +
 mm/kasan/kasan.c                          | 107 ++++++++-----
 mm/memory_hotplug.c                       | 180 +++++++++++++++++-----
 mm/page_alloc.c                           |  32 ++--
 mm/page_ext.c                             |   9 +-
 mm/sparse.c                               |  25 ++-
 14 files changed, 315 insertions(+), 110 deletions(-)

-- 
2.17.0

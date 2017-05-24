Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3A26B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 08:24:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v42so13623wrc.12
        for <linux-mm@kvack.org>; Wed, 24 May 2017 05:24:18 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d24si18876920wrb.106.2017.05.24.05.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 05:24:17 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id k15so45847393wmh.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 05:24:17 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] remove CONFIG_MOVABLE_NODE
Date: Wed, 24 May 2017 14:24:09 +0200
Message-Id: <20170524122411.25212-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
I am continuing to cleanup the memory hotplug code and
CONFIG_MOVABLE_NODE seems dubious at best. The following two patches
simply removes the flag and make it de-facto always enabled.

The current semantic of the config option is twofold 1) it automatically
binds hotplugable nodes to have memory in zone_movable by default when
movable_node is enabled 2) forbids memory hotplug to online all the memory
as movable when !CONFIG_MOVABLE_NODE.

The later restriction is quite dubious because there is no clear cut of
how much normal memory do we need for a reasonable system operation. A
single memory block which is sufficient to allow further movable
onlines is far from sufficient (e.g a node with >2GB and memblocks
128MB will fill up this zone with struct pages leaving nothing for
other allocations). Removing the config option will not only reduce the
configuration space it also removes quite some code.

The semantic of the movable_node command line parameter is preserved.

The first patch removes the restriction mentioned above and the second
one simply removes all the CONFIG_MOVABLE_NODE related stuff.

Shortlog
Michal Hocko (2):
      mm, memory_hotplug: drop artificial restriction on online/offline
      mm, memory_hotplug: drop CONFIG_MOVABLE_NODE

Diffstat:
 Documentation/admin-guide/kernel-parameters.txt |  7 ++-
 drivers/base/node.c                             |  4 --
 include/linux/memblock.h                        | 18 -------
 include/linux/nodemask.h                        |  4 --
 mm/Kconfig                                      | 26 -----------
 mm/memblock.c                                   |  2 -
 mm/memory_hotplug.c                             | 62 -------------------------
 mm/page_alloc.c                                 |  2 -
 8 files changed, 5 insertions(+), 120 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

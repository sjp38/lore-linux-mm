Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B06783204
	for <linux-mm@kvack.org>; Wed, 10 May 2017 00:43:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g12so4969271wrg.15
        for <linux-mm@kvack.org>; Tue, 09 May 2017 21:43:19 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id 130si2993868wmq.94.2017.05.09.21.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 21:43:17 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id g12so4967830wrg.2
        for <linux-mm@kvack.org>; Tue, 09 May 2017 21:43:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
From: Dan Williams <dan.j.williams@gmail.com>
Date: Tue, 9 May 2017 21:43:16 -0700
Message-ID: <CAA9_cmexLPT4m_TEh69fC_OqBD4n4bND-vz33qoKSgXm_Q72Cw@mail.gmail.com>
Subject: Re: [PATCH -v3 0/13] mm: make movable onlining suck less
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Tobias Regnery <tobias.regnery@gmail.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Fri, Apr 21, 2017 at 5:05 AM, Michal Hocko <mhocko@kernel.org> wrote:
> Hi,
> The last version of this series has been posted here [1]. It has seen
> some more testing (thanks to Reza Arbab and Igor Mammedov[2]), Jerome's
> and Vlastimil's review resulted in few fixes mostly folded in their
> respected patches.
> There are 4 more patches (patch 6+ in this series).  I have checked the
> most prominent pfn walkers to skip over offline holes and now and I feel
> more comfortable to have this merged. All the reported issues should be
> fixed
>
> There is still a lot of work on top - namely this implementation doesn't
> support reonlining to a different zone on the zones boundaries but I
> will do that in a separate series because this one is getting quite
> large already and it should work reasonably well now.
>
> Joonsoo had some worries about pfn_valid and suggested to change its
> semantic to return false on offline holes but I would be rally worried
> to change a established semantic used by a lot of code and so I have
> introuduced pfn_to_online_page helper instead. If this is seen as a
> controversial point I would rather drop pfn_to_online_page and related
> patches as they are not stictly necessary because the code would be
> similarly broken as now wrt. offline holes.
>
> This is a rebase on top of linux-next (next-20170418) and the full
> series is in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> try attempts/rewrite-mem_hotplug branch.
>
[..]
> Any thoughts, complains, suggestions?
>
> As a bonus we will get a nice cleanup in the memory hotplug codebase.
>  arch/ia64/mm/init.c            |  11 +-
>  arch/powerpc/mm/mem.c          |  12 +-
>  arch/s390/mm/init.c            |  32 +--
>  arch/sh/mm/init.c              |  10 +-
>  arch/x86/mm/init_32.c          |   7 +-
>  arch/x86/mm/init_64.c          |  11 +-
>  drivers/base/memory.c          |  79 +++----
>  drivers/base/node.c            |  58 ++----
>  include/linux/memory_hotplug.h |  40 +++-
>  include/linux/mmzone.h         |  44 +++-
>  include/linux/node.h           |  35 +++-
>  kernel/memremap.c              |   6 +-
>  mm/compaction.c                |   5 +-
>  mm/memory_hotplug.c            | 455 ++++++++++++++---------------------------
>  mm/page_alloc.c                |  13 +-
>  mm/page_isolation.c            |  26 ++-
>  mm/sparse.c                    |  48 ++++-
>  17 files changed, 407 insertions(+), 485 deletions(-)
>
> Shortlog says:
> Michal Hocko (13):
>       mm: remove return value from init_currently_empty_zone
>       mm, memory_hotplug: use node instead of zone in can_online_high_movable
>       mm: drop page_initialized check from get_nid_for_pfn
>       mm, memory_hotplug: get rid of is_zone_device_section
>       mm, memory_hotplug: split up register_one_node
>       mm, memory_hotplug: consider offline memblocks removable
>       mm: consider zone which is not fully populated to have holes
>       mm, compaction: skip over holes in __reset_isolation_suitable
>       mm: __first_valid_page skip over offline pages
>       mm, memory_hotplug: do not associate hotadded memory to zones until online
>       mm, memory_hotplug: replace for_device by want_memblock in arch_add_memory
>       mm, memory_hotplug: fix the section mismatch warning
>       mm, memory_hotplug: remove unused cruft after memory hotplug rework
>
> [1] http://lkml.kernel.org/r/20170410110351.12215-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20170410162749.7d7f31c1@nial.brq.redhat.com
>
>

The latest "attempts/rewrite-mem_hotplug" branch passes my regression
testing if I cherry-pick the following x86/mm fixes from mainline:

e6ab9c4d4377 x86/mm/64: Fix crash in remove_pagetable()
71389703839e mm, zone_device: Replace {get, put}_zone_device_page()
with a single reference to fix pmem crash

You can add:

Tested-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

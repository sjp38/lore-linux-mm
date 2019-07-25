Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79473C761A9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D5722238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D5722238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B3AA6B000A; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 788B46B0007; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F5476B026B; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D25A26B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:02:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so32430112ede.0
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=jopev64SMwdFM4yuCR4GCYDrplfSzkLZAxHiyL25AAc=;
        b=pKv9o3rr++ajZ57rKDkfx3RobJlLkts8s9MlE8DpunQTPG2fItn0N6KFMe6j6ROrLl
         np9U4RpS1Y/FnLZ0Gm4XpzXUVTkGbLp//eMDVuEKwcU7zfvMIr2mUSmw4DjydiOR+tw9
         3pVP5DfGDvM2sZPEKWm24yH/5yRX8o0NdViWe+4+jOuVia0A+AWDn1BsxgRX9A73YzLg
         OdWkniPJlO6q3qEasyIO792vTQW7mbG1myclNDyctUOkN+HAlBLsDTQn/HjqRyroP6G6
         saiQA8f8PmRT7SAGSPzX/LRZ3rbWopeoR5QEwVhruCtGEcOMmdX81v1VbKquhofXk8TL
         pHAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXBDI/5aggXy3pWjlb19yrC1QgmfZnVj3ruJEVKdqgNwg0rVdTc
	84gne4Js0o638xY6VDXXQc7f1UPMrimdxZxLd0eGdFB47pL/FfeVfGRenUpm9lT0zv8HJMgY9rX
	bP3qwMvCT4rx1g60OJeBqsocjn7zkx7zVB2AoCfvTUh4iedhRc8O0n2OuCIZbMQvtRA==
X-Received: by 2002:a50:91e5:: with SMTP id h34mr76340695eda.72.1564070537400;
        Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCX56JWCzsS4DI9nqAd4Rid8a0VxZDujQKkl69b6n97WVk7wiWhTOYVpp17/6KhNsmtA20
X-Received: by 2002:a50:91e5:: with SMTP id h34mr76340548eda.72.1564070535870;
        Thu, 25 Jul 2019 09:02:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564070535; cv=none;
        d=google.com; s=arc-20160816;
        b=OaNCbYMn1wy7ERAfvht4RHKEgU4kOtVr3ro4DJEExaUbNAEhIrPjSjl6dC6ZsJhLAP
         qSm9J4UBqrraCIhheSkCS6L9ZB6BPCZD67AU0QECcrZld+6hZE8fXfbJ9OI4ZO9PPexq
         /ljJ5cDTbGGmYJP2u3CuyzS5Mn9UF5x/8o9RwZgx0kpBKKcKEWQJDoYL7ZEGbYcKri7N
         jybmn1zpmhVvyuvxDVl6h8au2nt+YI/h/ryA/Sa+0tmXOrBrl27K3lJaY+zVKDSoMklS
         F9StbJVTpG3Dtyuwqmeuk1+EanWl9HpPe/l2xOFJgzBfAoq0t+Dc6e4nc4n1MnNsVa73
         6FLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=jopev64SMwdFM4yuCR4GCYDrplfSzkLZAxHiyL25AAc=;
        b=BaLhL7QgEYpBIAi987HFzZFtjVdaRAPN/BL96eP7p4AZ4cMjQSJWj6t478UVrvRJ5r
         iJVk9dWu5FD/NLUwb2BXH+SJ2xNMzJWvebxR93Y+4WpSonDwj3R1XXWrPHiYb/GUkTOH
         MsDUmmChmmV8AG/F6ga4prjAukXs6nwqlxnZ4+PjiK+YmkspgjT41/FszutZwq/MApzD
         O+Q/FIIrYTCxB/Nxd5RouTk3tP9XmvRO6qiNtNuF/xscg9pYUOTxI0ZRVV1koFLu+Lu2
         jdPNlxwZOPc5SlQG+nbw7xNT2b/48HK6Qt6/4h1AU9RK0oPInlvE01D83WGuCqkUERZz
         KOUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oq6si9636143ejb.160.2019.07.25.09.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:02:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EE14BAFC6;
	Thu, 25 Jul 2019 16:02:14 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	anshuman.khandual@arm.com,
	Jonathan.Cameron@huawei.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v3 0/5] Allocate memmap from hotadded memory
Date: Thu, 25 Jul 2019 18:02:02 +0200
Message-Id: <20190725160207.19579-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here we go with v3.

v3 -> v2:
        * Rewrite about vmemmap pages handling.
          Prior to this version, I was (ab)using hugepages fields
          from struct page, while here I am officially adding a new
          sub-page type with the fields I need.

        * Drop MHP_MEMMAP_{MEMBLOCK,DEVICE} in favor of MHP_MEMMAP_ON_MEMORY.
          While I am still not 100% if this the right decision, and while I
          still see some gaining in having MHP_MEMMAP_{MEMBLOCK,DEVICE},
          having only one flag ease the code.
          If the user wants to allocate memmaps per memblock, it'll
          have to call add_memory() variants with memory-block granularity.

          If we happen to have a more clear usecase MHP_MEMMAP_MEMBLOCK
          flag in the future, so user does not have to bother about the way
          it calls add_memory() variants, but only pass a flag, we can add it.
          Actually, I already had the code, so add it in the future is going to be
          easy.

        * Granularity check when hot-removing memory.
          Just checking that the granularity is the same.

[Testing]

 - x86_64: small and large memblocks (128MB, 1G and 2G)

So far, only acpi memory hotplug uses the new flag.
The other callers can be changed depending on their needs.

[Coverletter]

This is another step to make memory hotplug more usable. The primary
goal of this patchset is to reduce memory overhead of the hot-added
memory (at least for SPARSEMEM_VMEMMAP memory model). The current way we use
to populate memmap (struct page array) has two main drawbacks:

a) it consumes an additional memory until the hotadded memory itself is
   onlined and
b) memmap might end up on a different numa node which is especially true
   for movable_node configuration.

a) it is a problem especially for memory hotplug based memory "ballooning"
   solutions when the delay between physical memory hotplug and the
   onlining can lead to OOM and that led to introduction of hacks like auto
   onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
   policy for the newly added memory")).

b) can have performance drawbacks.

One way to mitigate all these issues is to simply allocate memmap array
(which is the largest memory footprint of the physical memory hotplug)
from the hot-added memory itself. SPARSEMEM_VMEMMAP memory model allows
us to map any pfn range so the memory doesn't need to be online to be
usable for the array. See patch 3 for more details.
This feature is only usable when CONFIG_SPARSEMEM_VMEMMAP is set.

[Overall design]:

Implementation wise we reuse vmem_altmap infrastructure to override
the default allocator used by vmemap_populate. Once the memmap is
allocated we need a way to mark altmap pfns used for the allocation.
If MHP_MEMMAP_ON_MEMORY flag was passed, we set up the layout of the
altmap structure at the beginning of __add_pages(), and then we call
mark_vmemmap_pages().

MHP_MEMMAP_ON_MEMORY flag parameter will specify to allocate memmaps
from the hot-added range.
If callers wants memmaps to be allocated per memory block, it will
have to call add_memory() variants in memory-block granularity
spanning the whole range, while if it wants to allocate memmaps
per whole memory range, just one call will do.

Want to add 384MB (3 sections, 3 memory-blocks)
e.g:

add_memory(0x1000, size_memory_block);
add_memory(0x2000, size_memory_block);
add_memory(0x3000, size_memory_block);

or

add_memory(0x1000, size_memory_block * 3);

One thing worth mention is that vmemmap pages residing in movable memory is not a
show-stopper for that memory to be offlined/migrated away.
Vmemmap pages are just ignored in that case and they stick around until sections
referred by those vmemmap pages are hot-removed.

Oscar Salvador (5):
  mm,memory_hotplug: Introduce MHP_MEMMAP_ON_MEMORY
  mm: Introduce a new Vmemmap page-type
  mm,sparse: Add SECTION_USE_VMEMMAP flag
  mm,memory_hotplug: Allocate memmap from the added memory range for
    sparse-vmemmap
  mm,memory_hotplug: Allow userspace to enable/disable vmemmap

 arch/powerpc/mm/init_64.c      |   7 ++
 arch/s390/mm/init.c            |   6 ++
 arch/x86/mm/init_64.c          |  10 +++
 drivers/acpi/acpi_memhotplug.c |   3 +-
 drivers/base/memory.c          |  35 +++++++++-
 drivers/dax/kmem.c             |   2 +-
 drivers/hv/hv_balloon.c        |   2 +-
 drivers/s390/char/sclp_cmd.c   |   2 +-
 drivers/xen/balloon.c          |   2 +-
 include/linux/memory_hotplug.h |  37 ++++++++--
 include/linux/memremap.h       |   2 +-
 include/linux/mm.h             |  17 +++++
 include/linux/mm_types.h       |   5 ++
 include/linux/mmzone.h         |   8 ++-
 include/linux/page-flags.h     |  19 +++++
 mm/compaction.c                |   7 ++
 mm/memory_hotplug.c            | 153 +++++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c                |  26 ++++++-
 mm/page_isolation.c            |  14 +++-
 mm/sparse.c                    | 116 ++++++++++++++++++++++++++++++-
 20 files changed, 441 insertions(+), 32 deletions(-)

-- 
2.12.3


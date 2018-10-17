Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6ADB86B0003
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 19:54:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i81-v6so28412666pfj.1
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 16:54:05 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 202-v6si17961131pgb.63.2018.10.17.16.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 16:54:03 -0700 (PDT)
Subject: [mm PATCH v4 0/6] Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Wed, 17 Oct 2018 16:54:02 -0700
Message-ID: <20181017235043.17213.92459.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

This patchset is essentially a refactor of the page initialization logic
that is meant to provide for better code reuse while providing a
significant improvement in deferred page initialization performance.

In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
memory per node I have seen the following. In the case of regular memory
initialization the deferred init time was decreased from 3.75s to 1.06s on
average. For the persistent memory the initialization time dropped from
24.17s to 19.12s on average. This amounts to a 253% improvement for the
deferred memory initialization performance, and a 26% improvement in the
persistent memory initialization performance.

I have called out the improvement observed with each patch.

v1->v2:
    Fixed build issue on PowerPC due to page struct size being 56
    Added new patch that removed __SetPageReserved call for hotplug
v2->v3:
    Rebased on latest linux-next
    Removed patch that had removed __SetPageReserved call from init
    Added patch that folded __SetPageReserved into set_page_links
    Tweaked __init_pageblock to use start_pfn to get section_nr instead of pfn
v3->v4:
    Updated patch description and comments for mm_zero_struct_page patch
        Replaced "default" with "case 64"
        Removed #ifndef mm_zero_struct_page
    Fixed typo in comment that ommited "_from" in kerneldoc for iterator
    Added Reviewed-by for patches reviewed by Pavel
    Added Acked-by from Michal Hocko
    Added deferred init times for patches that affect init performance
    Swapped patches 5 & 6, pulled some code/comments from 4 into 5
        Did this as reserved bit wasn't used in deferred memory init

---

Alexander Duyck (6):
      mm: Use mm_zero_struct_page from SPARC on all 64b architectures
      mm: Drop meminit_pfn_in_nid as it is redundant
      mm: Use memblock/zone specific iterator for handling deferred page init
      mm: Move hot-plug specific memory init into separate functions and optimize
      mm: Add reserved flag setting to set_page_links
      mm: Use common iterator for deferred_init_pages and deferred_free_pages


 arch/sparc/include/asm/pgtable_64.h |   30 --
 include/linux/memblock.h            |   58 ++++
 include/linux/mm.h                  |   50 +++
 mm/memblock.c                       |   63 ++++
 mm/page_alloc.c                     |  569 +++++++++++++++++++++--------------
 5 files changed, 513 insertions(+), 257 deletions(-)

--

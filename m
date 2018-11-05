Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC8F6B0010
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:19:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id d7-v6so10655619pfj.6
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:19:27 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id k190-v6si34117926pgk.261.2018.11.05.13.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:19:26 -0800 (PST)
Subject: [mm PATCH v5 0/7] Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 05 Nov 2018 13:19:25 -0800
Message-ID: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

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
v4->v5:
    Updated Acks/Reviewed-by
    Rebased on latest linux-next
    Split core bits of zone iterator patch from MAX_ORDER_NR_PAGES init

---

Alexander Duyck (7):
      mm: Use mm_zero_struct_page from SPARC on all 64b architectures
      mm: Drop meminit_pfn_in_nid as it is redundant
      mm: Implement new zone specific memblock iterator
      mm: Initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections
      mm: Move hot-plug specific memory init into separate functions and optimize
      mm: Add reserved flag setting to set_page_links
      mm: Use common iterator for deferred_init_pages and deferred_free_pages


 arch/sparc/include/asm/pgtable_64.h |   30 --
 include/linux/memblock.h            |   38 ++
 include/linux/mm.h                  |   50 +++
 mm/memblock.c                       |   63 ++++
 mm/page_alloc.c                     |  567 +++++++++++++++++++++--------------
 5 files changed, 492 insertions(+), 256 deletions(-)

--

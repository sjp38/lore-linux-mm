Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 549AC6B5A6A
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:52:50 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 89so5050558ple.19
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:52:50 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s11si5832718pgk.344.2018.11.30.13.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 13:52:48 -0800 (PST)
Subject: [mm PATCH v6 0/7] Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 30 Nov 2018 13:52:48 -0800
Message-ID: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
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

Note: This patch set is meant as a replacment for the v5 set that is already
      in the MM tree.
      
      I had considered just doing incremental changes but Pavel at the time
      had suggested I submit it as a whole set, however that was almost 3
      weeks ago so if incremental changes are preferred let me know and
      I can submit the changes as incremental updates.

      I appologize for the delay in submitting this follow-on set. I had been
      trying to address the DAX PageReserved bit issue at the same time but
      that is taking more time than I anticipated so I decided to push this
      before the code sits too much longer.

      Commit bf416078f1d83 ("mm/page_alloc.c: memory hotplug: free pages as 
      higher order") causes issues with the revert of patch 7. It was
      necessary to replace all instances of __free_pages_boot_core with
      __free_pages_core.

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
v5->v6:
    Rebased on linux-next with previous v5 reverted
    Drop the "This patch" or "This change" from patch desriptions.
    Cleaned up patch descriptions for patches 3 & 4
    Fixed kerneldoc for __next_mem_pfn_range_in_zone
    Updated several Reviewed-by, and incorporated suggestions from Pavel
    Added __init_single_page_nolru to patch 5 to consolidate code
    Refactored iterator in patch 7 and fixed several issues

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
 include/linux/memblock.h            |   41 +++
 include/linux/mm.h                  |   50 +++
 mm/memblock.c                       |   64 ++++
 mm/page_alloc.c                     |  571 +++++++++++++++++++++--------------
 5 files changed, 498 insertions(+), 258 deletions(-)

--

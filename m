Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3BF6B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:26:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h9-v6so15392858pgs.11
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:26:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id bb10-v6si11218652plb.359.2018.10.15.13.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 13:26:51 -0700 (PDT)
Subject: [mm PATCH v3 0/6] Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 15 Oct 2018 13:26:49 -0700
Message-ID: <20181015202456.2171.88406.stgit@localhost.localdomain>
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

In my testing I have seen a 60% reduction in the time needed for deferred
memory initialization on two different x86_64 based test systems I have. In
addition this provides a slight improvement for the persistent memory 
initialization, the improvement is about 15% from what I can
tell and that is mostly due to combining the setting of the reserved flag
into a number of other page->flags values that could be constructed outside
of the main initialization loop itself.

The biggest gains of this patchset come from not having to test each pfn
multiple times to see if it is valid and if it is actually a part of the
node being initialized.

v1->v2:
    Fixed build issue on PowerPC due to page struct size being 56
    Added new patch that removed __SetPageReserved call for hotplug
v2->v3:
    Removed patch that had removed __SetPageReserved call from init
    Tweaked __init_pageblock to use start_pfn to get section_nr instead of pfn
    Added patch that folded __SetPageReserved into set_page_links
    Rebased on latest linux-next

---

Alexander Duyck (6):
      mm: Use mm_zero_struct_page from SPARC on all 64b architectures
      mm: Drop meminit_pfn_in_nid as it is redundant
      mm: Use memblock/zone specific iterator for handling deferred page init
      mm: Move hot-plug specific memory init into separate functions and optimize
      mm: Use common iterator for deferred_init_pages and deferred_free_pages
      mm: Add reserved flag setting to set_page_links


 arch/sparc/include/asm/pgtable_64.h |   30 --
 include/linux/memblock.h            |   58 ++++
 include/linux/mm.h                  |   43 +++
 mm/memblock.c                       |   63 ++++
 mm/page_alloc.c                     |  572 +++++++++++++++++++++--------------
 5 files changed, 510 insertions(+), 256 deletions(-)

--

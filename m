Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 006426B0010
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 11:12:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r81-v6so9122907pfk.11
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 08:12:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c17-v6si7855581pgp.299.2018.10.05.08.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 08:11:59 -0700 (PDT)
Subject: [mm PATCH 0/5] Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 05 Oct 2018 08:11:57 -0700
Message-ID: <20181005151006.17473.83040.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

This patchset is essentially a refactor of the page initialization logic
that is meant to provide for better code reuse while providing a
significant improvement in deferred page initialization performance.

In my testing I have seen a 60% reduction in the time needed for deferred
memory initialization on two different x86_64 based test systems I have. In
addition this provides a very slight improvement for the hotplug memory 
initialization, although the improvement doesn't exceed 5% from what I can
tell and that is to be expected since most of the changes related to
hotplug init are mostly just code clean-up to allow for reuse.

The biggest gains of this patchset come from not having to test each pfn
multiple times to see if it is valid and if it is actually a part of the
node being initialized.

---

Alexander Duyck (5):
      mm: Use mm_zero_struct_page from SPARC on all 64b architectures
      mm: Drop meminit_pfn_in_nid as it is redundant
      mm: Use memblock/zone specific iterator for handling deferred page init
      mm: Move hot-plug specific memory init into separate functions and optimize
      mm: Use common iterator for deferred_init_pages and deferred_free_pages


 arch/sparc/include/asm/pgtable_64.h |   30 --
 include/linux/memblock.h            |   58 ++++
 include/linux/mm.h                  |   33 ++
 mm/memblock.c                       |   63 ++++
 mm/page_alloc.c                     |  555 +++++++++++++++++++++--------------
 5 files changed, 485 insertions(+), 254 deletions(-)

--

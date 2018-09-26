Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0068E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 19:29:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u13-v6so746280pfm.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 16:29:11 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d7-v6si360746pln.68.2018.09.26.16.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 16:29:09 -0700 (PDT)
Subject: [RFC mm PATCH 0/5] mm: Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Wed, 26 Sep 2018 16:28:20 -0700
Message-ID: <20180926232117.17365.72207.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, dan.j.williams@intel.com, willy@infradead.org, mingo@kernel.org, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, ldufour@linux.vnet.ibm.com, davem@davemloft.net, kirill.shutemov@linux.intel.com

This patchset is essentially a refactor of the page initialization logic
to provide for better code reuse while providing a significant improvement
in deferred page initialization performance.

In my testing I have seen a 3:1 reduction in the time needed for deferred
memory initialization on two different x86_64 based test systems I have.

In addition this provides a very slight improvement for the hotplug memory 
initialization, although the improvement doesn't exceed 5% from what I can
tell and that is to be expected since most of the changes related to
hotplug initialization are just code clean-up to allow for reuse. I had
been considering using a large memset for the entire pageblock I was
initializing which showed a significant speedup for persistent memory init
however that showed no improvements to a slight regression for regular
deferred initialization of standard memory.

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A961A6B0006
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:37:57 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x9-v6so1973487qto.18
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:37:57 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i1-v6si3662296qvm.272.2018.07.12.13.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 13:37:56 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v5 0/5] sparse_init rewrite
Date: Thu, 12 Jul 2018 16:37:25 -0400
Message-Id: <20180712203730.8703-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

Changelog:
v5 - v4
	- Fixed the issue that was reported on ppc64 when
	  CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER is removed
	- Consolidated the new buffer allocation between vmemmap
	  and non-vmemmap variants of sparse layout.
	- Removed all review-by comments, because I had to do
	  significant amount of changes compared to previous version
	  and need another round of review.
	- I also would appreciate if those who reported problems with
	  PPC64 could test this change.
v4 - v3
	- Addressed comments from Dave Hansen
v3 - v1
	- Fixed two issues found by Baoquan He
v1 - v2
	- Addressed comments from Oscar Salvador

In sparse_init() we allocate two large buffers to temporary hold usemap and
memmap for the whole machine. However, we can avoid doing that if we
changed sparse_init() to operated on per-node bases instead of doing it on
the whole machine beforehand.

As shown by Baoquan
http://lkml.kernel.org/r/20180628062857.29658-1-bhe@redhat.com

The buffers are large enough to cause machine stop to boot on small memory
systems.

Another benefit of these changes is that they also obsolete
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER.

Pavel Tatashin (5):
  mm/sparse: abstract sparse buffer allocations
  mm/sparse: use the new sparse buffer functions in non-vmemmap
  mm/sparse: move buffer init/fini to the common place
  mm/sparse: add new sparse_init_nid() and sparse_init()
  mm/sparse: delete old sprase_init and enable new one

 include/linux/mm.h  |   7 +-
 mm/Kconfig          |   4 -
 mm/sparse-vmemmap.c |  59 +--------
 mm/sparse.c         | 300 +++++++++++++++-----------------------------
 4 files changed, 105 insertions(+), 265 deletions(-)

-- 
2.18.0

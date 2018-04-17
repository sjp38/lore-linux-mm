Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id F086E6B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:09:33 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k15so15931467ioc.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:09:33 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a184-v6si2291299ita.4.2018.04.16.19.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:09:32 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/3] Interface for higher order contiguous allocations
Date: Mon, 16 Apr 2018 19:09:12 -0700
Message-Id: <20180417020915.11786-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

These patches came out of the "[RFC] mmap(MAP_CONTIG)" discussions at:
http://lkml.kernel.org/r/21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com

One suggestion in that thread was to create a friendlier interface that
could be used by drivers and others outside core mm code to allocate a
contiguous set of pages.  The alloc_contig_range() interface is used for
this purpose today by CMA and gigantic page allocation.  However, this is
not a general purpose interface.  So, wrap alloc_contig_range() in the
more general interface:

struct page *find_alloc_contig_pages(unsigned int order, gfp_t gfp, int nid,
                                        nodemask_t *nodemask)

This interface is essentially the same functionality provided by the
hugetlb specific routine alloc_gigantic_page().  After creating the
interface, change alloc_gigantic_page() to call find_alloc_contig_pages()
and delete all the supporting code in hugetlb.c.

A new use case for allocating contiguous memory has been identified in
Intel(R) Resource Director Technology Cache Pseudo-Locking.

Mike Kravetz (3):
  mm: change type of free_contig_range(nr_pages) to unsigned long
  mm: add find_alloc_contig_pages() interface
  mm/hugetlb: use find_alloc_contig_pages() to allocate gigantic pages

 include/linux/gfp.h | 14 +++++++-
 mm/cma.c            |  2 +-
 mm/hugetlb.c        | 87 ++++--------------------------------------------
 mm/page_alloc.c     | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 110 insertions(+), 88 deletions(-)

-- 
2.13.6

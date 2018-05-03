Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73AE66B0011
	for <linux-mm@kvack.org>; Thu,  3 May 2018 19:29:53 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id e64-v6so15578593vkd.5
        for <linux-mm@kvack.org>; Thu, 03 May 2018 16:29:53 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i140-v6si5177414vke.160.2018.05.03.16.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 16:29:51 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 0/4] Interface for higher order contiguous allocations
Date: Thu,  3 May 2018 16:29:31 -0700
Message-Id: <20180503232935.22539-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

A respin of of the series to address these issues:

- fix issues found by kbuild
- find_alloc_contig_pages() should take nr_pages as argument instead of
  page order (Vlastimil and Michal).
- Cleaned up migratetype handling (Vlastimil and Michal).
- Use pfn_to_online_page instead of pfn_to_page as suggested by Michal.
  Also added comment about minimal number of conditions checked in
  contig_pfn_range_valid().
- When scanning pfns in zone, take pgdat_resize_lock() instead of
  zone->lock (Michal)

Also, 
- Separate patch to change type of free_contig_range(nr_pages) to an
  unsigned long so that it is consistent with other uses of nr_pages.
- Separate patch to optionally validate migratetype during pageblock
  isolation.
- Make find_alloc_contig_pages() work for smaller size allocation by
  simply calling __alloc_pages_nodemask().

Vlastimil and Michal brought up the issue of allocation alignment.  The
routine will currently align to 'nr_pages' (which is the requested size
argument).  It does this by examining and trying to allocate the first
nr_pages aligned/nr_pages sized range.  If this fails, it moves on to the
next nr_pages aligned/nr_pages sized range until success or all potential
ranges are exhausted.  If we allow an alignment to be specified, we will
need to potentially check all alignment aligned/nr_pages sized ranges.
In the worst case where alignment = PAGE_SIZE, this could result in huge
increase in the number of ranges to check.
To help cut down on the number of ranges to check, we could identify the
first page that causes a range allocation failure and start the next
range at the next aligned boundary.  I tried this, and we still end up
with a huge number of ranges and wasted CPU cycles.
This series did not add an alignment option.  Allocations are aligned to
nr_pages as described above.  If someone can thing of a good way to support
an alignment argument, I am open to implementing/adding it.

As described before,
These patches came out of the "[RFC] mmap(MAP_CONTIG)" discussions at:
http://lkml.kernel.org/r/21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com

One suggestion in that thread was to create a friendlier interface that
could be used by drivers and others outside core mm code to allocate a
contiguous set of pages.  The alloc_contig_range() interface is used for
this purpose today by CMA and gigantic page allocation.  However, this is
not a general purpose interface.  So, wrap alloc_contig_range() in the
more general interface:

struct page *find_alloc_contig_pages(unsigned long nr_pages, gfp_t gfp,
					int nid, nodemask_t *nodemask)

This interface is essentially the same functionality provided by the
hugetlb specific routine alloc_gigantic_page().  After creating the
interface, change alloc_gigantic_page() to call find_alloc_contig_pages()
and delete all the supporting code in hugetlb.c.

A new use case for allocating contiguous memory has been identified in
Intel(R) Resource Director Technology Cache Pseudo-Locking.

Mike Kravetz (4):
  mm: change type of free_contig_range(nr_pages) to unsigned long
  mm: check for proper migrate type during isolation
  mm: add find_alloc_contig_pages() interface
  mm/hugetlb: use find_alloc_contig_pages() to allocate gigantic pages

 include/linux/gfp.h            |  14 +++-
 include/linux/page-isolation.h |   8 +--
 mm/cma.c                       |   2 +-
 mm/hugetlb.c                   |  87 ++--------------------
 mm/memory_hotplug.c            |   2 +-
 mm/page_alloc.c                | 159 +++++++++++++++++++++++++++++++++++++----
 mm/page_isolation.c            |  40 ++++++++---
 7 files changed, 200 insertions(+), 112 deletions(-)

-- 
2.13.6

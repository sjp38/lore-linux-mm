Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 982BB6B0007
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 17:21:23 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id k19so7308518ita.8
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 14:21:23 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 201si172092ioe.181.2018.02.12.14.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 14:21:22 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/3] Interface for higher order contiguous allocations
Date: Mon, 12 Feb 2018 14:20:53 -0800
Message-Id: <20180212222056.9735-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

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

No underlying changes are made to increase the likelihood that a contiguous
set of pages can be found and allocated.  Therefore, any user of this
interface must deal with failure.  The hope is that this interface will be
able to satisfy some use cases today.

If the "rate of failure" is too high to be useful, then more work can be put
into methods to help increase the rate of successful allocations.  Such a
proposal was recently sent by Christoph Lameter "[RFC] Protect larger order
pages from breaking up":
http://lkml.kernel.org/r/alpine.DEB.2.20.1802091311090.3059@nuc-kabylake

find_alloc_contig_pages() uses the same logic that exists today for scanning
zones to look for contiguous ranges suitable for gigantic pages.  The last
patch in the series changes gigantic page allocation to use the new interface.

Mike Kravetz (3):
  mm: make start_isolate_page_range() fail if already isolated
  mm: add find_alloc_contig_pages() interface
  mm/hugetlb: use find_alloc_contig_pages() to allocate gigantic pages

 include/linux/gfp.h | 12 +++++++
 mm/hugetlb.c        | 88 ++++--------------------------------------------
 mm/page_alloc.c     | 97 +++++++++++++++++++++++++++++++++++++++++++++++++----
 mm/page_isolation.c | 10 +++++-
 4 files changed, 118 insertions(+), 89 deletions(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

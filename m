Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF5FA6B0038
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 21:46:34 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k69so2862643ioi.13
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 18:46:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e185si5883320itb.97.2017.10.11.18.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 18:46:33 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/3] Add mmap(MAP_CONTIG) support
Date: Wed, 11 Oct 2017 18:46:08 -0700
Message-Id: <20171012014611.18725-1-mike.kravetz@oracle.com>
In-Reply-To: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

The following is a 'possible' way to add such functionality.  I just
did what was easy and pre-allocated contiguous pages which are used
to populate the mapping.  I did not use any of the higher order
allocators such as alloc_contig_range.  Therefore, it is limited to
allocations of MAX_ORDER size.  Also, the allocations should probably
be done outside mmap_sem but that was the easiest place to do it in
this quick and easy POC.

I just wanted to throw out some code to get further ideas.  It is far
from complete.

Mike Kravetz (3):
  mm/map_contig: Add VM_CONTIG flag to vma struct
  mm/map_contig: Use pre-allocated pages for VM_CONTIG mappings
  mm/map_contig: Add mmap(MAP_CONTIG) support

 include/linux/mm.h              |  1 +
 include/uapi/asm-generic/mman.h |  1 +
 kernel/fork.c                   |  2 +-
 mm/memory.c                     | 13 +++++-
 mm/mmap.c                       | 94 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 109 insertions(+), 2 deletions(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

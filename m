Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6D196B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 19:56:52 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k56so708253qtc.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 16:56:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z2si11637232qkf.132.2017.10.03.16.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 16:56:51 -0700 (PDT)
Subject: [RFC] mmap(MAP_CONTIG)
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
Date: Tue, 3 Oct 2017 16:56:42 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>

At Plumbers this year, Guy Shattah and Christoph Lameter gave a presentation
titled 'User space contiguous memory allocation for DMA' [1].  The slides
point out the performance benefits of devices that can take advantage of
larger physically contiguous areas.

When such physically contiguous allocations are done today, they are done
within drivers themselves in an ad-hoc manner.  In addition to allocations
for DMA, allocations of this type are also performed for buffers used by
coprocessors and other acceleration engines.

As mentioned in the presentation, posix specifies an interface to obtain
physically contiguous memory.  This is via typed memory objects as described
in the posix_typed_mem_open() man page.  Since Linux today does not follow
the posix typed memory object model, adding infrastructure for contiguous
memory allocations seems to be overkill.  Instead, a proposal was suggested
to add support via a mmap flag: MAP_CONTIG.

mmap(MAP_CONTIG) would have the following semantics:
- The entire mapping (length size) would be backed by physically contiguous
  pages.
- If 'length' physically contiguous pages can not be allocated, then mmap
  will fail.
- MAP_CONTIG only works with MAP_ANONYMOUS mappings.
- MAP_CONTIG will lock the associated pages in memory.  As such, the same
  privileges and limits that apply to mlock will also apply to MAP_CONTIG.
- A MAP_CONTIG mapping can not be expanded.
- At fork time, private MAP_CONTIG mappings will be converted to regular
  (non-MAP_CONTIG) mapping in the child.  As such a COW fault in the child
  will not require a contiguous allocation.

Some implementation considerations:
- alloc_contig_range() or similar will be used for allocations larger
  than MAX_ORDER.
- MAP_CONTIG should imply MAP_POPULATE.  At mmap time, all pages for the
  mapping must be 'pre-allocated', and they can only be used for the mapping,
  so it makes sense to 'fault in' all pages.
- Using 'pre-allocated' pages in the fault paths may be intrusive.
- We need to keep keep track of those pre-allocated pages until the vma is
  tore down, especially if free_contig_range() must be called.

Thoughts?
- Is such an interface useful?
- Any other ideas on how to achieve the same functionality?
- Any thoughts on implementation?

I have started down the path of pre-allocating contiguous pages at mmap
time and hanging those off the vma(vm_private_data) with some kludges to
use the pages at fault time.  It is really ugly, which is why I am not
sharing the code.  Hoping for some comments/suggestions.

[1] https://www.linuxplumbersconf.org/2017/ocw/proposals/4669
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

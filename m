Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 435D96B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 21:46:35 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id p138so2701018itp.12
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 18:46:35 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 1si2539167iov.315.2017.10.11.18.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 18:46:34 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 2/3] mm/map_contig: Use pre-allocated pages for VM_CONTIG mappings
Date: Wed, 11 Oct 2017 18:46:10 -0700
Message-Id: <20171012014611.18725-3-mike.kravetz@oracle.com>
In-Reply-To: <20171012014611.18725-1-mike.kravetz@oracle.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

When populating mappings backed by contiguous memory allocations
(VM_CONTIG), use the preallocated pages instead of allocating new.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/memory.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index a728bed16c20..fbef78d07cf3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3100,7 +3100,18 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	/* Allocate our own private page. */
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	page = alloc_zeroed_user_highpage_movable(vma, vmf->address);
+
+	/*
+	 * In the special VM_CONTIG case, pages have been pre-allocated. So,
+	 * simply grab the appropriate pre-allocated page.
+	 */
+	if (unlikely(vma->vm_flags & VM_CONTIG)) {
+		VM_BUG_ON(!vma->vm_private_data);
+		page = ((struct page *)vma->vm_private_data) +
+			((vmf->address - vma->vm_start) / PAGE_SIZE);
+	} else {
+		page = alloc_zeroed_user_highpage_movable(vma, vmf->address);
+	}
 	if (!page)
 		goto oom;
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DAC836B02A2
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:41 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t18so10032877plo.9
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d72si6071167pfe.328.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 22/64] mm: avoid mmap_sem trylock in vm_insert_page()
Date: Mon,  5 Feb 2018 02:27:12 +0100
Message-Id: <20180205012754.23615-23-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

The rules to this function state that mmap_sem must
be acquired by the caller:

- for write if used in f_op->mmap() (by far the most common case)
- for read if used from vma_op->fault()(with VM_MIXEDMAP)

The only exception is:
  mmap_vmcore()
   remap_vmalloc_range_partial()
      mmap_vmcore()

But there is no concurrency here, thus mmap_sem is not held.
After auditing the kernel, the following drivers use the fault
path and correctly set VM_MIXEDMAP):

.fault = etnaviv_gem_fault
.fault = udl_gem_fault
tegra_bo_fault()

As such, drop the reader trylock BUG_ON() for the common case.
This avoids having file_operations know about mmranges, as
mmap_sem is held during, mmap() for example.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/memory.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5adcdc7dee80..7c69674cd9da 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1773,7 +1773,6 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 	if (!page_count(page))
 		return -EINVAL;
 	if (!(vma->vm_flags & VM_MIXEDMAP)) {
-		BUG_ON(down_read_trylock(&vma->vm_mm->mmap_sem));
 		BUG_ON(vma->vm_flags & VM_PFNMAP);
 		vma->vm_flags |= VM_MIXEDMAP;
 	}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

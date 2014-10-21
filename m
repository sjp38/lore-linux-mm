Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0B36B00A5
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 08:15:02 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so1298546pab.12
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 05:15:02 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id z3si10836498pbw.195.2014.10.21.05.15.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 05:15:01 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so1252643pdi.10
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 05:15:01 -0700 (PDT)
From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH] mm/cma: Make kmemleak ignore CMA regions
Date: Tue, 21 Oct 2014 14:14:56 +0200
Message-Id: <1413893696-25484-1-git-send-email-thierry.reding@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

kmemleak will add allocations as objects to a pool. The memory allocated
for each object in this pool is periodically searched for pointers to
other allocated objects. This only works for memory that is mapped into
the kernel's virtual address space, which happens not to be the case for
most CMA regions.

Furthermore, CMA regions are typically used to store data transferred to
or from a device and therefore don't contain pointers to other objects.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Note: I'm not sure this is really the right fix. But without this, the
kernel crashes on the first execution of the scan_gray_list() because
it tries to access highmem. Perhaps a more appropriate fix would be to
reject any object that can't map to a kernel virtual address?
---
 mm/cma.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/cma.c b/mm/cma.c
index 963bc4add9af..349f9266f6d3 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -280,6 +280,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
 			ret = -ENOMEM;
 			goto err;
 		} else {
+			kmemleak_ignore(phys_to_virt(addr));
 			base = addr;
 		}
 	}
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

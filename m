Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2296F6B0256
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 11:21:46 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 65so107599876pfd.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 08:21:46 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id os10si2715892pac.121.2016.02.02.08.21.45
        for <linux-mm@kvack.org>;
        Tue, 02 Feb 2016 08:21:45 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 1/2] mempolicy: do not try to queue pages from !vma_migratable()
Date: Tue,  2 Feb 2016 19:21:00 +0300
Message-Id: <1454430061-116955-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Maybe I miss some point, but I don't see a reason why we try to queue
pages from non migratable VMAs.

This testcase steps on VM_BUG_ON_PAGE() in isolate_lru_page():

	#include <fcntl.h>
	#include <unistd.h>
	#include <stdio.h>
	#include <sys/mman.h>
	#include <numaif.h>

	#define SIZE 0x2000

	int foo;

	int main()
	{
		int fd;
		char *p;
		unsigned long mask = 2;

		fd = open("/dev/sg0", O_RDWR);
		p = mmap(NULL, SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
		/* Faultin pages */
		foo = p[0] + p[0x1000];
		mbind(p, SIZE, MPOL_BIND, &mask, 4, MPOL_MF_MOVE | MPOL_MF_STRICT);
		return 0;
	}

The only case when we can queue pages from such VMA is MPOL_MF_STRICT
plus MPOL_MF_MOVE or MPOL_MF_MOVE_ALL for VMA which has pages on LRU,
but gfp mask is not sutable for migaration (see mapping_gfp_mask() check
in vma_migratable()). That's looks like a bug to me.

Let's filter out non-migratable vma at start of queue_pages_test_walk()
and go to queue_pages_pte_range() only if MPOL_MF_MOVE or
MPOL_MF_MOVE_ALL flag is set.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 mm/mempolicy.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 27d135408a22..4c4187c0e1de 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -548,8 +548,7 @@ retry:
 			goto retry;
 		}
 
-		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, qp->pagelist, flags);
+		migrate_page_add(page, qp->pagelist, flags);
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
@@ -625,7 +624,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 	unsigned long endvma = vma->vm_end;
 	unsigned long flags = qp->flags;
 
-	if (vma->vm_flags & VM_PFNMAP)
+	if (!vma_migratable(vma))
 		return 1;
 
 	if (endvma > end)
@@ -644,16 +643,13 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 
 	if (flags & MPOL_MF_LAZY) {
 		/* Similar to task_numa_work, skip inaccessible VMAs */
-		if (vma_migratable(vma) &&
-			vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
+		if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
 			change_prot_numa(vma, start, endvma);
 		return 1;
 	}
 
-	if ((flags & MPOL_MF_STRICT) ||
-	    ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
-	     vma_migratable(vma)))
-		/* queue pages from current vma */
+	/* queue pages from current vma */
+	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 		return 0;
 	return 1;
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

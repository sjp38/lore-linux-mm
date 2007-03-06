Date: Mon, 5 Mar 2007 16:26:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-detach_vmas_to_be_unmapped-fix.patch
Message-Id: <20070305162613.29639e6c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akuster@mvista.com
List-ID: <linux-mm.kvack.org>


Could someone please review and test this?

I find the description to be pretty useless - no test results, no
description of the before-and-after impact, etc.


From: <akuster@mvista.com>

Wolfgang Wander submitted a fix to address a mmap fragmentation issue.  The
git patch ( 1363c3cd8603a913a27e2995dccbd70d5312d8e6 ) is somewhat different
and yields different results when running Wolfgang's test case leakme.c.

IMHO, the vm start and end address are swapped in arch_unmap_area and
arch_unmap_area_topdown functions.

Prior to this patch arch_unmap_area() used area->vm_start and
arch_unmap_area_topdown used area->vm_end in the git patch the following
change showed up.

if (mm->unmap_area == arch_unmap_area)
     addr = prev ? prev->vm_start : mm->mmap_base;
else
     addr = vma ?  vma->vm_end : mm->mmap_base;

Using Wolfgang Wander's leakme.c test, I get the same results seen with his
original "Avoiding mmap fragmentation" patch as I do after swapping the start
& end address in the above code segment.  The patch I submitted addresses this
typo issue.


Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mmap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/mmap.c~mm-detach_vmas_to_be_unmapped-fix mm/mmap.c
--- a/mm/mmap.c~mm-detach_vmas_to_be_unmapped-fix
+++ a/mm/mmap.c
@@ -1722,9 +1722,9 @@ detach_vmas_to_be_unmapped(struct mm_str
 	*insertion_point = vma;
 	tail_vma->vm_next = NULL;
 	if (mm->unmap_area == arch_unmap_area)
-		addr = prev ? prev->vm_end : mm->mmap_base;
+		addr = prev ? prev->vm_start : mm->mmap_base;
 	else
-		addr = vma ?  vma->vm_start : mm->mmap_base;
+		addr = vma ?  vma->vm_end : mm->mmap_base;
 	mm->unmap_area(mm, addr);
 	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

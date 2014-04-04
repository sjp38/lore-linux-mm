Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3706B0035
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 04:29:38 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so3122706pad.16
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 01:29:37 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id pc9si4285875pac.394.2014.04.04.01.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 01:29:37 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so3111428pab.24
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 01:29:36 -0700 (PDT)
Date: Fri, 4 Apr 2014 01:28:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: get_user_pages(write,force) refuse to COW in shared
 areas
Message-ID: <alpine.LSU.2.11.1404040120110.6880@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mauro Carvalho Chehab <m.chehab@samsung.com>, Omar Ramirez Luna <omar.ramirez@copitl.com>, Inki Dae <inki.dae@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org

get_user_pages(write=1, force=1) has always had odd behaviour on write-
protected shared mappings: although it demands FMODE_WRITE-access to the
underlying object (do_mmap_pgoff sets neither VM_SHARED nor VM_MAYWRITE
without that), it ends up with do_wp_page substituting private anonymous
Copied-On-Write pages for the shared file pages in the area.

That was long ago intentional, as a safety measure to prevent ptrace
setting a breakpoint (or POKETEXT or POKEDATA) from inadvertently
corrupting the underlying executable.  Yet exec and dynamic loaders
open the file read-only, and use MAP_PRIVATE rather than MAP_SHARED.

The traditional odd behaviour still causes surprises and bugs in mm,
and is probably not what any caller wants - even the comment on the flag
says "You do not want this" (although it's undoubtedly necessary for
overriding userspace protections in some contexts, and good when !write).

Let's stop doing that.  But it would be dangerous to remove the long-
standing safety at this stage, so just make get_user_pages(write,force)
fail with EFAULT when applied to a write-protected shared area.
Infiniband may in future want to force write through to underlying
object: we can add another FOLL_flag later to enable that if required.

Odd though the old behaviour was, there is no doubt that we may turn
out to break userspace with this change, and have to revert it quickly.
Issue a WARN_ON_ONCE to help debug the changed case (easily triggered
by userspace, so only once to prevent spamming the logs); and delay a
few associated cleanups until this change is proved.

get_user_pages callers who might see trouble from this change:
  ptrace poking, or writing to /proc/<pid>/mem
  drivers/infiniband/
  drivers/media/v4l2-core/
  drivers/gpu/drm/exynos/exynos_drm_gem.c
  drivers/staging/tidspbridge/core/tiomap3430.c
if they ever apply get_user_pages to write-protected shared mappings
of an object which was opened for writing.

I went to apply the same change to mm/nommu.c, but retreated.  NOMMU
has no place for COW, and its VM_flags conventions are not the same:
I'd be more likely to screw up NOMMU than make an improvement there.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

You suggested something like this in the LKML discussion of 887843961c4b
and "bad rss-counter message in 3.14rc5" on March 18th, and I agreed to
remind you "early in the 3.15 merge window".

Sorry, this comes a few days later than intended: and it's the first
time I've posted it, so it's not seen exposure in mmotm or linux-next;
nor any approval from those Cc'ed, though I did mention it to a few.
Up to you: you may prefer to hold it over, or give it exposure soonest;
I've seen no problem from it, but then I'm not likely to.

I may have exaggerated the accounting difficulties of the present
behaviour: even with this change, write-force still violates the
Committed_AS accounting which Konstantin had patches to fix; but
I hope we can do that more simply now, with some kind of cmpxchg
setting VM_ACCOUNT here in vm_flags, without mmap_sem for writing.

 mm/memory.c |   66 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 45 insertions(+), 21 deletions(-)

--- 3.14/mm/memory.c	2014-03-30 20:40:15.000000000 -0700
+++ linux/mm/memory.c	2014-04-03 15:26:41.884372480 -0700
@@ -1705,15 +1705,6 @@ long __get_user_pages(struct task_struct
 
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
-	/* 
-	 * Require read or write permissions.
-	 * If FOLL_FORCE is set, we only require the "MAY" flags.
-	 */
-	vm_flags  = (gup_flags & FOLL_WRITE) ?
-			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
-	vm_flags &= (gup_flags & FOLL_FORCE) ?
-			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
-
 	/*
 	 * If FOLL_FORCE and FOLL_NUMA are both set, handle_mm_fault
 	 * would be called on PROT_NONE ranges. We must never invoke
@@ -1741,7 +1732,7 @@ long __get_user_pages(struct task_struct
 
 			/* user gate pages are read-only */
 			if (gup_flags & FOLL_WRITE)
-				return i ? : -EFAULT;
+				goto efault;
 			if (pg > TASK_SIZE)
 				pgd = pgd_offset_k(pg);
 			else
@@ -1751,12 +1742,12 @@ long __get_user_pages(struct task_struct
 			BUG_ON(pud_none(*pud));
 			pmd = pmd_offset(pud, pg);
 			if (pmd_none(*pmd))
-				return i ? : -EFAULT;
+				goto efault;
 			VM_BUG_ON(pmd_trans_huge(*pmd));
 			pte = pte_offset_map(pmd, pg);
 			if (pte_none(*pte)) {
 				pte_unmap(pte);
-				return i ? : -EFAULT;
+				goto efault;
 			}
 			vma = get_gate_vma(mm);
 			if (pages) {
@@ -1769,7 +1760,7 @@ long __get_user_pages(struct task_struct
 						page = pte_page(*pte);
 					else {
 						pte_unmap(pte);
-						return i ? : -EFAULT;
+						goto efault;
 					}
 				}
 				pages[i] = page;
@@ -1780,10 +1771,42 @@ long __get_user_pages(struct task_struct
 			goto next_page;
 		}
 
-		if (!vma ||
-		    (vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
-		    !(vm_flags & vma->vm_flags))
-			return i ? : -EFAULT;
+		if (!vma)
+			goto efault;
+		vm_flags = vma->vm_flags;
+		if (vm_flags & (VM_IO | VM_PFNMAP))
+			goto efault;
+
+		if (gup_flags & FOLL_WRITE) {
+			if (!(vm_flags & VM_WRITE)) {
+				if (!(gup_flags & FOLL_FORCE))
+					goto efault;
+				/*
+				 * We used to let the write,force case do COW
+				 * in a VM_MAYWRITE VM_SHARED !VM_WRITE vma, so
+				 * ptrace could set a breakpoint in a read-only
+				 * mapping of an executable, without corrupting
+				 * the file (yet only when that file had been
+				 * opened for writing!).  Anon pages in shared
+				 * mappings are surprising: now just reject it.
+				 */
+				if (!is_cow_mapping(vm_flags)) {
+					WARN_ON_ONCE(vm_flags & VM_MAYWRITE);
+					goto efault;
+				}
+			}
+		} else {
+			if (!(vm_flags & VM_READ)) {
+				if (!(gup_flags & FOLL_FORCE))
+					goto efault;
+				/*
+				 * Is there actually any vma we can reach here
+				 * which does not have VM_MAYREAD set?
+				 */
+				if (!(vm_flags & VM_MAYREAD))
+					goto efault;
+			}
+		}
 
 		if (is_vm_hugetlb_page(vma)) {
 			i = follow_hugetlb_page(mm, vma, pages, vmas,
@@ -1837,7 +1860,7 @@ long __get_user_pages(struct task_struct
 							return -EFAULT;
 					}
 					if (ret & VM_FAULT_SIGBUS)
-						return i ? i : -EFAULT;
+						goto efault;
 					BUG();
 				}
 
@@ -1895,6 +1918,8 @@ next_page:
 		} while (nr_pages && start < vma->vm_end);
 	} while (nr_pages);
 	return i;
+efault:
+	return i ? : -EFAULT;
 }
 EXPORT_SYMBOL(__get_user_pages);
 
@@ -1962,9 +1987,8 @@ int fixup_user_fault(struct task_struct
  * @start:	starting user address
  * @nr_pages:	number of pages from start to pin
  * @write:	whether pages will be written to by the caller
- * @force:	whether to force write access even if user mapping is
- *		readonly. This will result in the page being COWed even
- *		in MAP_SHARED mappings. You do not want this.
+ * @force:	whether to force access even when user mapping is currently
+ *		protected (but never forces write access to shared mapping).
  * @pages:	array that receives pointers to the pages pinned.
  *		Should be at least nr_pages long. Or NULL, if caller
  *		only intends to ensure the pages are faulted in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

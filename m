Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27D8F6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:36 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so11516913lfc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:36 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id dh1si29853665wjb.116.2016.04.26.05.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:33 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so4193905wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:33 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 02/18] mm: make vm_mmap killable
Date: Tue, 26 Apr 2016 14:56:09 +0200
Message-Id: <1461675385-5934-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

All the callers of vm_mmap seem to check for the failure already
and bail out in one way or another on the error which means that
we can change it to use killable version of vm_mmap_pgoff and return
-EINTR if the current task gets killed while waiting for mmap_sem.
This also means that vm_mmap_pgoff can be killable by default and
drop the additional parameter.

This will help in the OOM conditions when the oom victim might be stuck
waiting for the mmap_sem for write which in turn can block oom_reaper
which relies on the mmap_sem for read to make a forward progress
and reclaim the address space of the victim.

Please note that load_elf_binary is ignoring vm_mmap error for
current->personality & MMAP_PAGE_ZERO case but that shouldn't be a
problem because the address is not used anywhere and we never return to
the userspace if we got killed.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h |  2 +-
 mm/internal.h      |  3 +--
 mm/mmap.c          |  2 +-
 mm/nommu.c         |  2 +-
 mm/util.c          | 13 ++++---------
 5 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ed06956a8a12..1085e025852a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2005,7 +2005,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len) {}
 /* These take the mm semaphore themselves */
 extern unsigned long vm_brk(unsigned long, unsigned long);
 extern int vm_munmap(unsigned long, size_t);
-extern unsigned long vm_mmap(struct file *, unsigned long,
+extern unsigned long __must_check vm_mmap(struct file *, unsigned long,
         unsigned long, unsigned long,
         unsigned long, unsigned long);
 
diff --git a/mm/internal.h b/mm/internal.h
index bdc754e90c53..dc2af5b7b85f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -453,8 +453,7 @@ extern u32 hwpoison_filter_enable;
 
 extern unsigned long  __must_check vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long,
-        unsigned long, unsigned long,
-        bool);
+        unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
diff --git a/mm/mmap.c b/mm/mmap.c
index a11cdb6d2566..1d229487dab1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1333,7 +1333,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, true);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 out_fput:
 	if (file)
 		fput(file);
diff --git a/mm/nommu.c b/mm/nommu.c
index b74512746aae..c8bd59a03c71 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1446,7 +1446,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, true);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 
 	if (file)
 		fput(file);
diff --git a/mm/util.c b/mm/util.c
index 03b237746850..917e0e3d0f8e 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -289,7 +289,7 @@ EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
-	unsigned long flag, unsigned long pgoff, bool killable)
+	unsigned long flag, unsigned long pgoff)
 {
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
@@ -297,12 +297,8 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
-		if (killable) {
-			if (down_write_killable(&mm->mmap_sem))
-				return -EINTR;
-		} else {
-			down_write(&mm->mmap_sem);
-		}
+		if (down_write_killable(&mm->mmap_sem))
+			return -EINTR;
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
 				    &populate);
 		up_write(&mm->mmap_sem);
@@ -312,7 +308,6 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	return ret;
 }
 
-/* XXX are all callers checking an error */
 unsigned long vm_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long offset)
@@ -322,7 +317,7 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 	if (unlikely(offset_in_page(offset)))
 		return -EINVAL;
 
-	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT, false);
+	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
 }
 EXPORT_SYMBOL(vm_mmap);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B32B36B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so11462901lfq.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:33 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id k71si3171238wmg.79.2016.04.26.05.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:32 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r12so4233119wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:32 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 01/18] mm: Make mmap_sem for write waits killable for mm syscalls
Date: Tue, 26 Apr 2016 14:56:08 +0200
Message-Id: <1461675385-5934-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

This is the first step in making mmap_sem write waiters killable. It
focuses on the trivial ones which are taking the lock early after
entering the syscall and they are not changing state before.

Therefore it is very easy to change them to use down_write_killable
and immediately return with -EINTR. This will allow the waiter to
pass away without blocking the mmap_sem which might be required to
make a forward progress. E.g. the oom reaper will need the lock for
reading to dismantle the OOM victim address space.

The only tricky function in this patch is vm_mmap_pgoff which has many
call sites via vm_mmap. To reduce the risk keep vm_mmap with the
original non-killable semantic for now.

vm_munmap callers do not bother checking the return value so open code
it into the munmap syscall path for now for simplicity.

Cc: Mel Gorman <mgorman@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/internal.h |  5 +++--
 mm/madvise.c  |  8 +++++---
 mm/mlock.c    | 16 ++++++++++------
 mm/mmap.c     | 27 +++++++++++++++++++++++----
 mm/mprotect.c |  3 ++-
 mm/mremap.c   |  3 ++-
 mm/nommu.c    |  2 +-
 mm/util.c     | 12 +++++++++---
 8 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index f69851ddf98d..bdc754e90c53 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -451,9 +451,10 @@ extern u64 hwpoison_filter_flags_value;
 extern u64 hwpoison_filter_memcg;
 extern u32 hwpoison_filter_enable;
 
-extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
+extern unsigned long  __must_check vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long,
-        unsigned long, unsigned long);
+        unsigned long, unsigned long,
+        bool);
 
 extern void set_pageblock_order(void);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
diff --git a/mm/madvise.c b/mm/madvise.c
index 07427d3fcead..93fb63e88b5e 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -707,10 +707,12 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 		return error;
 
 	write = madvise_need_mmap_write(behavior);
-	if (write)
-		down_write(&current->mm->mmap_sem);
-	else
+	if (write) {
+		if (down_write_killable(&current->mm->mmap_sem))
+			return -EINTR;
+	} else {
 		down_read(&current->mm->mmap_sem);
+	}
 
 	/*
 	 * If the interval [start,end) covers some unmapped address
diff --git a/mm/mlock.c b/mm/mlock.c
index 96f001041928..ef8dc9f395c4 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -617,7 +617,7 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
 	return error;
 }
 
-static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
+static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 {
 	unsigned long locked;
 	unsigned long lock_limit;
@@ -635,7 +635,8 @@ static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 	lock_limit >>= PAGE_SHIFT;
 	locked = len >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem))
+		return -EINTR;
 
 	locked += current->mm->locked_vm;
 
@@ -678,7 +679,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem))
+		return -EINTR;
 	ret = apply_vma_lock_flags(start, len, 0);
 	up_write(&current->mm->mmap_sem);
 
@@ -748,9 +750,10 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
-	ret = -ENOMEM;
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem))
+		return -EINTR;
 
+	ret = -ENOMEM;
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = apply_mlockall_flags(flags);
@@ -765,7 +768,8 @@ SYSCALL_DEFINE0(munlockall)
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem))
+		return -EINTR;
 	ret = apply_mlockall_flags(0);
 	up_write(&current->mm->mmap_sem);
 	return ret;
diff --git a/mm/mmap.c b/mm/mmap.c
index fba246b8f1a5..a11cdb6d2566 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -178,7 +178,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	unsigned long min_brk;
 	bool populate;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
 
 #ifdef CONFIG_COMPAT_BRK
 	/*
@@ -1332,7 +1333,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, true);
 out_fput:
 	if (file)
 		fput(file);
@@ -2493,6 +2494,10 @@ int vm_munmap(unsigned long start, size_t len)
 	int ret;
 	struct mm_struct *mm = current->mm;
 
+	/*
+	 * XXX convert to down_write_killable as soon as all users are able
+	 * to handle the error.
+	 */
 	down_write(&mm->mmap_sem);
 	ret = do_munmap(mm, start, len);
 	up_write(&mm->mmap_sem);
@@ -2502,8 +2507,15 @@ EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
+	int ret;
+	struct mm_struct *mm = current->mm;
+
 	profile_munmap(addr);
-	return vm_munmap(addr, len);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+	ret = do_munmap(mm, addr, len);
+	up_write(&mm->mmap_sem);
+	return ret;
 }
 
 
@@ -2535,7 +2547,9 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
 		return ret;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	vma = find_vma(mm, start);
 
 	if (!vma || !(vma->vm_flags & VM_SHARED))
@@ -2700,6 +2714,11 @@ unsigned long vm_brk(unsigned long addr, unsigned long len)
 	unsigned long ret;
 	bool populate;
 
+	/*
+	 * XXX not all users are chcecking the return value, convert
+	 * to down_write_killable after they are able to cope with
+	 * error
+	 */
 	down_write(&mm->mmap_sem);
 	ret = do_brk(addr, len);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index b650c5412f58..5019a1ef2848 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -379,7 +379,8 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 
 	reqprot = prot;
 
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem))
+		return -EINTR;
 
 	vma = find_vma(current->mm, start);
 	error = -ENOMEM;
diff --git a/mm/mremap.c b/mm/mremap.c
index 9dc499977924..1f157adfdaf9 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -503,7 +503,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	if (!new_len)
 		return ret;
 
-	down_write(&current->mm->mmap_sem);
+	if (down_write_killable(&current->mm->mmap_sem))
+		return -EINTR;
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
diff --git a/mm/nommu.c b/mm/nommu.c
index c8bd59a03c71..b74512746aae 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1446,7 +1446,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, true);
 
 	if (file)
 		fput(file);
diff --git a/mm/util.c b/mm/util.c
index 8a1b3a1fb595..03b237746850 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -289,7 +289,7 @@ EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
-	unsigned long flag, unsigned long pgoff)
+	unsigned long flag, unsigned long pgoff, bool killable)
 {
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
@@ -297,7 +297,12 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
-		down_write(&mm->mmap_sem);
+		if (killable) {
+			if (down_write_killable(&mm->mmap_sem))
+				return -EINTR;
+		} else {
+			down_write(&mm->mmap_sem);
+		}
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
 				    &populate);
 		up_write(&mm->mmap_sem);
@@ -307,6 +312,7 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	return ret;
 }
 
+/* XXX are all callers checking an error */
 unsigned long vm_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long offset)
@@ -316,7 +322,7 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 	if (unlikely(offset_in_page(offset)))
 		return -EINVAL;
 
-	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
+	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT, false);
 }
 EXPORT_SYMBOL(vm_mmap);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

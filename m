Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 331536B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:13 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id n186so49190848wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:13 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 02/18] mm: make vm_mmap killable
Date: Mon, 29 Feb 2016 14:26:41 +0100
Message-Id: <1456752417-9626-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>

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

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h |  2 +-
 mm/internal.h      |  3 +--
 mm/mmap.c          |  2 +-
 mm/nommu.c         |  2 +-
 mm/util.c          | 13 ++++---------
 5 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8a84cf07da8c..4ee6a3561540 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2079,7 +2079,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len) {}
 /* These take the mm semaphore themselves */
 extern unsigned long vm_brk(unsigned long, unsigned long);
 extern int vm_munmap(unsigned long, size_t);
-extern unsigned long vm_mmap(struct file *, unsigned long,
+extern unsigned long __must_check vm_mmap(struct file *, unsigned long,
         unsigned long, unsigned long,
         unsigned long, unsigned long);
 
diff --git a/mm/internal.h b/mm/internal.h
index 26576cb3247e..d8d4c32bfce4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -446,8 +446,7 @@ extern u32 hwpoison_filter_enable;
 
 extern unsigned long  __must_check vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long,
-        unsigned long, unsigned long,
-        bool);
+        unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
diff --git a/mm/mmap.c b/mm/mmap.c
index a8ea76c22bb6..4e1f852a52ff 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1337,7 +1337,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, true);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 out_fput:
 	if (file)
 		fput(file);
diff --git a/mm/nommu.c b/mm/nommu.c
index 50b1d32921c2..de8b6b6580c1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1448,7 +1448,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff, true);
+	retval = vm_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 
 	if (file)
 		fput(file);
diff --git a/mm/util.c b/mm/util.c
index 98eeec742254..0e383fe48145 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -319,7 +319,7 @@ EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
-	unsigned long flag, unsigned long pgoff, bool killable)
+	unsigned long flag, unsigned long pgoff)
 {
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
@@ -327,12 +327,8 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 
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
@@ -342,7 +338,6 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	return ret;
 }
 
-/* XXX are all callers checking an error */
 unsigned long vm_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long offset)
@@ -352,7 +347,7 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 	if (unlikely(offset_in_page(offset)))
 		return -EINVAL;
 
-	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT, false);
+	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
 }
 EXPORT_SYMBOL(vm_mmap);
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

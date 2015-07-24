Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 331B36B0253
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 17:28:52 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so16824996qge.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:28:52 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id i26si11714438qkh.62.2015.07.24.14.28.47
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 14:28:48 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V5 4/7] mm: mlock: Add mlock flags to enable VM_LOCKONFAULT usage
Date: Fri, 24 Jul 2015 17:28:42 -0400
Message-Id: <1437773325-8623-5-git-send-email-emunson@akamai.com>
In-Reply-To: <1437773325-8623-1-git-send-email-emunson@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

The previous patch introduced a flag that specified pages in a VMA
should be placed on the unevictable LRU, but they should not be made
present when the area is created.  This patch adds the ability to set
this state via the new mlock system calls.

We add MLOCK_ONFAULT for mlock2 and MCL_ONFAULT for mlockall.
MLOCK_ONFAULT will set the VM_LOCKONFAULT flag as well as the VM_LOCKED
flag for the target region.  MCL_CURRENT and MCL_ONFAULT are used to
lock current mappings.  With MCL_CURRENT all pages are made present and
with MCL_ONFAULT they are locked when faulted in.  When specified with
MCL_FUTURE all new mappings will be marked with VM_LOCKONFAULT.

Currently, mlockall() clears all VMA lock flags and then sets the
requested flags.  For instance, if a process has MCL_FUTURE and
MCL_CURRENT set, but they want to clear MCL_FUTURE this would be
accomplished by calling mlockall(MCL_CURRENT).  This still holds with
the introduction of MCL_ONFAULT.  Each call to mlockall() resets all
VMA flags to the values specified in the current call.  The new mlock2
system call behaves in the same way.  If a region is locked with
MLOCK_ONFAULT and a user wants to force it to be populated now, a second
call to mlock2(MLOCK_LOCKED) will accomplish this.

munlock() will unconditionally clear both vma flags.  munlockall()
unconditionally clears for VMA flags on all VMAs and in the
mm->def_flags field.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-arch@vger.kernel.org
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
---
Changes from V4:
* Split addition of VMA flag

Changes from V3:
* Do extensive search for VM_LOCKED and ensure that VM_LOCKONFAULT is also handled
 where appropriate
 arch/alpha/include/uapi/asm/mman.h   |  2 ++
 arch/mips/include/uapi/asm/mman.h    |  2 ++
 arch/parisc/include/uapi/asm/mman.h  |  2 ++
 arch/powerpc/include/uapi/asm/mman.h |  2 ++
 arch/sparc/include/uapi/asm/mman.h   |  2 ++
 arch/tile/include/uapi/asm/mman.h    |  3 +++
 arch/xtensa/include/uapi/asm/mman.h  |  2 ++
 include/uapi/asm-generic/mman.h      |  2 ++
 mm/mlock.c                           | 41 ++++++++++++++++++++++++------------
 9 files changed, 45 insertions(+), 13 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index ec72436..77ae8db 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -37,8 +37,10 @@
 
 #define MCL_CURRENT	 8192		/* lock all currently mapped pages */
 #define MCL_FUTURE	16384		/* lock all additions to address space */
+#define MCL_ONFAULT	32768		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 67c1cdf..71ed81d 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -61,11 +61,13 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index daab994..c0871ce 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -31,8 +31,10 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL     0               /* no further special treatment */
 #define MADV_RANDOM     1               /* expect random page references */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 189e85f..f93f7eb 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -22,8 +22,10 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 13d51be..8cd2ebc 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -17,8 +17,10 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
index f69ce48..acdd013 100644
--- a/arch/tile/include/uapi/asm/mman.h
+++ b/arch/tile/include/uapi/asm/mman.h
@@ -36,11 +36,14 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
+
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 
 #endif /* _ASM_TILE_MMAN_H */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 11f354f..5725a15 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -74,11 +74,13 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 242436b..555aab0 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -17,7 +17,9 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #endif /* __ASM_GENERIC_MMAN_H */
diff --git a/mm/mlock.c b/mm/mlock.c
index e98bdd4..3a99c80 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -506,7 +506,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
-		goto out;	/* don't set VM_LOCKED,  don't count */
+		/* don't set VM_LOCKED or VM_LOCKONFAULT and don't count */
+		goto out;
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
@@ -576,7 +577,7 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
 		prev = vma;
 
 	for (nstart = start ; ; ) {
-		vm_flags_t newflags = vma->vm_flags & ~VM_LOCKED;
+		vm_flags_t newflags = vma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
 		newflags |= flags;
 
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
@@ -645,9 +646,13 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 {
 	vm_flags_t vm_flags = VM_LOCKED;
-	if (!flags || (flags & ~(MLOCK_LOCKED)))
+	if (!flags || (flags & ~(MLOCK_LOCKED | MLOCK_ONFAULT)) ||
+	    flags == (MLOCK_LOCKED | MLOCK_ONFAULT))
 		return -EINVAL;
 
+	if (flags & MLOCK_ONFAULT)
+		vm_flags |= VM_LOCKONFAULT;
+
 	return do_mlock(start, len, vm_flags);
 }
 
@@ -668,21 +673,30 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 static int apply_mlockall_flags(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
+	vm_flags_t to_add = 0;
 
-	if (flags & MCL_FUTURE)
+	current->mm->def_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
+	if (flags & MCL_FUTURE) {
 		current->mm->def_flags |= VM_LOCKED;
-	else
-		current->mm->def_flags &= ~VM_LOCKED;
 
-	if (flags == MCL_FUTURE)
-		goto out;
+		if (flags == MCL_FUTURE)
+			goto out;
+
+		if (flags & MCL_ONFAULT)
+			current->mm->def_flags |= VM_LOCKONFAULT;
+	}
+
+	if (flags & (MCL_ONFAULT | MCL_CURRENT)) {
+		to_add |= VM_LOCKED;
+		if (flags & MCL_ONFAULT)
+			to_add |= VM_LOCKONFAULT;
+	}
 
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
 		vm_flags_t newflags;
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
-		if (flags & MCL_CURRENT)
-			newflags |= VM_LOCKED;
+		newflags = vma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
+		newflags |= to_add;
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
@@ -697,7 +711,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	unsigned long lock_limit;
 	int ret = -EINVAL;
 
-	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
+	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)) ||
+	    (flags & (MCL_CURRENT | MCL_ONFAULT)) == (MCL_CURRENT | MCL_ONFAULT))
 		goto out;
 
 	ret = -EPERM;
@@ -717,7 +732,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	    capable(CAP_IPC_LOCK))
 		ret = apply_mlockall_flags(flags);
 	up_write(&current->mm->mmap_sem);
-	if (!ret && (flags & MCL_CURRENT))
+	if (!ret && (flags & (MCL_CURRENT | MCL_ONFAULT)))
 		mm_populate(0, TASK_SIZE);
 out:
 	return ret;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

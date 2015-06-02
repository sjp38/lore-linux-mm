Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id D083C6B006E
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 14:13:29 -0400 (EDT)
Received: by qkx62 with SMTP id 62so105498364qkx.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 11:13:29 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id e76si14598429qka.106.2015.06.02.11.13.27
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 11:13:28 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V2 2/3] Add mlockall flag for locking pages on fault
Date: Tue,  2 Jun 2015 14:13:25 -0400
Message-Id: <1433268806-17109-3-git-send-email-emunson@akamai.com>
In-Reply-To: <1433268806-17109-1-git-send-email-emunson@akamai.com>
References: <1433268806-17109-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

Building on the previous patch, extend mlockall() to give a process a
way to specify that pages should be locked when they are faulted in, but
that pre-faulting is not needed.

MCL_ONFAULT is preferrable to MCL_FUTURE for the use cases enumerated
in the previous patch becuase MCL_FUTURE will behave as if each mapping
was made with MAP_LOCKED, causing the entire mapping to be faulted in
when new space is allocated or mapped.  MCL_ONFAULT allows the user to
delay the fault in cost of any given page until it is actually needed,
but then guarantees that that page will always be resident.

As with the mmap(MAP_LOCKONFAULT) case, the user is charged for the
mapping against the RLIMIT_MEMLOCK when the address space is allocated,
not when the page is faulted in.  This decision was made to keep the
accounting checks out of the page fault path.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
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
 arch/alpha/include/uapi/asm/mman.h   |  1 +
 arch/mips/include/uapi/asm/mman.h    |  1 +
 arch/parisc/include/uapi/asm/mman.h  |  1 +
 arch/powerpc/include/uapi/asm/mman.h |  1 +
 arch/sparc/include/uapi/asm/mman.h   |  1 +
 arch/tile/include/uapi/asm/mman.h    |  1 +
 arch/xtensa/include/uapi/asm/mman.h  |  1 +
 include/uapi/asm-generic/mman.h      |  1 +
 mm/mlock.c                           | 13 +++++++++----
 9 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 15e96e1..dfdaecf 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -38,6 +38,7 @@
 
 #define MCL_CURRENT	 8192		/* lock all currently mapped pages */
 #define MCL_FUTURE	16384		/* lock all additions to address space */
+#define MCL_ONFAULT	32768		/* lock all pages that are faulted in */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 47846a5..f0705ff 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -62,6 +62,7 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 1514cd7..7c2eb85 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -32,6 +32,7 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MADV_NORMAL     0               /* no further special treatment */
 #define MADV_RANDOM     1               /* expect random page references */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index fce74fe..0109937 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -22,6 +22,7 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x80000		/* lock all pages that are faulted in */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 12425d8..f2986f7 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -17,6 +17,7 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x80000		/* lock all pages that are faulted in */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
index ec04eaf..0f7ae45 100644
--- a/arch/tile/include/uapi/asm/mman.h
+++ b/arch/tile/include/uapi/asm/mman.h
@@ -37,6 +37,7 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 
 #endif /* _ASM_TILE_MMAN_H */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 42d43cc..10fbbb7 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -75,6 +75,7 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index fc4e586..7fb729b 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -18,5 +18,6 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #endif /* __ASM_GENERIC_MMAN_H */
diff --git a/mm/mlock.c b/mm/mlock.c
index 6fd2cf1..f15547f 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -579,7 +579,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
+		newflags = vma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
 		if (on)
 			newflags |= VM_LOCKED;
 
@@ -662,13 +662,17 @@ static int do_mlockall(int flags)
 		current->mm->def_flags |= VM_LOCKED;
 	else
 		current->mm->def_flags &= ~VM_LOCKED;
-	if (flags == MCL_FUTURE)
+	if (flags & MCL_ONFAULT)
+		current->mm->def_flags |= VM_LOCKONFAULT;
+	else
+		current->mm->def_flags &= ~VM_LOCKONFAULT;
+	if (flags == MCL_FUTURE || flags == MCL_ONFAULT)
 		goto out;
 
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
 		vm_flags_t newflags;
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
+		newflags = vma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
 		if (flags & MCL_CURRENT)
 			newflags |= VM_LOCKED;
 
@@ -685,7 +689,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	unsigned long lock_limit;
 	int ret = -EINVAL;
 
-	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
+	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)) ||
+	    ((flags & MCL_FUTURE) && (flags & MCL_ONFAULT)))
 		goto out;
 
 	ret = -EPERM;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

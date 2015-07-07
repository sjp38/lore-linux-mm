Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id C79E66B0253
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 13:03:52 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so144513518qkh.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 10:03:52 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id k39si25625606qgk.87.2015.07.07.10.03.51
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 10:03:51 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V3 4/5] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Date: Tue,  7 Jul 2015 13:03:42 -0400
Message-Id: <1436288623-13007-5-git-send-email-emunson@akamai.com>
In-Reply-To: <1436288623-13007-1-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

The cost of faulting in all memory to be locked can be very high when
working with large mappings.  If only portions of the mapping will be
used this can incur a high penalty for locking.

Now that we have the new VMA flag for the locked but not present state,
expose it  as an mmap option like MAP_LOCKED -> VM_LOCKED.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: linux-api@vger.kernel.org
---
 arch/alpha/include/uapi/asm/mman.h   | 1 +
 arch/mips/include/uapi/asm/mman.h    | 1 +
 arch/parisc/include/uapi/asm/mman.h  | 1 +
 arch/powerpc/include/uapi/asm/mman.h | 1 +
 arch/sparc/include/uapi/asm/mman.h   | 1 +
 arch/xtensa/include/uapi/asm/mman.h  | 1 +
 include/linux/mman.h                 | 3 ++-
 include/uapi/asm-generic/mman.h      | 1 +
 mm/mmap.c                            | 2 +-
 9 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 77ae8db..3f80ca4 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -30,6 +30,7 @@
 #define MAP_NONBLOCK	0x40000		/* do not block on IO */
 #define MAP_STACK	0x80000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
+#define MAP_LOCKONFAULT	0x200000	/* Lock pages after they are faulted in, do not prefault */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_SYNC		2		/* synchronous memory sync */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 71ed81d..905c1ea 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -48,6 +48,7 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
+#define MAP_LOCKONFAULT	0x100000	/* Lock pages after they are faulted in, do not prefault */
 
 /*
  * Flags for msync
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index c0871ce..c4695f6 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -24,6 +24,7 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
+#define MAP_LOCKONFAULT	0x100000	/* Lock pages after they are faulted in, do not prefault */
 
 #define MS_SYNC		1		/* synchronous memory sync */
 #define MS_ASYNC	2		/* sync memory asynchronously */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index f93f7eb..40a3fda 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -31,5 +31,6 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_LOCKONFAULT	0x80000		/* Lock pages after they are faulted in, do not prefault */
 
 #endif /* _UAPI_ASM_POWERPC_MMAN_H */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 8cd2ebc..3d74ab7 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -26,6 +26,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_LOCKONFAULT	0x8000		/* Lock pages after they are faulted in, do not prefault */
 
 
 #endif /* _UAPI__SPARC_MMAN_H__ */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 5725a15..689e1f2 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -55,6 +55,7 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
+#define MAP_LOCKONFAULT	0x100000	/* Lock pages after they are faulted in, do not prefault */
 #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
 # define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
 					 * uninitialized */
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 16373c8..437264b 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -86,7 +86,8 @@ calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
-	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
+	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    ) |
+	       _calc_vm_trans(flags, MAP_LOCKONFAULT,VM_LOCKONFAULT);
 }
 
 unsigned long vm_commit_limit(void);
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 555aab0..007b784 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_LOCKONFAULT	0x80000		/* Lock pages after they are faulted in, do not prefault */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
diff --git a/mm/mmap.c b/mm/mmap.c
index eb970ba..2dc4da3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1301,7 +1301,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
-	if (flags & MAP_LOCKED)
+	if (flags & (MAP_LOCKED | MAP_LOCKONFAULT))
 		if (!can_do_mlock())
 			return -EPERM;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

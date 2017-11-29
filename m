Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6F556B0281
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:42:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t65so2566719pfe.22
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:42:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1sor492798pgr.276.2017.11.29.06.42.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 06:42:36 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Date: Wed, 29 Nov 2017 15:42:18 +0100
Message-Id: <20171129144219.22867-2-mhocko@kernel.org>
In-Reply-To: <20171129144219.22867-1-mhocko@kernel.org>
References: <20171129144219.22867-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-api@vger.kernel.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

MAP_FIXED is used quite often to enforce mapping at the particular
range. The main problem of this flag is, however, that it is inherently
dangerous because it unmaps existing mappings covered by the requested
range. This can cause silent memory corruptions. Some of them even with
serious security implications. While the current semantic might be
really desiderable in many cases there are others which would want to
enforce the given range but rather see a failure than a silent memory
corruption on a clashing range. Please note that there is no guarantee
that a given range is obeyed by the mmap even when it is free - e.g.
arch specific code is allowed to apply an alignment.

Introduce a new MAP_FIXED_SAFE flag for mmap to achieve this behavior.
It has the same semantic as MAP_FIXED wrt. the given address request
with a single exception that it fails with EEXIST if the requested
address is already covered by an existing mapping. We still do rely on
get_unmaped_area to handle all the arch specific MAP_FIXED treatment and
check for a conflicting vma after it returns.

[fail on clashing range with EEXIST as per Florian Weimer]
[set MAP_FIXED before round_hint_to_min as per Khalid Aziz]
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/include/uapi/asm/mman.h   |  2 ++
 arch/mips/include/uapi/asm/mman.h    |  2 ++
 arch/parisc/include/uapi/asm/mman.h  |  2 ++
 arch/powerpc/include/uapi/asm/mman.h |  1 +
 arch/sparc/include/uapi/asm/mman.h   |  1 +
 arch/tile/include/uapi/asm/mman.h    |  1 +
 arch/xtensa/include/uapi/asm/mman.h  |  2 ++
 include/uapi/asm-generic/mman.h      |  1 +
 mm/mmap.c                            | 11 +++++++++++
 9 files changed, 23 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 6bf730063e3f..ef3770262925 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -32,6 +32,8 @@
 #define MAP_STACK	0x80000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
 
+#define MAP_FIXED_SAFE	0x200000	/* MAP_FIXED which doesn't unmap underlying mapping */
+
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_SYNC		2		/* synchronous memory sync */
 #define MS_INVALIDATE	4		/* invalidate the caches */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 20c3df7a8fdd..f1e15890345c 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -50,6 +50,8 @@
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
 
+#define MAP_FIXED_SAFE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
+
 /*
  * Flags for msync
  */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index d1af0d74a188..daf0282ac417 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -26,6 +26,8 @@
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
 
+#define MAP_FIXED_SAFE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
+
 #define MS_SYNC		1		/* synchronous memory sync */
 #define MS_ASYNC	2		/* sync memory asynchronously */
 #define MS_INVALIDATE	4		/* invalidate the caches */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index e63bc37e33af..3ffd284e7160 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -29,5 +29,6 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_FIXED_SAFE	0x800000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
 #endif /* _UAPI_ASM_POWERPC_MMAN_H */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 715a2c927e79..0c282c09fae8 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -24,6 +24,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 
 #endif /* _UAPI__SPARC_MMAN_H__ */
diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
index 9b7add95926b..b212f5fd5345 100644
--- a/arch/tile/include/uapi/asm/mman.h
+++ b/arch/tile/include/uapi/asm/mman.h
@@ -30,6 +30,7 @@
 #define MAP_DENYWRITE	0x0800		/* ETXTBSY */
 #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
 #define MAP_HUGETLB	0x4000		/* create a huge page mapping */
+#define MAP_FIXED_SAFE	0x8000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 
 /*
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 2bfe590694fc..0daf199caa57 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -56,6 +56,7 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
+#define MAP_FIXED_SAFE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
 # define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
 					 * uninitialized */
@@ -63,6 +64,7 @@
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
 
+
 /*
  * Flags for msync
  */
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 2dffcbf705b3..56cde132a80a 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -13,6 +13,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 476e810cf100..e84339842bb8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1342,6 +1342,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		if (!(file && path_noexec(&file->f_path)))
 			prot |= PROT_EXEC;
 
+	/* force arch specific MAP_FIXED handling in get_unmapped_area */
+	if (flags & MAP_FIXED_SAFE)
+		flags |= MAP_FIXED;
+
 	if (!(flags & MAP_FIXED))
 		addr = round_hint_to_min(addr);
 
@@ -1365,6 +1369,13 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	if (offset_in_page(addr))
 		return addr;
 
+	if (flags & MAP_FIXED_SAFE) {
+		struct vm_area_struct *vma = find_vma(mm, addr);
+
+		if (vma && vma->vm_start <= addr)
+			return -EEXIST;
+	}
+
 	if (prot == PROT_EXEC) {
 		pkey = execute_only_pkey(mm);
 		if (pkey < 0)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

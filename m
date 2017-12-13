Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0BD6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:26:02 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g80so981105wrd.17
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:26:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p27sor393824wma.28.2017.12.13.01.26.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 01:26:00 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Date: Wed, 13 Dec 2017 10:25:49 +0100
Message-Id: <20171213092550.2774-2-mhocko@kernel.org>
In-Reply-To: <20171213092550.2774-1-mhocko@kernel.org>
References: <20171213092550.2774-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-api@vger.kernel.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>

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

The flag is introduced as a completely new one rather than a MAP_FIXED
extension because of the backward compatibility. We really want a
never-clobber semantic even on older kernels which do not recognize
the flag. Unfortunately mmap sucks wrt. flags evaluation because we do
not EINVAL on unknown flags. On those kernels we would simply use the
traditional hint based semantic so the caller can still get a different
address (which sucks) but at least not silently corrupt an existing
mapping. I do not see a good way around that.

Changes since v1
- define MAP_FIXED_SAFE in asm-generic/mman-common.h as per Michael
  Ellerman because all architecture which use this header can share
  the same value. This will leave us with only 4 arches which need
  special handling.

[fail on clashing range with EEXIST as per Florian Weimer]
[set MAP_FIXED before round_hint_to_min as per Khalid Aziz]
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/include/uapi/asm/mman.h     |  1 +
 arch/mips/include/uapi/asm/mman.h      |  2 ++
 arch/parisc/include/uapi/asm/mman.h    |  2 ++
 arch/sparc/include/uapi/asm/mman.h     |  1 -
 arch/xtensa/include/uapi/asm/mman.h    |  2 ++
 include/uapi/asm-generic/mman-common.h |  1 +
 mm/mmap.c                              | 11 +++++++++++
 7 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 6bf730063e3f..7287dbf1e11b 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -31,6 +31,7 @@
 #define MAP_NONBLOCK	0x40000		/* do not block on IO */
 #define MAP_STACK	0x80000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
+#define MAP_FIXED_SAFE	0x200000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_SYNC		2		/* synchronous memory sync */
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
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 715a2c927e79..d21bffd5d3dc 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -25,5 +25,4 @@
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
 
-
 #endif /* _UAPI__SPARC_MMAN_H__ */
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
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 6d319c46fd90..1eca2cb10d44 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -25,6 +25,7 @@
 #else
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
+#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 /*
  * Flags for mlock
diff --git a/mm/mmap.c b/mm/mmap.c
index 0de87a376aaa..447223a2e469 100644
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

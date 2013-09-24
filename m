Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B3FD06B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 17:23:53 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so5528935pab.22
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 14:23:53 -0700 (PDT)
From: "Timothy Pepper" <timothy.c.pepper@linux.intel.com>
Subject: mm: insure topdown mmap chooses addresses above security minimum
Date: Tue, 24 Sep 2013 14:23:31 -0700
Message-Id: <1380057811-5352-1-git-send-email-timothy.c.pepper@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Tim Pepper <timothy.c.pepper@linux.intel.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org

A security check is performed on mmap addresses in
security/security.c:security_mmap_addr().  It uses mmap_min_addr to insure
mmaps don't get addresses lower than a user configurable guard value
(/proc/sys/vm/mmap_min_addr).  The arch specific mmap topdown searches
look for a map candidate address all the way down to a low_limit that is
currently hard coded as PAGE_SIZE.  Depending on compile time options
and userspace setting the procfs tunable, the security check's view of
the minimum allowable address may be something greater than PAGE_SIZE.
This leaves a gap where get_unmapped_area()'s call to get_area() might
return an address above PAGE_SIZE, but below mmap_min_addr, and thus
get_unmapped_area() fails.

This was seen on x86_64 in the case of a topdown address space and a large
stack rlimit, with mmap_min_addr having been set to 32k by the distro.
This left a 28k gap where the get area search intends to place a small
mmap, but then get_unmapped_area() stumbles at the security check.

What should have happened is the address search wraps back to a higher
address, the search continues and perhaps succeeds.  Indeed an mmap of
a larger size gets a topdown search that does wrap around back up into
the rlimit stack reserve and succeeds assuming suitable free space.
But a small mmap fits in the low gap and always fails.  It becomes
possible to make large mmaps but not small ones.

When an explicit address hint is given, mm/mmap.c's round_hint_to_min()
will round up to mmap_min_addr.

A topdown search's low_limit should similarly consider mmap_min_addr
instead of just PAGE_SIZE.

Signed-off-by: Tim Pepper <timothy.c.pepper@linux.intel.com>
Cc: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Russell King <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: linux-sh@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
--
 arch/arm/mm/mmap.c               | 3 ++-
 arch/mips/mm/mmap.c              | 3 ++-
 arch/powerpc/mm/slice.c          | 3 ++-
 arch/sh/mm/mmap.c                | 3 ++-
 arch/sparc/kernel/sys_sparc_64.c | 3 ++-
 arch/x86/kernel/sys_x86_64.c     | 3 ++-
 6 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 0c63562..0e7355d 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -9,6 +9,7 @@
 #include <linux/io.h>
 #include <linux/personality.h>
 #include <linux/random.h>
+#include <linux/security.h>
 #include <asm/cachetype.h>
 
 #define COLOUR_ALIGN(addr,pgoff)		\
@@ -146,7 +147,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
-	info.low_limit = PAGE_SIZE;
+	info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
 	info.high_limit = mm->mmap_base;
 	info.align_mask = do_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index f1baadd..8c0deb7 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -14,6 +14,7 @@
 #include <linux/personality.h>
 #include <linux/random.h>
 #include <linux/sched.h>
+#include <linux/security.h>
 
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
@@ -102,7 +103,7 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 
 	if (dir == DOWN) {
 		info.flags = VM_UNMAPPED_AREA_TOPDOWN;
-		info.low_limit = PAGE_SIZE;
+		info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
 		info.high_limit = mm->mmap_base;
 		addr = vm_unmapped_area(&info);
 
diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
index 3e99c14..34fc601 100644
--- a/arch/powerpc/mm/slice.c
+++ b/arch/powerpc/mm/slice.c
@@ -30,6 +30,7 @@
 #include <linux/err.h>
 #include <linux/spinlock.h>
 #include <linux/export.h>
+#include <linux/security.h>
 #include <asm/mman.h>
 #include <asm/mmu.h>
 #include <asm/spu.h>
@@ -338,7 +339,7 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 			addr = prev;
 			goto prev_slice;
 		}
-		info.low_limit = addr;
+		info.low_limit = max(addr, PAGE_ALIGN(mmap_min_addr));
 
 		found = vm_unmapped_area(&info);
 		if (!(found & ~PAGE_MASK))
diff --git a/arch/sh/mm/mmap.c b/arch/sh/mm/mmap.c
index 6777177..1e0c53d 100644
--- a/arch/sh/mm/mmap.c
+++ b/arch/sh/mm/mmap.c
@@ -11,6 +11,7 @@
 #include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/module.h>
+#include <linux/security.h>
 #include <asm/page.h>
 #include <asm/processor.h>
 
@@ -119,7 +120,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
-	info.low_limit = PAGE_SIZE;
+	info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
 	info.high_limit = mm->mmap_base;
 	info.align_mask = do_colour_align ? (PAGE_MASK & shm_align_mask) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 51561b8..dab0a5d 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -24,6 +24,7 @@
 #include <linux/personality.h>
 #include <linux/random.h>
 #include <linux/export.h>
+#include <linux/security.h>
 
 #include <asm/uaccess.h>
 #include <asm/utrap.h>
@@ -188,7 +189,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
-	info.low_limit = PAGE_SIZE;
+	info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
 	info.high_limit = mm->mmap_base;
 	info.align_mask = do_color_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 30277e2..93e563e 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -15,6 +15,7 @@
 #include <linux/random.h>
 #include <linux/uaccess.h>
 #include <linux/elf.h>
+#include <linux/security.h>
 
 #include <asm/ia32.h>
 #include <asm/syscalls.h>
@@ -172,7 +173,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
-	info.low_limit = PAGE_SIZE;
+	info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
 	info.high_limit = mm->mmap_base;
 	info.align_mask = filp ? get_align_mask() : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

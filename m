Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 57E786B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 08:38:04 -0500 (EST)
Date: Mon, 18 Jan 2010 15:37:55 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100118133755.GG30698@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com
List-ID: <linux-mm.kvack.org>

The current interaction between mlockall(MCL_FUTURE) and mmap has a
deficiency. In 'normal' mode, without MCL_FUTURE in force, the default
is that new memory mappings are not locked, but mmap provides MAP_LOCKED
specifically to override that default. However, with MCL_FUTURE toggled
to on, there is no analogous way to tell mmap to override the default. The
proposed MAP_UNLOCKED flag would resolve this deficiency.

The benefit of the patch is that it makes it possible for an application
which has previously called mlockall(MCL_FUTURE) to selectively exempt
new memory mappings from memory locking, on a per-mmap-call basis. There
is currently no thread-safe way for an application to do this as
toggling MCL_FUTURE around calls to mmap is racy in a multi-threaded
context. Other threads may manipulate the address space during the
window where MCL_FUTURE is off, subverting the programmers intended
memory locking semantics.

The ability to exempt specific memory mappings from memory locking is
necessary when the region to be mapped is larger than physical memory.
In such cases a call to mmap the region cannot succeed, unless
MAP_UNLOCKED is available.

Acked-by: WANG Cong <xiyou.wangcong@gmail.com>
Acked-by: Chris Wright <chrisw@sous-sol.org>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---

I keep the acks since the patch is exactly the same, only commit message
is changed.
Commit message is mostly copied from Andrew C. Morrow email. Hope now it
is OK. Thank you Andrew :)

 v1->v2
   - adding new flag to all archs
   - fixing typo
 v2->v3
   - one more typo fix 
 v3->v4
   - return error if MAP_LOCKED | MAP_UNLOCKED is specified
 v4->v5
  - rebase to latest head 
 v5->v6
  - commit message rewritten
 
diff --git a/arch/alpha/include/asm/mman.h b/arch/alpha/include/asm/mman.h
index 99c56d4..cfc51ac 100644
--- a/arch/alpha/include/asm/mman.h
+++ b/arch/alpha/include/asm/mman.h
@@ -30,6 +30,7 @@
 #define MAP_NONBLOCK	0x40000		/* do not block on IO */
 #define MAP_STACK	0x80000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
+#define MAP_UNLOCKED	0x200000	/* force page unlocking */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_SYNC		2		/* synchronous memory sync */
diff --git a/arch/mips/include/asm/mman.h b/arch/mips/include/asm/mman.h
index c892bfb..3e4d108 100644
--- a/arch/mips/include/asm/mman.h
+++ b/arch/mips/include/asm/mman.h
@@ -48,6 +48,7 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
+#define MAP_UNLOCKED	0x100000	/* force page unlocking */
 
 /*
  * Flags for msync
diff --git a/arch/parisc/include/asm/mman.h b/arch/parisc/include/asm/mman.h
index 9749c8a..4e8b9bf 100644
--- a/arch/parisc/include/asm/mman.h
+++ b/arch/parisc/include/asm/mman.h
@@ -24,6 +24,7 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
+#define MAP_UNLOCKED	0x100000	/* force page unlocking */
 
 #define MS_SYNC		1		/* synchronous memory sync */
 #define MS_ASYNC	2		/* sync memory asynchronously */
diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index d4a7f64..7d33f01 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -27,6 +27,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_UNLOCKED	0x80000		/* force page unlocking */
 
 #ifdef __KERNEL__
 #ifdef CONFIG_PPC64
diff --git a/arch/sparc/include/asm/mman.h b/arch/sparc/include/asm/mman.h
index c3029ad..f80d203 100644
--- a/arch/sparc/include/asm/mman.h
+++ b/arch/sparc/include/asm/mman.h
@@ -22,6 +22,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_UNLOCKED	0x80000		/* force page unlocking */
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
diff --git a/arch/xtensa/include/asm/mman.h b/arch/xtensa/include/asm/mman.h
index fca4db4..c62bcd8 100644
--- a/arch/xtensa/include/asm/mman.h
+++ b/arch/xtensa/include/asm/mman.h
@@ -55,6 +55,7 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
+#define MAP_UNLOCKED	0x100000	/* force page unlocking */
 
 /*
  * Flags for msync
diff --git a/include/asm-generic/mman.h b/include/asm-generic/mman.h
index 32c8bd6..59e0f29 100644
--- a/include/asm-generic/mman.h
+++ b/include/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_UNLOCKED	0x80000         /* force page unlocking */
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
diff --git a/mm/mmap.c b/mm/mmap.c
index ee22989..4bda220 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -962,6 +962,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		if (!can_do_mlock())
 			return -EPERM;
 
+        if (flags & MAP_UNLOCKED)
+                vm_flags &= ~VM_LOCKED;
+
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
@@ -1050,7 +1053,10 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 	struct file *file = NULL;
 	unsigned long retval = -EBADF;
 
-	if (!(flags & MAP_ANONYMOUS)) {
+	if (unlikely((flags & (MAP_LOCKED | MAP_UNLOCKED)) ==
+			(MAP_LOCKED | MAP_UNLOCKED))) {
+		return -EINVAL;
+	} else if (!(flags & MAP_ANONYMOUS)) {
 		if (unlikely(flags & MAP_HUGETLB))
 			return -EINVAL;
 		file = fget(fd);
--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

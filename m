Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27C7C280396
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 15:07:57 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u11so12019331qtu.10
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 12:07:57 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id n1si2142685qkc.535.2017.08.04.12.07.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 12:07:56 -0700 (PDT)
From: riel@redhat.com
Subject: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
Date: Fri,  4 Aug 2017 15:07:30 -0400
Message-Id: <20170804190730.17858-3-riel@redhat.com>
In-Reply-To: <20170804190730.17858-1-riel@redhat.com>
References: <20170804190730.17858-1-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org

From: Rik van Riel <riel@redhat.com>

Introduce MADV_WIPEONFORK semantics, which result in a VMA being
empty in the child process after fork. This differs from MADV_DONTFORK
in one important way.

If a child process accesses memory that was MADV_WIPEONFORK, it
will get zeroes. The address ranges are still valid, they are just empty.

If a child process accesses memory that was MADV_DONTFORK, it will
get a segmentation fault, since those address ranges are no longer
valid in the child after fork.

Since MADV_DONTFORK also seems to be used to allow very large
programs to fork in systems with strict memory overcommit restrictions,
changing the semantics of MADV_DONTFORK might break existing programs.

The use case is libraries that store or cache information, and
want to know that they need to regenerate it in the child process
after fork.

Examples of this would be:
- systemd/pulseaudio API checks (fail after fork)
  (replacing a getpid check, which is too slow without a PID cache)
- PKCS#11 API reinitialization check (mandated by specification)
- glibc's upcoming PRNG (reseed after fork)
- OpenSSL PRNG (reseed after fork)

The security benefits of a forking server having a re-inialized
PRNG in every child process are pretty obvious. However, due to
libraries having all kinds of internal state, and programs getting
compiled with many different versions of each library, it is
unreasonable to expect calling programs to re-initialize everything
manually after fork.

A further complication is the proliferation of clone flags,
programs bypassing glibc's functions to call clone directly,
and programs calling unshare, causing the glibc pthread_atfork
hook to not get called.

It would be better to have the kernel take care of this automatically.

This is similar to the OpenBSD minherit syscall with MAP_INHERIT_ZERO:

    https://man.openbsd.org/minherit.2

Reported-by: Florian Weimer <fweimer@redhat.com>
Reported-by: Colm MacCA!rtaigh <colm@allcosts.net>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 arch/alpha/include/uapi/asm/mman.h     |  3 +++
 arch/mips/include/uapi/asm/mman.h      |  3 +++
 arch/parisc/include/uapi/asm/mman.h    |  3 +++
 arch/xtensa/include/uapi/asm/mman.h    |  3 +++
 fs/proc/task_mmu.c                     |  1 +
 include/linux/mm.h                     |  2 +-
 include/uapi/asm-generic/mman-common.h |  3 +++
 kernel/fork.c                          |  8 ++++++--
 mm/madvise.c                           |  8 ++++++++
 mm/memory.c                            | 10 ++++++++++
 10 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 02760f6e6ca4..2a708a792882 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -64,6 +64,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
+#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 655e2fb5395b..d59c57d60d7d 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -91,6 +91,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
+#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 5979745815a5..e205e0179642 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -60,6 +60,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	70		/* Clear the MADV_NODUMP flag */
 
+#define MADV_WIPEONFORK 71		/* Zero memory on fork, child only */
+#define MADV_KEEPONFORK 72		/* Undo MADV_WIPEONFORK */
+
 /* compatibility flags */
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 24365b30aae9..ed23e0a1b30d 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -103,6 +103,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
 
+#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
+#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b836fd61ed87..2591e70216ff 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -651,6 +651,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_NORESERVE)]	= "nr",
 		[ilog2(VM_HUGETLB)]	= "ht",
 		[ilog2(VM_ARCH_1)]	= "ar",
+		[ilog2(VM_WIPEONFORK)]	= "wf",
 		[ilog2(VM_DONTDUMP)]	= "dd",
 #ifdef CONFIG_MEM_SOFT_DIRTY
 		[ilog2(VM_SOFTDIRTY)]	= "sd",
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7550eeb06ccf..58788c1b9e9d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -189,7 +189,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
-#define VM_ARCH_2	0x02000000
+#define VM_WIPEONFORK	0x02000000	/* Wipe VMA contents in child. */
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 8c27db0c5c08..49e2b1d78093 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -58,6 +58,9 @@
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_DONTDUMP flag */
 
+#define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
+#define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 17921b0390b4..2dd0d0cae3bb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -628,7 +628,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 
 	prev = NULL;
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
-		struct file *file;
+		struct file *file = NULL;
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
 			vm_stat_account(mm, mpnt->vm_flags, -vma_pages(mpnt));
@@ -658,7 +658,11 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 			goto fail_nomem_anon_vma_fork;
 		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
 		tmp->vm_next = tmp->vm_prev = NULL;
-		file = tmp->vm_file;
+
+		/* With VM_WIPEONFORK, the child gets an empty VMA. */
+		if (!(tmp->vm_flags & VM_WIPEONFORK))
+			file = tmp->vm_file;
+
 		if (file) {
 			struct inode *inode = file_inode(file);
 			struct address_space *mapping = file->f_mapping;
diff --git a/mm/madvise.c b/mm/madvise.c
index 9976852f1e1c..9e644c0ed4dc 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -80,6 +80,12 @@ static long madvise_behavior(struct vm_area_struct *vma,
 		}
 		new_flags &= ~VM_DONTCOPY;
 		break;
+	case MADV_WIPEONFORK:
+		new_flags |= VM_WIPEONFORK;
+		break;
+	case MADV_KEEPONFORK:
+		new_flags &= ~VM_WIPEONFORK;
+		break;
 	case MADV_DONTDUMP:
 		new_flags |= VM_DONTDUMP;
 		break;
@@ -689,6 +695,8 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_WIPEONFORK:
+	case MADV_KEEPONFORK:
 #ifdef CONFIG_MEMORY_FAILURE
 	case MADV_SOFT_OFFLINE:
 	case MADV_HWPOISON:
diff --git a/mm/memory.c b/mm/memory.c
index 0e517be91a89..f9b0ad7feb57 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1134,6 +1134,16 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			!vma->anon_vma)
 		return 0;
 
+	/*
+	 * With VM_WIPEONFORK, the child inherits the VMA from the
+	 * parent, but not its contents.
+	 *
+	 * A child accessing VM_WIPEONFORK memory will see all zeroes;
+	 * a child accessing VM_DONTCOPY memory receives a segfault.
+	 */
+	if (vma->vm_flags & VM_WIPEONFORK)
+		return 0;
+
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

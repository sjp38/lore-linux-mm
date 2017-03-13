Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 176C76B0399
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:14:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c143so15966092wmd.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:14:41 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 05/13] mm: Add mm_struct argument to 'mm_populate' and '__mm_populate'
Date: Mon, 13 Mar 2017 15:14:07 -0700
Message-Id: <20170313221415.9375-6-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Add to the 'mm_populate' and '__mm_populate' functions as additional
argument which mm_struct they should use during their execution. Before,
these functions simply used the memory map of the current task. However,
with the introduction of first class virtual address spaces, both
functions also need to be able to operate on other memory maps than just
the one of the current task. Accordingly, it is now possible to specify
explicitly which memory map these functions should use via an additional
argument.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
---
 arch/x86/mm/mpx.c  |  2 +-
 include/linux/mm.h | 13 ++++++++-----
 ipc/shm.c          |  9 +++++----
 mm/gup.c           |  4 ++--
 mm/mlock.c         | 21 +++++++++++----------
 mm/mmap.c          |  6 +++---
 mm/mremap.c        |  2 +-
 mm/util.c          |  2 +-
 8 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 99c664a97c35..b46f7cdbdad8 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -54,7 +54,7 @@ static unsigned long mpx_mmap(unsigned long len)
 		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate);
 	up_write(&mm->mmap_sem);
 	if (populate)
-		mm_populate(addr, populate);
+		mm_populate(mm, addr, populate);
 
 	return addr;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1520da8f9c67..92925d97da20 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2040,15 +2040,18 @@ do_mmap_pgoff(struct mm_struct *mm, struct file *file, unsigned long addr,
 }
 
 #ifdef CONFIG_MMU
-extern int __mm_populate(unsigned long addr, unsigned long len,
-			 int ignore_errors);
-static inline void mm_populate(unsigned long addr, unsigned long len)
+extern int __mm_populate(struct mm_struct *mm, unsigned long addr,
+			 unsigned long len, int ignore_errors);
+static inline void mm_populate(struct mm_struct *mm, unsigned long addr,
+			       unsigned long len)
 {
 	/* Ignore errors */
-	(void) __mm_populate(addr, len, 1);
+	(void) __mm_populate(mm, addr, len, 1);
 }
 #else
-static inline void mm_populate(unsigned long addr, unsigned long len) {}
+static inline void mm_populate(struct mm_struct *mm, unsigned long addr,
+			       unsigned long len)
+{}
 #endif
 
 /* These take the mm semaphore themselves */
diff --git a/ipc/shm.c b/ipc/shm.c
index 2fd73cda4ec8..be692e0abe79 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1106,6 +1106,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	struct shm_file_data *sfd;
 	struct path path;
 	fmode_t f_mode;
+	struct mm_struct *mm = current->mm;
 	unsigned long populate = 0;
 
 	err = -EINVAL;
@@ -1208,7 +1209,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	if (err)
 		goto out_fput;
 
-	if (down_write_killable(&current->mm->mmap_sem)) {
+	if (down_write_killable(&mm->mmap_sem)) {
 		err = -EINTR;
 		goto out_fput;
 	}
@@ -1218,7 +1219,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 		if (addr + size < addr)
 			goto invalid;
 
-		if (find_vma_intersection(current->mm, addr, addr + size))
+		if (find_vma_intersection(mm, addr, addr + size))
 			goto invalid;
 	}
 
@@ -1229,9 +1230,9 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	if (IS_ERR_VALUE(addr))
 		err = (long)addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	up_write(&mm->mmap_sem);
 	if (populate)
-		mm_populate(addr, populate);
+		mm_populate(mm, addr, populate);
 
 out_fput:
 	fput(file);
diff --git a/mm/gup.c b/mm/gup.c
index 55315555489d..ca5ba2703b40 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1053,9 +1053,9 @@ long populate_vma_page_range(struct vm_area_struct *vma,
  * flags. VMAs must be already marked with the desired vm_flags, and
  * mmap_sem must not be held.
  */
-int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
+int __mm_populate(struct mm_struct *mm, unsigned long start, unsigned long len,
+		  int ignore_errors)
 {
-	struct mm_struct *mm = current->mm;
 	unsigned long end, nstart, nend;
 	struct vm_area_struct *vma = NULL;
 	int locked = 0;
diff --git a/mm/mlock.c b/mm/mlock.c
index cdbed8aaa426..9d74948c7b22 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -664,6 +664,7 @@ static int count_mm_mlocked_page_nr(struct mm_struct *mm,
 
 static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 {
+	struct mm_struct *mm = current->mm;
 	unsigned long locked;
 	unsigned long lock_limit;
 	int error = -ENOMEM;
@@ -680,10 +681,10 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	lock_limit >>= PAGE_SHIFT;
 	locked = len >> PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-	locked += current->mm->locked_vm;
+	locked += mm->locked_vm;
 	if ((locked > lock_limit) && (!capable(CAP_IPC_LOCK))) {
 		/*
 		 * It is possible that the regions requested intersect with
@@ -691,19 +692,18 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 		 * should not be counted to new mlock increment count. So check
 		 * and adjust locked count if necessary.
 		 */
-		locked -= count_mm_mlocked_page_nr(current->mm,
-				start, len);
+		locked -= count_mm_mlocked_page_nr(mm, start, len);
 	}
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = apply_vma_lock_flags(start, len, flags);
 
-	up_write(&current->mm->mmap_sem);
+	up_write(&mm->mmap_sem);
 	if (error)
 		return error;
 
-	error = __mm_populate(start, len, 0);
+	error = __mm_populate(mm, start, len, 0);
 	if (error)
 		return __mlock_posix_error_return(error);
 	return 0;
@@ -790,6 +790,7 @@ static int apply_mlockall_flags(int flags)
 
 SYSCALL_DEFINE1(mlockall, int, flags)
 {
+	struct mm_struct *mm = current->mm;
 	unsigned long lock_limit;
 	int ret;
 
@@ -805,16 +806,16 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
 	ret = -ENOMEM;
-	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
+	if (!(flags & MCL_CURRENT) || (mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = apply_mlockall_flags(flags);
-	up_write(&current->mm->mmap_sem);
+	up_write(&mm->mmap_sem);
 	if (!ret && (flags & MCL_CURRENT))
-		mm_populate(0, TASK_SIZE);
+		mm_populate(mm, 0, TASK_SIZE);
 
 	return ret;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index 8a73dc458e69..3f60c8ebd6b6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -236,7 +236,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
 	up_write(&mm->mmap_sem);
 	if (populate)
-		mm_populate(oldbrk, newbrk - oldbrk);
+		mm_populate(mm, oldbrk, newbrk - oldbrk);
 	return brk;
 
 out:
@@ -2781,7 +2781,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 out:
 	up_write(&mm->mmap_sem);
 	if (populate)
-		mm_populate(ret, populate);
+		mm_populate(mm, ret, populate);
 	if (!IS_ERR_VALUE(ret))
 		ret = 0;
 	return ret;
@@ -2898,7 +2898,7 @@ int vm_brk(unsigned long addr, unsigned long len)
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
 	up_write(&mm->mmap_sem);
 	if (populate && !ret)
-		mm_populate(addr, len);
+		mm_populate(mm, addr, len);
 	return ret;
 }
 EXPORT_SYMBOL(vm_brk);
diff --git a/mm/mremap.c b/mm/mremap.c
index f085eed57bac..0f18ec452441 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -602,6 +602,6 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	}
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
-		mm_populate(new_addr + old_len, new_len - old_len);
+		mm_populate(mm, new_addr + old_len, new_len - old_len);
 	return ret;
 }
diff --git a/mm/util.c b/mm/util.c
index 46d05eef9a6b..7b1116b400a3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -306,7 +306,7 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 				    &populate);
 		up_write(&mm->mmap_sem);
 		if (populate)
-			mm_populate(ret, populate);
+			mm_populate(mm, ret, populate);
 	}
 	return ret;
 }
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 12 Oct 1999 10:06:06 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: [more fun] Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910111850370.18777-100000@weyl.math.psu.edu>
Message-ID: <Pine.GSO.4.10.9910120716490.22333-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Funny path #1: on 386 (sucky WP) copy_to_user() -> access_ok() ->
__verify_write() -> handle_mm_fault() and no mmap_sem in sight. Ditto for
__verify_write() on sh.

Another one: ptrace_readdata() -> access_process_vm() -> find_extend_vma()
-> make_pages_present(). Again, no mmap_sem in sight.

irix_brk(): calls do_brk() without mmap_sem.

sys_cacheflush() (on m68k): plays with vma without mmap_sem.

Patch follows (2.3.20, but these files didn't change in .21).

diff -urN linux-2.3.20/arch/i386/mm/fault.c linux-bird.mm/arch/i386/mm/fault.c
--- linux-2.3.20/arch/i386/mm/fault.c	Sun Sep 12 11:01:01 1999
+++ linux-bird.mm/arch/i386/mm/fault.c	Tue Oct 12 07:44:55 1999
@@ -35,6 +35,7 @@
 	if (!size)
 		return 1;
 
+	down(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, start);
 	if (!vma)
 		goto bad_area;
@@ -64,6 +65,7 @@
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;;
 	}
+	up(&current->mm->mmap_sem);
 	return 1;
 
 check_stack:
@@ -73,6 +75,7 @@
 		goto good_area;
 
 bad_area:
+	up(&current->mm->mmap_sem);
 	return 0;
 }
 
diff -urN linux-2.3.20/arch/m68k/kernel/sys_m68k.c linux-bird.mm/arch/m68k/kernel/sys_m68k.c
--- linux-2.3.20/arch/m68k/kernel/sys_m68k.c	Mon Jun 21 12:35:55 1999
+++ linux-bird.mm/arch/m68k/kernel/sys_m68k.c	Tue Oct 12 09:56:24 1999
@@ -535,6 +535,7 @@
 	int ret = -EINVAL;
 
 	lock_kernel();
+	down(&current->mm->mmap_sem);
 	if (scope < FLUSH_SCOPE_LINE || scope > FLUSH_SCOPE_ALL ||
 	    cache & ~FLUSH_CACHE_BOTH)
 		goto out;
@@ -591,6 +592,7 @@
 		ret = cache_flush_060 (addr, scope, cache, len);
 	}
 out:
+	up(&current->mm->mmap_sem);
 	unlock_kernel();
 	return ret;
 }
diff -urN linux-2.3.20/arch/mips/kernel/sysirix.c linux-bird.mm/arch/mips/kernel/sysirix.c
--- linux-2.3.20/arch/mips/kernel/sysirix.c	Sun Sep 12 05:54:08 1999
+++ linux-bird.mm/arch/mips/kernel/sysirix.c	Tue Oct 12 09:46:09 1999
@@ -534,6 +534,7 @@
 	int ret;
 
 	lock_kernel();
+	down(&current->mm->mmap_sem);
 	if (brk < current->mm->end_code) {
 		ret = -ENOMEM;
 		goto out;
@@ -591,6 +592,7 @@
 	ret = 0;
 
 out:
+	up(&current->mm->mmap_sem);
 	unlock_kernel();
 	return ret;
 }
diff -urN linux-2.3.20/arch/sh/mm/fault.c linux-bird.mm/arch/sh/mm/fault.c
--- linux-2.3.20/arch/sh/mm/fault.c	Sun Sep 12 13:29:49 1999
+++ linux-bird.mm/arch/sh/mm/fault.c	Tue Oct 12 09:57:03 1999
@@ -38,6 +38,7 @@
 	if (!size)
 		return 1;
 
+	down(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, start);
 	if (!vma)
 		goto bad_area;
@@ -67,6 +68,7 @@
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;;
 	}
+	up(&current->mm->mmap_sem);
 	return 1;
 
 check_stack:
@@ -76,6 +78,7 @@
 		goto good_area;
 
 bad_area:
+	up(&current->mm->mmap_sem);
 	return 0;
 }
 
diff -urN linux-2.3.20/kernel/ptrace.c linux-bird.mm/kernel/ptrace.c
--- linux-2.3.20/kernel/ptrace.c	Sun Sep 12 13:03:24 1999
+++ linux-bird.mm/kernel/ptrace.c	Tue Oct 12 09:15:27 1999
@@ -79,14 +79,15 @@
 
 int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write)
 {
-	int copied;
-	struct vm_area_struct * vma = find_extend_vma(tsk, addr);
+	int copied = 0;
+	struct vm_area_struct * vma;
+
+	down(&tsk->mm->mmap_sem);
+	vma = find_extend_vma(tsk, addr);
 
 	if (!vma)
-		return 0;
+		goto out;
 
-	down(&tsk->mm->mmap_sem);
-	copied = 0;
 	for (;;) {
 		unsigned long offset = addr & ~PAGE_MASK;
 		int this_len = PAGE_SIZE - offset;
@@ -115,6 +116,7 @@
 	
 		vma = vma->vm_next;
 	}
+out:
 	up(&tsk->mm->mmap_sem);
 	return copied;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

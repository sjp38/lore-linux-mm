From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910191950.MAA63187@google.engr.sgi.com>
Subject: [PATCH]kanoj-mm20-2.3.22 rlimits/RLIM_INFINITY fixes
Date: Tue, 19 Oct 1999 12:50:21 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

I have posted this rlimits patch before, but it has not made it into
2.3 yet. This patch is neccesary for any application that wants to 
have a >2Gb user address space.

Please take this into 2.3. Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a005Pw/mem.c	Tue Oct 19 12:42:21 1999
+++ fs/proc/mem.c	Tue Oct 19 10:56:38 1999
@@ -265,7 +265,9 @@
 		if (stmp < src_vma->vm_start) {
 			if (!(src_vma->vm_flags & VM_GROWSDOWN))
 				return -EINVAL;
-			if (src_vma->vm_end - stmp > current->rlim[RLIMIT_STACK].rlim_cur)
+			if ((current->rlim[RLIMIT_STACK].rlim_cur < 
+			     RLIM_INFINITY) && (src_vma->vm_end - stmp > 
+			     current->rlim[RLIMIT_STACK].rlim_cur))
 				return -EINVAL;
 		}
 		stmp += PAGE_SIZE;
--- /usr/tmp/p_rdiff_a005Q5/mm.h	Tue Oct 19 12:42:30 1999
+++ include/linux/mm.h	Tue Oct 19 11:19:48 1999
@@ -393,10 +393,11 @@
 
 	address &= PAGE_MASK;
 	grow = vma->vm_start - address;
-	if (vma->vm_end - address
-	    > (unsigned long) current->rlim[RLIMIT_STACK].rlim_cur ||
-	    (vma->vm_mm->total_vm << PAGE_SHIFT) + grow
-	    > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
+	if (((current->rlim[RLIMIT_STACK].rlim_cur < RLIM_INFINITY) &&
+	    (vma->vm_end - address > current->rlim[RLIMIT_STACK].rlim_cur)) ||
+	    ((current->rlim[RLIMIT_AS].rlim_cur < RLIM_INFINITY) &&
+	    ((vma->vm_mm->total_vm << PAGE_SHIFT) + grow
+	    > current->rlim[RLIMIT_AS].rlim_cur)))
 		return -ENOMEM;
 	vma->vm_start = address;
 	vma->vm_offset -= grow;
--- /usr/tmp/p_rdiff_a005QG/shm.c	Tue Oct 19 12:42:41 1999
+++ ipc/shm.c	Tue Oct 19 10:56:38 1999
@@ -458,8 +458,9 @@
 
 	/* add new mapping */
 	tmp = shmd->vm_end - shmd->vm_start;
-	if((current->mm->total_vm << PAGE_SHIFT) + tmp
-	   > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
+	if ((current->rlim[RLIMIT_AS].rlim_cur < RLIM_INFINITY) && 
+	   ((current->mm->total_vm << PAGE_SHIFT) + tmp
+	   > current->rlim[RLIMIT_AS].rlim_cur))
 		return -ENOMEM;
 	current->mm->total_vm += tmp >> PAGE_SHIFT;
 	insert_vm_struct(current->mm, shmd);
--- /usr/tmp/p_rdiff_a005QP/mlock.c	Tue Oct 19 12:42:55 1999
+++ mm/mlock.c	Tue Oct 19 10:56:38 1999
@@ -186,11 +186,13 @@
 	locked += current->mm->locked_vm;
 
 	lock_limit = current->rlim[RLIMIT_MEMLOCK].rlim_cur;
-	lock_limit >>= PAGE_SHIFT;
+	if (lock_limit < RLIM_INFINITY) {
+		lock_limit >>= PAGE_SHIFT;
 
-	/* check against resource limits */
-	if (locked > lock_limit)
-		goto out;
+		/* check against resource limits */
+		if (locked > lock_limit)
+			goto out;
+	}
 
 	/* we may lock at most half of physical memory... */
 	/* (this check is pretty bogus, but doesn't hurt) */
@@ -253,12 +255,14 @@
 	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
 		goto out;
 
+	ret = -ENOMEM;
 	lock_limit = current->rlim[RLIMIT_MEMLOCK].rlim_cur;
-	lock_limit >>= PAGE_SHIFT;
+	if (lock_limit < RLIM_INFINITY) {
+		lock_limit >>= PAGE_SHIFT;
 
-	ret = -ENOMEM;
-	if (current->mm->total_vm > lock_limit)
-		goto out;
+		if (current->mm->total_vm > lock_limit)
+			goto out;
+	}
 
 	/* we may lock at most half of physical memory... */
 	/* (this check is pretty bogus, but doesn't hurt) */
--- /usr/tmp/p_rdiff_a005QY/mmap.c	Tue Oct 19 12:43:04 1999
+++ mm/mmap.c	Tue Oct 19 10:56:38 1999
@@ -191,7 +191,8 @@
 	if (mm->def_flags & VM_LOCKED) {
 		unsigned long locked = mm->locked_vm << PAGE_SHIFT;
 		locked += len;
-		if (locked > current->rlim[RLIMIT_MEMLOCK].rlim_cur)
+		if ((current->rlim[RLIMIT_MEMLOCK].rlim_cur < RLIM_INFINITY) &&
+		   (locked > current->rlim[RLIMIT_MEMLOCK].rlim_cur))
 			return -EAGAIN;
 	}
 
@@ -282,8 +283,9 @@
 		goto free_vma;
 
 	/* Check against address space limit. */
-	if ((mm->total_vm << PAGE_SHIFT) + len
-	    > current->rlim[RLIMIT_AS].rlim_cur)
+	if ((current->rlim[RLIMIT_AS].rlim_cur < RLIM_INFINITY) &&
+	    ((mm->total_vm << PAGE_SHIFT) + len
+	    > current->rlim[RLIMIT_AS].rlim_cur))
 		goto free_vma;
 
 	/* Private writable mapping? Check memory availability.. */
@@ -737,7 +739,8 @@
 	if (mm->def_flags & VM_LOCKED) {
 		unsigned long locked = mm->locked_vm << PAGE_SHIFT;
 		locked += len;
-		if (locked > current->rlim[RLIMIT_MEMLOCK].rlim_cur)
+		if ((current->rlim[RLIMIT_MEMLOCK].rlim_cur < RLIM_INFINITY) &&
+		   (locked > current->rlim[RLIMIT_MEMLOCK].rlim_cur))
 			return -EAGAIN;
 	}
 
@@ -749,8 +752,9 @@
 		return retval;
 
 	/* Check against address space limits *after* clearing old maps... */
-	if ((mm->total_vm << PAGE_SHIFT) + len
-	    > current->rlim[RLIMIT_AS].rlim_cur)
+	if ((current->rlim[RLIMIT_AS].rlim_cur < RLIM_INFINITY) &&
+	    ((mm->total_vm << PAGE_SHIFT) + len
+	    > current->rlim[RLIMIT_AS].rlim_cur))
 		return -ENOMEM;
 
 	if (mm->map_count > MAX_MAP_COUNT)
--- /usr/tmp/p_rdiff_a005Qf/mremap.c	Tue Oct 19 12:43:14 1999
+++ mm/mremap.c	Tue Oct 19 10:56:38 1999
@@ -198,12 +198,14 @@
 		unsigned long locked = current->mm->locked_vm << PAGE_SHIFT;
 		locked += new_len - old_len;
 		ret = -EAGAIN;
-		if (locked > current->rlim[RLIMIT_MEMLOCK].rlim_cur)
+		if ((current->rlim[RLIMIT_MEMLOCK].rlim_cur < RLIM_INFINITY) &&
+		   (locked > current->rlim[RLIMIT_MEMLOCK].rlim_cur))
 			goto out;
 	}
 	ret = -ENOMEM;
-	if ((current->mm->total_vm << PAGE_SHIFT) + (new_len - old_len)
-	    > current->rlim[RLIMIT_AS].rlim_cur)
+	if ((current->rlim[RLIMIT_AS].rlim_cur < RLIM_INFINITY) &&
+	    ((current->mm->total_vm << PAGE_SHIFT) + (new_len - old_len)
+	    > current->rlim[RLIMIT_AS].rlim_cur))
 		goto out;
 	/* Private writable mapping? Check memory availability.. */
 	if ((vma->vm_flags & (VM_SHARED | VM_WRITE)) == VM_WRITE &&
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Subject: [RFC] mapping parts of shared memory
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 25 Nov 1999 14:58:19 +0100
Message-ID: <qww3dtuisg4.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, MM mailing list <linux-mm@kvack.org>
Cc: Doug Ledford <dledford@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>
List-ID: <linux-mm.kvack.org>

Hi,

I was investigating for some time about the possibility to create some
object which allows me to map and unmap parts of it it in different
processes. This would help to take advantage of the high memory
systems with applications like SAP R/3 which uses a small number of
processes to server many clients. It is now limited by the available
address space for one process.

I see the following possibilties (in decreasing order of acceptance):

1) use posix shm (shm_open and mmap).
   - This is not (yet?) implemented in Linux. 
   + standard API which fits cleanly into the UNIX API

2) add a flag to mmap(2) which replaces the filedescriptor with a shm
   segment identifier.
   - nonstandard API extension
   + easy to implement
   + consistent user API since you use /mmap/munmap like for shm_open

3) add a command to shmctl(2) which allows to map arbitrary page
   ranges out of a shm segment.
   - nonstandard API extension
   - inconsistent user API since you use shmctl for map and munmap()
     for unmap
   + easy to implement
   + less intrusive than 2) since it is local to shm

4) open a regular file and mmap(2).
   + works without changes
   - It syncs on unmap which kills performance badly
   - You have to reserve the same amount of disk space on your
     filesystem as you will ues memory. This is like the old UNIX swap
     behaviour.
   - The user cannot tune the virtual memory space solely by adding
     swap space.

The appended a patch which implements 2) for i386. It can be easily
extended for other architectures also.

I would really like to see 1), but I do not see how to implement this
best:

a) eric biedermann is working on shmfs for some time. It seems to be
   a lot of work and not for the near future. It has also the drawback
   that you have to know where the filesystem is mounted.
b) We could extend sysv shm to add the call shm_open. This would be
   much less intrusive than the filesystem. It could be completely
   done in shm.c. I see the following possibilities:
   i)  This could be done in the same way like unix domain sockets
       allocate the sockets in the normal name space. But here we run
       into the same problems like unix domain sockets: stale files
       without a reflecting object.
   ii) create your own name space without reflecting it in the
       filesystem. But how do I provide a dentry for such a
       filedecriptor?

Any comments?
             Christoph


diff -uNr 2.3.28/arch/i386/kernel/sys_i386.c make28/arch/i386/kernel/sys_i386.c
--- 2.3.28/arch/i386/kernel/sys_i386.c	Sun Nov  7 11:41:57 1999
+++ make28/arch/i386/kernel/sys_i386.c	Sun Nov 14 11:04:13 1999
@@ -73,7 +73,21 @@
 		file = fget(a.fd);
 		if (!file)
 			goto out;
-	}
+	} else if (a.flags & MAP_SYSV) {
+                int shmflg;
+                unsigned long raddr;
+                error = -EINVAL;
+                if (!(a.flags & MAP_SHARED))
+                        goto out;
+                
+                shmflg = (((a.flags | MAP_FIXED) ? 0 : SHM_RND) | 
+                          (a.addr ? SHM_REMAP : 0));
+                unlock_kernel();
+                error = shmmap (a.fd, a.addr, a.prot, shmflg, &raddr,
+                              1, a.len, a.offset);
+                return error ? error : raddr;
+        }
+
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
 	error = do_mmap(file, a.addr, a.len, a.prot, a.flags, a.offset);
diff -uNr 2.3.28/include/asm-i386/mman.h make28/include/asm-i386/mman.h
--- 2.3.28/include/asm-i386/mman.h	Mon Oct  7 07:55:48 1996
+++ make28/include/asm-i386/mman.h	Sat Nov 13 21:02:02 1999
@@ -8,6 +8,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
+#define MAP_SYSV	0x04		/* Map SYSV shm segment */
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
diff -uNr 2.3.28/include/linux/shm.h make28/include/linux/shm.h
--- 2.3.28/include/linux/shm.h	Sat Nov 13 16:51:17 1999
+++ make28/include/linux/shm.h	Sat Nov 13 22:27:38 1999
@@ -74,6 +74,8 @@
 asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, unsigned long *addr);
 asmlinkage long sys_shmdt (char *shmaddr);
 asmlinkage long sys_shmctl (int shmid, int cmd, struct shmid_ds *buf);
+long shmmap (int shmid, unsigned long shmaddr, unsigned long prot, int shmflg,
+             ulong *raddr, int extended, size_t len, off_t off);
 extern void shm_unuse(swp_entry_t entry, struct page *page);
 
 #endif /* __KERNEL__ */
diff -uNr 2.3.28/ipc/shm.c make28/ipc/shm.c
--- 2.3.28/ipc/shm.c	Sat Nov 13 16:43:55 1999
+++ make28/ipc/shm.c	Sun Nov 14 11:02:57 1999
@@ -19,10 +19,10 @@
 #include <linux/swap.h>
 #include <linux/smp_lock.h>
 #include <linux/init.h>
-#include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
 #include <linux/highmem.h>
+#include <linux/mman.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -579,19 +579,15 @@
 	return 0;
 }
 
-/*
- * Fix shmaddr, allocate descriptor, map shm, add attach descriptor to lists.
- */
-asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, ulong *raddr)
+long shmmap (int shmid, unsigned long shmaddr, unsigned long prot, int shmflg,
+             ulong *raddr, int extended, size_t len, off_t off)
 {
 	struct shmid_kernel *shp;
 	struct vm_area_struct *shmd;
 	int err = -EINVAL;
 	unsigned int id;
 	unsigned long addr;
-	unsigned long len;
 
-	down(&current->mm->mmap_sem);
 	spin_lock(&shm_lock);
 	if (shmid < 0)
 		goto out;
@@ -600,13 +596,23 @@
 	if (shp == IPC_UNUSED || shp == IPC_NOID)
 		goto out;
 
-	if (!(addr = (ulong) shmaddr)) {
+        if (!extended)
+                len = PAGE_ALIGN(shp->u.shm_segsz);
+        else
+                len = PAGE_ALIGN(len);
+
+        if (off & (PAGE_SIZE -1))
+                goto out;
+        if (off + len > PAGE_SIZE * shp->shm_npages)
+                goto out;
+
+	if (!(addr = shmaddr)) {
 		if (shmflg & SHM_REMAP)
 			goto out;
 		err = -ENOMEM;
 		addr = 0;
 	again:
-		if (!(addr = get_unmapped_area(addr, (unsigned long)shp->u.shm_segsz)))
+		if (!(addr = get_unmapped_area(addr, len)))
 			goto out;
 		if(addr & (SHMLBA - 1)) {
 			addr = (addr + (SHMLBA - 1)) & ~(SHMLBA - 1);
@@ -621,7 +627,6 @@
 	/*
 	 * Check if addr exceeds TASK_SIZE (from do_mmap)
 	 */
-	len = PAGE_SIZE*shp->shm_npages;
 	err = -EINVAL;
 	if (addr >= TASK_SIZE || len > TASK_SIZE  || addr > TASK_SIZE - len)
 		goto out;
@@ -630,13 +635,16 @@
 	 * space left for the stack to grow (presently 4 pages).
 	 */
 	if (addr < current->mm->start_stack &&
-	    addr > current->mm->start_stack - PAGE_SIZE*(shp->shm_npages + 4))
+	    addr > current->mm->start_stack - len - PAGE_SIZE*4)
 		goto out;
-	if (!(shmflg & SHM_REMAP) && find_vma_intersection(current->mm, addr, addr + (unsigned long)shp->u.shm_segsz))
+	if (!(shmflg & SHM_REMAP) && find_vma_intersection(current->mm, addr, addr + len))
 		goto out;
 
 	err = -EACCES;
-	if (ipcperms(&shp->u.shm_perm, shmflg & SHM_RDONLY ? S_IRUGO : S_IRUGO|S_IWUGO))
+	if (ipcperms(&shp->u.shm_perm,
+                     (prot & PROT_READ)  ? S_IRUGO : 0 |
+                     (prot & PROT_WRITE) ? S_IWUGO : 0 |
+                     (prot & PROT_EXEC)  ? S_IXUGO : 0))
 		goto out;
 	err = -EIDRM;
 	if (shp->u.shm_perm.seq != (unsigned int) shmid / IPCMNI)
@@ -656,14 +664,15 @@
 
 	shmd->vm_private_data = shm_segs[id];
 	shmd->vm_start = addr;
-	shmd->vm_end = addr + shp->shm_npages * PAGE_SIZE;
+	shmd->vm_end = addr + len;
 	shmd->vm_mm = current->mm;
-	shmd->vm_page_prot = (shmflg & SHM_RDONLY) ? PAGE_READONLY : PAGE_SHARED;
+	shmd->vm_page_prot = (prot & PROT_WRITE) ? PAGE_SHARED : PAGE_READONLY;
 	shmd->vm_flags = VM_SHM | VM_MAYSHARE | VM_SHARED
-			 | VM_MAYREAD | VM_MAYEXEC | VM_READ | VM_EXEC
-			 | ((shmflg & SHM_RDONLY) ? 0 : VM_MAYWRITE | VM_WRITE);
+                | ((prot & PROT_READ) ? VM_MAYREAD | VM_READ : 0)
+                | ((prot & PROT_EXEC) ? VM_MAYEXEC | VM_EXEC : 0)
+                | ((prot & PROT_WRITE) ? VM_MAYWRITE | VM_WRITE : 0);
 	shmd->vm_file = NULL;
-	shmd->vm_pgoff = 0;
+	shmd->vm_pgoff = off/PAGE_SIZE;
 	shmd->vm_ops = &shm_vm_ops;
 
 	shp->u.shm_nattch++;	    /* prevent destruction */
@@ -692,6 +701,19 @@
 	up(&current->mm->mmap_sem);
 	kmem_cache_free(vm_area_cachep, shmd);
 	return err;
+}
+
+/*
+ * Fix shmaddr, allocate descriptor, map shm, add attach descriptor to lists.
+ */
+asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, ulong *raddr)
+{
+        unsigned long prot;
+
+        prot  = PROT_READ | ((shmflg & SHM_RDONLY) ? 0 : PROT_WRITE);
+	down(&current->mm->mmap_sem);
+        return shmmap(shmid, (unsigned long) shmaddr, prot, shmflg, raddr,
+                      0, 0, 0);
 }
 
 /* This is called by fork, once for every shm attach. */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

From: "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>
Message-ID: <003601c2a3c2$cf721ba0$0d50858e@sybix>
Subject: freemaps
Date: Sat, 14 Dec 2002 17:47:34 -0500
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0033_01C2A398.E1FBD790"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_0033_01C2A398.E1FBD790
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Hi,

This patch is intended to provide better support for allocations done with
mmap. As mentioned by Ingo Molnar, keeping the last hole doesn't save us
from scanning vmas because of size constraint.

The following patch implements a simple scheme. The goal is to quickly
return virtual addresses but without scanning the address space at all. It
also works for fixed mappings by reserving areas of virtual addresses.

A global (per mm) cache is maintained from which we can peek ranges of
addresses. There is no link towards vmas. When addresses are cached out they
are simply forgotten. It is then up to the vma users to explicitly cache
out/back areas.

Two of the main functions used for allocations are:

vma_cache_detach(len) returns the first available range of this length
starting from the first block in the cache. The overhead is still very low
since only the cache is scanned (using a first-fit scheme).

vma_cache_area(addr, len) is used to reserve an area from addr to addr+len.
This gives also the possibility to reserve in advance a bunch of virtual
addresses without explicitly mapping them.

Caches are also accessible from /proc/<pid>/freemaps showing free areas
along with their length. Applications willing to map to fixed addresses can
check what is available before doing a mmap().

I guess it could probably give more control on the fragmentation of the
virtual address space too. I successfully ran this patch in a desktop
environment. I also did some simple testing to see how get_unmapped_area()
reacts. Running the kernel 2.5.50 I get
100000 mmaps, mmap=2545 msec munmap=59 msec
100000 mmaps, mmap=2545 msec munmap=58 msec
100000 mmaps, mmap=2544 msec munmap=60 msec
100000 mmaps, mmap=2547 msec munmap=60 msec

and with freemaps I get
100000 mmaps, mmap=79 msec munmap=60 msec
100000 mmaps, mmap=79 msec munmap=60 msec
100000 mmaps, mmap=80 msec munmap=60 msec
100000 mmaps, mmap=79 msec munmap=60 msec

Since there is quite an amazing difference I really would like to have your
comments on this.

I joined a patch against 2.5.50.

Regards,
Frederic







------=_NextPart_000_0033_01C2A398.E1FBD790
Content-Type: application/octet-stream;
	name="freemaps-2.5.50-p4.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="freemaps-2.5.50-p4.patch"

diff --exclude=3DRCS -BbNur linux-2.5.50/fs/binfmt_aout.c =
linux-2.5.50~/fs/binfmt_aout.c=0A=
--- linux-2.5.50/fs/binfmt_aout.c	Wed Nov 27 17:35:51 2002=0A=
+++ linux-2.5.50~/fs/binfmt_aout.c	Thu Dec 12 14:51:05 2002=0A=
@@ -24,6 +24,7 @@=0A=
 #include <linux/binfmts.h>=0A=
 #include <linux/personality.h>=0A=
 #include <linux/init.h>=0A=
+#include <linux/vma_cache.h>=0A=
 =0A=
 #include <asm/system.h>=0A=
 #include <asm/uaccess.h>=0A=
@@ -307,7 +308,8 @@=0A=
 		(current->mm->start_data =3D N_DATADDR(ex));=0A=
 	current->mm->brk =3D ex.a_bss +=0A=
 		(current->mm->start_brk =3D N_BSSADDR(ex));=0A=
-	current->mm->free_area_cache =3D TASK_UNMAPPED_BASE;=0A=
+=0A=
+	vma_cache_init (current->mm);=0A=
 =0A=
 	current->mm->rss =3D 0;=0A=
 	current->mm->mmap =3D NULL;=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/fs/binfmt_elf.c =
linux-2.5.50~/fs/binfmt_elf.c=0A=
--- linux-2.5.50/fs/binfmt_elf.c	Wed Nov 27 17:35:59 2002=0A=
+++ linux-2.5.50~/fs/binfmt_elf.c	Thu Dec 12 14:51:05 2002=0A=
@@ -35,6 +35,7 @@=0A=
 #include <linux/compiler.h>=0A=
 #include <linux/highmem.h>=0A=
 #include <linux/pagemap.h>=0A=
+#include <linux/vma_cache.h>=0A=
 =0A=
 #include <asm/uaccess.h>=0A=
 #include <asm/param.h>=0A=
@@ -617,7 +618,9 @@=0A=
 	/* Do this so that we can load the interpreter, if need be.  We =
will=0A=
 	   change some of these later */=0A=
 	current->mm->rss =3D 0;=0A=
-	current->mm->free_area_cache =3D TASK_UNMAPPED_BASE;=0A=
+ 	=0A=
+ 	vma_cache_init (current->mm);=0A=
+=0A=
 	retval =3D setup_arg_pages(bprm);=0A=
 	if (retval < 0) {=0A=
 		send_sig(SIGKILL, current, 0);=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/fs/proc/array.c =
linux-2.5.50~/fs/proc/array.c=0A=
--- linux-2.5.50/fs/proc/array.c	Wed Nov 27 17:36:05 2002=0A=
+++ linux-2.5.50~/fs/proc/array.c	Thu Dec 12 14:51:05 2002=0A=
@@ -73,6 +73,7 @@=0A=
 #include <linux/highmem.h>=0A=
 #include <linux/file.h>=0A=
 #include <linux/times.h>=0A=
+#include <linux/vma_cache.h>=0A=
 =0A=
 #include <asm/uaccess.h>=0A=
 #include <asm/pgtable.h>=0A=
@@ -513,6 +514,99 @@=0A=
 	return len;=0A=
 }=0A=
 =0A=
+ssize_t proc_pid_read_vmc (struct task_struct *task, struct file * =
file, char * buf, size_t count, loff_t *ppos)=0A=
+{=0A=
+	struct mm_struct *mm;=0A=
+	struct vm_area_struct * map;=0A=
+	char *tmp, *kbuf;=0A=
+	long retval;=0A=
+	int off, lineno, loff;=0A=
+	struct list_head *h;=0A=
+=0A=
+	/* reject calls with out of range parameters immediately */=0A=
+	retval =3D 0;=0A=
+	if (*ppos > LONG_MAX)=0A=
+		goto out;=0A=
+	if (count =3D=3D 0)=0A=
+		goto out;=0A=
+	off =3D (long)*ppos;=0A=
+	/*=0A=
+	 * We might sleep getting the page, so get it first.=0A=
+	 */=0A=
+	retval =3D -ENOMEM;=0A=
+	kbuf =3D (char*)__get_free_page(GFP_KERNEL);=0A=
+	if (!kbuf)=0A=
+		goto out;=0A=
+=0A=
+	tmp =3D (char*)__get_free_page(GFP_KERNEL);=0A=
+	if (!tmp)=0A=
+		goto out_free1;=0A=
+=0A=
+	task_lock(task);=0A=
+	mm =3D task->mm;=0A=
+	if (mm)=0A=
+		atomic_inc(&mm->mm_users);=0A=
+	task_unlock(task);=0A=
+	retval =3D 0;=0A=
+	if (!mm)=0A=
+		goto out_free2;=0A=
+=0A=
+	down_read(&mm->mmap_sem);=0A=
+	map =3D mm->mmap;=0A=
+	lineno =3D 0;=0A=
+	loff =3D 0;=0A=
+	if (count > PAGE_SIZE)=0A=
+		count =3D PAGE_SIZE;=0A=
+=0A=
+	list_for_each (h, &mm->vma_cache_head) {=0A=
+		struct vma_cache_struct *vmc =3D list_entry (h, struct =
vma_cache_struct, head);=0A=
+		=0A=
+		int len;=0A=
+		if (off > PAGE_SIZE) {=0A=
+			off -=3D PAGE_SIZE;=0A=
+			goto next;=0A=
+		}=0A=
+=0A=
+		len =3D sprintf (tmp, "%lx-%lx %lu\n", vmc->vm_start, vmc->vm_end, =
vmc->vm_end-vmc->vm_start);=0A=
+		len -=3D off;=0A=
+		if (len > 0) {=0A=
+			if (retval+len > count) {=0A=
+				/* only partial line transfer possible */=0A=
+				len =3D count - retval;=0A=
+				/* save the offset where the next read=0A=
+				 * must start */=0A=
+				loff =3D len+off;=0A=
+			}=0A=
+			memcpy(kbuf+retval, tmp+off, len);=0A=
+			retval +=3D len;=0A=
+		}=0A=
+		off =3D 0;=0A=
+next:=0A=
+		if (!loff)=0A=
+			lineno++;=0A=
+		if (retval >=3D count)=0A=
+			break;=0A=
+		if (loff) BUG();=0A=
+		map =3D map->vm_next;=0A=
+	}=0A=
+=0A=
+	up_read(&mm->mmap_sem);=0A=
+	mmput(mm);=0A=
+=0A=
+	if (retval > count) BUG();=0A=
+	if (copy_to_user(buf, kbuf, retval))=0A=
+		retval =3D -EFAULT;=0A=
+	else=0A=
+		*ppos =3D (lineno << PAGE_SHIFT) + loff;=0A=
+=0A=
+out_free2:=0A=
+	free_page((unsigned long)tmp);=0A=
+out_free1:=0A=
+	free_page((unsigned long)kbuf);=0A=
+out:=0A=
+	return retval;=0A=
+}=0A=
+=0A=
 ssize_t proc_pid_read_maps (struct task_struct *task, struct file * =
file, char * buf,=0A=
 			  size_t count, loff_t *ppos)=0A=
 {=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/fs/proc/base.c =
linux-2.5.50~/fs/proc/base.c=0A=
--- linux-2.5.50/fs/proc/base.c	Wed Nov 27 17:36:06 2002=0A=
+++ linux-2.5.50~/fs/proc/base.c	Thu Dec 12 14:51:05 2002=0A=
@@ -54,6 +54,7 @@=0A=
 	PROC_PID_CMDLINE,=0A=
 	PROC_PID_STAT,=0A=
 	PROC_PID_STATM,=0A=
+	PROC_PID_VMC,=0A=
 	PROC_PID_MAPS,=0A=
 	PROC_PID_MOUNTS,=0A=
 	PROC_PID_WCHAN,=0A=
@@ -75,6 +76,7 @@=0A=
   E(PROC_PID_CMDLINE,	"cmdline",	S_IFREG|S_IRUGO),=0A=
   E(PROC_PID_STAT,	"stat",		S_IFREG|S_IRUGO),=0A=
   E(PROC_PID_STATM,	"statm",	S_IFREG|S_IRUGO),=0A=
+  E(PROC_PID_VMC,	"freemaps",	S_IFREG|S_IRUGO),=0A=
   E(PROC_PID_MAPS,	"maps",		S_IFREG|S_IRUGO),=0A=
   E(PROC_PID_MEM,	"mem",		S_IFREG|S_IRUSR|S_IWUSR),=0A=
   E(PROC_PID_CWD,	"cwd",		S_IFLNK|S_IRWXUGO),=0A=
@@ -99,6 +101,7 @@=0A=
 }=0A=
 =0A=
 ssize_t proc_pid_read_maps(struct task_struct*,struct =
file*,char*,size_t,loff_t*);=0A=
+ssize_t proc_pid_read_vmc(struct task_struct*,struct =
file*,char*,size_t,loff_t*);=0A=
 int proc_pid_stat(struct task_struct*,char*);=0A=
 int proc_pid_status(struct task_struct*,char*);=0A=
 int proc_pid_statm(struct task_struct*,char*);=0A=
@@ -336,6 +339,21 @@=0A=
 	.read		=3D pid_maps_read,=0A=
 };=0A=
 =0A=
+static ssize_t pid_vmc_read(struct file * file, char * buf,=0A=
+			      size_t count, loff_t *ppos)=0A=
+{=0A=
+	struct inode * inode =3D file->f_dentry->d_inode;=0A=
+	struct task_struct *task =3D proc_task(inode);=0A=
+	ssize_t res;=0A=
+=0A=
+	res =3D proc_pid_read_vmc (task, file, buf, count, ppos);=0A=
+	return res;=0A=
+}=0A=
+=0A=
+static struct file_operations proc_vmc_operations =3D {=0A=
+	read:		pid_vmc_read,=0A=
+};=0A=
+=0A=
 extern struct seq_operations mounts_op;=0A=
 static int mounts_open(struct inode *inode, struct file *file)=0A=
 {=0A=
@@ -1023,6 +1041,9 @@=0A=
 			inode->i_fop =3D &proc_info_file_operations;=0A=
 			ei->op.proc_read =3D proc_pid_statm;=0A=
 			break;=0A=
+		case PROC_PID_VMC:=0A=
+			inode->i_fop =3D &proc_vmc_operations;=0A=
+			break;=0A=
 		case PROC_PID_MAPS:=0A=
 			inode->i_fop =3D &proc_maps_operations;=0A=
 			break;=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/include/linux/init_task.h =
linux-2.5.50~/include/linux/init_task.h=0A=
--- linux-2.5.50/include/linux/init_task.h	Wed Nov 27 17:35:49 2002=0A=
+++ linux-2.5.50~/include/linux/init_task.h	Thu Dec 12 14:51:05 2002=0A=
@@ -41,6 +41,7 @@=0A=
 	.page_table_lock =3D  SPIN_LOCK_UNLOCKED, 		\=0A=
 	.mmlist		=3D LIST_HEAD_INIT(name.mmlist),		\=0A=
 	.default_kioctx =3D INIT_KIOCTX(name.default_kioctx, name),	\=0A=
+        .vma_cache_head =3D LIST_HEAD_INIT(name.vma_cache_head),  \=0A=
 }=0A=
 =0A=
 #define INIT_SIGNALS(sig) {	\=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/include/linux/sched.h =
linux-2.5.50~/include/linux/sched.h=0A=
--- linux-2.5.50/include/linux/sched.h	Wed Nov 27 17:35:49 2002=0A=
+++ linux-2.5.50~/include/linux/sched.h	Thu Dec 12 14:51:05 2002=0A=
@@ -172,11 +172,16 @@=0A=
 =0A=
 #include <linux/aio.h>=0A=
 =0A=
+struct vma_cache_struct {=0A=
+	struct list_head head;=0A=
+	unsigned long vm_start;=0A=
+	unsigned long vm_end;=0A=
+};=0A=
+=0A=
 struct mm_struct {=0A=
 	struct vm_area_struct * mmap;		/* list of VMAs */=0A=
 	struct rb_root mm_rb;=0A=
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */=0A=
-	unsigned long free_area_cache;		/* first hole */=0A=
 	pgd_t * pgd;=0A=
 	atomic_t mm_users;			/* How many users with user space? */=0A=
 	atomic_t mm_count;			/* How many references to "struct mm_struct" =
(users count as 1) */=0A=
@@ -189,6 +194,8 @@=0A=
 						 * by mmlist_lock=0A=
 						 */=0A=
 =0A=
+        struct list_head vma_cache_head;        /* cache for free =
virtual address areas */=0A=
+=0A=
 	unsigned long start_code, end_code, start_data, end_data;=0A=
 	unsigned long start_brk, brk, start_stack;=0A=
 	unsigned long arg_start, arg_end, env_start, env_end;=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/include/linux/slab.h =
linux-2.5.50~/include/linux/slab.h=0A=
--- linux-2.5.50/include/linux/slab.h	Wed Nov 27 17:36:23 2002=0A=
+++ linux-2.5.50~/include/linux/slab.h	Thu Dec 12 14:51:05 2002=0A=
@@ -65,6 +65,7 @@=0A=
 extern int FASTCALL(kmem_cache_reap(int));=0A=
 =0A=
 /* System wide caches */=0A=
+extern kmem_cache_t	*vma_cache_cachep;=0A=
 extern kmem_cache_t	*vm_area_cachep;=0A=
 extern kmem_cache_t	*mm_cachep;=0A=
 extern kmem_cache_t	*names_cachep;=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/include/linux/vma_cache.h =
linux-2.5.50~/include/linux/vma_cache.h=0A=
--- linux-2.5.50/include/linux/vma_cache.h	Wed Dec 31 19:00:00 1969=0A=
+++ linux-2.5.50~/include/linux/vma_cache.h	Thu Dec 12 14:51:05 2002=0A=
@@ -0,0 +1,25 @@=0A=
+#ifndef _VMA_CACHE_H_=0A=
+#define _VMA_CACHE_H_=0A=
+=0A=
+#define VMA_CACHE_EMPTY(m,a)    (list_empty(&(a)->head))=0A=
+=0A=
+#define vma_cache_alloc()     (kmem_cache_alloc(vma_cache_cachep, =
GFP_KERNEL))=0A=
+#define vma_cache_free(v)                              \=0A=
+do {                                                   \=0A=
+        if (v) {                                       \=0A=
+                list_del_init (&(v)->head);            \=0A=
+                kmem_cache_free (vma_cache_cachep, v); \=0A=
+        }                                              \=0A=
+} while (0)=0A=
+=0A=
+int vma_cache_init (struct mm_struct *);=0A=
+struct vma_cache_struct *vma_cache_find (struct mm_struct *, unsigned =
long, int);=0A=
+void vma_cache_shtdn (struct mm_struct *);=0A=
+int vma_cache_attach (struct mm_struct *, unsigned long, int);=0A=
+int vma_cache_merge (struct mm_struct *, struct vma_cache_struct *, =
unsigned long, int);=0A=
+int vma_cache_clone (struct mm_struct *, struct mm_struct *);=0A=
+unsigned long vma_cache_area (struct mm_struct *, unsigned long, =
int);=0A=
+unsigned long vma_cache_detach (struct mm_struct *, int);=0A=
+=0A=
+#endif /* #ifndef _VMA_CACHE_H_ */=0A=
+=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/kernel/exit.c =
linux-2.5.50~/kernel/exit.c=0A=
--- linux-2.5.50/kernel/exit.c	Wed Nov 27 17:36:18 2002=0A=
+++ linux-2.5.50~/kernel/exit.c	Thu Dec 12 14:51:05 2002=0A=
@@ -21,6 +21,7 @@=0A=
 #include <linux/ptrace.h>=0A=
 #include <linux/profile.h>=0A=
 #include <linux/mount.h>=0A=
+#include <linux/vma_cache.h>=0A=
 =0A=
 #include <asm/uaccess.h>=0A=
 #include <asm/pgtable.h>=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/kernel/fork.c =
linux-2.5.50~/kernel/fork.c=0A=
--- linux-2.5.50/kernel/fork.c	Wed Nov 27 17:35:49 2002=0A=
+++ linux-2.5.50~/kernel/fork.c	Thu Dec 12 14:51:05 2002=0A=
@@ -29,6 +29,7 @@=0A=
 #include <linux/futex.h>=0A=
 #include <linux/ptrace.h>=0A=
 #include <linux/mount.h>=0A=
+#include <linux/vma_cache.h>=0A=
 =0A=
 #include <asm/pgtable.h>=0A=
 #include <asm/pgalloc.h>=0A=
@@ -215,10 +216,10 @@=0A=
 =0A=
 	down_write(&oldmm->mmap_sem);=0A=
 	flush_cache_mm(current->mm);=0A=
+	vma_cache_init (mm);=0A=
 	mm->locked_vm =3D 0;=0A=
 	mm->mmap =3D NULL;=0A=
 	mm->mmap_cache =3D NULL;=0A=
-	mm->free_area_cache =3D TASK_UNMAPPED_BASE;=0A=
 	mm->map_count =3D 0;=0A=
 	mm->rss =3D 0;=0A=
 	mm->cpu_vm_mask =3D 0;=0A=
@@ -246,6 +247,7 @@=0A=
 				goto fail_nomem;=0A=
 			charge +=3D len;=0A=
 		}=0A=
+		vma_cache_area (mm, mpnt->vm_start, mpnt->vm_end-mpnt->vm_start);=0A=
 		tmp =3D kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);=0A=
 		if (!tmp)=0A=
 			goto fail_nomem;=0A=
@@ -334,7 +336,7 @@=0A=
 	mm->page_table_lock =3D SPIN_LOCK_UNLOCKED;=0A=
 	mm->ioctx_list_lock =3D RW_LOCK_UNLOCKED;=0A=
 	mm->default_kioctx =3D (struct kioctx)INIT_KIOCTX(mm->default_kioctx, =
*mm);=0A=
-	mm->free_area_cache =3D TASK_UNMAPPED_BASE;=0A=
+	vma_cache_init (mm);=0A=
 =0A=
 	if (likely(!mm_alloc_pgd(mm)))=0A=
 		return mm;=0A=
@@ -381,6 +383,7 @@=0A=
 		mmlist_nr--;=0A=
 		spin_unlock(&mmlist_lock);=0A=
 		exit_mmap(mm);=0A=
+		vma_cache_shtdn(mm);=0A=
 		mmdrop(mm);=0A=
 	}=0A=
 }=0A=
@@ -1054,6 +1057,9 @@=0A=
 /* SLAB cache for mm_struct structures (tsk->mm) */=0A=
 kmem_cache_t *mm_cachep;=0A=
 =0A=
+/* SLAB cache for vma_cache structures */=0A=
+kmem_cache_t *vma_cache_cachep;=0A=
+=0A=
 void __init proc_caches_init(void)=0A=
 {=0A=
 	sigact_cachep =3D kmem_cache_create("signal_act",=0A=
@@ -1085,4 +1091,11 @@=0A=
 			SLAB_HWCACHE_ALIGN, NULL, NULL);=0A=
 	if(!mm_cachep)=0A=
 		panic("vma_init: Cannot alloc mm_struct SLAB cache");=0A=
+=0A=
+	vma_cache_cachep =3D kmem_cache_create("vma_cache_struct",=0A=
+			sizeof(struct vma_cache_struct), 0,=0A=
+			SLAB_HWCACHE_ALIGN, NULL, NULL);=0A=
+	if(!vm_area_cachep)=0A=
+		panic("vma_init: Cannot alloc vma_cache_struct SLAB cache");=0A=
+=0A=
 }=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/mm/Makefile =
linux-2.5.50~/mm/Makefile=0A=
--- linux-2.5.50/mm/Makefile	Wed Nov 27 17:36:14 2002=0A=
+++ linux-2.5.50~/mm/Makefile	Thu Dec 12 14:51:05 2002=0A=
@@ -8,7 +8,7 @@=0A=
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_alloc.o \=0A=
 	    oom_kill.o shmem.o highmem.o mempool.o msync.o mincore.o \=0A=
 	    readahead.o pdflush.o page-writeback.o rmap.o madvise.o \=0A=
-	    vcache.o truncate.o=0A=
+	    vcache.o truncate.o vma_cache.o=0A=
 =0A=
 obj-$(CONFIG_SWAP)	+=3D page_io.o swap_state.o swapfile.o=0A=
 =0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/mm/mmap.c =
linux-2.5.50~/mm/mmap.c=0A=
--- linux-2.5.50/mm/mmap.c	Wed Nov 27 17:36:06 2002=0A=
+++ linux-2.5.50~/mm/mmap.c	Thu Dec 12 14:51:05 2002=0A=
@@ -18,6 +18,7 @@=0A=
 #include <linux/security.h>=0A=
 #include <linux/hugetlb.h>=0A=
 #include <linux/profile.h>=0A=
+#include <linux/vma_cache.h>=0A=
 =0A=
 #include <asm/uaccess.h>=0A=
 #include <asm/pgalloc.h>=0A=
@@ -514,6 +515,7 @@=0A=
 	if (vma && vma->vm_start < addr + len) {=0A=
 		if (do_munmap(mm, addr, len))=0A=
 			return -ENOMEM;=0A=
+		vma_cache_area (mm, addr, len);=0A=
 		goto munmap_back;=0A=
 	}=0A=
 =0A=
@@ -647,7 +649,6 @@=0A=
 {=0A=
 	struct mm_struct *mm =3D current->mm;=0A=
 	struct vm_area_struct *vma;=0A=
-	int found_hole =3D 0;=0A=
 =0A=
 	if (len > TASK_SIZE)=0A=
 		return -ENOMEM;=0A=
@@ -657,25 +658,9 @@=0A=
 		vma =3D find_vma(mm, addr);=0A=
 		if (TASK_SIZE - len >=3D addr &&=0A=
 		    (!vma || addr + len <=3D vma->vm_start))=0A=
-			return addr;=0A=
-	}=0A=
-	addr =3D mm->free_area_cache;=0A=
-=0A=
-	for (vma =3D find_vma(mm, addr); ; vma =3D vma->vm_next) {=0A=
-		/* At this point:  (!vma || addr < vma->vm_end). */=0A=
-		if (TASK_SIZE - len < addr)=0A=
-			return -ENOMEM;=0A=
-		/*=0A=
-		 * Record the first available hole.=0A=
-		 */=0A=
-		if (!found_hole && (!vma || addr < vma->vm_start)) {=0A=
-			mm->free_area_cache =3D addr;=0A=
-			found_hole =3D 1;=0A=
-		}=0A=
-		if (!vma || addr + len <=3D vma->vm_start)=0A=
-			return addr;=0A=
-		addr =3D vma->vm_end;=0A=
+			return vma_cache_area (current->mm, addr, len);=0A=
 	}=0A=
+	return vma_cache_detach (current->mm, len);=0A=
 }=0A=
 #else=0A=
 extern unsigned long arch_get_unmapped_area(struct file *, unsigned =
long, unsigned long, unsigned long, unsigned long);=0A=
@@ -688,7 +673,7 @@=0A=
 			return -ENOMEM;=0A=
 		if (addr & ~PAGE_MASK)=0A=
 			return -EINVAL;=0A=
-		return addr;=0A=
+		return vma_cache_area (current->mm, addr, len);=0A=
 	}=0A=
 =0A=
 	if (file && file->f_op && file->f_op->get_unmapped_area)=0A=
@@ -962,13 +947,8 @@=0A=
 	area->vm_mm->total_vm -=3D len >> PAGE_SHIFT;=0A=
 	if (area->vm_flags & VM_LOCKED)=0A=
 		area->vm_mm->locked_vm -=3D len >> PAGE_SHIFT;=0A=
-	/*=0A=
-	 * Is this a new hole at the lowest possible address?=0A=
-	 */=0A=
-	if (area->vm_start >=3D TASK_UNMAPPED_BASE &&=0A=
-				area->vm_start < area->vm_mm->free_area_cache)=0A=
-	      area->vm_mm->free_area_cache =3D area->vm_start;=0A=
 =0A=
+	vma_cache_attach (mm, area->vm_start, =
area->vm_end-area->vm_start);=0A=
 	remove_shared_vm_struct(area);=0A=
 =0A=
 	if (area->vm_ops && area->vm_ops->close)=0A=
@@ -1336,7 +1316,6 @@=0A=
 		kmem_cache_free(vm_area_cachep, mpnt);=0A=
 		mpnt =3D next;=0A=
 	}=0A=
-		=0A=
 }=0A=
 =0A=
 /* Insert vm structure into process list sorted by address=0A=
diff --exclude=3DRCS -BbNur linux-2.5.50/mm/vma_cache.c =
linux-2.5.50~/mm/vma_cache.c=0A=
--- linux-2.5.50/mm/vma_cache.c	Wed Dec 31 19:00:00 1969=0A=
+++ linux-2.5.50~/mm/vma_cache.c	Fri Dec 13 08:52:52 2002=0A=
@@ -0,0 +1,364 @@=0A=
+/*=0A=
+ *  linux/mm/vma_cache.c=0A=
+ * =0A=
+ *  These routines are used for the allocation of virtual memory =
areas. Each MM context is =0A=
+ *  assigned a cache which contains virtual address ranges a process =
can allocate to map into =0A=
+ *  its own address space. These routines assume the caller holds the =
global mm->mmap_sem.=0A=
+ *  Dec 2002, frederic.rossi@ericsson.ca=0A=
+ *=0A=
+ */=0A=
+=0A=
+#include <linux/slab.h>=0A=
+#include <linux/sched.h>=0A=
+#include <linux/errno.h>=0A=
+#include <linux/vma_cache.h>=0A=
+=0A=
+#define next_area(v) (list_entry ((v)->head.next, struct =
vma_cache_struct, head))=0A=
+#define prev_area(v) (list_entry ((v)->head.prev, struct =
vma_cache_struct, head))=0A=
+=0A=
+/* not mapped addresses */=0A=
+#define unmapped_addr(v,a)    ((a)>=3D(v)->vm_start && =
(a)<=3D(v)->vm_end)=0A=
+#define unmapped_area(v,a,l)  ((a)>=3D(v)->vm_start && =
(a)+(l)<=3D(v)->vm_end)=0A=
+#define unmapped_left(v,a,l)  ((a)+(l)<(v)->vm_start)=0A=
+#define unmapped_right(v,al)  ((a)>(v)->vm_end)=0A=
+=0A=
+/* partially mapped addresses */=0A=
+#define pmapped_left(v,a,l)   ((a)+(l)=3D=3D(v)->vm_start)=0A=
+#define pmapped_right(v,a,l)  ((a)=3D=3D(v)->vm_end)=0A=
+=0A=
+static __inline__ int vma_cache_isvalid (struct mm_struct *mm, =
unsigned long addr, int len)=0A=
+{=0A=
+	return (addr >=3D TASK_UNMAPPED_BASE && addr+len <=3D TASK_SIZE)? 1 : =
0;=0A=
+}	=0A=
+=0A=
+static __inline__ int vma_cache_chainout (struct mm_struct *mm, struct =
vma_cache_struct *vmc)=0A=
+{=0A=
+	if (!vmc)=0A=
+		return -EINVAL;=0A=
+=0A=
+	list_del_init (&vmc->head);=0A=
+	vma_cache_free (vmc);=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+static __inline__ struct vma_cache_struct *vma_cache_append (struct =
mm_struct *mm, struct vma_cache_struct *vmc, unsigned long addr, int =
len)=0A=
+{=0A=
+	struct vma_cache_struct *new;=0A=
+=0A=
+	new =3D vma_cache_alloc ();=0A=
+	if (!new)=0A=
+		return NULL;=0A=
+=0A=
+	INIT_LIST_HEAD (&new->head);=0A=
+	new->vm_start =3D addr;=0A=
+	new->vm_end   =3D addr+len;=0A=
+	list_add (&new->head, &vmc->head);=0A=
+	=0A=
+	return new;=0A=
+}=0A=
+=0A=
+static __inline__ struct vma_cache_struct *vma_cache_insert (struct =
mm_struct *mm, struct vma_cache_struct *vmc, unsigned long addr, int =
len)=0A=
+{=0A=
+	struct vma_cache_struct *new;=0A=
+=0A=
+	new =3D vma_cache_alloc ();=0A=
+	if (!new)=0A=
+		return NULL;=0A=
+=0A=
+	INIT_LIST_HEAD (&new->head);=0A=
+	new->vm_start =3D addr;=0A=
+	new->vm_end   =3D addr+len;=0A=
+	list_add_tail (&new->head, &vmc->head);=0A=
+	=0A=
+	return new;=0A=
+}=0A=
+=0A=
+void vma_cache_shtdn (struct mm_struct *mm)=0A=
+{=0A=
+	struct vma_cache_struct *nptr, *vmc, *head;=0A=
+	=0A=
+	head =3D list_entry (&mm->vma_cache_head, struct vma_cache_struct, =
head);=0A=
+	vmc  =3D head;=0A=
+	nptr =3D NULL;=0A=
+=0A=
+	while (nptr !=3D head) {=0A=
+		nptr =3D next_area (vmc);=0A=
+		if (vma_cache_attach (mm, vmc->vm_start, vmc->vm_end-vmc->vm_start) =
=3D=3D 0)=0A=
+			vma_cache_free (vmc);=0A=
+		vmc =3D nptr;=0A=
+	}=0A=
+}=0A=
+=0A=
+int vma_cache_clone (struct mm_struct *mm_dst, struct mm_struct =
*mm_src)=0A=
+{=0A=
+	struct list_head *tmp, *prev;=0A=
+	struct vma_cache_struct *new;=0A=
+=0A=
+	if (!list_empty (&mm_dst->vma_cache_head)) {=0A=
+		/* Remove previous mapping */=0A=
+	again:=0A=
+		list_for_each (tmp, &mm_dst->vma_cache_head) {=0A=
+			struct vma_cache_struct *vmc =3D list_entry (tmp, struct =
vma_cache_struct, head);=0A=
+			vma_cache_free (vmc);=0A=
+			goto again;=0A=
+		}=0A=
+		INIT_LIST_HEAD (&mm_dst->vma_cache_head);=0A=
+	}=0A=
+		=0A=
+	prev =3D &mm_dst->vma_cache_head;=0A=
+	list_for_each (tmp, &mm_src->vma_cache_head) {=0A=
+		struct vma_cache_struct *vmc =3D list_entry (tmp, struct =
vma_cache_struct, head);=0A=
+=0A=
+		new =3D  vma_cache_alloc ();=0A=
+		if (!new)=0A=
+			return -ENOMEM;=0A=
+		=0A=
+		INIT_LIST_HEAD (&new->head);=0A=
+		new->vm_start =3D vmc->vm_start;=0A=
+		new->vm_end   =3D vmc->vm_end;=0A=
+		list_add (&new->head, prev);=0A=
+		prev =3D &new->head;=0A=
+	}=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+int vma_cache_init (struct mm_struct *mm)=0A=
+{=0A=
+	struct vma_cache_struct *vmc;=0A=
+	=0A=
+        INIT_LIST_HEAD (&mm->vma_cache_head);=0A=
+=0A=
+	vmc =3D  vma_cache_alloc ();=0A=
+	if (!vmc)=0A=
+		return -ENOMEM;=0A=
+=0A=
+	INIT_LIST_HEAD (&vmc->head);=0A=
+	vmc->vm_start =3D TASK_UNMAPPED_BASE;=0A=
+	vmc->vm_end   =3D TASK_SIZE;=0A=
+	list_add (&vmc->head, &mm->vma_cache_head);=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+struct vma_cache_struct *vma_cache_find (struct mm_struct *mm, =
unsigned long addr, int len)=0A=
+{=0A=
+	struct list_head *tmp;=0A=
+=0A=
+	if (!len)=0A=
+		return NULL;=0A=
+=0A=
+	list_for_each (tmp, &mm->vma_cache_head) {=0A=
+		struct vma_cache_struct *vmc =3D list_entry (tmp, struct =
vma_cache_struct, head);=0A=
+		if (unmapped_area (vmc, addr, len))=0A=
+			return vmc;=0A=
+	}=0A=
+=0A=
+	return NULL;=0A=
+}=0A=
+=0A=
+/* =0A=
+ * Give an address, find the left cache element and merge if =
mergeable.=0A=
+ */=0A=
+static struct vma_cache_struct *vma_cache_merge_left (struct mm_struct =
*mm, struct vma_cache_struct *vmc, unsigned long addr, int len)=0A=
+{=0A=
+	struct vma_cache_struct *vmc_left =3D NULL;=0A=
+=0A=
+	if (!vmc) {=0A=
+		vmc =3D vma_cache_find (mm, addr, len);=0A=
+		if (!vmc) goto out;=0A=
+	}=0A=
+=0A=
+	vmc_left =3D prev_area (vmc);=0A=
+=0A=
+	if (!vmc_left)=0A=
+		goto out;=0A=
+=0A=
+	if (vmc_left =3D=3D vmc)=0A=
+		goto out;=0A=
+=0A=
+	/* merge */=0A=
+	if (vmc->vm_start <=3D vmc_left->vm_end && vmc->vm_start >=3D =
vmc_left->vm_start){ =0A=
+		vmc_left->vm_end =3D vmc->vm_end;=0A=
+		vma_cache_chainout (mm, vmc);=0A=
+	}=0A=
+=0A=
+out:=0A=
+	return vmc_left;=0A=
+}=0A=
+=0A=
+/* =0A=
+ * Give an address, find the right cache element and merge if =
mergeable.=0A=
+ */=0A=
+static struct vma_cache_struct *vma_cache_merge_right (struct =
mm_struct *mm, struct vma_cache_struct *vmc, unsigned long addr, int =
len)=0A=
+{=0A=
+	struct vma_cache_struct *vmc_right =3D NULL;=0A=
+=0A=
+	if (!vmc) {=0A=
+		vmc =3D vma_cache_find (mm, addr, len);=0A=
+		if (!vmc) goto out;=0A=
+	}=0A=
+=0A=
+	vmc_right =3D next_area (vmc);=0A=
+=0A=
+	if (!vmc_right)=0A=
+		goto out;=0A=
+=0A=
+	if (vmc_right =3D=3D vmc)=0A=
+		goto out;=0A=
+=0A=
+	/* merge */=0A=
+	if (vmc->vm_end >=3D vmc_right->vm_start && vmc->vm_end <=3D =
vmc_right->vm_end) {=0A=
+		vmc_right->vm_start =3D vmc->vm_start;=0A=
+		vma_cache_chainout (mm, vmc);=0A=
+	}=0A=
+out:=0A=
+	return vmc_right;=0A=
+}=0A=
+=0A=
+int vma_cache_merge (struct mm_struct *mm, struct vma_cache_struct =
*vmc, unsigned long addr, int len)=0A=
+{=0A=
+	int err=3D0;=0A=
+=0A=
+	if (!vmc || vma_cache_find (mm, addr, len) =3D=3D vmc) {=0A=
+		err  =3D (int )vma_cache_merge_left (mm, vmc, addr, len);=0A=
+		err |=3D (int )vma_cache_merge_right (mm, vmc, addr, len);=0A=
+	}=0A=
+=0A=
+	return (err)? -EINVAL : 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Insert or increase an existing area. Returns 0 if successfull.=0A=
+ */=0A=
+int vma_cache_attach (struct mm_struct *mm, unsigned long addr, int =
len)=0A=
+{=0A=
+	struct list_head *tmp;=0A=
+	struct vma_cache_struct *vmc;=0A=
+=0A=
+	if (!vma_cache_isvalid (mm, addr, len))=0A=
+		return -EINVAL;=0A=
+=0A=
+	vmc =3D list_entry (&mm->vma_cache_head, struct vma_cache_struct, =
head);=0A=
+	list_for_each (tmp, &mm->vma_cache_head) {=0A=
+		vmc =3D list_entry (tmp, struct vma_cache_struct, head);=0A=
+		=0A=
+		if (addr > vmc->vm_end)=0A=
+			continue;=0A=
+=0A=
+		if (pmapped_left (vmc, addr, len)) { =0A=
+			vmc->vm_start =3D addr;=0A=
+			return vma_cache_merge (mm, vmc, addr, len);=0A=
+		}=0A=
+=0A=
+		if (unmapped_left (vmc, addr, len)) {=0A=
+			struct vma_cache_struct *new =3D vma_cache_insert (mm, vmc, addr, =
len);=0A=
+			if (!new)=0A=
+				return -ENOMEM;=0A=
+			return vma_cache_merge (mm, new, addr, len);=0A=
+		}=0A=
+		=0A=
+		if (pmapped_right (vmc, addr, len)) {=0A=
+			vmc->vm_end =3D addr+len;=0A=
+			return vma_cache_merge (mm, vmc, addr, len);=0A=
+		}=0A=
+=0A=
+		if (unmapped_area (vmc, addr, len))=0A=
+			return 0;=0A=
+=0A=
+		if (addr < vmc->vm_start && addr+len > vmc->vm_end) {=0A=
+			vmc->vm_start =3D addr;=0A=
+			vmc->vm_end   =3D addr+len;=0A=
+			return vma_cache_merge (mm, vmc, addr, len);=0A=
+		}=0A=
+=0A=
+		if (addr =3D=3D vmc->vm_start && addr+len > vmc->vm_end) {=0A=
+			vmc->vm_end =3D addr+len;=0A=
+			return vma_cache_merge (mm, vmc, addr, len);=0A=
+		}=0A=
+	=0A=
+		/* shouldn't go here */=0A=
+		printk ("vma_cache_area: task '%s' [%d]. Don't know how to attach =
address range [%lx, %lx] in range [%lx, %lx]\n", =0A=
+		      current->comm, current->pid, addr, addr+len, vmc->vm_start, =
vmc->vm_end);=0A=
+=0A=
+		break;=0A=
+	}=0A=
+=0A=
+	return -EINVAL;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Reserve a range of addresses. An error value is returned only if =
it's not=0A=
+ * possible to reserve this area.=0A=
+ */=0A=
+unsigned long vma_cache_area (struct mm_struct *mm, unsigned long =
addr, int len)=0A=
+{=0A=
+	struct vma_cache_struct *vmc;=0A=
+=0A=
+	if (!vma_cache_isvalid (mm, addr, len))=0A=
+		return addr;=0A=
+=0A=
+	vmc =3D vma_cache_find (mm, addr, len);=0A=
+	if (!vmc)=0A=
+		return addr;=0A=
+=0A=
+	if (addr =3D=3D vmc->vm_start && addr+len <=3D vmc->vm_end) {=0A=
+		vmc->vm_start =3D addr+len;=0A=
+		if (vmc->vm_start =3D=3D vmc->vm_end)=0A=
+			vma_cache_chainout (mm, vmc);=0A=
+		return addr;=0A=
+	}=0A=
+	=0A=
+	if (addr > vmc->vm_start && addr+len =3D=3D vmc->vm_end) {=0A=
+		vmc->vm_end =3D addr;=0A=
+		if (vmc->vm_start =3D=3D vmc->vm_end)=0A=
+			vma_cache_chainout (mm, vmc);=0A=
+		return addr;=0A=
+	}=0A=
+	=0A=
+	if (addr > vmc->vm_start && addr+len < vmc->vm_end) {=0A=
+		unsigned long old_end;=0A=
+=0A=
+		/* vmc->vm_start -> addr */=0A=
+		old_end =3D vmc->vm_end;=0A=
+		vmc->vm_end =3D addr;=0A=
+=0A=
+		/* addr+len -> vmc->vm_end */=0A=
+		vma_cache_append (mm, vmc, addr+len, old_end-addr-len);=0A=
+		return addr;=0A=
+	}=0A=
+=0A=
+	printk ("vma_cache_area: task '%s' [%d]. Don't know how to cache out =
address range [%lx, %lx] from range [%lx, %lx]\n", =0A=
+		current->comm, current->pid, addr, addr+len, vmc->vm_start, =
vmc->vm_end);=0A=
+=0A=
+	return -EINVAL;=0A=
+}=0A=
+=0A=
+/* =0A=
+ * Find the first available range of addresses. The return value=0A=
+ * is to satisfy get_unmapped_area().=0A=
+ */=0A=
+unsigned long vma_cache_detach (struct mm_struct *mm, int len)=0A=
+{=0A=
+	struct list_head *tmp;=0A=
+	unsigned long addr;=0A=
+=0A=
+	if (!len)=0A=
+		return -EINVAL;=0A=
+=0A=
+	addr =3D -ENOMEM;=0A=
+=0A=
+	list_for_each (tmp, &mm->vma_cache_head) {=0A=
+		struct vma_cache_struct *vmc =3D list_entry (tmp, struct =
vma_cache_struct, head);=0A=
+		=0A=
+		if (len <=3D vmc->vm_end - vmc->vm_start) {=0A=
+			addr =3D vmc->vm_start;=0A=
+			vmc->vm_start +=3D len;=0A=
+			if (vmc->vm_start =3D=3D vmc->vm_end)=0A=
+				vma_cache_chainout (mm, vmc);=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+	=0A=
+	return addr;=0A=
+}=0A=

------=_NextPart_000_0033_01C2A398.E1FBD790--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

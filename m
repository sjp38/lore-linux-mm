From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906240518.WAA38723@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm10-2.2.10 Clean up shm code
Date: Wed, 23 Jun 1999 22:18:31 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch cleans up the unneeded SHM_ID_MASK, SHM_SWP_TYPE, SHM_IDX_MASK
and SHM_IDX_SHIFT.

Thanks.

Kanoj
kanoj@engr.sgi.com

--- /usr/tmp/p_rdiff_a007kK/shmparam.h	Wed Jun 23 22:07:04 1999
+++ include/asm-alpha/shmparam.h	Wed Jun 16 22:00:09 1999
@@ -9,32 +9,12 @@
 
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the Alpha and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMAX 0x3fa000			/* max shared seg size (bytes) */
 #define SHMMIN 1 /* really PAGE_SIZE */	/* min shared seg size (bytes) */
--- /usr/tmp/p_rdiff_a007br/shmparam.h	Wed Jun 23 22:07:12 1999
+++ include/asm-arm/shmparam.h	Wed Jun 16 22:00:13 1999
@@ -10,32 +10,12 @@
 #include <asm/proc/shmparam.h>
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the i386 and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMIN 1 /* really PAGE_SIZE */	/* min shared seg size (bytes) */
 #define SHMMNI (1<<_SHM_ID_BITS)	/* max num of segs system wide */
--- /usr/tmp/p_rdiff_a007eU/shmparam.h	Wed Jun 23 22:07:21 1999
+++ include/asm-i386/shmparam.h	Wed Jun 23 20:52:25 1999
@@ -6,32 +6,12 @@
 #define SHM_RANGE_END	0x60000000
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the i386 and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMAX 0x2000000		/* max shared seg size (bytes) */
 /* Try not to change the default shipped SHMMAX - people rely on it */
--- /usr/tmp/p_rdiff_a007do/shm.h	Wed Jun 23 22:07:28 1999
+++ include/asm-m68k/shm.h	Wed Jun 23 21:05:20 1999
@@ -1,24 +1,10 @@
 #ifndef _M68K_SHM_H
 #define _M68K_SHM_H
 
-/* format of page table entries that correspond to shared memory pages
-   currently out in swap space (see also mm/swap.c):
-   bits 0-1 (PAGE_PRESENT) is  = 0
-   bits 8..2 (SWP_TYPE) are = SHM_SWP_TYPE
-   bits 31..9 are used like this:
-   bits 15..9 (SHM_ID) the id of the shared memory segment
-   bits 30..16 (SHM_IDX) the index of the page within the shared memory segment
-                    (actually only bits 25..16 get used since SHMMAX is so low)
-   bit 31 (SHM_READ_ONLY) flag whether the page belongs to a read-only attach
-*/
 /* on the m68k both bits 0 and 1 must be zero */
 
-#define SHM_ID_SHIFT	9
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(SHM_ID_SHIFT+_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
 
 #endif /* _M68K_SHM_H */
--- /usr/tmp/p_rdiff_a007hK/shmparam.h	Wed Jun 23 22:07:35 1999
+++ include/asm-m68k/shmparam.h	Wed Jun 16 22:00:20 1999
@@ -6,32 +6,12 @@
 #define SHM_RANGE_END	0xD0000000
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the i386 and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMAX 0x1000000		/* max shared seg size (bytes) */
 #define SHMMIN 1 /* really PAGE_SIZE */	/* min shared seg size (bytes) */
--- /usr/tmp/p_rdiff_a007iv/shmparam.h	Wed Jun 23 22:07:42 1999
+++ include/asm-mips/shmparam.h	Wed Jun 16 22:00:24 1999
@@ -6,32 +6,12 @@
 #define SHM_RANGE_END	0x60000000
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the i386 and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMAX 0x1000000		/* max shared seg size (bytes) */
 #define SHMMIN 1 /* really PAGE_SIZE */	/* min shared seg size (bytes) */
--- /usr/tmp/p_rdiff_a007LM/shmparam.h	Wed Jun 23 22:07:50 1999
+++ include/asm-ppc/shmparam.h	Wed Jun 16 22:00:27 1999
@@ -6,32 +6,12 @@
 #define SHM_RANGE_END	0x60000000
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the i386 and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMAX 0x3fa000			/* max shared seg size (bytes) */
 #define SHMMIN 1 /* really PAGE_SIZE */	/* min shared seg size (bytes) */
--- /usr/tmp/p_rdiff_a007hj/shmparam.h	Wed Jun 23 22:07:57 1999
+++ include/asm-sparc/shmparam.h	Wed Jun 16 22:00:30 1999
@@ -7,32 +7,12 @@
 #define SHM_RANGE_END	0x20000000
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the i386 and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMAX 0x1000000		/* max shared seg size (bytes) */
 #define SHMMIN 1 /* really PAGE_SIZE */	/* min shared seg size (bytes) */
--- /usr/tmp/p_rdiff_a007aU/shmparam.h	Wed Jun 23 22:08:04 1999
+++ include/asm-sparc64/shmparam.h	Wed Jun 16 22:00:33 1999
@@ -9,32 +9,12 @@
 #define SHM_RANGE_END	0x20000000
 
 /*
- * Format of a swap-entry for shared memory pages currently out in
- * swap space (see also mm/swap.c).
- *
- * SWP_TYPE = SHM_SWP_TYPE
- * SWP_OFFSET is used as follows:
- *
- *  bits 0..6 : id of shared memory segment page belongs to (SHM_ID)
- *  bits 7..21: index of page within shared memory segment (SHM_IDX)
- *		(actually fewer bits get used since SHMMAX is so low)
- */
-
-/*
  * Keep _SHM_ID_BITS as low as possible since SHMMNI depends on it and
  * there is a static array of size SHMMNI.
  */
 #define _SHM_ID_BITS	7
-#define SHM_ID_MASK	((1<<_SHM_ID_BITS)-1)
 
-#define SHM_IDX_SHIFT	(_SHM_ID_BITS)
 #define _SHM_IDX_BITS	15
-#define SHM_IDX_MASK	((1<<_SHM_IDX_BITS)-1)
-
-/*
- * _SHM_ID_BITS + _SHM_IDX_BITS must be <= 24 on the i386 and
- * SHMMAX <= (PAGE_SIZE << _SHM_IDX_BITS).
- */
 
 #define SHMMAX 0x1000000		/* max shared seg size (bytes) */
 #define SHMMIN 1 /* really PAGE_SIZE */	/* min shared seg size (bytes) */
--- /usr/tmp/p_rdiff_a007lP/swap.h	Wed Jun 23 22:08:13 1999
+++ include/linux/swap.h	Wed Jun 16 21:14:09 1999
@@ -125,13 +125,6 @@
 asmlinkage int sys_swapon(const char *, int);
 
 /*
- * vm_ops not present page codes for shared memory.
- *
- * Will go away eventually..
- */
-#define SHM_SWP_TYPE 0x20
-
-/*
  * swap cache stuff (in linux/mm/swap_state.c)
  */
 
--- /usr/tmp/p_rdiff_a007bJ/shm.c	Wed Jun 23 22:08:21 1999
+++ ipc/shm.c	Wed Jun 23 20:47:21 1999
@@ -495,7 +495,7 @@
 		goto out;
 	}
 
-	shmd->vm_pte = SWP_ENTRY(SHM_SWP_TYPE, id);
+	shmd->vm_pte = id;
 	shmd->vm_start = addr;
 	shmd->vm_end = addr + shp->shm_npages * PAGE_SIZE;
 	shmd->vm_mm = current->mm;
@@ -534,7 +534,7 @@
 	unsigned int id;
 	struct shmid_kernel *shp;
 
-	id = SWP_OFFSET(shmd->vm_pte) & SHM_ID_MASK;
+	id = shmd->vm_pte;
 	shp = shm_segs[id];
 	if (shp == IPC_UNUSED) {
 		printk("shm_open: unused id=%d PANIC\n", id);
@@ -558,7 +558,7 @@
 	int id;
 
 	/* remove from the list of attaches of the shm segment */
-	id = SWP_OFFSET(shmd->vm_pte) & SHM_ID_MASK;
+	id = shmd->vm_pte;
 	shp = shm_segs[id];
 	remove_attach(shp,shmd);  /* remove from shp->attaches */
   	shp->u.shm_lpid = current->pid;
@@ -610,7 +610,7 @@
 	struct shmid_kernel *shp;
 	unsigned int id, idx;
 
-	id = SWP_OFFSET(shmd->vm_pte) & SHM_ID_MASK;
+	id = shmd->vm_pte;
 	idx = (address - shmd->vm_start + shmd->vm_offset) >> PAGE_SHIFT;
 
 #ifdef DEBUG_SHM
--- /usr/tmp/p_rdiff_a007lU/swap_state.c	Wed Jun 23 22:08:29 1999
+++ mm/swap_state.c	Wed Jun 16 21:03:48 1999
@@ -85,8 +85,6 @@
 	if (!entry)
 		goto out;
 	type = SWP_TYPE(entry);
-	if (type & SHM_SWP_TYPE)
-		goto out;
 	if (type >= nr_swapfiles)
 		goto bad_file;
 	p = type + swap_info;
@@ -140,8 +138,6 @@
 	if (!entry)
 		goto bad_entry;
 	type = SWP_TYPE(entry);
-	if (type & SHM_SWP_TYPE)
-		goto out;
 	if (type >= nr_swapfiles)
 		goto bad_file;
 	p = type + swap_info;
--- /usr/tmp/p_rdiff_a007k3/swapfile.c	Wed Jun 23 22:08:37 1999
+++ mm/swapfile.c	Wed Jun 16 21:04:19 1999
@@ -119,8 +119,6 @@
 		goto out;
 
 	type = SWP_TYPE(entry);
-	if (type & SHM_SWP_TYPE)
-		goto out;
 	if (type >= nr_swapfiles)
 		goto bad_nofile;
 	p = & swap_info[type];
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Date: Sat, 21 Apr 2007 03:12:02 -0400
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
Message-ID: <20070421071202.GA355@devserv.devel.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <46247427.6000902@redhat.com> <20070420135715.f6e8e091.akpm@linux-foundation.org> <462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4629524C.5040302@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 20, 2007 at 07:52:44PM -0400, Rik van Riel wrote:
> It turns out that Nick's patch does not improve peak
> performance much, but it does prevent the decline when
> running with 16 threads on my quad core CPU!
> 
> We _definately_ want both patches, there's a huge benefit
> in having them both.
> 
> Here are the transactions/seconds for each combination:
> 
>    vanilla   new glibc  madv_free kernel   madv_free + mmap_sem
> threads
> 
> 1     610         609             596                545
> 2    1032        1136            1196               1200
> 4    1070        1128            2014               2024
> 8    1000        1088            1665               2087
> 16    779        1073            1310               1999

FYI, I have uploaded a testing glibc that uses MADV_FREE and falls back
to MADV_DONTUSE if MADV_FREE is not available, to
http://people.redhat.com/jakub/glibc/2.5.90-21.1/
and I'm also attaching the glibc patch for those who want to build it
themselves:

2007-04-19  Ulrich Drepper  <drepper@redhat.com>
	    Jakub Jelinek  <jakub@redhat.com>

	* malloc/arena.c (heap_info): Add mprotect_size field, adjust pad.
	(new_heap): Initialize mprotect_size.
	(no_madv_free): New variable.
	(grow_heap): When growing, only mprotect from mprotect_size till
	new_size if mprotect_size is smaller.  When shrinking, use PROT_NONE
	MMAP for __libc_enable_secure only, otherwise if MADV_FREE is
	available use it and fall back to MADV_DONTNEED.
	* sysdeps/unix/sysv/linux/alpha/bits/mman.h (MADV_FREE): Define.
	* sysdeps/unix/sysv/linux/ia64/bits/mman.h (MADV_FREE): Likewise.
	* sysdeps/unix/sysv/linux/i386/bits/mman.h (MADV_FREE): Likewise.
	* sysdeps/unix/sysv/linux/s390/bits/mman.h (MADV_FREE): Likewise.
	* sysdeps/unix/sysv/linux/powerpc/bits/mman.h (MADV_FREE): Likewise.
	* sysdeps/unix/sysv/linux/x86_64/bits/mman.h (MADV_FREE): Likewise.
	* sysdeps/unix/sysv/linux/sparc/bits/mman.h (MADV_FREE): Likewise.
	* sysdeps/unix/sysv/linux/sh/bits/mman.h (MADV_FREE): Likewise.

--- libc/malloc/arena.c.jj	2006-10-31 23:05:31.000000000 +0100
+++ libc/malloc/arena.c	2007-04-19 18:54:20.000000000 +0200
@@ -1,5 +1,6 @@
 /* Malloc implementation for multiple threads without lock contention.
-   Copyright (C) 2001,2002,2003,2004,2005,2006 Free Software Foundation, Inc.
+   Copyright (C) 2001,2002,2003,2004,2005,2006,2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
    Contributed by Wolfram Gloger <wg@malloc.de>, 2001.
 
@@ -59,10 +60,12 @@ typedef struct _heap_info {
   mstate ar_ptr; /* Arena for this heap. */
   struct _heap_info *prev; /* Previous heap. */
   size_t size;   /* Current size in bytes. */
+  size_t mprotect_size;	/* Size in bytes that has been mprotected
+			   PROT_READ|PROT_WRITE.  */
   /* Make sure the following data is properly aligned, particularly
      that sizeof (heap_info) + 2 * SIZE_SZ is a multiple of
-     MALLOG_ALIGNMENT. */
-  char pad[-5 * SIZE_SZ & MALLOC_ALIGN_MASK];
+     MALLOC_ALIGNMENT. */
+  char pad[-6 * SIZE_SZ & MALLOC_ALIGN_MASK];
 } heap_info;
 
 /* Get a compile-time error if the heap_info padding is not correct
@@ -692,10 +695,15 @@ new_heap(size, top_pad) size_t size, top
   }
   h = (heap_info *)p2;
   h->size = size;
+  h->mprotect_size = size;
   THREAD_STAT(stat_n_heaps++);
   return h;
 }
 
+#if defined _LIBC && defined MADV_FREE
+static int no_madv_free;
+#endif
+
 /* Grow or shrink a heap.  size is automatically rounded up to a
    multiple of the page size if it is positive. */
 
@@ -714,17 +722,49 @@ grow_heap(h, diff) heap_info *h; long di
     new_size = (long)h->size + diff;
     if((unsigned long) new_size > (unsigned long) HEAP_MAX_SIZE)
       return -1;
-    if(mprotect((char *)h + h->size, diff, PROT_READ|PROT_WRITE) != 0)
-      return -2;
+    if((unsigned long) new_size > h->mprotect_size) {
+      if (mprotect((char *)h + h->mprotect_size,
+		   (unsigned long) new_size - h->mprotect_size,
+		   PROT_READ|PROT_WRITE) != 0)
+	return -2;
+      h->mprotect_size = new_size;
+    }
   } else {
     new_size = (long)h->size + diff;
     if(new_size < (long)sizeof(*h))
       return -1;
     /* Try to re-map the extra heap space freshly to save memory, and
        make it inaccessible. */
-    if((char *)MMAP((char *)h + new_size, -diff, PROT_NONE,
-                    MAP_PRIVATE|MAP_FIXED) == (char *) MAP_FAILED)
-      return -2;
+#ifdef _LIBC
+    if (__builtin_expect (__libc_enable_secure, 0))
+#else
+    if (1)
+#endif
+      {
+	if((char *)MMAP((char *)h + new_size, -diff, PROT_NONE,
+			MAP_PRIVATE|MAP_FIXED) == (char *) MAP_FAILED)
+	  return -2;
+	h->mprotect_size = new_size;
+      }
+#ifdef _LIBC
+    else
+      {
+# ifdef MADV_FREE
+	if (!__builtin_expect (no_madv_free, 0))
+	  {
+	    if (__builtin_expect (madvise ((char *)h + new_size,
+					   -diff, MADV_FREE), 0) == -1
+		&& errno == EINVAL)
+	      {
+		no_madv_free = 1;
+		madvise ((char *)h + new_size, -diff, MADV_DONTNEED);
+	      }
+	  }
+	else
+# endif
+	  madvise ((char *)h + new_size, -diff, MADV_DONTNEED);
+      }
+#endif
     /*fprintf(stderr, "shrink %p %08lx\n", h, new_size);*/
   }
   h->size = new_size;
--- libc/sysdeps/unix/sysv/linux/alpha/bits/mman.h.jj	2006-05-02 16:33:44.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/alpha/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,6 @@
 /* Definitions for POSIX memory map interface.  Linux/Alpha version.
-   Copyright (C) 1997, 1998, 2000, 2003, 2006 Free Software Foundation, Inc.
+   Copyright (C) 1997, 1998, 2000, 2003, 2006, 2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -96,6 +97,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED   3	/* Will need these pages.  */
 # define MADV_DONTNEED   6	/* Don't need these pages.  */
+# define MADV_FREE	 7	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */
--- libc/sysdeps/unix/sysv/linux/ia64/bits/mman.h.jj	2006-05-02 16:33:44.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/ia64/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,6 @@
 /* Definitions for POSIX memory map interface.  Linux/ia64 version.
-   Copyright (C) 1997,1998,2000,2003,2005,2006 Free Software Foundation, Inc.
+   Copyright (C) 1997,1998,2000,2003,2005,2006,2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -89,6 +90,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED	 3	/* Will need these pages.  */
 # define MADV_DONTNEED	 4	/* Don't need these pages.  */
+# define MADV_FREE	 5	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */
--- libc/sysdeps/unix/sysv/linux/i386/bits/mman.h.jj	2006-05-02 16:33:44.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/i386/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,6 @@
 /* Definitions for POSIX memory map interface.  Linux/i386 version.
-   Copyright (C) 1997, 2000, 2003, 2005, 2006 Free Software Foundation, Inc.
+   Copyright (C) 1997, 2000, 2003, 2005, 2006, 2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -88,6 +89,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED	 3	/* Will need these pages.  */
 # define MADV_DONTNEED	 4	/* Don't need these pages.  */
+# define MADV_FREE	 5	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */
--- libc/sysdeps/unix/sysv/linux/s390/bits/mman.h.jj	2006-05-02 16:33:44.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/s390/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,6 @@
 /* Definitions for POSIX memory map interface.  Linux/s390 version.
-   Copyright (C) 2000,2001,2002,2003,2005,2006 Free Software Foundation, Inc.
+   Copyright (C) 2000,2001,2002,2003,2005,2006,2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -89,6 +90,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED	 3	/* Will need these pages.  */
 # define MADV_DONTNEED	 4	/* Don't need these pages.  */
+# define MADV_FREE	 5	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */
--- libc/sysdeps/unix/sysv/linux/powerpc/bits/mman.h.jj	2006-05-02 16:33:44.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/powerpc/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,6 @@
 /* Definitions for POSIX memory map interface.  Linux/PowerPC version.
-   Copyright (C) 1997, 2000, 2003, 2005, 2006 Free Software Foundation, Inc.
+   Copyright (C) 1997, 2000, 2003, 2005, 2006, 2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -89,6 +90,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED	 3	/* Will need these pages.  */
 # define MADV_DONTNEED	 4	/* Don't need these pages.  */
+# define MADV_FREE	 5	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */
--- libc/sysdeps/unix/sysv/linux/x86_64/bits/mman.h.jj	2006-05-02 16:33:46.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/x86_64/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,5 @@
 /* Definitions for POSIX memory map interface.  Linux/x86_64 version.
-   Copyright (C) 2001, 2003, 2005, 2006 Free Software Foundation, Inc.
+   Copyright (C) 2001, 2003, 2005, 2006, 2007 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -89,6 +89,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED	 3	/* Will need these pages.  */
 # define MADV_DONTNEED	 4	/* Don't need these pages.  */
+# define MADV_FREE	 5	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */
--- libc/sysdeps/unix/sysv/linux/sparc/bits/mman.h.jj	2006-05-02 16:33:44.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/sparc/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,6 @@
 /* Definitions for POSIX memory map interface.  Linux/SPARC version.
-   Copyright (C) 1997,1999,2000,2003,2005,2006 Free Software Foundation, Inc.
+   Copyright (C) 1997,1999,2000,2003,2005,2006,2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -90,7 +91,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED	 3	/* Will need these pages.  */
 # define MADV_DONTNEED	 4	/* Don't need these pages.  */
-# define MADV_FREE	 5	/* Content can be freed (Solaris).  */
+# define MADV_FREE	 5	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */
--- libc/sysdeps/unix/sysv/linux/sh/bits/mman.h.jj	2006-05-02 16:33:44.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/sh/bits/mman.h	2007-04-19 18:37:43.000000000 +0200
@@ -1,5 +1,6 @@
 /* Definitions for POSIX memory map interface.  Linux/SH version.
-   Copyright (C) 1997,1999,2000,2003,2005,2006 Free Software Foundation, Inc.
+   Copyright (C) 1997,1999,2000,2003,2005,2006,2007
+   Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -88,6 +89,7 @@
 # define MADV_SEQUENTIAL 2	/* Expect sequential page references.  */
 # define MADV_WILLNEED	 3	/* Will need these pages.  */
 # define MADV_DONTNEED	 4	/* Don't need these pages.  */
+# define MADV_FREE	 5	/* Content can be freed.  */
 # define MADV_REMOVE	 9	/* Remove these pages and resources.  */
 # define MADV_DONTFORK	 10	/* Do not inherit across fork.  */
 # define MADV_DOFORK	 11	/* Do inherit across fork.  */


	Jakub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

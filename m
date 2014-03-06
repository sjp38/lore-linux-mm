Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 488076B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 17:56:43 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id up15so3279671pbc.20
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 14:56:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id m9si6304292pab.119.2014.03.06.14.56.37
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 14:56:42 -0800 (PST)
Date: Thu, 6 Mar 2014 14:56:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: per-thread vma caching
Message-Id: <20140306145636.092dc60215aea0925e47e41b@linux-foundation.org>
In-Reply-To: <1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	<20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
	<1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 03 Mar 2014 16:59:38 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:

> > > --- a/include/linux/sched.h
> > > +++ b/include/linux/sched.h
> > > @@ -23,6 +23,7 @@ struct sched_param {
> > >  #include <linux/errno.h>
> > >  #include <linux/nodemask.h>
> > >  #include <linux/mm_types.h>
> > > +#include <linux/vmacache.h>
> > 
> > This might be awkward - vmacache.h drags in mm.h and we have had tangly
> > problems with these major header files in the past.  I'd be inclined to
> > remove this inclusion and just forward-declare vm_area_struct, but we
> > still need VMACACHE_SIZE, sigh.  Wait and see what happens, I guess.
> 
> Yeah, I wasn't sure what to do about that and was expecting it to come
> up in the review process. Let me know if you want me to change/update
> this.

OK, so the include graph has blown up in our faces.

This is what I came up with.  Haven't tested it a lot yet.  Thoughts?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-per-thread-vma-caching-fix-3

Attempt to untangle header files.

Prior to this patch:

mm.h does not require sched.h
sched.h does not require mm.h
sched.h requires vmacache.h
vmacache.h requires mm.h

After this patch:

mm.h still does not require sched.h
sched.h still does not require mm.h
sched.h does not require vmacache.h
mm.h does not require vmacache.h
vmacache.h requires (and includes) mm.h
vmacache.h requires (and includes) sched.h

To do all this, the three "#define VMACACHE_foo" lines were moved to
sched.h.

The inclusions of sched.h and mm.h into vmacache.h are actually
unrequired because the .c files include mm.h and sched.h directly, but
I put them in there for cargo-cult reasons.

vmacache_flush() no longer needs to be implemented in cpp - make it so.

Cc: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/unicore32/include/asm/mmu_context.h |    2 ++
 fs/exec.c                                |    1 +
 fs/proc/task_mmu.c                       |    1 +
 include/linux/sched.h                    |    5 ++++-
 include/linux/vmacache.h                 |   12 +++++-------
 kernel/debug/debug_core.c                |    1 +
 kernel/fork.c                            |    2 ++
 mm/mmap.c                                |    1 +
 mm/nommu.c                               |    1 +
 mm/vmacache.c                            |    1 +
 10 files changed, 19 insertions(+), 8 deletions(-)

diff -puN arch/unicore32/include/asm/mmu_context.h~mm-per-thread-vma-caching-fix-3 arch/unicore32/include/asm/mmu_context.h
--- a/arch/unicore32/include/asm/mmu_context.h~mm-per-thread-vma-caching-fix-3
+++ a/arch/unicore32/include/asm/mmu_context.h
@@ -14,6 +14,8 @@
 
 #include <linux/compiler.h>
 #include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/vmacache.h>
 #include <linux/io.h>
 
 #include <asm/cacheflush.h>
diff -puN fs/exec.c~mm-per-thread-vma-caching-fix-3 fs/exec.c
--- a/fs/exec.c~mm-per-thread-vma-caching-fix-3
+++ a/fs/exec.c
@@ -26,6 +26,7 @@
 #include <linux/file.h>
 #include <linux/fdtable.h>
 #include <linux/mm.h>
+#include <linux/vmacache.h>
 #include <linux/stat.h>
 #include <linux/fcntl.h>
 #include <linux/swap.h>
diff -puN fs/proc/task_mmu.c~mm-per-thread-vma-caching-fix-3 fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~mm-per-thread-vma-caching-fix-3
+++ a/fs/proc/task_mmu.c
@@ -1,4 +1,5 @@
 #include <linux/mm.h>
+#include <linux/vmacache.h>
 #include <linux/hugetlb.h>
 #include <linux/huge_mm.h>
 #include <linux/mount.h>
diff -puN include/linux/mm_types.h~mm-per-thread-vma-caching-fix-3 include/linux/mm_types.h
diff -puN include/linux/sched.h~mm-per-thread-vma-caching-fix-3 include/linux/sched.h
--- a/include/linux/sched.h~mm-per-thread-vma-caching-fix-3
+++ a/include/linux/sched.h
@@ -23,7 +23,6 @@ struct sched_param {
 #include <linux/errno.h>
 #include <linux/nodemask.h>
 #include <linux/mm_types.h>
-#include <linux/vmacache.h>
 #include <linux/preempt_mask.h>
 
 #include <asm/page.h>
@@ -131,6 +130,10 @@ struct perf_event_context;
 struct blk_plug;
 struct filename;
 
+#define VMACACHE_BITS 2
+#define VMACACHE_SIZE (1U << VMACACHE_BITS)
+#define VMACACHE_MASK (VMACACHE_SIZE - 1)
+
 /*
  * List of flags we want to share for kernel threads,
  * if only because they are not used by them anyway.
diff -puN include/linux/vmacache.h~mm-per-thread-vma-caching-fix-3 include/linux/vmacache.h
--- a/include/linux/vmacache.h~mm-per-thread-vma-caching-fix-3
+++ a/include/linux/vmacache.h
@@ -1,21 +1,19 @@
 #ifndef __LINUX_VMACACHE_H
 #define __LINUX_VMACACHE_H
 
+#include <linux/sched.h>
 #include <linux/mm.h>
 
-#define VMACACHE_BITS 2
-#define VMACACHE_SIZE (1U << VMACACHE_BITS)
-#define VMACACHE_MASK (VMACACHE_SIZE - 1)
 /*
  * Hash based on the page number. Provides a good hit rate for
  * workloads with good locality and those with random accesses as well.
  */
 #define VMACACHE_HASH(addr) ((addr >> PAGE_SHIFT) & VMACACHE_MASK)
 
-#define vmacache_flush(tsk)					 \
-	do {							 \
-		memset(tsk->vmacache, 0, sizeof(tsk->vmacache)); \
-	} while (0)
+static inline void vmacache_flush(struct task_struct *tsk)
+{
+	memset(tsk->vmacache, 0, sizeof(tsk->vmacache));
+}
 
 extern void vmacache_flush_all(struct mm_struct *mm);
 extern void vmacache_update(unsigned long addr, struct vm_area_struct *newvma);
diff -puN kernel/debug/debug_core.c~mm-per-thread-vma-caching-fix-3 kernel/debug/debug_core.c
--- a/kernel/debug/debug_core.c~mm-per-thread-vma-caching-fix-3
+++ a/kernel/debug/debug_core.c
@@ -49,6 +49,7 @@
 #include <linux/pid.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
+#include <linux/vmacache.h>
 #include <linux/rcupdate.h>
 
 #include <asm/cacheflush.h>
diff -puN kernel/fork.c~mm-per-thread-vma-caching-fix-3 kernel/fork.c
--- a/kernel/fork.c~mm-per-thread-vma-caching-fix-3
+++ a/kernel/fork.c
@@ -28,6 +28,8 @@
 #include <linux/mman.h>
 #include <linux/mmu_notifier.h>
 #include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/vmacache.h>
 #include <linux/nsproxy.h>
 #include <linux/capability.h>
 #include <linux/cpu.h>
diff -puN mm/Makefile~mm-per-thread-vma-caching-fix-3 mm/Makefile
diff -puN mm/mmap.c~mm-per-thread-vma-caching-fix-3 mm/mmap.c
--- a/mm/mmap.c~mm-per-thread-vma-caching-fix-3
+++ a/mm/mmap.c
@@ -10,6 +10,7 @@
 #include <linux/slab.h>
 #include <linux/backing-dev.h>
 #include <linux/mm.h>
+#include <linux/vmacache.h>
 #include <linux/shm.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
diff -puN mm/nommu.c~mm-per-thread-vma-caching-fix-3 mm/nommu.c
--- a/mm/nommu.c~mm-per-thread-vma-caching-fix-3
+++ a/mm/nommu.c
@@ -15,6 +15,7 @@
 
 #include <linux/export.h>
 #include <linux/mm.h>
+#include <linux/vmacache.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/file.h>
diff -puN mm/vmacache.c~mm-per-thread-vma-caching-fix-3 mm/vmacache.c
--- a/mm/vmacache.c~mm-per-thread-vma-caching-fix-3
+++ a/mm/vmacache.c
@@ -2,6 +2,7 @@
  * Copyright (C) 2014 Davidlohr Bueso.
  */
 #include <linux/sched.h>
+#include <linux/mm.h>
 #include <linux/vmacache.h>
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

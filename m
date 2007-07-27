Subject: [PATCH/RFC] Add MM_DEAD flag to struct mm_struct
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 12:00:58 +1000
Message-Id: <1185501659.5495.174.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Some architectures like sparc can do useful optimizations when knowing
that an entire MM is being destroyed. At the moment, they rely on
fullmm in the mmu_gather structure. However, that doesn't always work
out very well with some of the changes we are doing. Among other things,
the TLB flushing on sparc64 is done using per-CPU tracking data, making
the batch not per-CPU will break that link.

So instead, we add a new flag to struct mm_struct that indicates that
the mm is going away, for those archs to use. It also allows to use it
in situations (such as PTE ops) where the batch isn't accessible (or
there is no batch)

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Index: linux-work/include/linux/sched.h
===================================================================
--- linux-work.orig/include/linux/sched.h	2007-07-27 11:09:16.000000000 +1000
+++ linux-work/include/linux/sched.h	2007-07-27 11:09:22.000000000 +1000
@@ -353,6 +353,7 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMPABLE      0  /* core dump is permitted */
 #define MMF_DUMP_SECURELY 1  /* core file is readable only by root */
 #define MMF_DUMPABLE_BITS 2
+#define MMF_DEAD          3  /* mm is being destroyed */
 
 /* coredump filter bits */
 #define MMF_DUMP_ANON_PRIVATE	2
Index: linux-work/mm/mmap.c
===================================================================
--- linux-work.orig/mm/mmap.c	2007-07-27 11:09:52.000000000 +1000
+++ linux-work/mm/mmap.c	2007-07-27 11:10:05.000000000 +1000
@@ -1991,6 +1991,9 @@ void exit_mmap(struct mm_struct *mm)
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
+	/* Mark the MM as dead */
+	__set_bit(MMF_DEAD, &mm->flags);
+
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

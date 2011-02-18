Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F14A68D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 10:49:12 -0500 (EST)
Subject: mm: mm_struct remove 16 bytes of alignment padding on 64 bit builds
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 15:49:07 +0000
Message-ID: <1298044147.2071.5.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Reorder mm_struct to remove 16 bytes of alignment padding on 64 bit
builds.
On my config this shrinks mm_struct by enough to fit in one fewer cache
lines and allows more objects per slab in mm_struct kmem_cache under
SLUB.

slabinfo before patch :-
    Sizes (bytes)     Slabs
    --------------------------------
    Object :     848  Total  :       9
    SlabObj:     896  Full   :       2
    SlabSiz:   16384  Partial:       5
    Loss   :      48  CpuSlab:       2
    Align  :      64  Objects:      18
    
 slabinfo after :-
    Sizes (bytes)     Slabs
    --------------------------------
    Object :     832  Total  :       7
    SlabObj:     832  Full   :       2
    SlabSiz:   16384  Partial:       3
    Loss   :       0  CpuSlab:       2
    Align  :      64  Objects:      19

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
---
patch against v2.6.38-rc4
compiled & tested on x86_64

regards
Richard


diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 26bc4e2..02aa561 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -237,8 +237,9 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
-	struct rw_semaphore mmap_sem;
+
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
+	struct rw_semaphore mmap_sem;
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
 						 * together off init_mm.mmlist, and are protected
@@ -281,6 +282,9 @@ struct mm_struct {
 	unsigned int token_priority;
 	unsigned int last_interval;
 
+	/* How many tasks sharing this mm are OOM_DISABLE */
+	atomic_t oom_disable_count;
+
 	unsigned long flags; /* Must use atomic bitops to access the bits */
 
 	struct core_state *core_state; /* coredumping support */
@@ -313,8 +317,6 @@ struct mm_struct {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
-	/* How many tasks sharing this mm are OOM_DISABLE */
-	atomic_t oom_disable_count;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

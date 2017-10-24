Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0516B0271
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:25:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 4so7070399wrt.8
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:25:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i191si363988wmd.139.2017.10.24.08.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 12/17] mm: Define MAP_SYNC and VM_SYNC flags
Date: Tue, 24 Oct 2017 17:24:09 +0200
Message-Id: <20171024152415.22864-13-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Define new MAP_SYNC flag and corresponding VMA VM_SYNC flag. As the
MAP_SYNC flag is not part of LEGACY_MAP_MASK, currently it will be
refused by all MAP_SHARED_VALIDATE map attempts and silently ignored for
everything else.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/proc/task_mmu.c              | 1 +
 include/linux/mm.h              | 1 +
 include/linux/mman.h            | 8 ++++++--
 include/uapi/asm-generic/mman.h | 1 +
 4 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5589b4bd4b85..ea78b37deeaa 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -664,6 +664,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_ACCOUNT)]	= "ac",
 		[ilog2(VM_NORESERVE)]	= "nr",
 		[ilog2(VM_HUGETLB)]	= "ht",
+		[ilog2(VM_SYNC)]	= "sf",
 		[ilog2(VM_ARCH_1)]	= "ar",
 		[ilog2(VM_WIPEONFORK)]	= "wf",
 		[ilog2(VM_DONTDUMP)]	= "dd",
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ca72b67153d5..5411cb7442de 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -189,6 +189,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
+#define VM_SYNC		0x00800000	/* Synchronous page faults */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_WIPEONFORK	0x02000000	/* Wipe VMA contents in child. */
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 94b63b4d71ff..8f7cc87828e6 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -9,7 +9,7 @@
 
 /*
  * Arrange for legacy / undefined architecture specific flags to be
- * ignored by default in LEGACY_MAP_MASK.
+ * ignored by mmap handling code.
  */
 #ifndef MAP_32BIT
 #define MAP_32BIT 0
@@ -23,6 +23,9 @@
 #ifndef MAP_UNINITIALIZED
 #define MAP_UNINITIALIZED 0
 #endif
+#ifndef MAP_SYNC
+#define MAP_SYNC 0
+#endif
 
 /*
  * The historical set of flags that all mmap implementations implicitly
@@ -125,7 +128,8 @@ calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
-	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
+	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    ) |
+	       _calc_vm_trans(flags, MAP_SYNC,	     VM_SYNC      );
 }
 
 unsigned long vm_commit_limit(void);
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 7162cd4cca73..00e55627d2df 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_SYNC	0x80000		/* perform synchronous page faults for the mapping */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

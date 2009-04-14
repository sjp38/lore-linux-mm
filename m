Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 286DF5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 00:22:28 -0400 (EDT)
Date: Tue, 14 Apr 2009 12:22:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
Message-ID: <20090414042231.GA4341@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Export the following page flags in /proc/kpageflags,
just in case they will be useful to someone:

- PG_swapcache
- PG_swapbacked
- PG_mappedtodisk
- PG_reserved
- PG_private
- PG_private_2
- PG_owner_priv_1

- PG_head
- PG_tail
- PG_compound

- PG_unevictable
- PG_mlocked

- PG_poison

Also add the following two pseudo page flags:

- PG_MMAP:   whether the page is memory mapped
- PG_NOPAGE: whether the page is present

This increases the total number of exported page flags to 25.

Cc: Andi Kleen <andi@firstfloor.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/page.c |  112 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 81 insertions(+), 31 deletions(-)

--- mm.orig/fs/proc/page.c
+++ mm/fs/proc/page.c
@@ -68,20 +68,86 @@ static const struct file_operations proc
 
 /* These macros are used to decouple internal flags from exported ones */
 
-#define KPF_LOCKED     0
-#define KPF_ERROR      1
-#define KPF_REFERENCED 2
-#define KPF_UPTODATE   3
-#define KPF_DIRTY      4
-#define KPF_LRU        5
-#define KPF_ACTIVE     6
-#define KPF_SLAB       7
-#define KPF_WRITEBACK  8
-#define KPF_RECLAIM    9
-#define KPF_BUDDY     10
+enum {
+	KPF_LOCKED,		/*  0 */
+	KPF_ERROR,		/*  1 */
+	KPF_REFERENCED,		/*  2 */
+	KPF_UPTODATE,		/*  3 */
+	KPF_DIRTY,		/*  4 */
+	KPF_LRU,		/*  5 */
+	KPF_ACTIVE,		/*  6 */
+	KPF_SLAB,		/*  7 */
+	KPF_WRITEBACK,		/*  8 */
+	KPF_RECLAIM,		/*  9 */
+	KPF_BUDDY,		/* 10 */
+	KPF_MMAP,		/* 11 */
+	KPF_SWAPCACHE,		/* 12 */
+	KPF_SWAPBACKED,		/* 13 */
+	KPF_MAPPEDTODISK,	/* 14 */
+	KPF_RESERVED,		/* 15 */
+	KPF_PRIVATE,		/* 16 */
+	KPF_PRIVATE2,		/* 17 */
+	KPF_OWNER_PRIVATE,	/* 18 */
+	KPF_COMPOUND_HEAD,	/* 19 */
+	KPF_COMPOUND_TAIL,	/* 20 */
+	KPF_UNEVICTABLE,	/* 21 */
+	KPF_MLOCKED,		/* 22 */
+	KPF_POISON,		/* 23 */
+	KPF_NOPAGE,		/* 24 */
+	KPF_NUM
+};
 
 #define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
 
+u64 get_uflags(struct page *page)
+{
+	unsigned long kflags; /* todo: use u64 when KPF_NUM grows beyond 32 */
+	u64 uflags;
+
+	if (!page)
+		return 1 << KPF_NOPAGE;
+
+	kflags = page->flags;
+	uflags = 0;
+
+	if (page_mapped(page))
+		uflags |= 1 << KPF_MMAP;
+
+	uflags |= kpf_copy_bit(kflags, KPF_LOCKED,	PG_locked);
+	uflags |= kpf_copy_bit(kflags, KPF_ERROR,	PG_error);
+	uflags |= kpf_copy_bit(kflags, KPF_REFERENCED,	PG_referenced);
+	uflags |= kpf_copy_bit(kflags, KPF_UPTODATE,	PG_uptodate);
+	uflags |= kpf_copy_bit(kflags, KPF_DIRTY,	PG_dirty);
+	uflags |= kpf_copy_bit(kflags, KPF_LRU,		PG_lru)	;
+	uflags |= kpf_copy_bit(kflags, KPF_ACTIVE,	PG_active);
+	uflags |= kpf_copy_bit(kflags, KPF_SLAB,	PG_slab);
+	uflags |= kpf_copy_bit(kflags, KPF_WRITEBACK,	PG_writeback);
+	uflags |= kpf_copy_bit(kflags, KPF_RECLAIM,	PG_reclaim);
+	uflags |= kpf_copy_bit(kflags, KPF_BUDDY,	PG_buddy);
+	uflags |= kpf_copy_bit(kflags, KPF_SWAPCACHE,	PG_swapcache);
+	uflags |= kpf_copy_bit(kflags, KPF_SWAPBACKED,	PG_swapbacked);
+	uflags |= kpf_copy_bit(kflags, KPF_MAPPEDTODISK, PG_mappedtodisk);
+	uflags |= kpf_copy_bit(kflags, KPF_RESERVED,	PG_reserved);
+	uflags |= kpf_copy_bit(kflags, KPF_PRIVATE,	PG_private);
+	uflags |= kpf_copy_bit(kflags, KPF_PRIVATE2,	PG_private_2);
+	uflags |= kpf_copy_bit(kflags, KPF_OWNER_PRIVATE, PG_owner_priv_1);
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+	uflags |= kpf_copy_bit(kflags, KPF_COMPOUND_HEAD, PG_head);
+	uflags |= kpf_copy_bit(kflags, KPF_COMPOUND_TAIL, PG_tail);
+#else
+	uflags |= kpf_copy_bit(kflags, KPF_COMPOUND_HEAD, PG_compound);
+#endif
+#ifdef CONFIG_UNEVICTABLE_LRU
+	uflags |= kpf_copy_bit(kflags, KPF_UNEVICTABLE,	PG_unevictable);
+	uflags |= kpf_copy_bit(kflags, KPF_MLOCKED,	PG_mlocked);
+#endif
+#ifdef CONFIG_MEMORY_FAILURE
+	uflags |= kpf_copy_bit(kflags, KPF_POISON,	PG_poison);
+#endif
+
+	return uflags;
+};
+
 static ssize_t kpageflags_read(struct file *file, char __user *buf,
 			     size_t count, loff_t *ppos)
 {
@@ -90,7 +156,6 @@ static ssize_t kpageflags_read(struct fi
 	unsigned long src = *ppos;
 	unsigned long pfn;
 	ssize_t ret = 0;
-	u64 kflags, uflags;
 
 	pfn = src / KPMSIZE;
 	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
@@ -98,32 +163,17 @@ static ssize_t kpageflags_read(struct fi
 		return -EINVAL;
 
 	while (count > 0) {
-		ppage = NULL;
 		if (pfn_valid(pfn))
 			ppage = pfn_to_page(pfn);
-		pfn++;
-		if (!ppage)
-			kflags = 0;
 		else
-			kflags = ppage->flags;
+			ppage = NULL;
 
-		uflags = kpf_copy_bit(kflags, KPF_LOCKED, PG_locked) |
-			kpf_copy_bit(kflags, KPF_ERROR, PG_error) |
-			kpf_copy_bit(kflags, KPF_REFERENCED, PG_referenced) |
-			kpf_copy_bit(kflags, KPF_UPTODATE, PG_uptodate) |
-			kpf_copy_bit(kflags, KPF_DIRTY, PG_dirty) |
-			kpf_copy_bit(kflags, KPF_LRU, PG_lru) |
-			kpf_copy_bit(kflags, KPF_ACTIVE, PG_active) |
-			kpf_copy_bit(kflags, KPF_SLAB, PG_slab) |
-			kpf_copy_bit(kflags, KPF_WRITEBACK, PG_writeback) |
-			kpf_copy_bit(kflags, KPF_RECLAIM, PG_reclaim) |
-			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy);
-
-		if (put_user(uflags, out++)) {
+		if (put_user(get_uflags(ppage), out)) {
 			ret = -EFAULT;
 			break;
 		}
-
+		out++;
+		pfn++;
 		count -= KPMSIZE;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

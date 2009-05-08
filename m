From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Date: Fri, 08 May 2009 18:53:24 +0800
Message-ID: <20090508111031.020574236@intel.com>
References: <20090508105320.316173813@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 826196B0062
	for <linux-mm@kvack.org>; Fri,  8 May 2009 07:12:38 -0400 (EDT)
Content-Disposition: inline; filename=kpageflags-extending.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Export all page flags faithfully in /proc/kpageflags.

	11. KPF_MMAP		(pseudo flag) memory mapped page
	12. KPF_ANON		(pseudo flag) memory mapped page (anonymous)
	13. KPF_SWAPCACHE	page is in swap cache
	14. KPF_SWAPBACKED	page is swap/RAM backed
	15. KPF_COMPOUND_HEAD	(*)
	16. KPF_COMPOUND_TAIL	(*)
	17. KPF_HUGE		hugeTLB pages
	18. KPF_UNEVICTABLE	page is in the unevictable LRU list
	19. KPF_HWPOISON(TBD)	hardware detected corruption
	20. KPF_NOPAGE		(pseudo flag) no page frame at the address
	32-39.			more obscure flags for kernel developers

	(*) For compound pages, exporting _both_ head/tail info enables
	    users to tell where a compound page starts/ends, and its order.

The acompanied page-types tool will handle the details like decoupling
overloaded flags and hiding obscure flags to normal users.

Thanks to KOSAKI and Andi for their valuable recommendations!

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/page.c |  148 +++++++++++++++++++++++++++++++++++++----------
 1 file changed, 118 insertions(+), 30 deletions(-)

--- linux.orig/fs/proc/page.c
+++ linux/fs/proc/page.c
@@ -71,19 +71,124 @@ static const struct file_operations proc
 
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
+#define KPF_LOCKED		0
+#define KPF_ERROR		1
+#define KPF_REFERENCED		2
+#define KPF_UPTODATE		3
+#define KPF_DIRTY		4
+#define KPF_LRU			5
+#define KPF_ACTIVE		6
+#define KPF_SLAB		7
+#define KPF_WRITEBACK		8
+#define KPF_RECLAIM		9
+#define KPF_BUDDY		10
+
+/* 11-20: new additions in 2.6.31 */
+#define KPF_MMAP		11
+#define KPF_ANON		12
+#define KPF_SWAPCACHE		13
+#define KPF_SWAPBACKED		14
+#define KPF_COMPOUND_HEAD	15
+#define KPF_COMPOUND_TAIL	16
+#define KPF_HUGE		17
+#define KPF_UNEVICTABLE		18
+#define KPF_NOPAGE		20
+
+/* kernel hacking assistances
+ * WARNING: subject to change, never rely on them!
+ */
+#define KPF_RESERVED		32
+#define KPF_MLOCKED		33
+#define KPF_MAPPEDTODISK	34
+#define KPF_PRIVATE		35
+#define KPF_PRIVATE_2		36
+#define KPF_OWNER_PRIVATE	37
+#define KPF_ARCH		38
+#define KPF_UNCACHED		39
 
-#define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
+static inline u64 kpf_copy_bit(u64 kflags, int ubit, int kbit)
+{
+	return ((kflags >> kbit) & 1) << ubit;
+}
+
+static u64 get_uflags(struct page *page)
+{
+	u64 k;
+	u64 u;
+
+	/*
+	 * pseudo flag: KPF_NOPAGE
+	 * it differentiates a memory hole from a page with no flags
+	 */
+	if (!page)
+		return 1 << KPF_NOPAGE;
+
+	k = page->flags;
+	u = 0;
+
+	/*
+	 * pseudo flags for the well known (anonymous) memory mapped pages
+	 *
+	 * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
+	 * simple test in page_mapped() is not enough.
+	 */
+	if (!PageSlab(page) && page_mapped(page))
+		u |= 1 << KPF_MMAP;
+	if (PageAnon(page))
+		u |= 1 << KPF_ANON;
+
+	/*
+	 * compound pages: export both head/tail info
+	 * they together define a compound page's start/end pos and order
+	 */
+	if (PageHead(page))
+		u |= 1 << KPF_COMPOUND_HEAD;
+	if (PageTail(page))
+		u |= 1 << KPF_COMPOUND_TAIL;
+	if (PageHuge(page))
+		u |= 1 << KPF_HUGE;
+
+	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
+
+	/*
+	 * Caveats on high order pages:
+	 * PG_buddy will only be set on the head page; SLUB/SLQB do the same
+	 * for PG_slab; SLOB won't set PG_slab at all on compound pages.
+	 */
+	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
+	u |= kpf_copy_bit(k, KPF_BUDDY,		PG_buddy);
+
+	u |= kpf_copy_bit(k, KPF_ERROR,		PG_error);
+	u |= kpf_copy_bit(k, KPF_DIRTY,		PG_dirty);
+	u |= kpf_copy_bit(k, KPF_UPTODATE,	PG_uptodate);
+	u |= kpf_copy_bit(k, KPF_WRITEBACK,	PG_writeback);
+
+	u |= kpf_copy_bit(k, KPF_LRU,		PG_lru);
+	u |= kpf_copy_bit(k, KPF_REFERENCED,	PG_referenced);
+	u |= kpf_copy_bit(k, KPF_ACTIVE,	PG_active);
+	u |= kpf_copy_bit(k, KPF_RECLAIM,	PG_reclaim);
+
+	u |= kpf_copy_bit(k, KPF_SWAPCACHE,	PG_swapcache);
+	u |= kpf_copy_bit(k, KPF_SWAPBACKED,	PG_swapbacked);
+
+#ifdef CONFIG_UNEVICTABLE_LRU
+	u |= kpf_copy_bit(k, KPF_UNEVICTABLE,	PG_unevictable);
+	u |= kpf_copy_bit(k, KPF_MLOCKED,	PG_mlocked);
+#endif
+
+#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
+	u |= kpf_copy_bit(k, KPF_UNCACHED,	PG_uncached);
+#endif
+
+	u |= kpf_copy_bit(k, KPF_RESERVED,	PG_reserved);
+	u |= kpf_copy_bit(k, KPF_MAPPEDTODISK,	PG_mappedtodisk);
+	u |= kpf_copy_bit(k, KPF_PRIVATE,	PG_private);
+	u |= kpf_copy_bit(k, KPF_PRIVATE_2,	PG_private_2);
+	u |= kpf_copy_bit(k, KPF_OWNER_PRIVATE,	PG_owner_priv_1);
+	u |= kpf_copy_bit(k, KPF_ARCH,		PG_arch_1);
+
+	return u;
+};
 
 static ssize_t kpageflags_read(struct file *file, char __user *buf,
 			     size_t count, loff_t *ppos)
@@ -93,7 +198,6 @@ static ssize_t kpageflags_read(struct fi
 	unsigned long src = *ppos;
 	unsigned long pfn;
 	ssize_t ret = 0;
-	u64 kflags, uflags;
 
 	pfn = src / KPMSIZE;
 	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
@@ -105,24 +209,8 @@ static ssize_t kpageflags_read(struct fi
 			ppage = pfn_to_page(pfn);
 		else
 			ppage = NULL;
-		if (!ppage)
-			kflags = 0;
-		else
-			kflags = ppage->flags;
-
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
 
-		if (put_user(uflags, out)) {
+		if (put_user(get_uflags(ppage), out)) {
 			ret = -EFAULT;
 			break;
 		}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

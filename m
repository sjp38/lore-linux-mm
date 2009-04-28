From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Date: Tue, 28 Apr 2009 09:09:12 +0800
Message-ID: <20090428014920.769723618@intel.com>
References: <20090428010907.912554629@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A79A06B00E6
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 21:50:41 -0400 (EDT)
Content-Disposition: inline; filename=kpageflags-extending.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Export 9 page flags in /proc/kpageflags, and 8 more for kernel developers.

1) for kernel hackers (on CONFIG_DEBUG_KERNEL)
   - all available page flags are exported, and
   - exported as is
2) for admins and end users
   - only the more `well known' flags are exported:
	11. KPF_MMAP		(pseudo flag) memory mapped page
	12. KPF_ANON		(pseudo flag) memory mapped page (anonymous)
	13. KPF_SWAPCACHE	page is in swap cache
	14. KPF_SWAPBACKED	page is swap/RAM backed
	15. KPF_COMPOUND_HEAD	(*)
	16. KPF_COMPOUND_TAIL	(*)
	17. KPF_UNEVICTABLE	page is in the unevictable LRU list
	18. KPF_HWPOISON	hardware detected corruption
	19. KPF_NOPAGE		(pseudo flag) no page frame at the address

	(*) For compound pages, exporting _both_ head/tail info enables
	    users to tell where a compound page starts/ends, and its order.

   - limit flags to their typical usage scenario, as indicated by KOSAKI:
	- LRU pages: only export relevant flags
		- PG_lru
		- PG_unevictable
		- PG_active
		- PG_referenced
		- page_mapped()
		- PageAnon()
		- PG_swapcache
		- PG_swapbacked
		- PG_reclaim
	- no-IO pages: mask out irrelevant flags
		- PG_dirty
		- PG_uptodate
		- PG_writeback
	- SLAB pages: mask out overloaded flags:
		- PG_error
		- PG_active
		- PG_private
	- PG_reclaim: mask out the overloaded PG_readahead
	- compound flags: only export huge/gigantic pages

Here are the admin/linus views of all page flags on a newly booted nfs-root system:

# ./page-types # for admin
         flags  page-count       MB  symbolic-flags                     long-symbolic-flags
0x000000000000      491174     1918  ____________________________                
0x000000000020           1        0  _____l______________________       lru      
0x000000000028        2543        9  ___U_l______________________       uptodate,lru
0x00000000002c        5288       20  __RU_l______________________       referenced,uptodate,lru
0x000000004060           1        0  _____lA_______b_____________       lru,active,swapbacked
0x000000004064          19        0  __R__lA_______b_____________       referenced,lru,active,swapbacked
0x000000000068         225        0  ___U_lA_____________________       uptodate,lru,active
0x00000000006c         969        3  __RU_lA_____________________       referenced,uptodate,lru,active
0x000000000080        6832       26  _______S____________________       slab     
0x000000000400         576        2  __________B_________________       buddy    
0x000000000828        1159        4  ___U_l_____M________________       uptodate,lru,mmap
0x00000000082c         310        1  __RU_l_____M________________       referenced,uptodate,lru,mmap
0x000000004860           2        0  _____lA____M__b_____________       lru,active,mmap,swapbacked
0x000000000868         375        1  ___U_lA____M________________       uptodate,lru,active,mmap
0x00000000086c         635        2  __RU_lA____M________________       referenced,uptodate,lru,active,mmap
0x000000005860        3831       14  _____lA____Ma_b_____________       lru,active,mmap,anonymous,swapbacked
0x000000005864          28        0  __R__lA____Ma_b_____________       referenced,lru,active,mmap,anonymous,swapbacked
         total      513968     2007                                              

# ./page-types # for linus, when CONFIG_DEBUG_KERNEL is turned on
         flags  page-count       MB  symbolic-flags                     long-symbolic-flags
0x000000000000      471058     1840  ____________________________
0x000100000000       19288       75  ____________________r_______       reserved
0x000000010000        1064        4  ________________T___________       compound_tail
0x000000008000           1        0  _______________H____________       compound_head
0x000000008014           1        0  __R_D__________H____________       referenced,dirty,compound_head
0x000000010014           4        0  __R_D___________T___________       referenced,dirty,compound_tail
0x000000000020           1        0  _____l______________________       lru
0x000000000028        2522        9  ___U_l______________________       uptodate,lru
0x00000000002c        5207       20  __RU_l______________________       referenced,uptodate,lru
0x000000000068         203        0  ___U_lA_____________________       uptodate,lru,active
0x00000000006c         869        3  __RU_lA_____________________       referenced,uptodate,lru,active
0x000000004078           1        0  ___UDlA_______b_____________       uptodate,dirty,lru,active,swapbacked
0x00000000407c          19        0  __RUDlA_______b_____________       referenced,uptodate,dirty,lru,active,swapbacked
0x000000000080        5989       23  _______S____________________       slab
0x000000008080         778        3  _______S_______H____________       slab,compound_head
0x000000000228          44        0  ___U_l___I__________________       uptodate,lru,reclaim
0x00000000022c          39        0  __RU_l___I__________________       referenced,uptodate,lru,reclaim
0x000000000268          12        0  ___U_lA__I__________________       uptodate,lru,active,reclaim
0x00000000026c          44        0  __RU_lA__I__________________       referenced,uptodate,lru,active,reclaim
0x000000000400         550        2  __________B_________________       buddy
0x000000000804           1        0  __R________M________________       referenced,mmap
0x000000000828        1068        4  ___U_l_____M________________       uptodate,lru,mmap
0x00000000082c         326        1  __RU_l_____M________________       referenced,uptodate,lru,mmap
0x000000000868         335        1  ___U_lA____M________________       uptodate,lru,active,mmap
0x00000000086c         599        2  __RU_lA____M________________       referenced,uptodate,lru,active,mmap
0x000000004878           2        0  ___UDlA____M__b_____________       uptodate,dirty,lru,active,mmap,swapbacked
0x000000000a28          44        0  ___U_l___I_M________________       uptodate,lru,reclaim,mmap
0x000000000a2c          12        0  __RU_l___I_M________________       referenced,uptodate,lru,reclaim,mmap
0x000000000a68           8        0  ___U_lA__I_M________________       uptodate,lru,active,reclaim,mmap
0x000000000a6c          31        0  __RU_lA__I_M________________       referenced,uptodate,lru,active,reclaim,mmap
0x000000001000         442        1  ____________a_______________       anonymous
0x000000005808           7        0  ___U_______Ma_b_____________       uptodate,mmap,anonymous,swapbacked
0x000000005868        3371       13  ___U_lA____Ma_b_____________       uptodate,lru,active,mmap,anonymous,swapbacked                
0x00000000586c          28        0  __RU_lA____Ma_b_____________       referenced,uptodate,lru,active,mmap,anonymous,swapbacked
         total      513968     2007

Thanks to KOSAKI and Andi for their valuable recommendations!

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/page.c |  197 +++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 167 insertions(+), 30 deletions(-)

--- mm.orig/fs/proc/page.c
+++ mm/fs/proc/page.c
@@ -6,6 +6,7 @@
 #include <linux/mmzone.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/backing-dev.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
@@ -70,19 +71,172 @@ static const struct file_operations proc
 
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
+/* new additions in 2.6.31 */
+#define KPF_MMAP		11
+#define KPF_ANON		12
+#define KPF_SWAPCACHE		13
+#define KPF_SWAPBACKED		14
+#define KPF_COMPOUND_HEAD	15
+#define KPF_COMPOUND_TAIL	16
+#define KPF_UNEVICTABLE		17
+#define KPF_HWPOISON		18
+#define KPF_NOPAGE		19
+
+/* kernel hacking assistances */
+#define KPF_RESERVED		32
+#define KPF_MLOCKED		33
+#define KPF_MAPPEDTODISK	34
+#define KPF_PRIVATE		35
+#define KPF_PRIVATE2		36
+#define KPF_OWNER_PRIVATE	37
+#define KPF_ARCH		38
+#define KPF_UNCACHED		39
+
+/*
+ * Kernel flags are exported faithfully to Linus and his fellow hackers.
+ * Otherwise some details are masked to avoid confusing the end user:
+ * - some kernel flags are completely invisible
+ * - some kernel flags are conditionally invisible on their odd usages
+ */
+#ifdef CONFIG_DEBUG_KERNEL
+static inline int genuine_linus(void) { return 1; }
+#else
+static inline int genuine_linus(void) { return 0; }
+#endif
+
+#define kpf_copy_bit(uflags, kflags, visible, ubit, kbit)		\
+	do {								\
+		if (visible || genuine_linus())				\
+			uflags |= ((kflags >> kbit) & 1) << ubit;	\
+	} while (0);
+
+/* a helper function _not_ intended for more general uses */
+static inline int page_cap_writeback_dirty(struct page *page)
+{
+	struct address_space *mapping;
+
+	if (!PageSlab(page))
+		mapping = page_mapping(page);
+	else
+		mapping = NULL;
+
+	return mapping && mapping_cap_writeback_dirty(mapping);
+}
+
+static u64 get_uflags(struct page *page)
+{
+	u64 k;
+	u64 u;
+	int io;
+	int lru;
+	int slab;
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
+	io   = page_cap_writeback_dirty(page);
+	lru  = k & (1 << PG_lru);
+	slab = k & (1 << PG_slab);
+
+	/*
+	 * pseudo flags for the well known (anonymous) memory mapped pages
+	 */
+	if (lru || genuine_linus()) {
+		if (!slab && page_mapped(page))
+			u |= 1 << KPF_MMAP;
+		if (PageAnon(page))
+			u |= 1 << KPF_ANON;
+	}
 
-#define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
+	/*
+	 * compound pages: export both head/tail info
+	 * they together define a compound page's start/end pos and order
+	 */
+	if (PageHuge(page) || genuine_linus()) {
+		if (PageHead(page))
+			u |= 1 << KPF_COMPOUND_HEAD;
+		if (PageTail(page))
+			u |= 1 << KPF_COMPOUND_TAIL;
+	}
+
+	kpf_copy_bit(u, k, 1,	  KPF_LOCKED,		PG_locked);
+
+	/*
+	 * Caveats on high order pages:
+	 * PG_buddy will only be set on the head page; SLUB/SLQB do the same
+	 * for PG_slab; SLOB won't set PG_slab at all on compound pages.
+	 */
+	kpf_copy_bit(u, k, 1,     KPF_SLAB,		PG_slab);
+	kpf_copy_bit(u, k, 1,     KPF_BUDDY,		PG_buddy);
+
+	kpf_copy_bit(u, k, io,    KPF_ERROR,		PG_error);
+	kpf_copy_bit(u, k, io,    KPF_DIRTY,		PG_dirty);
+	kpf_copy_bit(u, k, io,    KPF_UPTODATE,		PG_uptodate);
+	kpf_copy_bit(u, k, io,    KPF_WRITEBACK,	PG_writeback);
+
+	kpf_copy_bit(u, k, 1,     KPF_LRU,		PG_lru);
+	kpf_copy_bit(u, k, lru,	  KPF_REFERENCED,	PG_referenced);
+	kpf_copy_bit(u, k, lru,   KPF_ACTIVE,		PG_active);
+	kpf_copy_bit(u, k, lru,   KPF_RECLAIM,		PG_reclaim);
+
+	kpf_copy_bit(u, k, lru,   KPF_SWAPCACHE,	PG_swapcache);
+	kpf_copy_bit(u, k, lru,   KPF_SWAPBACKED,	PG_swapbacked);
+
+#ifdef CONFIG_MEMORY_FAILURE
+	kpf_copy_bit(u, k, 1,     KPF_HWPOISON,		PG_hwpoison);
+#endif
+
+#ifdef CONFIG_UNEVICTABLE_LRU
+	kpf_copy_bit(u, k, lru,   KPF_UNEVICTABLE,	PG_unevictable);
+	kpf_copy_bit(u, k, 0,     KPF_MLOCKED,		PG_mlocked);
+#endif
+
+	kpf_copy_bit(u, k, 0,     KPF_RESERVED,		PG_reserved);
+	kpf_copy_bit(u, k, 0,     KPF_MAPPEDTODISK,	PG_mappedtodisk);
+	kpf_copy_bit(u, k, 0,     KPF_PRIVATE,		PG_private);
+	kpf_copy_bit(u, k, 0,     KPF_PRIVATE2,		PG_private_2);
+	kpf_copy_bit(u, k, 0,     KPF_OWNER_PRIVATE,	PG_owner_priv_1);
+	kpf_copy_bit(u, k, 0,     KPF_ARCH,		PG_arch_1);
+
+#ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
+	kpf_copy_bit(u, k, 0,     KPF_UNCACHED,		PG_uncached);
+#endif
+
+	if (!genuine_linus()) {
+		/*
+		 * SLUB overloads some page flags which may confuse end user.
+		 */
+		if (slab)
+			u &= ~((1 << KPF_ACTIVE) | (1 << KPF_ERROR));
+		/*
+		 * PG_reclaim could be overloaded as PG_readahead,
+		 * and we only want to export the first one.
+		 */
+		if (!(u & (1 << KPF_WRITEBACK)))
+			u &= ~(1 << KPF_RECLAIM);
+	}
+
+	return u;
+};
 
 static ssize_t kpageflags_read(struct file *file, char __user *buf,
 			     size_t count, loff_t *ppos)
@@ -92,7 +246,6 @@ static ssize_t kpageflags_read(struct fi
 	unsigned long src = *ppos;
 	unsigned long pfn;
 	ssize_t ret = 0;
-	u64 kflags, uflags;
 
 	pfn = src / KPMSIZE;
 	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
@@ -104,24 +257,8 @@ static ssize_t kpageflags_read(struct fi
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

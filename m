Message-Id: <20080529122602.208851000@nick.local0.net>
References: <20080529122050.823438000@nick.local0.net>
Date: Thu, 29 May 2008 22:20:52 +1000
From: npiggin@suse.de
Subject: [patch 2/5] mm: introduce get_user_pages_fast
Content-Disposition: inline; filename=mm-get_user_pages-fast.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: shaggy@austin.ibm.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Introduce a new get_user_pages_fast mm API, which is basically a get_user_pages
with a less general API (but still tends to be suited to the common case):

- task and mm are always current and current->mm
- force is always 0
- pages is always non-NULL
- don't pass back vmas

This restricted API can be implemented in a much more scalable way on
many architectures when the ptes are present, by walking the page tables
locklessly (no mmap_sem or page table locks). When the ptes are not
populated, get_user_pages_fast() could be slower.

This is implemented locklessly on x86, and used in some key direct IO call
sites, in later patches, which provides nearly 10% performance improvement
on a threaded database workload.

Lots of other code could use this too, depending on use cases (eg. grep
drivers/). And it might inspire some new and clever ways to use it.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: shaggy@austin.ibm.com
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: apw@shadowen.org

---
 include/linux/mm.h |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -12,6 +12,7 @@
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/uaccess.h> /* for __HAVE_ARCH_GET_USER_PAGES_FAST */
 
 struct mempolicy;
 struct anon_vma;
@@ -830,6 +831,38 @@ extern int mprotect_fixup(struct vm_area
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
 
+#ifdef __HAVE_ARCH_GET_USER_PAGES_FAST
+/*
+ * get_user_pages_fast provides equivalent functionality to get_user_pages,
+ * operating on current and current->mm (force=0 and doesn't return any vmas).
+ *
+ * get_user_pages_fast may take mmap_sem and page tables, so no assumptions
+ * can be made about locking. get_user_pages_fast is to be implemented in a
+ * way that is advantageous (vs get_user_pages()) when the user memory area is
+ * already faulted in and present in ptes. However if the pages have to be
+ * faulted in, it may turn out to be slightly slower).
+ */
+int get_user_pages_fast(unsigned long start, int nr_pages, int write, struct page **pages);
+
+#else
+/*
+ * Should probably be moved to asm-generic, and architectures can include it if
+ * they don't implement their own get_user_pages_fast.
+ */
+#define get_user_pages_fast(start, nr_pages, write, pages)	\
+({								\
+	struct mm_struct *mm = current->mm;			\
+	int ret;						\
+								\
+	down_read(&mm->mmap_sem);				\
+	ret = get_user_pages(current, mm, start, nr_pages,	\
+					write, 0, pages, NULL);	\
+	up_read(&mm->mmap_sem);					\
+								\
+	ret;							\
+})
+#endif
+
 /*
  * A callback you can register to apply pressure to ageable caches.
  *

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

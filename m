Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3A16B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 09:01:51 -0400 (EDT)
Received: by lahh5 with SMTP id h5so24544136lah.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 06:01:51 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a2si751698lah.138.2015.07.30.06.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 06:01:48 -0700 (PDT)
Date: Thu, 30 Jul 2015 16:01:22 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150730130122.GC8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
 <20150729142618.GJ15801@dhcp22.suse.cz>
 <20150729152817.GV8100@esperanza>
 <20150729154718.GN15801@dhcp22.suse.cz>
 <20150729162908.GY8100@esperanza>
 <20150729143015.e8420eca17acbd36d1ce9242@linux-foundation.org>
 <20150730091212.GA8100@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150730091212.GA8100@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 30, 2015 at 12:12:12PM +0300, Vladimir Davydov wrote:
> On Wed, Jul 29, 2015 at 02:30:15PM -0700, Andrew Morton wrote:
> > On Wed, 29 Jul 2015 19:29:08 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> > 
> > > /proc/kpageidle should probably live somewhere in /sys/kernel/mm, but I
> > > added it where similar files are located (kpagecount, kpageflags) to
> > > keep things consistent.
> > 
> > I think these files should be moved elsewhere.  Consistency is good,
> > but not when we're being consistent with a bad thing.
> > 
> > So let's place these in /sys/kernel/mm and then start being consistent
> > with that?
> 
> I really don't think we should separate kpagecgroup from kpagecount and
> kpageflags, because they look very similar (each of them is read-only,
> contains an array of u64 values referenced by PFN). Scattering these
> files between different filesystems would look ugly IMO.
> 
> However, kpageidle is somewhat different (it's read-write, contains a
> bitmap) so I think it's worth moving it to /sys/kernel/mm. We have to
> move the code from fs/proc to mm/something then to remove dependency
> from PROC_FS, which would be unnecessary. Let me give it a try.

Here it goes:

From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap

Since IDLE_PAGE_TRACKING does not need to depend on PROC_FS anymore,
this patch also moves the code from fs/proc/page.c to mm/page_idle.c and
introduces a dedicated header file include/linux/page_idle.h.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/Documentation/vm/idle_page_tracking.txt b/Documentation/vm/idle_page_tracking.txt
index d0f332d544c4..85dcc3bb85dc 100644
--- a/Documentation/vm/idle_page_tracking.txt
+++ b/Documentation/vm/idle_page_tracking.txt
@@ -6,10 +6,12 @@ estimating the workload's working set size, which, in turn, can be taken into
 account when configuring the workload parameters, setting memory cgroup limits,
 or deciding where to place the workload within a compute cluster.
 
+It is enabled by CONFIG_IDLE_PAGE_TRACKING=y.
+
 USER API
 
-If CONFIG_IDLE_PAGE_TRACKING was enabled on compile time, a new read-write file
-is present on the proc filesystem, /proc/kpageidle.
+The idle page tracking API is located at /sys/kernel/mm/page_idle. Currently,
+it consists of the only read-write file, /sys/kernel/mm/page_idle/bitmap.
 
 The file implements a bitmap where each bit corresponds to a memory page. The
 bitmap is represented by an array of 8-byte integers, and the page at PFN #i is
@@ -30,24 +32,25 @@ and hence such pages are never reported idle.
 For huge pages the idle flag is set only on the head page, so one has to read
 /proc/kpageflags in order to correctly count idle huge pages.
 
-Reading from or writing to /proc/kpageidle will return -EINVAL if you are not
-starting the read/write on an 8-byte boundary, or if the size of the read/write
-is not a multiple of 8 bytes. Writing to this file beyond max PFN will return
--ENXIO.
+Reading from or writing to /sys/kernel/mm/page_idle/bitmap will return
+-EINVAL if you are not starting the read/write on an 8-byte boundary, or
+if the size of the read/write is not a multiple of 8 bytes. Writing to
+this file beyond max PFN will return -ENXIO.
 
 That said, in order to estimate the amount of pages that are not used by a
 workload one should:
 
- 1. Mark all the workload's pages as idle by setting corresponding bits in the
-    /proc/kpageidle bitmap. The pages can be found by reading /proc/pid/pagemap
-    if the workload is represented by a process, or by filtering out alien pages
-    using /proc/kpagecgroup in case the workload is placed in a memory cgroup.
+ 1. Mark all the workload's pages as idle by setting corresponding bits in
+    /sys/kernel/mm/page_idle/bitmap. The pages can be found by reading
+    /proc/pid/pagemap if the workload is represented by a process, or by
+    filtering out alien pages using /proc/kpagecgroup in case the workload is
+    placed in a memory cgroup.
 
  2. Wait until the workload accesses its working set.
 
- 3. Read /proc/kpageidle and count the number of bits set. If one wants to
-    ignore certain types of pages, e.g. mlocked pages since they are not
-    reclaimable, he or she can filter them out using /proc/kpageflags.
+ 3. Read /sys/kernel/mm/page_idle/bitmap and count the number of bits set. If
+    one wants to ignore certain types of pages, e.g. mlocked pages since they
+    are not reclaimable, he or she can filter them out using /proc/kpageflags.
 
 See Documentation/vm/pagemap.txt for more information about /proc/pid/pagemap,
 /proc/kpageflags, and /proc/kpagecgroup.
@@ -74,8 +77,9 @@ When a dirty page is written to swap or disk as a result of memory reclaim or
 exceeding the dirty memory limit, it is not marked referenced.
 
 The idle memory tracking feature adds a new page flag, the Idle flag. This flag
-is set manually, by writing to /proc/kpageidle (see the USER API section), and
-cleared automatically whenever a page is referenced as defined above.
+is set manually, by writing to /sys/kernel/mm/page_idle/bitmap (see the USER API
+section), and cleared automatically whenever a page is referenced as defined
+above.
 
 When a page is marked idle, the Accessed bit must be cleared in all PTEs it is
 mapped to, otherwise we will not be able to detect accesses to the page coming
@@ -90,5 +94,5 @@ Since the idle memory tracking feature is based on the memory reclaimer logic,
 it only works with pages that are on an LRU list, other pages are silently
 ignored. That means it will ignore a user memory page if it is isolated, but
 since there are usually not many of them, it should not affect the overall
-result noticeably. In order not to stall scanning of /proc/kpageidle, locked
-pages may be skipped too.
+result noticeably. In order not to stall scanning of the idle page bitmap,
+locked pages may be skipped too.
diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 8ed148d17c2e..0e1e55588b59 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
 userspace programs to examine the page tables and related information by
 reading files in /proc.
 
-There are five components to pagemap:
+There are four components to pagemap:
 
  * /proc/pid/pagemap.  This file lets a userspace process find out which
    physical frame each virtual page is mapped to.  It contains one 64-bit
@@ -76,9 +76,6 @@ There are five components to pagemap:
    memory cgroup each page is charged to, indexed by PFN. Only available when
    CONFIG_MEMCG is set.
 
- * /proc/kpageidle.  This file comprises API of the idle page tracking feature.
-   See Documentation/vm/idle_page_tracking.txt for more details.
-
 Short descriptions to the page flags:
 
  0. LOCKED
@@ -125,9 +122,10 @@ Short descriptions to the page flags:
     zero page for pfn_zero or huge_zero page
 
 25. IDLE
-    page has not been accessed since it was marked idle (see /proc/kpageidle)
-    Note that this flag may be stale in case the page was accessed via a PTE.
-    To make sure the flag is up-to-date one has to read /proc/kpageidle first.
+    page has not been accessed since it was marked idle (see
+    Documentation/vm/idle_page_tracking.txt). Note that this flag may be
+    stale in case the page was accessed via a PTE. To make sure the flag
+    is up-to-date one has to read /sys/kernel/mm/page_idle/bitmap first.
 
     [IO related page flags]
  1. ERROR     IO error occurred
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 4191ddb79b84..72c604b876e4 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -5,20 +5,18 @@
 #include <linux/ksm.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
-#include <linux/rmap.h>
-#include <linux/mmu_notifier.h>
 #include <linux/huge_mm.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
 #include <linux/memcontrol.h>
+#include <linux/page_idle.h>
 #include <linux/kernel-page-flags.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
 #define KPMSIZE sizeof(u64)
 #define KPMMASK (KPMSIZE - 1)
-#define KPMBITS (KPMSIZE * BITS_PER_BYTE)
 
 /* /proc/kpagecount - an array exposing page counts
  *
@@ -287,223 +285,6 @@ static const struct file_operations proc_kpagecgroup_operations = {
 };
 #endif /* CONFIG_MEMCG */
 
-#ifdef CONFIG_IDLE_PAGE_TRACKING
-/*
- * Idle page tracking only considers user memory pages, for other types of
- * pages the idle flag is always unset and an attempt to set it is silently
- * ignored.
- *
- * We treat a page as a user memory page if it is on an LRU list, because it is
- * always safe to pass such a page to rmap_walk(), which is essential for idle
- * page tracking. With such an indicator of user pages we can skip isolated
- * pages, but since there are not usually many of them, it will hardly affect
- * the overall result.
- *
- * This function tries to get a user memory page by pfn as described above.
- */
-static struct page *kpageidle_get_page(unsigned long pfn)
-{
-	struct page *page;
-	struct zone *zone;
-
-	if (!pfn_valid(pfn))
-		return NULL;
-
-	page = pfn_to_page(pfn);
-	if (!page || !PageLRU(page) ||
-	    !get_page_unless_zero(page))
-		return NULL;
-
-	zone = page_zone(page);
-	spin_lock_irq(&zone->lru_lock);
-	if (unlikely(!PageLRU(page))) {
-		put_page(page);
-		page = NULL;
-	}
-	spin_unlock_irq(&zone->lru_lock);
-	return page;
-}
-
-static int kpageidle_clear_pte_refs_one(struct page *page,
-					struct vm_area_struct *vma,
-					unsigned long addr, void *arg)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	pmd_t *pmd;
-	pte_t *pte;
-	bool referenced = false;
-
-	if (unlikely(PageTransHuge(page))) {
-		pmd = page_check_address_pmd(page, mm, addr,
-					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
-		if (pmd) {
-			referenced = pmdp_clear_young_notify(vma, addr, pmd);
-			spin_unlock(ptl);
-		}
-	} else {
-		pte = page_check_address(page, mm, addr, &ptl, 0);
-		if (pte) {
-			referenced = ptep_clear_young_notify(vma, addr, pte);
-			pte_unmap_unlock(pte, ptl);
-		}
-	}
-	if (referenced) {
-		clear_page_idle(page);
-		/*
-		 * We cleared the referenced bit in a mapping to this page. To
-		 * avoid interference with page reclaim, mark it young so that
-		 * page_referenced() will return > 0.
-		 */
-		set_page_young(page);
-	}
-	return SWAP_AGAIN;
-}
-
-static void kpageidle_clear_pte_refs(struct page *page)
-{
-	/*
-	 * Since rwc.arg is unused, rwc is effectively immutable, so we
-	 * can make it static const to save some cycles and stack.
-	 */
-	static const struct rmap_walk_control rwc = {
-		.rmap_one = kpageidle_clear_pte_refs_one,
-		.anon_lock = page_lock_anon_vma_read,
-	};
-	bool need_lock;
-
-	if (!page_mapped(page) ||
-	    !page_rmapping(page))
-		return;
-
-	need_lock = !PageAnon(page) || PageKsm(page);
-	if (need_lock && !trylock_page(page))
-		return;
-
-	rmap_walk(page, (struct rmap_walk_control *)&rwc);
-
-	if (need_lock)
-		unlock_page(page);
-}
-
-static ssize_t kpageidle_read(struct file *file, char __user *buf,
-			      size_t count, loff_t *ppos)
-{
-	u64 __user *out = (u64 __user *)buf;
-	struct page *page;
-	unsigned long pfn, end_pfn;
-	ssize_t ret = 0;
-	u64 idle_bitmap = 0;
-	int bit;
-
-	if (*ppos & KPMMASK || count & KPMMASK)
-		return -EINVAL;
-
-	pfn = *ppos * BITS_PER_BYTE;
-	if (pfn >= max_pfn)
-		return 0;
-
-	end_pfn = pfn + count * BITS_PER_BYTE;
-	if (end_pfn > max_pfn)
-		end_pfn = ALIGN(max_pfn, KPMBITS);
-
-	for (; pfn < end_pfn; pfn++) {
-		bit = pfn % KPMBITS;
-		page = kpageidle_get_page(pfn);
-		if (page) {
-			if (page_is_idle(page)) {
-				/*
-				 * The page might have been referenced via a
-				 * pte, in which case it is not idle. Clear
-				 * refs and recheck.
-				 */
-				kpageidle_clear_pte_refs(page);
-				if (page_is_idle(page))
-					idle_bitmap |= 1ULL << bit;
-			}
-			put_page(page);
-		}
-		if (bit == KPMBITS - 1) {
-			if (put_user(idle_bitmap, out)) {
-				ret = -EFAULT;
-				break;
-			}
-			idle_bitmap = 0;
-			out++;
-		}
-		cond_resched();
-	}
-
-	*ppos += (char __user *)out - buf;
-	if (!ret)
-		ret = (char __user *)out - buf;
-	return ret;
-}
-
-static ssize_t kpageidle_write(struct file *file, const char __user *buf,
-			       size_t count, loff_t *ppos)
-{
-	const u64 __user *in = (const u64 __user *)buf;
-	struct page *page;
-	unsigned long pfn, end_pfn;
-	ssize_t ret = 0;
-	u64 idle_bitmap = 0;
-	int bit;
-
-	if (*ppos & KPMMASK || count & KPMMASK)
-		return -EINVAL;
-
-	pfn = *ppos * BITS_PER_BYTE;
-	if (pfn >= max_pfn)
-		return -ENXIO;
-
-	end_pfn = pfn + count * BITS_PER_BYTE;
-	if (end_pfn > max_pfn)
-		end_pfn = ALIGN(max_pfn, KPMBITS);
-
-	for (; pfn < end_pfn; pfn++) {
-		bit = pfn % KPMBITS;
-		if (bit == 0) {
-			if (copy_from_user(&idle_bitmap, in, sizeof(u64))) {
-				ret = -EFAULT;
-				break;
-			}
-			in++;
-		}
-		if ((idle_bitmap >> bit) & 1) {
-			page = kpageidle_get_page(pfn);
-			if (page) {
-				kpageidle_clear_pte_refs(page);
-				set_page_idle(page);
-				put_page(page);
-			}
-		}
-		cond_resched();
-	}
-
-	*ppos += (const char __user *)in - buf;
-	if (!ret)
-		ret = (const char __user *)in - buf;
-	return ret;
-}
-
-static const struct file_operations proc_kpageidle_operations = {
-	.llseek = mem_lseek,
-	.read = kpageidle_read,
-	.write = kpageidle_write,
-};
-
-#ifndef CONFIG_64BIT
-static bool need_page_idle(void)
-{
-	return true;
-}
-struct page_ext_operations page_idle_ops = {
-	.need = need_page_idle,
-};
-#endif
-#endif /* CONFIG_IDLE_PAGE_TRACKING */
-
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
@@ -511,10 +292,6 @@ static int __init proc_page_init(void)
 #ifdef CONFIG_MEMCG
 	proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
 #endif
-#ifdef CONFIG_IDLE_PAGE_TRACKING
-	proc_create("kpageidle", S_IRUSR | S_IWUSR, NULL,
-		    &proc_kpageidle_operations);
-#endif
 	return 0;
 }
 fs_initcall(proc_page_init);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7c9a17414106..bdd7e48a85f0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -13,6 +13,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/page_idle.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5e08787c92df..363ea2cda35f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2199,103 +2199,5 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
-#ifdef CONFIG_IDLE_PAGE_TRACKING
-#ifdef CONFIG_64BIT
-static inline bool page_is_young(struct page *page)
-{
-	return PageYoung(page);
-}
-
-static inline void set_page_young(struct page *page)
-{
-	SetPageYoung(page);
-}
-
-static inline bool test_and_clear_page_young(struct page *page)
-{
-	return TestClearPageYoung(page);
-}
-
-static inline bool page_is_idle(struct page *page)
-{
-	return PageIdle(page);
-}
-
-static inline void set_page_idle(struct page *page)
-{
-	SetPageIdle(page);
-}
-
-static inline void clear_page_idle(struct page *page)
-{
-	ClearPageIdle(page);
-}
-#else /* !CONFIG_64BIT */
-/*
- * If there is not enough space to store Idle and Young bits in page flags, use
- * page ext flags instead.
- */
-extern struct page_ext_operations page_idle_ops;
-
-static inline bool page_is_young(struct page *page)
-{
-	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
-}
-
-static inline void set_page_young(struct page *page)
-{
-	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
-}
-
-static inline bool test_and_clear_page_young(struct page *page)
-{
-	return test_and_clear_bit(PAGE_EXT_YOUNG,
-				  &lookup_page_ext(page)->flags);
-}
-
-static inline bool page_is_idle(struct page *page)
-{
-	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
-}
-
-static inline void set_page_idle(struct page *page)
-{
-	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
-}
-
-static inline void clear_page_idle(struct page *page)
-{
-	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
-}
-#endif /* CONFIG_64BIT */
-#else /* !CONFIG_IDLE_PAGE_TRACKING */
-static inline bool page_is_young(struct page *page)
-{
-	return false;
-}
-
-static inline void set_page_young(struct page *page)
-{
-}
-
-static inline bool test_and_clear_page_young(struct page *page)
-{
-	return false;
-}
-
-static inline bool page_is_idle(struct page *page)
-{
-	return false;
-}
-
-static inline void set_page_idle(struct page *page)
-{
-}
-
-static inline void clear_page_idle(struct page *page)
-{
-}
-#endif /* CONFIG_IDLE_PAGE_TRACKING */
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
new file mode 100644
index 000000000000..bf268fa92c5b
--- /dev/null
+++ b/include/linux/page_idle.h
@@ -0,0 +1,110 @@
+#ifndef _LINUX_MM_PAGE_IDLE_H
+#define _LINUX_MM_PAGE_IDLE_H
+
+#include <linux/bitops.h>
+#include <linux/page-flags.h>
+#include <linux/page_ext.h>
+
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+
+#ifdef CONFIG_64BIT
+static inline bool page_is_young(struct page *page)
+{
+	return PageYoung(page);
+}
+
+static inline void set_page_young(struct page *page)
+{
+	SetPageYoung(page);
+}
+
+static inline bool test_and_clear_page_young(struct page *page)
+{
+	return TestClearPageYoung(page);
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return PageIdle(page);
+}
+
+static inline void set_page_idle(struct page *page)
+{
+	SetPageIdle(page);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	ClearPageIdle(page);
+}
+#else /* !CONFIG_64BIT */
+/*
+ * If there is not enough space to store Idle and Young bits in page flags, use
+ * page ext flags instead.
+ */
+extern struct page_ext_operations page_idle_ops;
+
+static inline bool page_is_young(struct page *page)
+{
+	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+}
+
+static inline void set_page_young(struct page *page)
+{
+	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+}
+
+static inline bool test_and_clear_page_young(struct page *page)
+{
+	return test_and_clear_bit(PAGE_EXT_YOUNG,
+				  &lookup_page_ext(page)->flags);
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+
+static inline void set_page_idle(struct page *page)
+{
+	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+#endif /* CONFIG_64BIT */
+
+#else /* !CONFIG_IDLE_PAGE_TRACKING */
+
+static inline bool page_is_young(struct page *page)
+{
+	return false;
+}
+
+static inline void set_page_young(struct page *page)
+{
+}
+
+static inline bool test_and_clear_page_young(struct page *page)
+{
+	return false;
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return false;
+}
+
+static inline void set_page_idle(struct page *page)
+{
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+}
+
+#endif /* CONFIG_IDLE_PAGE_TRACKING */
+
+#endif /* _LINUX_MM_PAGE_IDLE_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 7482b60e927f..fe133a98a9ef 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -651,8 +651,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
-	depends on PROC_FS && MMU
-	select PROC_PAGE_MONITOR
+	depends on SYSFS
 	select PAGE_EXTENSION if !64BIT
 	help
 	  This feature allows to estimate the amount of user pages that have
diff --git a/mm/Makefile b/mm/Makefile
index b424d5e5b6ff..56f8eed73f1a 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -79,3 +79,4 @@ obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
 obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
 obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
+obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index aa58a326d238..1ce276ac4e0c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -25,6 +25,7 @@
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/page_idle.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
diff --git a/mm/migrate.c b/mm/migrate.c
index d86cec005aa6..1f887f594cc6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -37,6 +37,7 @@
 #include <linux/gfp.h>
 #include <linux/balloon_compaction.h>
 #include <linux/mmu_notifier.h>
+#include <linux/page_idle.h>
 
 #include <asm/tlbflush.h>
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index e4b3af054bf2..292ca7b8debd 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -6,6 +6,7 @@
 #include <linux/vmalloc.h>
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
+#include <linux/page_idle.h>
 
 /*
  * struct page extension
diff --git a/mm/page_idle.c b/mm/page_idle.c
new file mode 100644
index 000000000000..d5dd79041484
--- /dev/null
+++ b/mm/page_idle.c
@@ -0,0 +1,232 @@
+#include <linux/init.h>
+#include <linux/bootmem.h>
+#include <linux/fs.h>
+#include <linux/sysfs.h>
+#include <linux/kobject.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
+#include <linux/page_ext.h>
+#include <linux/page_idle.h>
+
+#define BITMAP_CHUNK_SIZE	sizeof(u64)
+#define BITMAP_CHUNK_BITS	(BITMAP_CHUNK_SIZE * BITS_PER_BYTE)
+
+/*
+ * Idle page tracking only considers user memory pages, for other types of
+ * pages the idle flag is always unset and an attempt to set it is silently
+ * ignored.
+ *
+ * We treat a page as a user memory page if it is on an LRU list, because it is
+ * always safe to pass such a page to rmap_walk(), which is essential for idle
+ * page tracking. With such an indicator of user pages we can skip isolated
+ * pages, but since there are not usually many of them, it will hardly affect
+ * the overall result.
+ *
+ * This function tries to get a user memory page by pfn as described above.
+ */
+static struct page *page_idle_get_page(unsigned long pfn)
+{
+	struct page *page;
+	struct zone *zone;
+
+	if (!pfn_valid(pfn))
+		return NULL;
+
+	page = pfn_to_page(pfn);
+	if (!page || !PageLRU(page) ||
+	    !get_page_unless_zero(page))
+		return NULL;
+
+	zone = page_zone(page);
+	spin_lock_irq(&zone->lru_lock);
+	if (unlikely(!PageLRU(page))) {
+		put_page(page);
+		page = NULL;
+	}
+	spin_unlock_irq(&zone->lru_lock);
+	return page;
+}
+
+static int page_idle_clear_pte_refs_one(struct page *page,
+					struct vm_area_struct *vma,
+					unsigned long addr, void *arg)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
+	pmd_t *pmd;
+	pte_t *pte;
+	bool referenced = false;
+
+	if (unlikely(PageTransHuge(page))) {
+		pmd = page_check_address_pmd(page, mm, addr,
+					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		if (pmd) {
+			referenced = pmdp_clear_young_notify(vma, addr, pmd);
+			spin_unlock(ptl);
+		}
+	} else {
+		pte = page_check_address(page, mm, addr, &ptl, 0);
+		if (pte) {
+			referenced = ptep_clear_young_notify(vma, addr, pte);
+			pte_unmap_unlock(pte, ptl);
+		}
+	}
+	if (referenced) {
+		clear_page_idle(page);
+		/*
+		 * We cleared the referenced bit in a mapping to this page. To
+		 * avoid interference with page reclaim, mark it young so that
+		 * page_referenced() will return > 0.
+		 */
+		set_page_young(page);
+	}
+	return SWAP_AGAIN;
+}
+
+static void page_idle_clear_pte_refs(struct page *page)
+{
+	/*
+	 * Since rwc.arg is unused, rwc is effectively immutable, so we
+	 * can make it static const to save some cycles and stack.
+	 */
+	static const struct rmap_walk_control rwc = {
+		.rmap_one = page_idle_clear_pte_refs_one,
+		.anon_lock = page_lock_anon_vma_read,
+	};
+	bool need_lock;
+
+	if (!page_mapped(page) ||
+	    !page_rmapping(page))
+		return;
+
+	need_lock = !PageAnon(page) || PageKsm(page);
+	if (need_lock && !trylock_page(page))
+		return;
+
+	rmap_walk(page, (struct rmap_walk_control *)&rwc);
+
+	if (need_lock)
+		unlock_page(page);
+}
+
+static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
+				     struct bin_attribute *attr, char *buf,
+				     loff_t pos, size_t count)
+{
+	u64 *out = (u64 *)buf;
+	struct page *page;
+	unsigned long pfn, end_pfn;
+	int bit;
+
+	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
+		return -EINVAL;
+
+	pfn = pos * BITS_PER_BYTE;
+	if (pfn >= max_pfn)
+		return 0;
+
+	end_pfn = pfn + count * BITS_PER_BYTE;
+	if (end_pfn > max_pfn)
+		end_pfn = ALIGN(max_pfn, BITMAP_CHUNK_BITS);
+
+	for (; pfn < end_pfn; pfn++) {
+		bit = pfn % BITMAP_CHUNK_BITS;
+		if (!bit)
+			*out = 0ULL;
+		page = page_idle_get_page(pfn);
+		if (page) {
+			if (page_is_idle(page)) {
+				/*
+				 * The page might have been referenced via a
+				 * pte, in which case it is not idle. Clear
+				 * refs and recheck.
+				 */
+				page_idle_clear_pte_refs(page);
+				if (page_is_idle(page))
+					*out |= 1ULL << bit;
+			}
+			put_page(page);
+		}
+		if (bit == BITMAP_CHUNK_BITS - 1)
+			out++;
+		cond_resched();
+	}
+	return (char *)out - buf;
+}
+
+static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
+				      struct bin_attribute *attr, char *buf,
+				      loff_t pos, size_t count)
+{
+	const u64 *in = (u64 *)buf;
+	struct page *page;
+	unsigned long pfn, end_pfn;
+	int bit;
+
+	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
+		return -EINVAL;
+
+	pfn = pos * BITS_PER_BYTE;
+	if (pfn >= max_pfn)
+		return -ENXIO;
+
+	end_pfn = pfn + count * BITS_PER_BYTE;
+	if (end_pfn > max_pfn)
+		end_pfn = ALIGN(max_pfn, BITMAP_CHUNK_BITS);
+
+	for (; pfn < end_pfn; pfn++) {
+		bit = pfn % BITMAP_CHUNK_BITS;
+		if ((*in >> bit) & 1) {
+			page = page_idle_get_page(pfn);
+			if (page) {
+				page_idle_clear_pte_refs(page);
+				set_page_idle(page);
+				put_page(page);
+			}
+		}
+		if (bit == BITMAP_CHUNK_BITS - 1)
+			in++;
+		cond_resched();
+	}
+	return (char *)in - buf;
+}
+
+static struct bin_attribute page_idle_bitmap_attr =
+		__BIN_ATTR(bitmap, S_IRUSR | S_IWUSR,
+			   page_idle_bitmap_read, page_idle_bitmap_write, 0);
+
+static struct bin_attribute *page_idle_bin_attrs[] = {
+	&page_idle_bitmap_attr,
+	NULL,
+};
+
+static struct attribute_group page_idle_attr_group = {
+	.bin_attrs = page_idle_bin_attrs,
+	.name = "page_idle",
+};
+
+#ifndef CONFIG_64BIT
+static bool need_page_idle(void)
+{
+	return true;
+}
+struct page_ext_operations page_idle_ops = {
+	.need = need_page_idle,
+};
+#endif
+
+static int __init page_idle_init(void)
+{
+	int err;
+
+	err = sysfs_create_group(mm_kobj, &page_idle_attr_group);
+	if (err) {
+		pr_err("page_idle: register sysfs failed\n");
+		return err;
+	}
+	return 0;
+}
+subsys_initcall(page_idle_init);
diff --git a/mm/rmap.c b/mm/rmap.c
index b6db6a676f6f..dcaad464aab0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -59,6 +59,7 @@
 #include <linux/migrate.h>
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
+#include <linux/page_idle.h>
 
 #include <asm/tlbflush.h>
 
diff --git a/mm/swap.c b/mm/swap.c
index db43c9b4891d..4a6aec976ab1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -32,6 +32,7 @@
 #include <linux/gfp.h>
 #include <linux/uio.h>
 #include <linux/hugetlb.h>
+#include <linux/page_idle.h>
 
 #include "internal.h"
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

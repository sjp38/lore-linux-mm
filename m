Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B14706B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:17:38 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t18-v6so834354plo.16
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 06:17:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h1-v6si1171914pgc.459.2018.10.12.06.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Oct 2018 06:17:37 -0700 (PDT)
Date: Fri, 12 Oct 2018 06:17:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 07/27] mm/mmap: Create a guard area between VMAs
Message-ID: <20181012131728.GA28309@bombadil.infradead.org>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-8-yu-cheng.yu@intel.com>
 <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: yu-cheng.yu@intel.com, Andy Lutomirski <luto@amacapital.net>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, rdunlap@infradead.org, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com, Daniel Micay <danielmicay@gmail.com>

On Thu, Oct 11, 2018 at 10:39:24PM +0200, Jann Horn wrote:
> Sorry to bring this up so late, but Daniel Micay pointed out to me
> that, given that VMA guards will raise the number of VMAs by
> inhibiting vma_merge(), people are more likely to run into
> /proc/sys/vm/max_map_count (which limits the number of VMAs to ~65k by
> default, and can't easily be raised without risking an overflow of
> page->_mapcount on systems with over ~800GiB of RAM, see
> https://lore.kernel.org/lkml/20180208021112.GB14918@bombadil.infradead.org/
> and replies) with this change.
> 
[...]
> 
> Arguably the proper solution to this would be to raise the default
> max_map_count to be much higher; but then that requires fixing the
> mapcount overflow.

I have a fix that nobody has any particular reaction to:

diff --git a/mm/internal.h b/mm/internal.h
index 7059a8389194..977852b8329e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -97,6 +97,11 @@ extern void putback_lru_page(struct page *page);
  */
 extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
 
+#ifdef CONFIG_64BIT
+extern void mm_mapcount_overflow(struct page *page);
+#else
+static inline void mm_mapcount_overflow(struct page *page) { }
+#endif
 /*
  * in mm/page_alloc.c
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021ad22..575766ec02f8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1315,6 +1315,115 @@ static inline int mlock_future_check(struct mm_struct *mm,
 	return 0;
 }
 
+#ifdef CONFIG_64BIT
+/*
+ * Machines with more than 2TB of memory can create enough VMAs to overflow
+ * page->_mapcount if they all point to the same page.  32-bit machines do
+ * not need to be concerned.
+ */
+/*
+ * Experimentally determined.  gnome-shell currently uses fewer than
+ * 3000 mappings, so should have zero effect on desktop users.
+ */
+#define mm_track_threshold	5000
+static DEFINE_SPINLOCK(heavy_users_lock);
+static DEFINE_IDR(heavy_users);
+
+static void mmap_track_user(struct mm_struct *mm, int max)
+{
+	struct mm_struct *entry;
+	unsigned int id;
+
+	idr_preload(GFP_KERNEL);
+	spin_lock(&heavy_users_lock);
+	idr_for_each_entry(&heavy_users, entry, id) {
+		if (entry == mm)
+			break;
+		if (entry->map_count < mm_track_threshold)
+			idr_remove(&heavy_users, id);
+	}
+	if (!entry)
+		idr_alloc(&heavy_users, mm, 0, 0, GFP_ATOMIC);
+	spin_unlock(&heavy_users_lock);
+}
+
+static void mmap_untrack_user(struct mm_struct *mm)
+{
+	struct mm_struct *entry;
+	unsigned int id;
+
+	spin_lock(&heavy_users_lock);
+	idr_for_each_entry(&heavy_users, entry, id) {
+		if (entry == mm) {
+			idr_remove(&heavy_users, id);
+			break;
+		}
+	}
+	spin_unlock(&heavy_users_lock);
+}
+
+static void kill_mm(struct task_struct *tsk)
+{
+	/* Tear down the mappings first */
+	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, tsk, true);
+}
+
+static void kill_abuser(struct mm_struct *mm)
+{
+	struct task_struct *tsk;
+
+	for_each_process(tsk)
+		if (tsk->mm == mm)
+			break;
+
+	if (down_write_trylock(&mm->mmap_sem)) {
+		kill_mm(tsk);
+		up_write(&mm->mmap_sem);
+	} else {
+		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, tsk, true);
+	}
+}
+
+void mm_mapcount_overflow(struct page *page)
+{
+	struct mm_struct *entry = current->mm;
+	unsigned int id;
+	struct vm_area_struct *vma;
+	struct address_space *mapping = page_mapping(page);
+	unsigned long pgoff = page_to_pgoff(page);
+	unsigned int count = 0;
+
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff + 1) {
+		if (vma->vm_mm == entry)
+			count++;
+		if (count > 1000)
+			kill_mm(current);
+	}
+
+	rcu_read_lock();
+	idr_for_each_entry(&heavy_users, entry, id) {
+		count = 0;
+
+		vma_interval_tree_foreach(vma, &mapping->i_mmap,
+				pgoff, pgoff + 1) {
+			if (vma->vm_mm == entry)
+				count++;
+			if (count > 1000) {
+				kill_abuser(entry);
+				goto out;
+			}
+		}
+	}
+	if (!entry)
+		panic("No abusers found but mapcount exceeded\n");
+out:
+	rcu_read_unlock();
+}
+#else
+static void mmap_track_user(struct mm_struct *mm, int max) { }
+static void mmap_untrack_user(struct mm_struct *mm) { }
+#endif
+
 /*
  * The caller must hold down_write(&current->mm->mmap_sem).
  */
@@ -1357,6 +1466,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	/* Too many mappings? */
 	if (mm->map_count > sysctl_max_map_count)
 		return -ENOMEM;
+	if (mm->map_count > mm_track_threshold)
+		mmap_track_user(mm, mm_track_threshold);
 
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
@@ -2997,6 +3108,8 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
 
+	mmap_untrack_user(mm);
+
 	if (mm->locked_vm) {
 		vma = mm->mmap;
 		while (vma) {
diff --git a/mm/rmap.c b/mm/rmap.c
index 47db27f8049e..d88acf5c98e9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1190,6 +1190,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 		__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
+		int v;
 		if (PageTransCompound(page) && page_mapping(page)) {
 			VM_WARN_ON_ONCE(!PageLocked(page));
 
@@ -1197,8 +1198,13 @@ void page_add_file_rmap(struct page *page, bool compound)
 			if (PageMlocked(page))
 				clear_page_mlock(compound_head(page));
 		}
-		if (!atomic_inc_and_test(&page->_mapcount))
+		v = atomic_inc_return(&page->_mapcount);
+		if (likely(v > 0))
 			goto out;
+		if (unlikely(v < 0)) {
+			mm_mapcount_overflow(page);
+			goto out;
+		}
 	}
 	__mod_lruvec_page_state(page, NR_FILE_MAPPED, nr);
 out:

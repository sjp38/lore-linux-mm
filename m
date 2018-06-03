Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB4F06B0270
	for <linux-mm@kvack.org>; Sun,  3 Jun 2018 01:33:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k193-v6so253177pge.3
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 22:33:29 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id v66-v6si43365226pfv.48.2018.06.02.22.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jun 2018 22:33:28 -0700 (PDT)
Subject: [PATCH v2 09/11] mm,
 memory_failure: Fix page->mapping assumptions relative to the page
 lock
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 02 Jun 2018 22:23:31 -0700
Message-ID: <152800341110.17112.2806198295112832622.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

The current memory_failure() implementation assumes that lock_page() is
sufficient for stabilizing page->mapping and that ->mapping->host will
not be freed. The dax implementation, on the other hand, relies on
xa_lock_irq() for stabilizing the page->mapping relationship and it is
not possible to hold the lock over current routines in the
memory_failure() path that run under lock_page().

Teach the various memory_failure() helpers to pin the address_space and
revalidate page->mapping under xa_lock_irq(mapping->i_pages).

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory-failure.c |   56 +++++++++++++++++++++++++++++++++++----------------
 1 file changed, 38 insertions(+), 18 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 42a193ee14d3..b6efb78ba49b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -179,12 +179,20 @@ EXPORT_SYMBOL_GPL(hwpoison_filter);
  * ``action required'' if error happened in current execution context
  */
 static int kill_proc(struct task_struct *t, unsigned long addr,
-			unsigned long pfn, unsigned size_shift, int flags)
+		struct address_space *mapping, struct page *page,
+		unsigned size_shift, int flags)
 {
-	int ret;
+	int ret = 0;
+
+	/* revalidate the page before killing the process */
+	xa_lock_irq(&mapping->i_pages);
+	if (page->mapping != mapping) {
+		xa_unlock_irq(&mapping->i_pages);
+		return 0;
+	}
 
 	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corruption\n",
-		pfn, t->comm, t->pid);
+			page_to_pfn(page), t->comm, t->pid);
 
 	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
 		ret = force_sig_mceerr(BUS_MCEERR_AR, (void __user *)addr,
@@ -199,6 +207,7 @@ static int kill_proc(struct task_struct *t, unsigned long addr,
 		ret = send_sig_mceerr(BUS_MCEERR_AO, (void __user *)addr,
 				      size_shift, t);  /* synchronous? */
 	}
+	xa_unlock_irq(&mapping->i_pages);
 	if (ret < 0)
 		pr_info("Memory failure: Error sending signal to %s:%d: %d\n",
 			t->comm, t->pid, ret);
@@ -316,8 +325,8 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
  * wrong earlier.
  */
 static void kill_procs(struct list_head *to_kill, int forcekill,
-			  bool fail, unsigned size_shift, unsigned long pfn,
-			  int flags)
+		bool fail, unsigned size_shift, struct address_space *mapping,
+		struct page *page, int flags)
 {
 	struct to_kill *tk, *next;
 
@@ -330,7 +339,8 @@ static void kill_procs(struct list_head *to_kill, int forcekill,
 			 */
 			if (fail || tk->addr_valid == 0) {
 				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
-				       pfn, tk->tsk->comm, tk->tsk->pid);
+						page_to_pfn(page), tk->tsk->comm,
+						tk->tsk->pid);
 				force_sig(SIGKILL, tk->tsk);
 			}
 
@@ -341,9 +351,10 @@ static void kill_procs(struct list_head *to_kill, int forcekill,
 			 * process anyways.
 			 */
 			else if (kill_proc(tk->tsk, tk->addr,
-					      pfn, size_shift, flags) < 0)
+					      mapping, page, size_shift, flags) < 0)
 				pr_err("Memory failure: %#lx: Cannot send advisory machine check signal to %s:%d\n",
-				       pfn, tk->tsk->comm, tk->tsk->pid);
+						page_to_pfn(page), tk->tsk->comm,
+						tk->tsk->pid);
 		}
 		put_task_struct(tk->tsk);
 		kfree(tk);
@@ -429,21 +440,27 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 /*
  * Collect processes when the error hit a file mapped page.
  */
-static void collect_procs_file(struct page *page, struct list_head *to_kill,
-			      struct to_kill **tkc, int force_early)
+static void collect_procs_file(struct address_space *mapping, struct page *page,
+		struct list_head *to_kill, struct to_kill **tkc,
+		int force_early)
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
-	struct address_space *mapping = page->mapping;
 
 	i_mmap_lock_read(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
-		pgoff_t pgoff = page_to_pgoff(page);
+		pgoff_t pgoff;
 		struct task_struct *t = task_early_kill(tsk, force_early);
 
 		if (!t)
 			continue;
+		xa_lock_irq(&mapping->i_pages);
+		if (page->mapping != mapping) {
+			xa_unlock_irq(&mapping->i_pages);
+			break;
+		}
+		pgoff = page_to_pgoff(page);
 		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff,
 				      pgoff) {
 			/*
@@ -456,6 +473,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 			if (vma->vm_mm == t->mm)
 				add_to_kill(t, page, vma, to_kill, tkc);
 		}
+		xa_unlock_irq(&mapping->i_pages);
 	}
 	read_unlock(&tasklist_lock);
 	i_mmap_unlock_read(mapping);
@@ -467,12 +485,12 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
  * First preallocate one tokill structure outside the spin locks,
  * so that we can kill at least one process reasonably reliable.
  */
-static void collect_procs(struct page *page, struct list_head *tokill,
-				int force_early)
+static void collect_procs(struct address_space *mapping, struct page *page,
+		struct list_head *tokill, int force_early)
 {
 	struct to_kill *tk;
 
-	if (!page->mapping)
+	if (!mapping)
 		return;
 
 	tk = kmalloc(sizeof(struct to_kill), GFP_NOIO);
@@ -481,7 +499,7 @@ static void collect_procs(struct page *page, struct list_head *tokill,
 	if (PageAnon(page))
 		collect_procs_anon(page, tokill, &tk, force_early);
 	else
-		collect_procs_file(page, tokill, &tk, force_early);
+		collect_procs_file(mapping, page, tokill, &tk, force_early);
 	kfree(tk);
 }
 
@@ -986,7 +1004,8 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	 * there's nothing that can be done.
 	 */
 	if (kill)
-		collect_procs(hpage, &tokill, flags & MF_ACTION_REQUIRED);
+		collect_procs(mapping, hpage, &tokill,
+				flags & MF_ACTION_REQUIRED);
 
 	unmap_success = try_to_unmap(hpage, ttu);
 	if (!unmap_success)
@@ -1012,7 +1031,8 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	 */
 	forcekill = PageDirty(hpage) || (flags & MF_MUST_KILL);
 	size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
-	kill_procs(&tokill, forcekill, !unmap_success, size_shift, pfn, flags);
+	kill_procs(&tokill, forcekill, !unmap_success, size_shift, mapping,
+			hpage, flags);
 
 	return unmap_success;
 }

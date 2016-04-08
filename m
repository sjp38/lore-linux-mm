Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id C28B16B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 09:41:29 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id f1so13302562igr.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 06:41:29 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id i141si4916607ioe.71.2016.04.08.06.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 06:41:28 -0700 (PDT)
Received: by mail-io0-x231.google.com with SMTP id 2so131990410ioy.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 06:41:28 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] memory failure: replace 'MCE' with 'Memory failure'
Date: Fri,  8 Apr 2016 21:41:15 +0800
Message-Id: <1460122875-4635-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

HWPoison was specific to some particular x86 platforms.
And it is often seen as high level machine check handler.
And therefore, 'MCE' is used for the format prefix of
printk(). However, 'PowerNV' has also used HWPoison for
handling memory errors[1], so 'MCE' is no longer suitable
to memory_failure.c.

Additionally, 'MCE' and 'Memory failure' have different
context. The former belongs to exception context and the
latter belongs to process context. Furthermore, HWPoison
can also be used for off-lining those sub-health pages
that do not trigger any machine check exception.

This patch aims to replace 'MCE' with a more appropriate prefix.

[1] commit 75eb3d9b60c2 ("powerpc/powernv: Get FSP memory errors
and plumb into memory poison infrastructure.")

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/memory-failure.c |   69 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 38 insertions(+), 31 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 78f5f26..e9752f4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -184,8 +184,8 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
 	struct siginfo si;
 	int ret;
 
-	pr_err("MCE %#lx: Killing %s:%d due to hardware memory corruption\n",
-	       pfn, t->comm, t->pid);
+	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corruption\n",
+		pfn, t->comm, t->pid);
 	si.si_signo = SIGBUS;
 	si.si_errno = 0;
 	si.si_addr = (void *)addr;
@@ -208,7 +208,7 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
 		ret = send_sig_info(SIGBUS, &si, t);  /* synchronous? */
 	}
 	if (ret < 0)
-		pr_info("MCE: Error sending signal to %s:%d: %d\n",
+		pr_info("Memory failure: Error sending signal to %s:%d: %d\n",
 			t->comm, t->pid, ret);
 	return ret;
 }
@@ -289,7 +289,7 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 	} else {
 		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
 		if (!tk) {
-			pr_err("MCE: Out of memory while machine check handling\n");
+			pr_err("Memory failure: Out of memory while machine check handling\n");
 			return;
 		}
 	}
@@ -303,7 +303,7 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 	 * a SIGKILL because the error is not contained anymore.
 	 */
 	if (tk->addr == -EFAULT) {
-		pr_info("MCE: Unable to find user space address %lx in %s\n",
+		pr_info("Memory failure: Unable to find user space address %lx in %s\n",
 			page_to_pfn(p), tsk->comm);
 		tk->addr_valid = 0;
 	}
@@ -334,7 +334,7 @@ static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
 			 * signal and then access the memory. Just kill it.
 			 */
 			if (fail || tk->addr_valid == 0) {
-				pr_err("MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
+				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
 				       pfn, tk->tsk->comm, tk->tsk->pid);
 				force_sig(SIGKILL, tk->tsk);
 			}
@@ -347,7 +347,7 @@ static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
 			 */
 			else if (kill_proc(tk->tsk, tk->addr, trapno,
 					      pfn, page, flags) < 0)
-				pr_err("MCE %#lx: Cannot send advisory machine check signal to %s:%d\n",
+				pr_err("Memory failure: %#lx: Cannot send advisory machine check signal to %s:%d\n",
 				       pfn, tk->tsk->comm, tk->tsk->pid);
 		}
 		put_task_struct(tk->tsk);
@@ -559,7 +559,7 @@ static int me_kernel(struct page *p, unsigned long pfn)
  */
 static int me_unknown(struct page *p, unsigned long pfn)
 {
-	pr_err("MCE %#lx: Unknown page state\n", pfn);
+	pr_err("Memory failure: %#lx: Unknown page state\n", pfn);
 	return MF_FAILED;
 }
 
@@ -604,11 +604,12 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 	if (mapping->a_ops->error_remove_page) {
 		err = mapping->a_ops->error_remove_page(mapping, p);
 		if (err != 0) {
-			pr_info("MCE %#lx: Failed to punch page: %d\n",
+			pr_info("Memory failure: %#lx: Failed to punch page: %d\n",
 				pfn, err);
 		} else if (page_has_private(p) &&
 				!try_to_release_page(p, GFP_NOIO)) {
-			pr_info("MCE %#lx: failed to release buffers\n", pfn);
+			pr_info("Memory failure: %#lx: failed to release buffers\n",
+				pfn);
 		} else {
 			ret = MF_RECOVERED;
 		}
@@ -620,7 +621,8 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 		if (invalidate_inode_page(p))
 			ret = MF_RECOVERED;
 		else
-			pr_info("MCE %#lx: Failed to invalidate\n", pfn);
+			pr_info("Memory failure: %#lx: Failed to invalidate\n",
+				pfn);
 	}
 	return ret;
 }
@@ -833,7 +835,7 @@ static void action_result(unsigned long pfn, enum mf_action_page_type type,
 {
 	trace_memory_failure_event(pfn, type, result);
 
-	pr_err("MCE %#lx: recovery action for %s: %s\n",
+	pr_err("Memory failure: %#lx: recovery action for %s: %s\n",
 		pfn, action_page_types[type], action_name[result]);
 }
 
@@ -849,7 +851,7 @@ static int page_action(struct page_state *ps, struct page *p,
 	if (ps->action == me_swapcache_dirty && result == MF_DELAYED)
 		count--;
 	if (count != 0) {
-		pr_err("MCE %#lx: %s still referenced by %d users\n",
+		pr_err("Memory failure: %#lx: %s still referenced by %d users\n",
 		       pfn, action_page_types[ps->type], count);
 		result = MF_FAILED;
 	}
@@ -882,7 +884,7 @@ int get_hwpoison_page(struct page *page)
 		 * tries to touch the "partially handled" page.
 		 */
 		if (!PageAnon(head)) {
-			pr_err("MCE: %#lx: non anonymous thp\n",
+			pr_err("Memory failure: %#lx: non anonymous thp\n",
 				page_to_pfn(page));
 			return 0;
 		}
@@ -923,12 +925,13 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 		return SWAP_SUCCESS;
 
 	if (PageKsm(p)) {
-		pr_err("MCE %#lx: can't handle KSM pages.\n", pfn);
+		pr_err("Memory failure: %#lx: can't handle KSM pages.\n", pfn);
 		return SWAP_FAIL;
 	}
 
 	if (PageSwapCache(p)) {
-		pr_err("MCE %#lx: keeping poisoned page in swap cache\n", pfn);
+		pr_err("Memory failure: %#lx: keeping poisoned page in swap cache\n",
+			pfn);
 		ttu |= TTU_IGNORE_HWPOISON;
 	}
 
@@ -946,7 +949,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 		} else {
 			kill = 0;
 			ttu |= TTU_IGNORE_HWPOISON;
-			pr_info("MCE %#lx: corrupted page was clean: dropped without side effects\n",
+			pr_info("Memory failure: %#lx: corrupted page was clean: dropped without side effects\n",
 				pfn);
 		}
 	}
@@ -964,7 +967,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 
 	ret = try_to_unmap(hpage, ttu);
 	if (ret != SWAP_SUCCESS)
-		pr_err("MCE %#lx: failed to unmap page (mapcount=%d)\n",
+		pr_err("Memory failure: %#lx: failed to unmap page (mapcount=%d)\n",
 		       pfn, page_mapcount(hpage));
 
 	/*
@@ -1032,14 +1035,16 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		panic("Memory failure from trap %d on page %lx", trapno, pfn);
 
 	if (!pfn_valid(pfn)) {
-		pr_err("MCE %#lx: memory outside kernel control\n", pfn);
+		pr_err("Memory failure: %#lx: memory outside kernel control\n",
+			pfn);
 		return -ENXIO;
 	}
 
 	p = pfn_to_page(pfn);
 	orig_head = hpage = compound_head(p);
 	if (TestSetPageHWPoison(p)) {
-		pr_err("MCE %#lx: already hardware poisoned\n", pfn);
+		pr_err("Memory failure: %#lx: already hardware poisoned\n",
+			pfn);
 		return 0;
 	}
 
@@ -1104,9 +1109,11 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
 			unlock_page(hpage);
 			if (!PageAnon(hpage))
-				pr_err("MCE: %#lx: non anonymous thp\n", pfn);
+				pr_err("Memory failure: %#lx: non anonymous thp\n",
+					pfn);
 			else
-				pr_err("MCE: %#lx: thp split failed\n", pfn);
+				pr_err("Memory failure: %#lx: thp split failed\n",
+					pfn);
 			if (TestClearPageHWPoison(p))
 				num_poisoned_pages_sub(nr_pages);
 			put_hwpoison_page(p);
@@ -1170,7 +1177,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 * unpoison always clear PG_hwpoison inside page lock
 	 */
 	if (!PageHWPoison(p)) {
-		pr_err("MCE %#lx: just unpoisoned\n", pfn);
+		pr_err("Memory failure: %#lx: just unpoisoned\n", pfn);
 		num_poisoned_pages_sub(nr_pages);
 		unlock_page(hpage);
 		put_hwpoison_page(hpage);
@@ -1387,25 +1394,25 @@ int unpoison_memory(unsigned long pfn)
 	page = compound_head(p);
 
 	if (!PageHWPoison(p)) {
-		unpoison_pr_info("MCE: Page was already unpoisoned %#lx\n",
+		unpoison_pr_info("Unpoison: Page was already unpoisoned %#lx\n",
 				 pfn, &unpoison_rs);
 		return 0;
 	}
 
 	if (page_count(page) > 1) {
-		unpoison_pr_info("MCE: Someone grabs the hwpoison page %#lx\n",
+		unpoison_pr_info("Unpoison: Someone grabs the hwpoison page %#lx\n",
 				 pfn, &unpoison_rs);
 		return 0;
 	}
 
 	if (page_mapped(page)) {
-		unpoison_pr_info("MCE: Someone maps the hwpoison page %#lx\n",
+		unpoison_pr_info("Unpoison: Someone maps the hwpoison page %#lx\n",
 				 pfn, &unpoison_rs);
 		return 0;
 	}
 
 	if (page_mapping(page)) {
-		unpoison_pr_info("MCE: the hwpoison page has non-NULL mapping %#lx\n",
+		unpoison_pr_info("Unpoison: the hwpoison page has non-NULL mapping %#lx\n",
 				 pfn, &unpoison_rs);
 		return 0;
 	}
@@ -1416,7 +1423,7 @@ int unpoison_memory(unsigned long pfn)
 	 * In such case, we yield to memory_failure() and make unpoison fail.
 	 */
 	if (!PageHuge(page) && PageTransHuge(page)) {
-		unpoison_pr_info("MCE: Memory failure is now running on %#lx\n",
+		unpoison_pr_info("Unpoison: Memory failure is now running on %#lx\n",
 				 pfn, &unpoison_rs);
 		return 0;
 	}
@@ -1431,13 +1438,13 @@ int unpoison_memory(unsigned long pfn)
 		 * to the end.
 		 */
 		if (PageHuge(page)) {
-			unpoison_pr_info("MCE: Memory failure is now running on free hugepage %#lx\n",
+			unpoison_pr_info("Unpoison: Memory failure is now running on free hugepage %#lx\n",
 					 pfn, &unpoison_rs);
 			return 0;
 		}
 		if (TestClearPageHWPoison(p))
 			num_poisoned_pages_dec();
-		unpoison_pr_info("MCE: Software-unpoisoned free page %#lx\n",
+		unpoison_pr_info("Unpoison: Software-unpoisoned free page %#lx\n",
 				 pfn, &unpoison_rs);
 		return 0;
 	}
@@ -1450,7 +1457,7 @@ int unpoison_memory(unsigned long pfn)
 	 * the free buddy page pool.
 	 */
 	if (TestClearPageHWPoison(page)) {
-		unpoison_pr_info("MCE: Software-unpoisoned page %#lx\n",
+		unpoison_pr_info("Unpoison: Software-unpoisoned page %#lx\n",
 				 pfn, &unpoison_rs);
 		num_poisoned_pages_sub(nr_pages);
 		freeit = 1;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBEE6B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:10:14 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so1276726qae.20
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:10:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t7si2256737qar.75.2013.12.19.01.10.13
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 01:10:13 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/memory-failure.c: transfer page count from head page to tail page after split thp
Date: Thu, 19 Dec 2013 04:09:34 -0500
Message-Id: <1387444174-16752-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Memory failures on thp tail pages cause kernel panic like below:

  [  317.361821] mce: [Hardware Error]: Machine check events logged
  [  317.361831] MCE exception done on CPU 7
  [  317.362007] BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
  [  317.362015] IP: [<ffffffff811b7cd1>] dequeue_hwpoisoned_huge_page+0x131/0x1e0
  [  317.362017] PGD bae42067 PUD ba47d067 PMD 0
  [  317.362019] Oops: 0000 [#1] SMP
  ...
  [  317.362052] CPU: 7 PID: 128 Comm: kworker/7:2 Tainted: G   M       O 3.13.0-rc4-131217-1558-00003-g83b7df08e462 #25
  ...
  [  317.362083] Call Trace:
  [  317.362091]  [<ffffffff811d9bae>] me_huge_page+0x3e/0x50
  [  317.362094]  [<ffffffff811dab9b>] memory_failure+0x4bb/0xc20
  [  317.362096]  [<ffffffff8106661e>] mce_process_work+0x3e/0x70
  [  317.362100]  [<ffffffff810b1e21>] process_one_work+0x171/0x420
  [  317.362102]  [<ffffffff810b2c1b>] worker_thread+0x11b/0x3a0
  [  317.362105]  [<ffffffff810b2b00>] ? manage_workers.isra.25+0x2b0/0x2b0
  [  317.362109]  [<ffffffff810b93c4>] kthread+0xe4/0x100
  [  317.362112]  [<ffffffff810b92e0>] ? kthread_create_on_node+0x190/0x190
  [  317.362117]  [<ffffffff816e3c6c>] ret_from_fork+0x7c/0xb0
  [  317.362119]  [<ffffffff810b92e0>] ? kthread_create_on_node+0x190/0x190
  ...
  [  317.362162] RIP  [<ffffffff811b7cd1>] dequeue_hwpoisoned_huge_page+0x131/0x1e0
  [  317.362163]  RSP <ffff880426699cf0>
  [  317.362164] CR2: 0000000000000058

The reasoning of this problem is shown below:
 - when we have a memory error on a thp tail page, the memory error
   handler grabs a refcount of the head page to keep the thp under us.
 - Before unmapping the error page from processes, we split the thp,
   where page refcounts of both of head/tail pages don't change.
 - Then we call try_to_unmap() over the error page (which was a tail
   page before). We didn't pin the error page to handle the memory error,
   this error page is freed and removed from LRU list.
 - We never have the error page on LRU list, so the first page state
   check returns "unknown page," then we move to the second check
   with the saved page flag.
 - The saved page flag have PG_tail set, so the second page state check
   returns "hugepage."
 - We call me_huge_page() for freed error page, then we hit the above panic.

The root cause is that we didn't move refcount from the head page to
the tail page after split thp. So this patch suggests to do this.

This panic was introduced by commit 524fca1e73 "HWPOISON: fix misjudgement
of page_action() for errors on mlocked pages."  Note that we did have
the same refcount problem before this commit, but it was just ignored
because we had only first page state check which returned "unknown page."
The commit changed the refcount problem from "doesn't work" to "kernel panic."

Cc: stable@vger.kernel.org # 3.9+
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git v3.13-rc4.orig/mm/memory-failure.c v3.13-rc4/mm/memory-failure.c
index db08af92c6fc..fabe55046c1d 100644
--- v3.13-rc4.orig/mm/memory-failure.c
+++ v3.13-rc4/mm/memory-failure.c
@@ -938,6 +938,16 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 				BUG_ON(!PageHWPoison(p));
 				return SWAP_FAIL;
 			}
+			/*
+			 * We pinned the head page for hwpoison handling,
+			 * now we split the thp and we are interested in
+			 * the hwpoisoned raw page, so move the refcount
+			 * to it.
+			 */
+			if (hpage != p) {
+				put_page(hpage);
+				get_page(p);
+			}
 			/* THP is split, so ppage should be the real poisoned page. */
 			ppage = p;
 		}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

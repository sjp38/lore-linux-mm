Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 470338D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 06:42:15 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4CDFB3EE0AE
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:42:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 347CA45DE95
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:42:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1530945DE93
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:42:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0854FE08003
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:42:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B990EE08001
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:42:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/4] x86,mm: make pagefault killable
In-Reply-To: <20110329193953.2B7E.A69D9226@jp.fujitsu.com>
References: <20110329193953.2B7E.A69D9226@jp.fujitsu.com>
Message-Id: <20110329194249.2B8E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 29 Mar 2011 19:42:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

When oom killer occured, almost processes are getting stuck following
two points.

	1) __alloc_pages_nodemask
	2) __lock_page_or_retry

1) is not much problematic because TIF_MEMDIE lead to make allocation
failure and get out from page allocator. 2) is more problematic. When
OOM situation, Zones typically don't have page cache at all and Memory
starvation might lead to reduce IO performance largely. When fork bomb
occur, TIF_MEMDIE task don't die quickly mean fork bomb may create
new process quickly rather than oom-killer kill it. Then, the system
may become livelock.

This patch makes pagefault interruptible by SIGKILL.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 arch/x86/mm/fault.c |   12 +++++++++++-
 include/linux/mm.h  |    1 +
 mm/filemap.c        |   31 ++++++++++++++++++++++++-------
 3 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 20e3f87..57a9fce 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -964,7 +964,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	struct mm_struct *mm;
 	int fault;
 	int write = error_code & PF_WRITE;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY |
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE |
 					(write ? FAULT_FLAG_WRITE : 0);
 
 	tsk = current;
@@ -1138,6 +1138,16 @@ good_area:
 	}
 
 	/*
+	 * Pagefault was interrupted by SIGKILL. We have no reason to
+	 * continue pagefault.
+	 */
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		if (!(error_code & PF_USER))
+			no_context(regs, error_code, address);
+		return;
+	}
+
+	/*
 	 * Major/minor page fault accounting is only done on the
 	 * initial attempt. If we go through a retry, it is extremely
 	 * likely that the page will be found in page cache at that point.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7606d7d..aba870b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -152,6 +152,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
 #define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
+#define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
diff --git a/mm/filemap.c b/mm/filemap.c
index dea8a38..8144f87 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -654,15 +654,32 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
-	if (!(flags & FAULT_FLAG_ALLOW_RETRY)) {
-		__lock_page(page);
-		return 1;
-	} else {
-		if (!(flags & FAULT_FLAG_RETRY_NOWAIT)) {
-			up_read(&mm->mmap_sem);
+	if (flags & FAULT_FLAG_ALLOW_RETRY) {
+		/*
+		 * CAUTION! In this case, mmap_sem is not released
+		 * even though return 0.
+		 */
+		if (flags & FAULT_FLAG_RETRY_NOWAIT)
+			return 0;
+
+		up_read(&mm->mmap_sem);
+		if (flags & FAULT_FLAG_KILLABLE)
+			wait_on_page_locked_killable(page);
+		else
 			wait_on_page_locked(page);
-		}
 		return 0;
+	} else {
+		if (flags & FAULT_FLAG_KILLABLE) {
+			int ret;
+
+			ret = __lock_page_killable(page);
+			if (ret) {
+				up_read(&mm->mmap_sem);
+				return 0;
+			}
+		} else
+			__lock_page(page);
+		return 1;
 	}
 }
 
-- 
1.7.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

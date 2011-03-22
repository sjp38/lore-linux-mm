Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C01D48D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 07:09:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4CACB3EE0BC
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:09:31 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 337DB45DE52
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:09:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F69B45DE51
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:09:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C5C1DB8037
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:09:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AFEB9E78003
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:09:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] x86,mm: make pagefault killable
In-Reply-To: <20110322194721.B05E.A69D9226@jp.fujitsu.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com> <20110322194721.B05E.A69D9226@jp.fujitsu.com>
Message-Id: <20110322200945.B06D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 22 Mar 2011 20:09:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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
 arch/x86/mm/fault.c |    9 +++++++++
 include/linux/mm.h  |    1 +
 mm/filemap.c        |   22 +++++++++++++++++-----
 3 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 20e3f87..797c7d0 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1035,6 +1035,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	if (user_mode_vm(regs)) {
 		local_irq_enable();
 		error_code |= PF_USER;
+		flags |= FAULT_FLAG_KILLABLE;
 	} else {
 		if (regs->flags & X86_EFLAGS_IF)
 			local_irq_enable();
@@ -1138,6 +1139,14 @@ good_area:
 	}
 
 	/*
+	 * Pagefault was interrupted by SIGKILL. We have no reason to
+	 * continue pagefault.
+	 */
+	if ((flags & FAULT_FLAG_KILLABLE) && (fault & VM_FAULT_RETRY) &&
+	    fatal_signal_pending(current))
+		return;
+
+	/*
 	 * Major/minor page fault accounting is only done on the
 	 * initial attempt. If we go through a retry, it is extremely
 	 * likely that the page will be found in page cache at that point.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0716517..9e7c567 100644
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
index f5f9ac2..affba94 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -719,15 +719,27 @@ void __lock_page_nosync(struct page *page)
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
-	if (!(flags & FAULT_FLAG_ALLOW_RETRY)) {
-		__lock_page(page);
-		return 1;
-	} else {
+	int ret;
+
+	if (flags & FAULT_FLAG_ALLOW_RETRY) {
 		if (!(flags & FAULT_FLAG_RETRY_NOWAIT)) {
 			up_read(&mm->mmap_sem);
-			wait_on_page_locked(page);
+			if (flags & FAULT_FLAG_KILLABLE)
+				wait_on_page_locked_killable(page);
+			else
+				wait_on_page_locked(page);
 		}
 		return 0;
+	} else {
+		if (flags & FAULT_FLAG_KILLABLE) {
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
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

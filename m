Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4A3B46B0078
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 05:22:42 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0EAMaQp000448
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 19:22:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 98DCB45DE57
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 19:22:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7831945DE4E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 19:22:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F671E18002
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 19:22:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C7807EF8004
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 19:22:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] oom: OOM-Killed process don't invoke pagefault-oom
Message-Id: <20100114191940.6749.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 19:22:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Nick, I've found this issue by code review. I'm glad if you review this
patch.

Thanks.

=============================
commit 1c0fe6e3 (invoke oom-killer from page fault) created
page fault specific oom handler.

But If OOM occur, alloc_pages() in page fault might return
NULL. It mean page fault return VM_FAULT_OOM. But OOM Killer
itself sholdn't invoke next OOM Kill. it is obviously strange.

Plus, process exiting itself makes some free memory. we
don't need kill another process.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/oom_kill.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4f167b8..86cecdf 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -596,6 +596,15 @@ void pagefault_out_of_memory(void)
 {
 	unsigned long freed = 0;
 
+	/*
+	 * If the task was received SIGKILL while memory allocation, alloc_pages
+	 * might return NULL and it cause page fault return VM_FAULT_OOM. But
+	 * in such case, the task don't need kill any another task, it need
+	 * just die.
+	 */
+	if (fatal_signal_pending(current))
+		return;
+
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
 		/* Got some memory back in the last second. */
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

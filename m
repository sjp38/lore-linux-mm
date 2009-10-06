Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8D5B96B0055
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 22:41:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n962fQfm011078
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Oct 2009 11:41:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B514345DE5C
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:41:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BE8645DE5A
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:41:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F2321DB8037
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:41:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 214B01DB8041
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:41:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] mlock use lru_add_drain_all_async()
In-Reply-To: <20091006112803.5FA5.A69D9226@jp.fujitsu.com>
References: <20091006112803.5FA5.A69D9226@jp.fujitsu.com>
Message-Id: <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Oct 2009 11:41:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Recently, Peter Zijlstra reported RT-task can lead to prevent mlock
very long time.

  Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1),
  cpu0 does mlock()->lru_add_drain_all(), which does
  schedule_on_each_cpu(), which then waits for all cpus to complete the
  work. Except that cpu1, which is busy with the RT task, will never run
  keventd until the RT load goes away.

  This is not so much an actual deadlock as a serious starvation case.

Actually, mlock() doesn't need to wait to finish lru_add_drain_all().
Thus, this patch replace it with lru_add_drain_all_async().

Cc: Oleg Nesterov <onestero@redhat.com>
Reported-by: Peter Zijlstra <a.p.zijlstra@chello.nl> 
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mlock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 22041aa..46a016f 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -458,7 +458,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	if (!can_do_mlock())
 		return -EPERM;
 
-	lru_add_drain_all();	/* flush pagevec */
+	lru_add_drain_all_async();	/* flush pagevec */
 
 	down_write(&current->mm->mmap_sem);
 	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
@@ -526,7 +526,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	if (!can_do_mlock())
 		goto out;
 
-	lru_add_drain_all();	/* flush pagevec */
+	lru_add_drain_all_async();	/* flush pagevec */
 
 	down_write(&current->mm->mmap_sem);
 
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

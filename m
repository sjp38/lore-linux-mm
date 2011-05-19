Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CEED26B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 22:34:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0CFE53EE0BB
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:34:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DAFBE45DE5D
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:34:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C157045DE58
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:34:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF2F0E08002
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:34:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 74CE4E08001
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:34:22 +0900 (JST)
Message-ID: <4DD481A7.3050108@jp.fujitsu.com>
Date: Thu, 19 May 2011 11:34:15 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 3/3] vmscan: implement swap token priority aging
References: <4DD480DD.2040307@jp.fujitsu.com>
In-Reply-To: <4DD480DD.2040307@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com

While testing for memcg aware swap token, I observed a swap token
was often grabbed an intermittent running process (eg init, auditd)
and they never release a token.

Why?

Some processes (eg init, auditd, audispd) wake up when a process
exiting. And swap token can be get first page-in process when
a process exiting makes no swap token owner. Thus such above
intermittent running process often get a token.

And currently, swap token priority is only decreased at page fault
path. Then, if the process sleep immediately after to grab swap
token, the swap token priority never be decreased. That's obviously
undesirable.

This patch implement very poor (and lightweight) priority aging.
It only be affect to the above corner case and doesn't change swap
tendency workload performance (eg multi process qsbench load)

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/trace/events/vmscan.h |   20 +++++++++++++-------
 mm/thrash.c                   |   11 ++++++++++-
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 1798e0c..b2c33bd 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -366,9 +366,10 @@ DEFINE_EVENT_CONDITION(put_swap_token_template, disable_swap_token,

 TRACE_EVENT_CONDITION(update_swap_token_priority,
 	TP_PROTO(struct mm_struct *mm,
-		 unsigned int old_prio),
+		 unsigned int old_prio,
+		 struct mm_struct *swap_token_mm),

-	TP_ARGS(mm, old_prio),
+	TP_ARGS(mm, old_prio, swap_token_mm),

 	TP_CONDITION(mm->token_priority != old_prio),

@@ -376,16 +377,21 @@ TRACE_EVENT_CONDITION(update_swap_token_priority,
 		__field(struct mm_struct*, mm)
 		__field(unsigned int, old_prio)
 		__field(unsigned int, new_prio)
+		__field(struct mm_struct*, swap_token_mm)
+		__field(unsigned int, swap_token_prio)
 	),

 	TP_fast_assign(
-		__entry->mm = mm;
-		__entry->old_prio = old_prio;
-		__entry->new_prio = mm->token_priority;
+		__entry->mm		= mm;
+		__entry->old_prio	= old_prio;
+		__entry->new_prio	= mm->token_priority;
+		__entry->swap_token_mm	= swap_token_mm;
+		__entry->swap_token_prio = swap_token_mm ? swap_token_mm->token_priority : 0;
 	),

-	TP_printk("mm=%p old_prio=%u new_prio=%u",
-		  __entry->mm, __entry->old_prio, __entry->new_prio)
+	TP_printk("mm=%p old_prio=%u new_prio=%u swap_token_mm=%p token_prio=%u",
+		  __entry->mm, __entry->old_prio, __entry->new_prio,
+		  __entry->swap_token_mm, __entry->swap_token_prio)
 );

 #endif /* _TRACE_VMSCAN_H */
diff --git a/mm/thrash.c b/mm/thrash.c
index 14c6c9f..af46d67 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -25,10 +25,13 @@

 #include <trace/events/vmscan.h>

+#define TOKEN_AGING_INTERVAL	(0xFF)
+
 static DEFINE_SPINLOCK(swap_token_lock);
 struct mm_struct *swap_token_mm;
 struct mem_cgroup *swap_token_memcg;
 static unsigned int global_faults;
+static unsigned int last_aging;

 void grab_swap_token(struct mm_struct *mm)
 {
@@ -47,6 +50,11 @@ void grab_swap_token(struct mm_struct *mm)
 	if (!swap_token_mm)
 		goto replace_token;

+	if ((global_faults - last_aging) > TOKEN_AGING_INTERVAL) {
+		swap_token_mm->token_priority /= 2;
+		last_aging = global_faults;
+	}
+
 	if (mm == swap_token_mm) {
 		mm->token_priority += 2;
 		goto update_priority;
@@ -64,7 +72,7 @@ void grab_swap_token(struct mm_struct *mm)
 		goto replace_token;

 update_priority:
-	trace_update_swap_token_priority(mm, old_prio);
+	trace_update_swap_token_priority(mm, old_prio, swap_token_mm);

 out:
 	mm->faultstamp = global_faults;
@@ -80,6 +88,7 @@ replace_token:
 	trace_replace_swap_token(swap_token_mm, mm);
 	swap_token_mm = mm;
 	swap_token_memcg = memcg;
+	last_aging = global_faults;
 	goto out;
 }

-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

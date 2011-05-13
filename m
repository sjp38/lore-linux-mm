Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EDD9290010B
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:40:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 84DE03EE0B5
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:40:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F2C545DE95
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:40:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EAB045DE93
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:40:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 420EF1DB8037
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:40:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E21B1DB802F
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:40:30 +0900 (JST)
Message-ID: <4DCD1913.2090200@jp.fujitsu.com>
Date: Fri, 13 May 2011 20:42:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] vmscan: implement swap token priority decay
References: <4DCD1824.1060801@jp.fujitsu.com>
In-Reply-To: <4DCD1824.1060801@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, riel@redhat.com

While testing for memcg aware swap token, I observed a swap token
was often grabbed an intermittent running process (eg init, auditd)
and they never release a token.

Why? Currently, swap toke priority is only decreased at page fault
path. Then, if the process sleep immediately after to grab swap
token, their swap token priority never be decreased. That makes
obviously undesired result.

This patch implement very poor (and lightweight) priority decay
mechanism. It only be affect to the above corner case and doesn't
change swap tendency workload performance (eg multi process qsbench
load)

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/trace/events/vmscan.h |   12 ++++++++----
 mm/thrash.c                   |    5 ++++-
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 1798e0c..ba18137 100644
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

@@ -376,16 +377,19 @@ TRACE_EVENT_CONDITION(update_swap_token_priority,
 		__field(struct mm_struct*, mm)
 		__field(unsigned int, old_prio)
 		__field(unsigned int, new_prio)
+		__field(unsigned int, token_prio)
 	),

 	TP_fast_assign(
 		__entry->mm = mm;
 		__entry->old_prio = old_prio;
 		__entry->new_prio = mm->token_priority;
+		__entry->token_prio = swap_token_mm ? swap_token_mm->token_priority : 0;
 	),

-	TP_printk("mm=%p old_prio=%u new_prio=%u",
-		  __entry->mm, __entry->old_prio, __entry->new_prio)
+	TP_printk("mm=%p old_prio=%u new_prio=%u token_prio=%u",
+		  __entry->mm, __entry->old_prio, __entry->new_prio,
+		  __entry->token_prio)
 );

 #endif /* _TRACE_VMSCAN_H */
diff --git a/mm/thrash.c b/mm/thrash.c
index 14c6c9f..0c4f0a8 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -47,6 +47,9 @@ void grab_swap_token(struct mm_struct *mm)
 	if (!swap_token_mm)
 		goto replace_token;

+	if (!(global_faults & 0xff))
+		mm->token_priority /= 2;
+
 	if (mm == swap_token_mm) {
 		mm->token_priority += 2;
 		goto update_priority;
@@ -64,7 +67,7 @@ void grab_swap_token(struct mm_struct *mm)
 		goto replace_token;

 update_priority:
-	trace_update_swap_token_priority(mm, old_prio);
+	trace_update_swap_token_priority(mm, old_prio, swap_token_mm);

 out:
 	mm->faultstamp = global_faults;
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 35D0590010B
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:39:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 317433EE0BC
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:39:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14EA745DE94
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:39:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1A5F45DE93
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:39:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4A551DB803C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:39:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A1CCB1DB8038
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:39:12 +0900 (JST)
Message-ID: <4DCD18C4.1000902@jp.fujitsu.com>
Date: Fri, 13 May 2011 20:40:52 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] vmscan: implement swap token trace
References: <4DCD1824.1060801@jp.fujitsu.com>
In-Reply-To: <4DCD1824.1060801@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, riel@redhat.com

This is useful for observing swap token activity.

example output:

             zsh-1845  [000]   598.962716: update_swap_token_priority:
mm=ffff88015eaf7700 old_prio=1 new_prio=0
          memtoy-1830  [001]   602.033900: update_swap_token_priority:
mm=ffff880037a45880 old_prio=947 new_prio=949
          memtoy-1830  [000]   602.041509: update_swap_token_priority:
mm=ffff880037a45880 old_prio=949 new_prio=951
          memtoy-1830  [000]   602.051959: update_swap_token_priority:
mm=ffff880037a45880 old_prio=951 new_prio=953
          memtoy-1830  [000]   602.052188: update_swap_token_priority:
mm=ffff880037a45880 old_prio=953 new_prio=955
          memtoy-1830  [001]   602.427184: put_swap_token:
token_mm=ffff880037a45880
             zsh-1789  [000]   602.427281: replace_swap_token:
old_token_mm=          (null) old_prio=0 new_token_mm=ffff88015eaf7018
new_prio=2
             zsh-1789  [001]   602.433456: update_swap_token_priority:
mm=ffff88015eaf7018 old_prio=2 new_prio=4
             zsh-1789  [000]   602.437613: update_swap_token_priority:
mm=ffff88015eaf7018 old_prio=4 new_prio=6
             zsh-1789  [000]   602.443924: update_swap_token_priority:
mm=ffff88015eaf7018 old_prio=6 new_prio=8
             zsh-1789  [000]   602.451873: update_swap_token_priority:
mm=ffff88015eaf7018 old_prio=8 new_prio=10
             zsh-1789  [001]   602.462639: update_swap_token_priority:
mm=ffff88015eaf7018 old_prio=10 new_prio=12

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/trace/events/vmscan.h |   77 +++++++++++++++++++++++++++++++++++++++++
 mm/thrash.c                   |   11 +++++-
 2 files changed, 87 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index ea422aa..1798e0c 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -6,6 +6,8 @@

 #include <linux/types.h>
 #include <linux/tracepoint.h>
+#include <linux/mm.h>
+#include <linux/memcontrol.h>
 #include "gfpflags.h"

 #define RECLAIM_WB_ANON		0x0001u
@@ -310,6 +312,81 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		show_reclaim_flags(__entry->reclaim_flags))
 );

+TRACE_EVENT(replace_swap_token,
+	TP_PROTO(struct mm_struct *old_mm,
+		 struct mm_struct *new_mm),
+
+	TP_ARGS(old_mm, new_mm),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct*,	old_mm)
+		__field(unsigned int,		old_prio)
+		__field(struct mm_struct*,	new_mm)
+		__field(unsigned int,		new_prio)
+	),
+
+	TP_fast_assign(
+		__entry->old_mm   = old_mm;
+		__entry->old_prio = old_mm ? old_mm->token_priority : 0;
+		__entry->new_mm   = new_mm;
+		__entry->new_prio = new_mm->token_priority;
+	),
+
+	TP_printk("old_token_mm=%p old_prio=%u new_token_mm=%p new_prio=%u",
+		  __entry->old_mm, __entry->old_prio,
+		  __entry->new_mm, __entry->new_prio)
+);
+
+DECLARE_EVENT_CLASS(put_swap_token_template,
+	TP_PROTO(struct mm_struct *swap_token_mm),
+
+	TP_ARGS(swap_token_mm),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct*, swap_token_mm)
+	),
+
+	TP_fast_assign(
+		__entry->swap_token_mm = swap_token_mm;
+	),
+
+	TP_printk("token_mm=%p", __entry->swap_token_mm)
+);
+
+DEFINE_EVENT(put_swap_token_template, put_swap_token,
+	TP_PROTO(struct mm_struct *swap_token_mm),
+	TP_ARGS(swap_token_mm)
+);
+
+DEFINE_EVENT_CONDITION(put_swap_token_template, disable_swap_token,
+	TP_PROTO(struct mm_struct *swap_token_mm),
+	TP_ARGS(swap_token_mm),
+	TP_CONDITION(swap_token_mm != NULL)
+);
+
+TRACE_EVENT_CONDITION(update_swap_token_priority,
+	TP_PROTO(struct mm_struct *mm,
+		 unsigned int old_prio),
+
+	TP_ARGS(mm, old_prio),
+
+	TP_CONDITION(mm->token_priority != old_prio),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct*, mm)
+		__field(unsigned int, old_prio)
+		__field(unsigned int, new_prio)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->old_prio = old_prio;
+		__entry->new_prio = mm->token_priority;
+	),
+
+	TP_printk("mm=%p old_prio=%u new_prio=%u",
+		  __entry->mm, __entry->old_prio, __entry->new_prio)
+);

 #endif /* _TRACE_VMSCAN_H */

diff --git a/mm/thrash.c b/mm/thrash.c
index 32c07fd..14c6c9f 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -23,6 +23,8 @@
 #include <linux/swap.h>
 #include <linux/memcontrol.h>

+#include <trace/events/vmscan.h>
+
 static DEFINE_SPINLOCK(swap_token_lock);
 struct mm_struct *swap_token_mm;
 struct mem_cgroup *swap_token_memcg;
@@ -31,6 +33,7 @@ static unsigned int global_faults;
 void grab_swap_token(struct mm_struct *mm)
 {
 	int current_interval;
+	unsigned int old_prio = mm->token_priority;
 	struct mem_cgroup *memcg;

 	global_faults++;
@@ -46,7 +49,7 @@ void grab_swap_token(struct mm_struct *mm)

 	if (mm == swap_token_mm) {
 		mm->token_priority += 2;
-		goto out;
+		goto update_priority;
 	}

 	if (current_interval < mm->last_interval)
@@ -60,6 +63,9 @@ void grab_swap_token(struct mm_struct *mm)
 	if (mm->token_priority > swap_token_mm->token_priority)
 		goto replace_token;

+update_priority:
+	trace_update_swap_token_priority(mm, old_prio);
+
 out:
 	mm->faultstamp = global_faults;
 	mm->last_interval = current_interval;
@@ -71,6 +77,7 @@ replace_token:
 	memcg = try_get_mem_cgroup_from_mm(mm);
 	if (memcg)
 		css_put(mem_cgroup_css(memcg));
+	trace_replace_swap_token(swap_token_mm, mm);
 	swap_token_mm = mm;
 	swap_token_memcg = memcg;
 	goto out;
@@ -81,6 +88,7 @@ void __put_swap_token(struct mm_struct *mm)
 {
 	spin_lock(&swap_token_lock);
 	if (likely(mm == swap_token_mm)) {
+		trace_put_swap_token(swap_token_mm);
 		swap_token_mm = NULL;
 		swap_token_memcg = NULL;
 	}
@@ -104,6 +112,7 @@ void disable_swap_token(struct mem_cgroup *memcg)
 	if (match_memcg(memcg, swap_token_memcg)) {
 		spin_lock(&swap_token_lock);
 		if (match_memcg(memcg, swap_token_memcg)) {
+			trace_disable_swap_token(swap_token_mm);
 			swap_token_mm = NULL;
 			swap_token_memcg = NULL;
 		}
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

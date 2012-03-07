Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 97FC76B004D
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 22:21:44 -0500 (EST)
Received: by mail-iy0-f169.google.com with SMTP id r24so10389355iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 19:21:44 -0800 (PST)
Date: Tue, 6 Mar 2012 19:21:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, counters: fold __sync_task_rss_stat into
 sync_mm_rss
In-Reply-To: <alpine.DEB.2.00.1203061919260.21806@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1203061920370.21806@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061919260.21806@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There's no difference between sync_mm_rss() and __sync_task_rss_stat(),
so fold the latter into the former.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memory.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -125,7 +125,7 @@ core_initcall(init_zero_pfn);
 
 #if defined(SPLIT_RSS_COUNTING)
 
-static void __sync_task_rss_stat(struct mm_struct *mm)
+void sync_mm_rss(struct mm_struct *mm)
 {
 	int i;
 
@@ -157,7 +157,7 @@ static void check_sync_rss_stat(struct task_struct *task)
 	if (unlikely(task != current))
 		return;
 	if (unlikely(task->rss_stat.events++ > TASK_RSS_EVENTS_THRESH))
-		__sync_task_rss_stat(task->mm);
+		sync_mm_rss(task->mm);
 }
 
 unsigned long get_mm_counter(struct mm_struct *mm, int member)
@@ -177,11 +177,6 @@ unsigned long get_mm_counter(struct mm_struct *mm, int member)
 		return 0;
 	return (unsigned long)val;
 }
-
-void sync_mm_rss(struct mm_struct *mm)
-{
-	__sync_task_rss_stat(mm);
-}
 #else /* SPLIT_RSS_COUNTING */
 
 #define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

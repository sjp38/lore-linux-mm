Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E7B9D6B00BE
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:37 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 60 of 66] freeze khugepaged and ksmd
Message-Id: <99438562b17e61f5bf56.1288798115@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

It's unclear why schedule friendly kernel threads can't be taken away by the
CPU through the scheduler itself. It's safer to stop them as they can trigger
memory allocation, if kswapd also freezes itself to avoid generating I/O they
have too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -15,6 +15,7 @@
 #include <linux/mm_inline.h>
 #include <linux/kthread.h>
 #include <linux/khugepaged.h>
+#include <linux/freezer.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -2063,6 +2064,9 @@ static void khugepaged_do_scan(struct pa
 			break;
 #endif
 
+		if (unlikely(kthread_should_stop() || freezing(current)))
+			break;
+
 		spin_lock(&khugepaged_mm_lock);
 		if (!khugepaged_scan.mm_slot)
 			pass_through_head++;
@@ -2125,6 +2129,9 @@ static void khugepaged_loop(void)
 		if (hpage)
 			put_page(hpage);
 #endif
+		try_to_freeze();
+		if (unlikely(kthread_should_stop()))
+			break;
 		if (khugepaged_has_work()) {
 			DEFINE_WAIT(wait);
 			if (!khugepaged_scan_sleep_millisecs)
@@ -2135,8 +2142,8 @@ static void khugepaged_loop(void)
 					khugepaged_scan_sleep_millisecs));
 			remove_wait_queue(&khugepaged_wait, &wait);
 		} else if (khugepaged_enabled())
-			wait_event_interruptible(khugepaged_wait,
-						 khugepaged_wait_event());
+			wait_event_freezable(khugepaged_wait,
+					     khugepaged_wait_event());
 	}
 }
 
@@ -2144,6 +2151,7 @@ static int khugepaged(void *none)
 {
 	struct mm_slot *mm_slot;
 
+	set_freezable();
 	set_user_nice(current, 19);
 
 	/* serialize with start_khugepaged() */
@@ -2158,6 +2166,8 @@ static int khugepaged(void *none)
 		mutex_lock(&khugepaged_mutex);
 		if (!khugepaged_enabled())
 			break;
+		if (unlikely(kthread_should_stop()))
+			break;
 	}
 
 	spin_lock(&khugepaged_mm_lock);
diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -34,6 +34,7 @@
 #include <linux/swap.h>
 #include <linux/ksm.h>
 #include <linux/hash.h>
+#include <linux/freezer.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -1374,7 +1375,7 @@ static void ksm_do_scan(unsigned int sca
 	struct rmap_item *rmap_item;
 	struct page *uninitialized_var(page);
 
-	while (scan_npages--) {
+	while (scan_npages-- && likely(!freezing(current))) {
 		cond_resched();
 		rmap_item = scan_get_next_rmap_item(&page);
 		if (!rmap_item)
@@ -1392,6 +1393,7 @@ static int ksmd_should_run(void)
 
 static int ksm_scan_thread(void *nothing)
 {
+	set_freezable();
 	set_user_nice(current, 5);
 
 	while (!kthread_should_stop()) {
@@ -1400,11 +1402,13 @@ static int ksm_scan_thread(void *nothing
 			ksm_do_scan(ksm_thread_pages_to_scan);
 		mutex_unlock(&ksm_thread_mutex);
 
+		try_to_freeze();
+
 		if (ksmd_should_run()) {
 			schedule_timeout_interruptible(
 				msecs_to_jiffies(ksm_thread_sleep_millisecs));
 		} else {
-			wait_event_interruptible(ksm_thread_wait,
+			wait_event_freezable(ksm_thread_wait,
 				ksmd_should_run() || kthread_should_stop());
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

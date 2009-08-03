Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E6476B0062
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:54:47 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:14:03 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 5/12] ksm: keep quiet while list empty
In-Reply-To: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
Message-ID: <Pine.LNX.4.64.0908031313030.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ksm_scan_thread already sleeps in wait_event_interruptible until setting
ksm_run activates it; but if there's nothing on its list to look at, i.e.
nobody has yet said madvise MADV_MERGEABLE, it's a shame to be clocking
up system time and full_scans: ksmd_should_run added to check that too.

And move the mutex_lock out around it: the new counts showed that when
ksm_run is stopped, a little work often got done afterwards, because it
had been read before taking the mutex.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

--- ksm4/mm/ksm.c	2009-08-02 13:49:59.000000000 +0100
+++ ksm5/mm/ksm.c	2009-08-02 13:50:07.000000000 +0100
@@ -1287,21 +1287,27 @@ static void ksm_do_scan(unsigned int sca
 	}
 }
 
+static int ksmd_should_run(void)
+{
+	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
+}
+
 static int ksm_scan_thread(void *nothing)
 {
 	set_user_nice(current, 5);
 
 	while (!kthread_should_stop()) {
-		if (ksm_run & KSM_RUN_MERGE) {
-			mutex_lock(&ksm_thread_mutex);
+		mutex_lock(&ksm_thread_mutex);
+		if (ksmd_should_run())
 			ksm_do_scan(ksm_thread_pages_to_scan);
-			mutex_unlock(&ksm_thread_mutex);
+		mutex_unlock(&ksm_thread_mutex);
+
+		if (ksmd_should_run()) {
 			schedule_timeout_interruptible(
 				msecs_to_jiffies(ksm_thread_sleep_millisecs));
 		} else {
 			wait_event_interruptible(ksm_thread_wait,
-					(ksm_run & KSM_RUN_MERGE) ||
-					kthread_should_stop());
+				ksmd_should_run() || kthread_should_stop());
 		}
 	}
 	return 0;
@@ -1346,10 +1352,16 @@ int ksm_madvise(struct vm_area_struct *v
 
 int __ksm_enter(struct mm_struct *mm)
 {
-	struct mm_slot *mm_slot = alloc_mm_slot();
+	struct mm_slot *mm_slot;
+	int needs_wakeup;
+
+	mm_slot = alloc_mm_slot();
 	if (!mm_slot)
 		return -ENOMEM;
 
+	/* Check ksm_run too?  Would need tighter locking */
+	needs_wakeup = list_empty(&ksm_mm_head.mm_list);
+
 	spin_lock(&ksm_mmlist_lock);
 	insert_to_mm_slots_hash(mm, mm_slot);
 	/*
@@ -1361,6 +1373,10 @@ int __ksm_enter(struct mm_struct *mm)
 	spin_unlock(&ksm_mmlist_lock);
 
 	set_bit(MMF_VM_MERGEABLE, &mm->flags);
+
+	if (needs_wakeup)
+		wake_up_interruptible(&ksm_thread_wait);
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

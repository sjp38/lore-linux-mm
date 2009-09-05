Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0E3896B0083
	for <linux-mm@kvack.org>; Sat,  5 Sep 2009 17:25:55 -0400 (EDT)
Date: Sat, 5 Sep 2009 22:25:21 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 2/3] ksm: unmerge is an origin of OOMs
In-Reply-To: <Pine.LNX.4.64.0909052219580.7381@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909052222430.7387@sister.anvils>
References: <Pine.LNX.4.64.0909052219580.7381@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just as the swapoff system call allocates many pages of RAM to various
processes, perhaps triggering OOM, so "echo 2 >/sys/kernel/mm/ksm/run"
(unmerge) is liable to allocate many pages of RAM to various processes,
perhaps triggering OOM; and each is normally run from a modest admin
process (swapoff or shell), easily repeated until it succeeds.

So treat unmerge_and_remove_all_rmap_items() in the same way that we
treat try_to_unuse(): generalize PF_SWAPOFF to PF_OOM_ORIGIN, and
bracket both with that, to ask the OOM killer to kill them first,
to prevent them from spawning more and more OOM kills.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/sched.h |    2 +-
 mm/ksm.c              |    2 ++
 mm/oom_kill.c         |    2 +-
 mm/swapfile.c         |    4 ++--
 4 files changed, 6 insertions(+), 4 deletions(-)

--- mmotm/include/linux/sched.h	2009-09-05 14:40:16.000000000 +0100
+++ linux/include/linux/sched.h	2009-09-05 16:41:55.000000000 +0100
@@ -1755,7 +1755,7 @@ extern cputime_t task_gtime(struct task_
 #define PF_FROZEN	0x00010000	/* frozen for system suspend */
 #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
 #define PF_KSWAPD	0x00040000	/* I am kswapd */
-#define PF_SWAPOFF	0x00080000	/* I am in swapoff */
+#define PF_OOM_ORIGIN	0x00080000	/* Allocating much memory to others */
 #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
 #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
--- mmotm/mm/ksm.c	2009-09-05 14:40:16.000000000 +0100
+++ linux/mm/ksm.c	2009-09-05 16:41:55.000000000 +0100
@@ -1564,7 +1564,9 @@ static ssize_t run_store(struct kobject
 	if (ksm_run != flags) {
 		ksm_run = flags;
 		if (flags & KSM_RUN_UNMERGE) {
+			current->flags |= PF_OOM_ORIGIN;
 			err = unmerge_and_remove_all_rmap_items();
+			current->flags &= ~PF_OOM_ORIGIN;
 			if (err) {
 				ksm_run = KSM_RUN_STOP;
 				count = err;
--- mmotm/mm/oom_kill.c	2009-09-05 14:40:16.000000000 +0100
+++ linux/mm/oom_kill.c	2009-09-05 16:41:55.000000000 +0100
@@ -103,7 +103,7 @@ unsigned long badness(struct task_struct
 	/*
 	 * swapoff can easily use up all memory, so kill those first.
 	 */
-	if (p->flags & PF_SWAPOFF)
+	if (p->flags & PF_OOM_ORIGIN)
 		return ULONG_MAX;
 
 	/*
--- mmotm/mm/swapfile.c	2009-09-05 14:40:16.000000000 +0100
+++ linux/mm/swapfile.c	2009-09-05 16:41:55.000000000 +0100
@@ -1573,9 +1573,9 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	p->flags &= ~SWP_WRITEOK;
 	spin_unlock(&swap_lock);
 
-	current->flags |= PF_SWAPOFF;
+	current->flags |= PF_OOM_ORIGIN;
 	err = try_to_unuse(type);
-	current->flags &= ~PF_SWAPOFF;
+	current->flags &= ~PF_OOM_ORIGIN;
 
 	if (err) {
 		/* re-insert swap space back into swap_list */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

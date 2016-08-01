Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 560796B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 04:15:00 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so70410048lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 01:15:00 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id p145si14811575wme.109.2016.08.01.01.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 01:14:59 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so25068142wmg.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 01:14:58 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] kernel/fork: fix CLONE_CHILD_CLEARTID regression in nscd
Date: Mon,  1 Aug 2016 10:14:47 +0200
Message-Id: <1470039287-14643-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, William Preston <wpreston@suse.com>, Michal Hocko <mhocko@suse.com>, Roland McGrath <roland@hack.frob.com>, Oleg Nesterov <oleg@redhat.com>, Andreas Schwab <schwab@suse.com>

From: Michal Hocko <mhocko@suse.com>

fec1d0115240 ("[PATCH] Disable CLONE_CHILD_CLEARTID for abnormal exit")
has caused a subtle regression in nscd which uses CLONE_CHILD_CLEARTID
to clear the nscd_certainly_running flag in the shared databases, so
that the clients are notified when nscd is restarted.  Now, when nscd
uses a non-persistent database, clients that have it mapped keep
thinking the database is being updated by nscd, when in fact nscd has
created a new (anonymous) one (for non-persistent databases it uses an
unlinked file as backend).

The original proposal for the CLONE_CHILD_CLEARTID change claimed
(https://lkml.org/lkml/2006/10/25/233):
"
The NPTL library uses the CLONE_CHILD_CLEARTID flag on clone() syscalls
on behalf of pthread_create() library calls.  This feature is used to
request that the kernel clear the thread-id in user space (at an address
provided in the syscall) when the thread disassociates itself from the
address space, which is done in mm_release().

Unfortunately, when a multi-threaded process incurs a core dump (such as
from a SIGSEGV), the core-dumping thread sends SIGKILL signals to all of
the other threads, which then proceed to clear their user-space tids
before synchronizing in exit_mm() with the start of core dumping.  This
misrepresents the state of process's address space at the time of the
SIGSEGV and makes it more difficult for someone to debug NPTL and glibc
problems (misleading him/her to conclude that the threads had gone away
before the fault).

The fix below is to simply avoid the CLONE_CHILD_CLEARTID action if a
core dump has been initiated.
"

The resulting patch from Roland (https://lkml.org/lkml/2006/10/26/269)
seems to have a larger scope than the original patch asked for. It seems
that limitting the scope of the check to core dumping should work for
SIGSEGV issue describe above. We should also check for vfork because
this is killable since d68b46fe16ad ("vfork: make it killable").

[Changelog partly based on Andreas' description]
Fixes: fec1d0115240 ("[PATCH] Disable CLONE_CHILD_CLEARTID for abnormal exit")
Tested-by:  William Preston <wpreston@suse.com>
Cc: Roland McGrath <roland@hack.frob.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andreas Schwab <schwab@suse.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
the issue has been reported by Andreas https://lkml.org/lkml/2015/8/20/459
almost one year ago without any response. This is my attempt to fix the issue
and the testing confirms that nscd doesn't complain with this patch applied
but I have hard time to think through all the consequences, to be honest so
I am sending this as an RFC.

 kernel/fork.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 52e725d4a866..0c1184473c3e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -913,14 +913,12 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 	deactivate_mm(tsk, mm);
 
 	/*
-	 * If we're exiting normally, clear a user-space tid field if
-	 * requested.  We leave this alone when dying by signal, to leave
-	 * the value intact in a core dump, and to save the unnecessary
-	 * trouble, say, a killed vfork parent shouldn't touch this mm.
-	 * Userland only wants this done for a sys_exit.
+	 * Signal userspace if we're not exiting with a core dump
+	 * or a killed vfork parent which shouldn't touch this mm.
 	 */
 	if (tsk->clear_child_tid) {
-		if (!(tsk->flags & PF_SIGNALED) &&
+		if (!(tsk->flags & PF_SIGNALED && tsk->vfork_done) &&
+		    !(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
 		    atomic_read(&mm->mm_users) > 1) {
 			/*
 			 * We don't check the error code - if userspace has
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

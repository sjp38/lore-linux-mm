Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 895E56B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:12:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so88596669wme.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:12:40 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 17si21769316wmg.21.2016.08.23.09.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 09:12:39 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so18728816wmf.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:12:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2] kernel/fork: fix CLONE_CHILD_CLEARTID regression in nscd
Date: Tue, 23 Aug 2016 18:12:29 +0200
Message-Id: <1471968749-26173-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Roland McGrath <roland@hack.frob.com>, Oleg Nesterov <oleg@redhat.com>, Andreas Schwab <schwab@suse.com>, William Preston <wpreston@suse.com>

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
SIGSEGV issue describe above.

[Changelog partly based on Andreas' description]
Fixes: fec1d0115240 ("[PATCH] Disable CLONE_CHILD_CLEARTID for abnormal exit")
Tested-by:  William Preston <wpreston@suse.com>
Cc: Roland McGrath <roland@hack.frob.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andreas Schwab <schwab@suse.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
the previous version of this patch was sent http://lkml.kernel.org/r/1470039287-14643-1-git-send-email-mhocko@kernel.org
I have dropped the vfork check which Oleg didn't like. It shouldn't
have caused any change for the nscd testing so I am keeping William's
tested-by.

 kernel/fork.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 52e725d4a866..b89f0eb99f0a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -913,14 +913,11 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
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
+		if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
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

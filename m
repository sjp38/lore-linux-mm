Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id C204F6B0266
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 11:41:12 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so60264272ioi.2
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:41:12 -0700 (PDT)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id 39si7287463iop.174.2015.09.18.08.41.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 18 Sep 2015 08:41:11 -0700 (PDT)
Date: Fri, 18 Sep 2015 10:41:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <20150917192204.GA2728@redhat.com>
Message-ID: <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

> But yes, such a deadlock is possible. I would really like to see the comments
> from maintainers. In particular, I seem to recall that someone suggested to
> try to kill another !TIF_MEMDIE process after timeout, perhaps this is what
> we should actually do...

Well yes here is a patch that kills another memdie process but there is
some risk with such an approach of overusing the reserves.


Subject: Allow multiple kills from the OOM killer

The OOM killer currently aborts if it finds a process that already is having
access to the reserve memory pool for exit processing. This is done so that
the reserves are not overcommitted but on the other hand this also allows
only one process being oom killed at the time. That process may be stuck
in D state.

The patch simply removes the aborting of the scan so that other processes
may be killed if one is stuck in D state.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/oom_kill.c
===================================================================
--- linux.orig/mm/oom_kill.c	2015-09-18 10:38:29.601963726 -0500
+++ linux/mm/oom_kill.c	2015-09-18 10:39:55.911699017 -0500
@@ -265,8 +265,8 @@ enum oom_scan_t oom_scan_process_thread(
 	 * Don't allow any other task to have access to the reserves.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (oc->order != -1)
-			return OOM_SCAN_ABORT;
+		if (unlikely(frozen(task)))
+			__thaw_task(task);
 	}
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

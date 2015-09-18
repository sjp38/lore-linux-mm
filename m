Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id D19F96B0254
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 13:01:02 -0400 (EDT)
Received: by iofb144 with SMTP id b144so63167415iof.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 10:01:02 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id jk10si972104igb.32.2015.09.18.10.01.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 18 Sep 2015 10:01:01 -0700 (PDT)
Date: Fri, 18 Sep 2015 12:00:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <20150918162423.GA18136@redhat.com>
Message-ID: <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On Fri, 18 Sep 2015, Oleg Nesterov wrote:

> To simplify the discussion lets ignore PF_FROZEN, this is another issue.

Ok.

Subject: Allow multiple kills from the OOM killer

The OOM killer currently aborts if it finds a process that already is having
access to the reserve memory pool for exit processing. This is done so that
the reserves are not overcommitted but on the other hand this also allows
only one process being oom killed at the time. That process may be stuck
in D state.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/oom_kill.c
===================================================================
--- linux.orig/mm/oom_kill.c	2015-09-18 11:58:52.963946782 -0500
+++ linux/mm/oom_kill.c	2015-09-18 11:59:42.010684778 -0500
@@ -264,10 +264,9 @@ enum oom_scan_t oom_scan_process_thread(
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (oc->order != -1)
-			return OOM_SCAN_ABORT;
-	}
+	if (test_tsk_thread_flag(task, TIF_MEMDIE))
+		return OOM_SCAN_CONTINUE;
+
 	if (!task->mm)
 		return OOM_SCAN_CONTINUE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

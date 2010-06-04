Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1323A6B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 06:54:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o54Asj1q025915
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Jun 2010 19:54:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C48E45DE70
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0894245DE6F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE4351DB8040
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 864401DB8037
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
In-Reply-To: <20100602203827.GA29244@redhat.com>
References: <20100602185812.4B5894A549@magilla.sf.frob.com> <20100602203827.GA29244@redhat.com>
Message-Id: <20100604194635.72D3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Jun 2010 19:54:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On 06/02, Roland McGrath wrote:
> >
> > > when select_bad_process() finds the task P to kill it can participate
> > > in the core dump (sleep in exit_mm), but we should somehow inform the
> > > thread which actually dumps the core: P->mm->core_state->dumper.
> >
> > Perhaps it should simply do that: if you would choose P to oom-kill, and
> > P->mm->core_state!=NULL, then choose P->mm->core_state->dumper instead.
> 
> ... to set TIF_MEMDIE which should be checked in elf_core_dump().
> 
> Probably yes.

Yep, probably. but can you please allow me additonal explanation?

In multi threaded OOM case, we have two problematic routine, coredump
and vmscan. Roland's idea can only solve the former. 

But I also interest vmscan quickly exit if OOM received. if other threads
get stuck in vmscan for freeing addional pages (this is very typical because
usually every thread call any syscall and eventually call kmalloc etc), 
recovering oom become very slow even if this doesn't makes deadlock.

Unfortunatelly, vmscan need much refactoring before appling this idea.
then, I didn't include such fixes.

I mean I hope to implement per-process OOM flag even if coredump don't
really need it.

So, I created MMF_OOM patch today. It is just for discussion, still.

(BFrom f099e1ba6e7b5654b35b468c13e1ae9e4f182ea4 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 4 Jun 2010 18:56:56 +0900
Subject: [RFC][PATCH v2] oom: make coredump interruptible

If oom victim process is under core dumping, sending SIGKILL cause
no-op. Unfortunately, coredump need relatively much memory. It mean
OOM vs coredump can makes deadlock.

Then, coredump logic should check the task has received SIGKILL
from OOM.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/binfmt_elf.c       |    4 ++++
 include/linux/sched.h |    1 +
 mm/oom_kill.c         |    3 ++-
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 535e763..2aca748 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -2038,6 +2038,10 @@ static int elf_core_dump(struct coredump_params *cprm)
 				page_cache_release(page);
 			} else
 				stop = !dump_seek(cprm->file, PAGE_SIZE);
+
+			/* The task need to exit ASAP if received OOM. */
+			if (test_bit(MMF_OOM_KILLED, &current->mm->flags))
+				stop = 1;
 			if (stop)
 				goto end_coredump;
 		}
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8485aa2..53b7caa 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -436,6 +436,7 @@ extern int get_dumpable(struct mm_struct *mm);
 #endif
 					/* leave room for more dump flags */
 #define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
+#define MMF_OOM_KILLED		17	/* Killed by OOM */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2678a04..29850c4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -401,7 +401,6 @@ static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
 		       K(p->mm->total_vm),
 		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
 		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
-	task_unlock(p);
 
 	/*
 	 * We give our sacrificial lamb high priority and access to
@@ -410,6 +409,8 @@ static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
 	 */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
+	set_bit(MMF_OOM_KILLED, &p->mm->flags);
+	task_unlock(p);
 
 	force_sig(SIGKILL, p);
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

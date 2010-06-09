Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A671B6B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 15:54:43 -0400 (EDT)
Date: Wed, 9 Jun 2010 21:53:09 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
Message-ID: <20100609195309.GA6899@redhat.com>
References: <20100602185812.4B5894A549@magilla.sf.frob.com> <20100602203827.GA29244@redhat.com> <20100604194635.72D3.A69D9226@jp.fujitsu.com> <20100604112721.GA12582@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100604112721.GA12582@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/04, Oleg Nesterov wrote:
>
> On 06/04, KOSAKI Motohiro wrote:
> >
> > In multi threaded OOM case, we have two problematic routine, coredump
> > and vmscan. Roland's idea can only solve the former.
> >
> > But I also interest vmscan quickly exit if OOM received.
>
> Yes, agreed. See another email from me, MMF_ flags looks "obviously
> useful" to me.

Well. But somehow we forgot about the !coredumping case... Suppose
that select_bad_process() chooses the process P to kill and we have
other processes (not sub-threads) which share the same ->mm.

In that case I am not sure we should blindly set MMF_OOMKILL. Suppose
that we kill P and after that the "out-of-memory" condition goes away.
But its ->mm still has MMF_OOMKILL set, and it is used. Who/when will
clear this flag?

Perhaps something like below makes sense for now.

Oleg.

--- x/fs/exec.c
+++ x/fs/exec.c
@@ -1594,6 +1594,7 @@ static inline int zap_threads(struct tas
 	spin_lock_irq(&tsk->sighand->siglock);
 	if (!signal_group_exit(tsk->signal)) {
 		mm->core_state = core_state;
+		set_bit(MMF_COREDUMP, &mm->flags);
 		nr = zap_process(tsk, exit_code);
 	}
 	spin_unlock_irq(&tsk->sighand->siglock);
--- x/fs/binfmt_elf.c
+++ x/fs/binfmt_elf.c
@@ -2028,6 +2028,9 @@ static int elf_core_dump(struct coredump
 			struct page *page;
 			int stop;
 
+			if (!test_bit(MMF_COREDUMP, &current->mm->flags))
+				goto end_coredump;
+
 			page = get_dump_page(addr);
 			if (page) {
 				void *kaddr = kmap(page);
--- x/mm/oom_kill.c
+++ x/mm/oom_kill.c
@@ -414,6 +414,7 @@ static void __oom_kill_task(struct task_
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 
+	clear_bit(MMF_COREDUMP, &p->mm->flags);
 	force_sig(SIGKILL, p);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

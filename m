Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 43C386B01B7
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:58 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOs49007405
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F241445DE54
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0AC545DE50
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 90B9E1DB8040
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CFA91DB803F
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 08/10] oom: use send_sig() instead force_sig()
In-Reply-To: <20100608184144.GA5914@redhat.com>
References: <20100608210000.7692.A69D9226@jp.fujitsu.com> <20100608184144.GA5914@redhat.com>
Message-Id: <20100613180912.617B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On 06/08, KOSAKI Motohiro wrote:
> >
> > Oleg pointed out oom_kill.c has force_sig() abuse. force_sig() mean
> > ignore signal mask. but SIGKILL itself is not maskable.
> 
> Yes. And we have other reasons to avoid force_sig(). It should be used
> only for synchronous signals.
> 
> But,
> 
> > @@ -399,7 +399,7 @@ static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem)
> >  	p->rt.time_slice = HZ;
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> >
> > -	force_sig(SIGKILL, p);
> > +	send_sig(SIGKILL, p, 1);
> 
> This is not right, we need send_sig(SIGKILL, p, 0). Better yet,
> send_sig_info(SIGKILL, SEND_SIG_NOINFO). I think send_sig() should
> die.
> 
> The reason is that si_fromuser() must be true, otherwise we can't kill
> the SIGNAL_UNKILLABLE (sub-namespace inits) tasks.

Thanks. I am not signal expert. 
To be honest, current special siginfo arguments have a bit unclear meanings
to me ;)
current definition (following) doesn't teach anything.

sched.h
=====================
/* These can be the second arg to send_sig_info/send_group_sig_info.  */
#define SEND_SIG_NOINFO ((struct siginfo *) 0)
#define SEND_SIG_PRIV   ((struct siginfo *) 1)
#define SEND_SIG_FORCED ((struct siginfo *) 2)


If anyone write exact meanings, I'm really really glad.



> Oh. This reminds me, we really need the trivial (but annoying) cleanups
> here. The usage of SEND_SIG_ constants is messy, and they should be
> renamed at least.
> 
> And in fact, we need the new one which acts like SEND_SIG_FORCED but
> si_fromuser(). We do not want to allocate the memory when the caller
> is oom_kill or zap_pid_ns_processes().
> 
> OK. I'll send the simple patch which adds the new helper with the
> comment. send_sigkill() or kernel_kill_task(), or do you see a
> better name?

Very thanks. both name are pretty good to me.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

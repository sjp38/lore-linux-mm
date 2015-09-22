Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 557166B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:46:07 -0400 (EDT)
Received: by iofb144 with SMTP id b144so13411939iof.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 05:46:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j199si2343166ioe.58.2015.09.22.05.46.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 05:46:06 -0700 (PDT)
Date: Tue, 22 Sep 2015 14:43:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150922124303.GA24570@redhat.com>
References: <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com> <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz> <20150921153252.GA21988@redhat.com> <201509220151.CHF17629.LFFJSHQVOMtOFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509220151.CHF17629.LFFJSHQVOMtOFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On 09/22, Tetsuo Handa wrote:
>
> I imagined a dedicated kernel thread doing something like shown below.
> (I don't know about mm->mmap management.)
> mm->mmap_zapped corresponds to MMF_MEMDIE.

No, it doesn't, please see below.

> bool has_sigkill_task;
> wait_queue_head_t kick_mm_zapper;

OK, if this kthread is kicked by oom this makes more sense, but still
doesn't look right at least initially.

Let me repeat, I do think we need MMF_MEMDIE or something like it before
we do something more clever. And in fact I think this flag makes sense
regardless.

> static void mm_zapper(void *unused)
> {
> 	struct task_struct *g, *p;
> 	struct mm_struct *mm;
>
> sleep:
> 	wait_event(kick_remover, has_sigkill_task);
> 	has_sigkill_task = false;
> restart:
> 	rcu_read_lock();
> 	for_each_process_thread(g, p) {
> 		if (likely(!fatal_signal_pending(p)))
> 			continue;
> 		task_lock(p);
> 		mm = p->mm;
> 		if (mm && mm->mmap && !mm->mmap_zapped && down_read_trylock(&mm->mmap_sem)) {
                                       ^^^^^^^^^^^^^^^

We do not want mm->mmap_zapped, it can't work. We need mm->needs_zap
set by oom_kill_process() and cleared after zap_page_range().

Because otherwise we can not handle CLONE_VM correctly. Suppose that
an innocent process P does vfork() and the child is killed but not
exited yet. mm_zapper() can find the child, do zap_page_range(), and
surprise its alive parent P which uses the same ->mm.

And if we rely on MMF_MEMDIE or mm->needs_zap or whaveter then
for_each_process_thread() doesn't really make sense. And if we have
a single MMF_MEMDIE process (likely case) then the unconditional
_trylock is suboptimal.

Tetsuo, can't we do something simple which "obviously can't hurt at
least" and then discuss the potential improvements?

And yes, yes, the "Kill all user processes sharing victim->mm" logic
in oom_kill_process() doesn't 100% look right, at least wrt the change
we discuss.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

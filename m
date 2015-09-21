Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 587626B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:51:55 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so121364733pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:51:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x8si39097918pbt.32.2015.09.21.09.51.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 09:51:54 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150920125642.GA2104@redhat.com>
	<CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
	<20150921134414.GA15974@redhat.com>
	<20150921142423.GC19811@dhcp22.suse.cz>
	<20150921153252.GA21988@redhat.com>
In-Reply-To: <20150921153252.GA21988@redhat.com>
Message-Id: <201509220151.CHF17629.LFFJSHQVOMtOFO@I-love.SAKURA.ne.jp>
Date: Tue, 22 Sep 2015 01:51:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com, mhocko@kernel.org
Cc: torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Oleg Nesterov wrote:
> Yes, yes, and I already tried to comment this part. We probably need a
> dedicated kernel thread, but I still think (although I am not sure) that
> initial change can use workueue. In the likely case system_unbound_wq pool
> should have an idle thread, if not - OK, this change won't help in this
> case. This is minor.
> 
I imagined a dedicated kernel thread doing something like shown below.
(I don't know about mm->mmap management.)
mm->mmap_zapped corresponds to MMF_MEMDIE.
I think this kernel thread can be used for normal kill(pid, SIGKILL) cases.

----------
bool has_sigkill_task;
wait_queue_head_t kick_mm_zapper;

static void mm_zapper(void *unused)
{
	struct task_struct *g, *p;
	struct mm_struct *mm;

sleep:
	wait_event(kick_remover, has_sigkill_task);
	has_sigkill_task = false;
restart:
	rcu_read_lock();
	for_each_process_thread(g, p) {
		if (likely(!fatal_signal_pending(p)))
			continue;
		task_lock(p);
		mm = p->mm;
		if (mm && mm->mmap && !mm->mmap_zapped && down_read_trylock(&mm->mmap_sem)) {
			atomic_inc(&mm->mm_users);
			task_unlock(p);
			rcu_read_unlock();
			if (mm->mmap && !mm->mmap_zapped)
				zap_page_range(mm->mmap, 0, TASK_SIZE, NULL);
			mm->mmap_zapped = 1;
			up_read(&mm->mmap_sem);
			mmput(mm);
			cond_resched();
			goto restart;
		}
		task_unlock(p);
	}
	rcu_read_unlock();
	goto sleep;
}

kthread_run(mm_zapper, NULL, "mm_zapper");
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

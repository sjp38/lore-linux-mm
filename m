Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 331246B0033
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 11:56:41 -0400 (EDT)
Date: Tue, 23 Apr 2013 17:56:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-ID: <20130423155638.GJ8001@dhcp22.suse.cz>
References: <1366643184-3627-1-git-send-email-dserrg@gmail.com>
 <20130422195138.GB31098@dhcp22.suse.cz>
 <20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dserrg <dserrg@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>, Oleg Nesterov <oleg@redhat.com>

[CCing Oleg]

On Tue 23-04-13 19:26:14, dserrg wrote:
> On Mon, 22 Apr 2013 21:51:38 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Mon 22-04-13 19:06:24, Sergey Dyasly wrote:
> > > Currently, fatal_signal_pending() check is issued only for task that invoked
> > > oom killer. Add the same check for oom killer's chosen victim.
> > > 
> > > This eliminates regression with killing multithreaded processes which was
> > > introduced by commit 6b0c81b3be114a93f79bd4c5639ade5107d77c21
> > > (mm, oom: reduce dependency on tasklist_lock). When one of threads
> > > was oom-killed, other threads could also become victims of oom killer, which
> > > can cause an infinite loop.
> > > 
> > > There is a race with task->thread_group RCU protected list deletion/iteration:
> > > now only a reference to a chosen thread of dying threadgroup is held, so when
> > > the thread doesn't have PF_EXITING flag yet and dump_header() is called
> > > to print info, it already has SIGKILL and can call do_exit(), which removes
> > > the thread from the thread_group list. After printing info, oom killer
> > > is doing while_each_thread() on this thread and it still has next reference
> > > to some other thread, but no other thread has next reference to this one.
> > > This causes the infinite loop with tasklist_lock read held.
> > 
> > I am not sure I understand the race you are describing here.
> > release_task calls __exit_signal with tasklist_lock held for write. And
> > we are holding the very same lock for reading around while_each_thread
> > in oom_kill_process.
> 
> Yes, we are holding tasklist_lock when iterating, but the thread can be deleted
> from thread_group list _before_ that. In this case, while_each_thread loop exit
> condition will never be true.
> 
> Imagine the following situation:
> Threadgroup with 4 threads: thread_1, thread_2, thread_3, thread_4.
> 
> thread_1 is oom killed and SIGKILL is sent to all threads.
> 
> allocation --> no memory --> invoke oom killer
> oom killer selects thread_2 as victim:
> 
> 
>            OOM killer               |              thread_2
>                                     |
>   oom_kill_process(thread_2)        |
>       thread_2 has PF_EXITING? no   |      (but has pending SIGKILL)
>       dump_header()                 |
>                                     |
>                                     |      do_exit()
>                                     |          sets PF_EXITING
>                                     |          list_del_rcu(thread_group)
>                                     |
>       read_lock(tasklist_lock)      |
>       while_each_thread()           |
> 
> Iteration order: thread_2 --> thread_3 --> thread_4 --> thread_3 --> thread_4...
> This will never reach thread_2 again and break loop, as result: infinite loop.

Oleg, is there anything that would prevent from this race? Maybe we need
to call thread_group_empty before?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

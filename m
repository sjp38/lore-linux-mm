Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AB0706B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 21:47:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5A1lULM018009
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Jun 2010 10:47:30 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F057C45DE50
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:47:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C971D45DE4F
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:47:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B2B7D1DB803B
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:47:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E0A01DB8037
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:47:29 +0900 (JST)
Date: Thu, 10 Jun 2010 10:43:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
Message-Id: <20100610104309.f7559f31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100610012101.GA5412@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
	<20100608202611.GA11284@redhat.com>
	<alpine.DEB.2.00.1006082330160.30606@chino.kir.corp.google.com>
	<20100609162523.GA30464@redhat.com>
	<alpine.DEB.2.00.1006091241330.26827@chino.kir.corp.google.com>
	<20100609201430.GA8210@redhat.com>
	<20100610091547.d2c88d4c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100610012101.GA5412@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010 03:21:01 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> On 06/10, KAMEZAWA Hiroyuki wrote:
> >
> > On Wed, 9 Jun 2010 22:14:30 +0200
> > Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > > > in this case since it would
> > > > not be allocating memory without p->mm.
> > >
> > > This thread will not allocate the memory, yes. But its sub-threads can.
> > > And select_bad_process() can constantly return the same (dead) thread P,
> > > badness() inspects ->mm under find_lock_task_mm() which finds the thread
> > > with the valid ->mm.
> > >
> > > OK. Probably this doesn't matter. I don't know if task_in_mem_cgroup(task)
> > > was fixed or not, but currently it also looks at task->mm and thus have
> > > the same boring problem: it is trivial to make the memory-hog process
> > > invisible to oom. Unless I missed something, of course.
> >
> > HmHm...your concern is that there is a case when mem_cgroup_out_of_memory()
> > can't kill anything ?
> 
> Or it can kill the wrong task. But once again, I am only speculating
> looking at the current code.
> 
> > Now, memcg doesn't return -ENOMEM in usual case.
> > So, it loops until there are some available memory under its limit.
> > Then, if memory_cgroup_out_of_memory() can kill a process in several trial,
> > we'll not have terrible problem. (even if it's slow.)
> >
> > Hmm. What I can't understand is whether there is a case when PF_EXITING
> > thread never exit. If so, we need some care (in memcg?)
> 
> 	void *thread_func(void *)
> 	{
> 		for (;;)
> 			malloc();
> 	}
> 
> 	int main(void)
> 	{
> 		pthread_create(..., thread_func, ...);
> 		pthread_exit();
> 	}
> 
> This process runs with the dead group-leader (PF_EXITING is set, ->mm == NULL).
> mem_cgroup_out_of_memory()->select_bad_process() can't see it due to
> task_in_mem_cgroup() check.
> 
> Afaics
> 
> 	- task_in_mem_cgroup() should use find_lock_task_mm() too
> 
> 	- oom_kill_process() should check "PF_EXITING && p->mm",
> 	  like select_bad_process() does.
> 

Hm. I'd like to look into that when the next mmotm is shipped.
(too many pactches in flight..)

The problem is
  
  for (walking each 'process') 
	if (task_in_mem_cgroup(p, memcg))

 can't check 'p' containes threads belongs to given memcg because p->mm can
 be NULL. So, task_in_mem_cgroup should call find_lock_task_mm() when
 getting "mm" struct.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

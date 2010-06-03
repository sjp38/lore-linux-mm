Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EB1C26B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:06:10 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o53068ro005779
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 09:06:08 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5703145DE4E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:06:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F392245DE56
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:06:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7414E1DB804C
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:06:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DED41DB8044
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:06:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] oom: dump_tasks() use find_lock_task_mm() too
In-Reply-To: <20100602150304.GA5326@barrios-desktop>
References: <20100601145033.2446.A69D9226@jp.fujitsu.com> <20100602150304.GA5326@barrios-desktop>
Message-Id: <20100603084829.7234.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 09:06:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi

> > @@ -344,35 +344,30 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >   */
> >  static void dump_tasks(const struct mem_cgroup *mem)
> >  {
> > -	struct task_struct *g, *p;
> > +	struct task_struct *p;
> > +	struct task_struct *task;
> >  
> >  	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
> >  	       "name\n");
> > -	do_each_thread(g, p) {
> > +
> > +	for_each_process(p) {
> >  		struct mm_struct *mm;
> >  
> > -		if (mem && !task_in_mem_cgroup(p, mem))
> > +		if (is_global_init(p) || (p->flags & PF_KTHREAD))
> 
> select_bad_process needs is_global_init check to not select init as victim.
> But in this case, it is just for dumping information of tasks. 

But dumping oom unrelated process is useless and making confusion.
Do you have any suggestion? Instead, adding unkillable field?


> 
> >  			continue;
> > -		if (!thread_group_leader(p))
> > +		if (mem && !task_in_mem_cgroup(p, mem))
> >  			continue;
> >  
> > -		task_lock(p);
> > -		mm = p->mm;
> > -		if (!mm) {
> > -			/*
> > -			 * total_vm and rss sizes do not exist for tasks with no
> > -			 * mm so there's no need to report them; they can't be
> > -			 * oom killed anyway.
> > -			 */
> 
> Please, do not remove the comment for mm newbies unless you think it's useless.

How is this?

               task = find_lock_task_mm(p);
               if (!task)
                        /*
                         * Probably oom vs task-exiting race was happen and ->mm
                         * have been detached. thus there's no need to report them;
                         * they can't be oom killed anyway.
                         */
                        continue;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

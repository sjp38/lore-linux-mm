Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AAF416B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:41:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o530fsZo006361
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 09:41:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8784645DE82
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:41:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 321D845DE6F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:41:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C9FCA1DB803F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:41:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F8E31DB803E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:41:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] oom: dump_tasks() use find_lock_task_mm() too
In-Reply-To: <AANLkTilBq_dRXW1u56gbqc3Z5fU1I66UiFiQbbRU_2Ur@mail.gmail.com>
References: <20100603084829.7234.A69D9226@jp.fujitsu.com> <AANLkTilBq_dRXW1u56gbqc3Z5fU1I66UiFiQbbRU_2Ur@mail.gmail.com>
Message-Id: <20100603093548.7237.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  3 Jun 2010 09:41:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On Thu, Jun 3, 2010 at 9:06 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hi
> >
> >> > @@ -344,35 +344,30 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >> > A  */
> >> > A static void dump_tasks(const struct mem_cgroup *mem)
> >> > A {
> >> > - A  struct task_struct *g, *p;
> >> > + A  struct task_struct *p;
> >> > + A  struct task_struct *task;
> >> >
> >> > A  A  printk(KERN_INFO "[ pid ] A  uid A tgid total_vm A  A  A rss cpu oom_adj "
> >> > A  A  A  A  A  A "name\n");
> >> > - A  do_each_thread(g, p) {
> >> > +
> >> > + A  for_each_process(p) {
> >> > A  A  A  A  A  A  struct mm_struct *mm;
> >> >
> >> > - A  A  A  A  A  if (mem && !task_in_mem_cgroup(p, mem))
> >> > + A  A  A  A  A  if (is_global_init(p) || (p->flags & PF_KTHREAD))
> >>
> >> select_bad_process needs is_global_init check to not select init as victim.
> >> But in this case, it is just for dumping information of tasks.
> >
> > But dumping oom unrelated process is useless and making confusion.
> > Do you have any suggestion? Instead, adding unkillable field?
> 
> I think it's not unrelated. Of course, init process doesn't consume
> lots of memory but might consume more memory than old as time goes by
> or some BUG although it is unlikely.
> 
> I think whether we print information of init or not isn't a big deal.
> But we have been done it until now and you are trying to change it.
> At least, we need some description why you want to remove it.
> Making confusion? Hmm.. I don't think it make many people confusion.

Hm. ok, I'll change logic as you said.



> >> > - A  A  A  A  A  mm = p->mm;
> >> > - A  A  A  A  A  if (!mm) {
> >> > - A  A  A  A  A  A  A  A  A  /*
> >> > - A  A  A  A  A  A  A  A  A  A * total_vm and rss sizes do not exist for tasks with no
> >> > - A  A  A  A  A  A  A  A  A  A * mm so there's no need to report them; they can't be
> >> > - A  A  A  A  A  A  A  A  A  A * oom killed anyway.
> >> > - A  A  A  A  A  A  A  A  A  A */
> >>
> >> Please, do not remove the comment for mm newbies unless you think it's useless.
> >
> > How is this?
> >
> > A  A  A  A  A  A  A  task = find_lock_task_mm(p);
> > A  A  A  A  A  A  A  if (!task)
> > A  A  A  A  A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  A  A  A  A  * Probably oom vs task-exiting race was happen and ->mm
> > A  A  A  A  A  A  A  A  A  A  A  A  * have been detached. thus there's no need to report them;
> > A  A  A  A  A  A  A  A  A  A  A  A  * they can't be oom killed anyway.
> > A  A  A  A  A  A  A  A  A  A  A  A  */
> > A  A  A  A  A  A  A  A  A  A  A  A continue;
> >
> 
> Looks good to adding story about racing. but my point was "total_vm
> and rss sizes do not exist for tasks with no mm". But I don't want to
> bother you due to trivial.
> It depends on you. :)


old ->mm check have two intention.

   a) the task is kernel thread?
   b) the task have alredy detached ->mm

but a) is not strictly correct check because we should think use_mm(). 
therefore we appended PF_KTHREAD check. then, here find_lock_task_mm()
focus exiting race, I think.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

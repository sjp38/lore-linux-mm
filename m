Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 59ADF6B01B2
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 20:06:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o61074Ca014282
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 1 Jul 2010 09:07:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A786745DE6E
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60A3145DE6F
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 24D7C1DB8037
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AFF0D1DB803A
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 03/11] oom: make oom_unkillable_task() helper function
In-Reply-To: <20100630141944.GE15644@barrios-desktop>
References: <20100630182752.AA4E.A69D9226@jp.fujitsu.com> <20100630141944.GE15644@barrios-desktop>
Message-Id: <20100701085648.DA19.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu,  1 Jul 2010 09:07:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 30, 2010 at 06:28:37PM +0900, KOSAKI Motohiro wrote:
> > Now, we have the same task check in two places. Unify it.
> > 
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/oom_kill.c |   33 ++++++++++++++++++++++-----------
> >  1 files changed, 22 insertions(+), 11 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index dc8589e..a4a5439 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -101,6 +101,26 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
> >  	return NULL;
> >  }
> >  
> > +/* return true if the task is not adequate as candidate victim task. */
> > +static bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *mem,
> > +			   const nodemask_t *nodemask)
> > +{
> > +	if (is_global_init(p))
> > +		return true;
> > +	if (p->flags & PF_KTHREAD)
> > +		return true;
> > +
> > +	/* When mem_cgroup_out_of_memory() and p is not member of the group */
> > +	if (mem && !task_in_mem_cgroup(p, mem))
> > +		return true;
> > +
> > +	/* p may not have freeable memory in nodemask */
> > +	if (!has_intersects_mems_allowed(p, nodemask))
> > +		return true;
> > +
> > +	return false;
> > +}
> > +
> 
> I returend this patch as review 7/11. 
> Why didn't you check p->signal->oom_adj == OOM_DISABLE in here?
> I don't figure out code after your patches are applied totally.
> But I think it would be check it in this function as function's name says.

For preserve select_bad_process() semantics. It have

        for_each_process(p) {
                if (oom_unkillable_task(p, mem, nodemask))
			continue;

                if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
                        if (p != current)
                                return ERR_PTR(-1UL);

                        chosen = p;
                        *ppoints = ULONG_MAX;
                }

	        if (oom_adj == OOM_DISABLE)
			continue;

That said, Current OOM-Killer intend to kill PF_EXITING process even if
it have OOM_DISABLE. (practically, it's not kill. it only affect to give 
allocation bonus to PF_EXITING process)

My trivial fixes series don't intend to make large semantics change.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

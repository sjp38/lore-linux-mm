Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CCDEE6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 01:50:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N5qGqm010652
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Jun 2009 14:52:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6240B45DE4E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:52:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D8CB45DE59
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:52:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 13FDC1DB8061
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:52:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AECD81DB8060
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 14:52:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Patch] mm tracepoints update - use case.
In-Reply-To: <1245683057.3212.89.camel@dhcp-100-19-198.bos.redhat.com>
References: <20090622122755.21F6.A69D9226@jp.fujitsu.com> <1245683057.3212.89.camel@dhcp-100-19-198.bos.redhat.com>
Message-Id: <20090623133230.220A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Jun 2009 14:52:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

> On Mon, 2009-06-22 at 12:37 +0900, KOSAKI Motohiro wrote:
> 
> Thanks for the feedback KOSAKI!
> 
> 
> > > Larry Woodman wrote:
> > > 
> > > >> - Please don't display mm and/or another kernel raw pointer.
> > > >>   if we assume non stop system, we can't use kernel-dump. Thus kernel pointer
> > > >>   logging is not so useful.
> > > > 
> > > > OK, I just dont know how valuable the trace output is with out some raw
> > > > data like the mm_struct.
> > > 
> > > I believe that we do want something like the mm_struct in
> > > the trace info, so we can figure out which process was
> > > allocating pages, etc...
> > 
> > Yes.
> > I think we need to print tgid, it is needed to imporove CONFIG_MM_OWNER.
> > current CONFIG_MM_OWNER back-pointer point to semi-random task_struct.
> 
> All of the tracepoints contain command, pid, CPU and timestamp and
> tracepoint name information.  Are you saying I should capture more
> information in specific mm tracepoints like the tgid and if the answer
> is yes, what would we need this for?
> 
> 
> cat-10962 [005]  1877.984589: mm_anon_fault:
> cat-10962 [005]  1877.984638: mm_anon_fault:
> cat-10962 [005]  1877.984658: sched_switch:
> cat-10962 [005]  1877.988359: sched_switch:

this is sufficient in almost cause. but there are few exception.

ftrace common header logged current->pid, but kswapd steal the page
from another process. we interest victim process, not kswapd pid.
(e.g. Please see your trace_mm_anon_unmap())


> > > >> - Please consider how do this feature works on mem-cgroup.
> > > >>   (IOW, please don't ignore many "if (scanning_global_lru())")
> > > 
> > > Good point, we want to trace cgroup vs non-cgroup reclaims,
> > > too.
> > 
> > thank you.
> 
> All of the mm tracepoints are located above the cgroup specific calls.
> This means that they will capture the same exact data reguardless of
> whether cgroups are used or not.  Are you saying I should capture
> whether the data was specific to a cgroup or it was from the global
> LRUs?

Yes and No.

example, if frequently cgroup reclaim occur, it mean administrator
miss to set memory limit.
but if frequently global reclaim occur, it mean we need to add physical
memory.

I mean, cgroup or not is one of major information for making analysis.
and perhaps cgroup path name is also useful.



> > > >> - tracepoint caller shouldn't have any assumption of displaying representation.
> > > >>   e.g.
> > > >>     wrong)  trace_mm_pagereclaim_pgout(mapping, page->index<<PAGE_SHIFT, PageAnon(page));
> > > >>     good)   trace_mm_pagereclaim_pgout(mapping, page)
> > > > 
> > > > OK.
> > > > 
> > > >>   that's general and good callback and/or hook manner.
> > > 
> > > How do we figure those out from the page pointer at the time
> > > the tracepoint triggers?
> > > 
> > > I believe that it would be useful to export that info in the
> > > trace point, since we cannot expect the userspace trace tool
> > > to figure out these things from the struct page address.
> > > 
> > > Or did I overlook something here?
> > 
> > current, TRACE_EVENT have two step information trasformation.
> > 
> >  - step1 - TP_fast_assign()
> >    it is called from tracepoint directly. it makes ring-buffer representaion.
> >  - step2 - TP_printk
> >    it is called when reading debug/tracing/trace file. it makes printable
> >    representation from ring-buffer data.
> > 
> > example:
> > 
> > trace_sched_switch() has three argument, rq, prev, next.
> > 
> > --------------------------------------------------
> > static inline void
> > context_switch(struct rq *rq, struct task_struct *prev,
> >                struct task_struct *next)
> > {
> > (snip)
> >         trace_sched_switch(rq, prev, next);
> > 
> > -------------------------------------------------
> > 
> > TP_fast_assing extract data from argument pointer.
> > -----------------------------------------------------
> >         TP_fast_assign(
> >                 memcpy(__entry->next_comm, next->comm, TASK_COMM_LEN);
> >                 __entry->prev_pid       = prev->pid;
> >                 __entry->prev_prio      = prev->prio;
> >                 __entry->prev_state     = prev->state;
> >                 memcpy(__entry->prev_comm, prev->comm, TASK_COMM_LEN);
> >                 __entry->next_pid       = next->pid;
> >                 __entry->next_prio      = next->prio;
> >         ),
> > -----------------------------------------------------
> > 
> > 
> > I think mm tracepoint can do the same way.
> 
> The sched_switch tracepoint tells us the name of the outgoing and
> incomming process during a context switch so this information is very
> significant to that tracepoint.  What mm tracepoint would I need to add
> such information without it being redundant?

perhaps I missed you mean.
I only pointed out that mm tracepoint can reduce number of argument.

I don't says increase/decrease display information.


maybe my explanation was wrong. my english is very poor. sorry.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E614F6B004F
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 23:36:20 -0400 (EDT)
Date: Mon, 22 Jun 2009 12:37:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Patch] mm tracepoints update - use case.
In-Reply-To: <4A3A9844.8030004@redhat.com>
References: <1245352954.3212.67.camel@dhcp-100-19-198.bos.redhat.com> <4A3A9844.8030004@redhat.com>
Message-Id: <20090622122755.21F6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

> Larry Woodman wrote:
> 
> >> - Please don't display mm and/or another kernel raw pointer.
> >>   if we assume non stop system, we can't use kernel-dump. Thus kernel pointer
> >>   logging is not so useful.
> > 
> > OK, I just dont know how valuable the trace output is with out some raw
> > data like the mm_struct.
> 
> I believe that we do want something like the mm_struct in
> the trace info, so we can figure out which process was
> allocating pages, etc...

Yes.
I think we need to print tgid, it is needed to imporove CONFIG_MM_OWNER.
current CONFIG_MM_OWNER back-pointer point to semi-random task_struct.


> >> - Please consider how do this feature works on mem-cgroup.
> >>   (IOW, please don't ignore many "if (scanning_global_lru())")
> 
> Good point, we want to trace cgroup vs non-cgroup reclaims,
> too.

thank you.

> 
> >> - tracepoint caller shouldn't have any assumption of displaying representation.
> >>   e.g.
> >>     wrong)  trace_mm_pagereclaim_pgout(mapping, page->index<<PAGE_SHIFT, PageAnon(page));
> >>     good)   trace_mm_pagereclaim_pgout(mapping, page)
> > 
> > OK.
> > 
> >>   that's general and good callback and/or hook manner.
> 
> How do we figure those out from the page pointer at the time
> the tracepoint triggers?
> 
> I believe that it would be useful to export that info in the
> trace point, since we cannot expect the userspace trace tool
> to figure out these things from the struct page address.
> 
> Or did I overlook something here?

current, TRACE_EVENT have two step information trasformation.

 - step1 - TP_fast_assign()
   it is called from tracepoint directly. it makes ring-buffer representaion.
 - step2 - TP_printk
   it is called when reading debug/tracing/trace file. it makes printable
   representation from ring-buffer data.

example:

trace_sched_switch() has three argument, rq, prev, next.

--------------------------------------------------
static inline void
context_switch(struct rq *rq, struct task_struct *prev,
               struct task_struct *next)
{
(snip)
        trace_sched_switch(rq, prev, next);

-------------------------------------------------

TP_fast_assing extract data from argument pointer.
-----------------------------------------------------
        TP_fast_assign(
                memcpy(__entry->next_comm, next->comm, TASK_COMM_LEN);
                __entry->prev_pid       = prev->pid;
                __entry->prev_prio      = prev->prio;
                __entry->prev_state     = prev->state;
                memcpy(__entry->prev_comm, prev->comm, TASK_COMM_LEN);
                __entry->next_pid       = next->pid;
                __entry->next_prio      = next->prio;
        ),
-----------------------------------------------------


I think mm tracepoint can do the same way.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

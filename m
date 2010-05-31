Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 069D16B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 02:35:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4V6ZW0T010551
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 31 May 2010 15:35:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6355F45DE4E
	for <linux-mm@kvack.org>; Mon, 31 May 2010 15:35:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 43D2745DE4F
	for <linux-mm@kvack.org>; Mon, 31 May 2010 15:35:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 16187E18003
	for <linux-mm@kvack.org>; Mon, 31 May 2010 15:35:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C79B91DB8045
	for <linux-mm@kvack.org>; Mon, 31 May 2010 15:35:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <AANLkTimg3PuUAmUUib2pdXNyEeniccLSCEvAm9jtKNji@mail.gmail.com>
References: <20100529125136.62CA.A69D9226@jp.fujitsu.com> <AANLkTimg3PuUAmUUib2pdXNyEeniccLSCEvAm9jtKNji@mail.gmail.com>
Message-Id: <20100531152424.739D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 31 May 2010 15:35:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hi

> Hi, Kosaki.
> 
> On Sat, May 29, 2010 at 12:59 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hi
> >
> >> oom-killer: give the dying task rt priority (v3)
> >>
> >> Give the dying task RT priority so that it can be scheduled quickly and die,
> >> freeing needed memory.
> >>
> >> Signed-off-by: Luis Claudio R. GonA?alves <lgoncalv@redhat.com>
> >
> > Almostly acceptable to me. but I have two requests,
> >
> > - need 1) force_sig() 2)sched_setscheduler() order as Oleg mentioned
> > - don't boost priority if it's in mem_cgroup_out_of_memory()
> 
> Why do you want to not boost priority if it's path of memcontrol?
> 
> If it's path of memcontrol and CONFIG_CGROUP_MEM_RES_CTLR is enabled,
> mem_cgroup_out_of_memory will select victim task in memcg.
> So __oom_kill_task's target task would be in memcg, I think.

Yep.
But priority boost naturally makes CPU starvation for out of the group
processes.
It seems to break cgroup's isolation concept.

> As you and memcg guys don't complain this, I would be missing something.
> Could you explain it? :)

So, My points are, 

1) Usually priority boost is wrong idea. It have various side effect, but
   system wide OOM is one of exception. In such case, all tasks aren't 
   runnable, then, the downside is acceptable.
2) memcg have OOM notification mechanism. If the admin need priority boost,
   they can do it by their OOM-daemon.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

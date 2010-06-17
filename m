Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8D0D56B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:41 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1pd3b029649
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D2E645DE55
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 69A1145DE4F
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 215C51DB805A
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6917DE38007
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/9] oom: oom_kill_process() need to check p is unkillable
In-Reply-To: <20100616150728.GD9278@barrios-desktop>
References: <20100616203212.72E0.A69D9226@jp.fujitsu.com> <20100616150728.GD9278@barrios-desktop>
Message-Id: <20100617084416.FB36.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 16, 2010 at 08:32:45PM +0900, KOSAKI Motohiro wrote:
> > When oom_kill_allocating_task is enabled, an argument of
> > oom_kill_process is not selected by select_bad_process(), but
> > just out_of_memory() caller task. It mean the task can be
> > unkillable. check it first.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/oom_kill.c |   11 +++++++++++
> >  1 files changed, 11 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 6ca6cb8..3e48023 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -436,6 +436,17 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  	unsigned long victim_points = 0;
> >  	struct timespec uptime;
> >  
> > +	/*
> > +	 * When oom_kill_allocating_task is enabled, p can be
> > +	 * unkillable. check it first.
> > +	 */
> > +	if (is_global_init(p) || (p->flags & PF_KTHREAD))
> > +		return 1;
> > +	if (mem && !task_in_mem_cgroup(p, mem))
> > +		return 1;
> > +	if (!has_intersects_mems_allowed(p, nodemask))
> > +		return 1;
> > +
> 
> I think this check could be done before oom_kill_proces in case of
> sysctl_oom_kill_allocating_task, too. 

ok.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5976B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:41:21 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o58IfIrA020362
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:41:18 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by kpbe17.cbf.corp.google.com with ESMTP id o58IfH3V020016
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:41:17 -0700
Received: by pvc21 with SMTP id 21so420090pvc.20
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:41:17 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:41:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 02/18] oom: sacrifice child with highest badness
 score for parent
In-Reply-To: <20100606175117.8721.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081140030.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013220.29202@chino.kir.corp.google.com> <20100606175117.8721.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > Reviewers may observe that the previous implementation would iterate
> > through the children and attempt to kill each until one was successful and
> > then the parent if none were found while the new code simply kills the
> > most memory-hogging task or the parent.  Note that the only time
> > oom_kill_task() fails, however, is when a child does not have an mm or has
> > a /proc/pid/oom_adj of OOM_DISABLE.  badness() returns 0 for both cases,
> > so the final oom_kill_task() will always succeed.
> 
> probably we need to call has_intersects_mems_allowed() in this loop. likes
> 
>         /* Try to sacrifice the worst child first */
>         do {
>                 list_for_each_entry(c, &t->children, sibling) {
>                         unsigned long cpoints;
> 
>                         if (c->mm == p->mm)
>                                 continue;
>                         if (oom_unkillable(c, mem, nodemask))
>                                 continue;
> 
>                         /* oom_badness() returns 0 if the thread is unkillable */
>                         cpoints = oom_badness(c);
>                         if (cpoints > victim_points) {
>                                 victim = c;
>                                 victim_points = cpoints;
>                         }
>                 }
>         } while_each_thread(p, t);
> 
> 
> It mean we shouldn't assume parent and child have the same mems_allowed,
> perhaps.
> 

I'd be happy to have that in oom_kill_process() if you pass the
enum oom_constraint and only do it for CONSTRAINT_CPUSET.  Please add a 
followup patch to my latest patch series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

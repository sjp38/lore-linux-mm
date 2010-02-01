Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35F7B6B0078
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 05:28:12 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o11AS6hG029661
	for <linux-mm@kvack.org>; Mon, 1 Feb 2010 10:28:06 GMT
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by wpaz29.hot.corp.google.com with ESMTP id o11AS402018095
	for <linux-mm@kvack.org>; Mon, 1 Feb 2010 02:28:05 -0800
Received: by pzk17 with SMTP id 17so3947729pzk.6
        for <linux-mm@kvack.org>; Mon, 01 Feb 2010 02:28:04 -0800 (PST)
Date: Mon, 1 Feb 2010 02:28:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <20100201090140.116cc704.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002010223510.12764@chino.kir.corp.google.com>
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com> <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk> <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com> <20100129163030.1109ce78@lxorguk.ukuu.org.uk>
 <5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com> <alpine.DEB.2.00.1001291258490.2938@chino.kir.corp.google.com> <20100201090140.116cc704.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, vedran.furac@gmail.com, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > >  109         /*
> > >  110          * Processes which fork a lot of child processes are likely
> > >  111          * a good choice. We add half the vmsize of the children if they
> > >  112          * have an own mm. This prevents forking servers to flood the
> > >  113          * machine with an endless amount of children. In case a single
> > >  114          * child is eating the vast majority of memory, adding only half
> > >  115          * to the parents will make the child our kill candidate of
> > > choice.
> > >  116          */
> > >  117         list_for_each_entry(child, &p->children, sibling) {
> > >  118                 task_lock(child);
> > >  119                 if (child->mm != mm && child->mm)
> > >  120                         points += child->mm->total_vm/2 + 1;
> > >  121                 task_unlock(child);
> > >  122         }
> > >  123
> > > ==
> > > This makes task launcher(the fist child of some daemon.) first victim.
> > 
> > That "victim", p, is passed to oom_kill_process() which does this:
> > 
> > 	/* Try to kill a child first */
> > 	list_for_each_entry(c, &p->children, sibling) {
> > 		if (c->mm == p->mm)
> > 			continue;
> > 		if (!oom_kill_task(c))
> > 			return 0;
> > 	}
> > 	return oom_kill_task(p);
> > 
> 
> Then, finally, per-process oom_adj(!=OOM_DISABLE) control is ignored ?
> Seems broken.
> 

No, oom_kill_task() returns 1 if the child has OOM_DISABLE set, meaning it 
never gets killed and we continue iterating through the child list.  If 
there are no children with seperate memory to kill, the selected task gets 
killed.  This prevents things from like sshd or bash from getting killed 
unless they are actually the memory leaker themselves.

It would naturally be better to select the child with the highest 
badness() score, but it only depends on the ordering of p->children at the 
moment.  That's because we only want to iterate through this potentially 
long list once, but improvements in this area (as well as sane tweaks to 
the heuristic) would certainly be welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

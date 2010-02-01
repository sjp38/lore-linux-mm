Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 72DAE6001DA
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 19:05:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o11058M9007048
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Feb 2010 09:05:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AD4F45DE54
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 09:05:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ECF845DE50
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 09:05:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D341DB803C
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 09:05:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D05AE38004
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 09:05:07 +0900 (JST)
Date: Mon, 1 Feb 2010 09:01:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100201090140.116cc704.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1001291258490.2938@chino.kir.corp.google.com>
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com>
	<20100129162137.79b2a6d4@lxorguk.ukuu.org.uk>
	<c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com>
	<20100129163030.1109ce78@lxorguk.ukuu.org.uk>
	<5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.1001291258490.2938@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, vedran.furac@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jan 2010 13:07:01 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Sat, 30 Jan 2010, KAMEZAWA Hiroyuki wrote:
> 
> > okay...I guess the cause of the problem Vedran met came from
> > this calculation.
> > ==
> >  109         /*
> >  110          * Processes which fork a lot of child processes are likely
> >  111          * a good choice. We add half the vmsize of the children if they
> >  112          * have an own mm. This prevents forking servers to flood the
> >  113          * machine with an endless amount of children. In case a single
> >  114          * child is eating the vast majority of memory, adding only half
> >  115          * to the parents will make the child our kill candidate of
> > choice.
> >  116          */
> >  117         list_for_each_entry(child, &p->children, sibling) {
> >  118                 task_lock(child);
> >  119                 if (child->mm != mm && child->mm)
> >  120                         points += child->mm->total_vm/2 + 1;
> >  121                 task_unlock(child);
> >  122         }
> >  123
> > ==
> > This makes task launcher(the fist child of some daemon.) first victim.
> 
> That "victim", p, is passed to oom_kill_process() which does this:
> 
> 	/* Try to kill a child first */
> 	list_for_each_entry(c, &p->children, sibling) {
> 		if (c->mm == p->mm)
> 			continue;
> 		if (!oom_kill_task(c))
> 			return 0;
> 	}
> 	return oom_kill_task(p);
> 

Then, finally, per-process oom_adj(!=OOM_DISABLE) control is ignored ?
Seems broken.

I think all this children-parent logic is bad.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

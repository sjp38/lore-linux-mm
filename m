Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9551E6B0078
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 05:34:03 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o11AXwsC022944
	for <linux-mm@kvack.org>; Mon, 1 Feb 2010 10:33:58 GMT
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by kpbe19.cbf.corp.google.com with ESMTP id o11AXEMH013806
	for <linux-mm@kvack.org>; Mon, 1 Feb 2010 02:33:57 -0800
Received: by pzk26 with SMTP id 26so1063061pzk.26
        for <linux-mm@kvack.org>; Mon, 01 Feb 2010 02:33:56 -0800 (PST)
Date: Mon, 1 Feb 2010 02:33:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <4B65E82D.5010408@gmail.com>
Message-ID: <alpine.DEB.2.00.1002010228360.12764@chino.kir.corp.google.com>
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com> <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk> <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com> <20100129163030.1109ce78@lxorguk.ukuu.org.uk>
 <5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com> <alpine.DEB.2.00.1001291258490.2938@chino.kir.corp.google.com> <4B642A40.1020709@gmail.com> <alpine.DEB.2.00.1001301444480.16189@chino.kir.corp.google.com> <4B65E82D.5010408@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Vedran Furac <vedran.furac@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Jan 2010, Vedran Furac wrote:

> > You snipped the code segment where I demonstrated that the selected task 
> > for oom kill is not necessarily the one chosen to die: if there is a child 
> > with disjoint memory that is killable, it will be selected instead.  If 
> > Xorg or sshd is being chosen for kill, then you should investigate why 
> > that is, but there is nothing random about how the oom killer chooses 
> > tasks to kill.
> 
> I know that it isn't random, but it sure looks like that to the end user
> and I use it to emphasize the problem. And about me investigating, that
> simply not possible as I am not a kernel hacker who understands the code
> beyond the syntax level. I can only point to the problem in hope that
> someone will fix it.
> 

Disregarding the opportunity that userspace has to influence the oom 
killer's selection for a moment, it really tends to favor killing tasks 
that are the largest in size.  Tasks that typically get the highest 
badness score are those that have the highest mm->total_vm, it's that 
simple.  There are definitely cornercases where the first generation 
children have a strong influence, but they are often killed either as a 
result of themselves being a thread group leader with seperate memory from 
the parent or as the result of the oom killer killing a task with seperate 
memory before the selected task.  It's completely natural for the oom 
killer to select bash, for example, when in actuality it will kill a 
memory leaker that has a high badness score as a result of the logic in 
oom_kill_process().

If you have specific logs that you'd like to show, please enable 
/proc/sys/vm/oom_dump_tasks and respond with them in another message with 
that data inline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

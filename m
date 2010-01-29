Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EA8466B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 16:07:11 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o0TL79xp011750
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 13:07:09 -0800
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz5.hot.corp.google.com with ESMTP id o0TL6fj8011654
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 13:07:08 -0800
Received: by pxi12 with SMTP id 12so1971983pxi.33
        for <linux-mm@kvack.org>; Fri, 29 Jan 2010 13:07:07 -0800 (PST)
Date: Fri, 29 Jan 2010 13:07:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001291258490.2938@chino.kir.corp.google.com>
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com> <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk> <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com> <20100129163030.1109ce78@lxorguk.ukuu.org.uk>
 <5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, vedran.furac@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jan 2010, KAMEZAWA Hiroyuki wrote:

> okay...I guess the cause of the problem Vedran met came from
> this calculation.
> ==
>  109         /*
>  110          * Processes which fork a lot of child processes are likely
>  111          * a good choice. We add half the vmsize of the children if they
>  112          * have an own mm. This prevents forking servers to flood the
>  113          * machine with an endless amount of children. In case a single
>  114          * child is eating the vast majority of memory, adding only half
>  115          * to the parents will make the child our kill candidate of
> choice.
>  116          */
>  117         list_for_each_entry(child, &p->children, sibling) {
>  118                 task_lock(child);
>  119                 if (child->mm != mm && child->mm)
>  120                         points += child->mm->total_vm/2 + 1;
>  121                 task_unlock(child);
>  122         }
>  123
> ==
> This makes task launcher(the fist child of some daemon.) first victim.

That "victim", p, is passed to oom_kill_process() which does this:

	/* Try to kill a child first */
	list_for_each_entry(c, &p->children, sibling) {
		if (c->mm == p->mm)
			continue;
		if (!oom_kill_task(c))
			return 0;
	}
	return oom_kill_task(p);

which prevents your example of the task launcher from getting killed 
unless it itself is using such an egregious amount of memory that its VM 
size has caused the heuristic to select the daemon in the first place.  
We only look at a single level of children, and attempt to kill one of 
those children not sharing memory with the selected task first, so your 
example is exaggerated for dramatic value.

The oom killer has been doing this for years and I haven't noticed a huge 
surge in complaints about it killing X specifically because of that code 
in oom_kill_process().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

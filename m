Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9E86B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 19:22:03 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o1C0LxJP031464
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 00:21:59 GMT
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by spaceape14.eur.corp.google.com with ESMTP id o1C0LvwI019294
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:21:58 -0800
Received: by pzk41 with SMTP id 41so4734260pzk.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:21:57 -0800 (PST)
Date: Thu, 11 Feb 2010 16:21:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 7/7 -mm] oom: remove unnecessary code and cleanup
In-Reply-To: <20100212091237.adb94384.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002111619370.13384@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100230010.8001@chino.kir.corp.google.com> <20100212091237.adb94384.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > Remove the redundancy in __oom_kill_task() since:
> > 
> >  - init can never be passed to this function: it will never be PF_EXITING
> >    or selectable from select_bad_process(), and
> > 
> >  - it will never be passed a task from oom_kill_task() without an ->mm
> >    and we're unconcerned about detachment from exiting tasks, there's no
> >    reason to protect them against SIGKILL or access to memory reserves.
> > 
> > Also moves the kernel log message to a higher level since the verbosity
> > is not always emitted here; we need not print an error message if an
> > exiting task is given a longer timeslice.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> If you say "never", it's better to add BUG_ON() rather than 
> if (!p->mm)...
> 

As the description says, oom_kill_task() never passes __oom_kill_task() a 
task, p, where !p->mm, but it doesn't imply that p cannot detach its ->mm 
before __oom_kill_task() gets a chance to run.  The point is that we don't 
really care about giving it access to memory reserves anymore since it's 
exiting and won't be allocating anything.  Warning about that scenario is 
unnecessary and would simply spam the kernel log, a recall to the oom 
killer would no longer select this task in case the oom condition persists 
anyway.

> But yes, this patch seesm to remove unnecessary codes.
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

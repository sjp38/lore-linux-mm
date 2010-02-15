Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C60386B0083
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:15:41 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o1FMFkWB022432
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 22:15:47 GMT
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by kpbe20.cbf.corp.google.com with ESMTP id o1FMFjoH022137
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:15:45 -0800
Received: by pzk36 with SMTP id 36so6364290pzk.23
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:15:45 -0800 (PST)
Date: Mon, 15 Feb 2010 14:15:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 5/7 -mm] oom: replace sysctls with quick mode
In-Reply-To: <20100215170634.729E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002151411530.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100229250.8001@chino.kir.corp.google.com> <20100215170634.729E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010, KOSAKI Motohiro wrote:

> > Two VM sysctls, oom dump_tasks and oom_kill_allocating_task, were
> > implemented for very large systems to avoid excessively long tasklist
> > scans.  The former suppresses helpful diagnostic messages that are
> > emitted for each thread group leader that are candidates for oom kill
> > including their pid, uid, vm size, rss, oom_adj value, and name; this
> > information is very helpful to users in understanding why a particular
> > task was chosen for kill over others.  The latter simply kills current,
> > the task triggering the oom condition, instead of iterating through the
> > tasklist looking for the worst offender.
> > 
> > Both of these sysctls are combined into one for use on the aforementioned
> > large systems: oom_kill_quick.  This disables the now-default
> > oom_dump_tasks and kills current whenever the oom killer is called.
> > 
> > The oom killer rewrite is the perfect opportunity to combine both sysctls
> > into one instead of carrying around the others for years to come for
> > nothing else than legacy purposes.
> 
> "_quick" is always bad sysctl name.

Why?  It does exactly what it says: it kills current without doing an 
expensive tasklist scan and suppresses the possibly long tasklist dump.  
That's the oom killer's "quick mode."

> instead, turnning oom_dump_tasks on
> by default is better.
> 

It's now on by default and can be disabled by enabling oom_kill_quick.

> plus, this patch makes unnecessary compatibility issue.
> 

It's the perfect opportunity when totally rewriting the oom killer to 
combine two sysctls with the exact same users into one.  Users will notice 
that the tasklist is always dumped now (we're defaulting oom_dump_tasks 
to be enabled), so there is no reason why we can't remove oom_dump_tasks, 
we're just giving them a new way to disable it.  oom_kill_allocating_task 
no longer always means what it once did: with the mempolicy-constrained 
oom rewrite, we now iterate the tasklist for such cases to kill a task.  
So users need to reassess whether this should be set if all tasks on the 
system are constrained by mempolicies, a typical configuration for 
extremely large systems.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

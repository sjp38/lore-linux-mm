Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 07DD76B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:38:05 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o58Ibx3e007308
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:38:00 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by kpbe16.cbf.corp.google.com with ESMTP id o58IbwR3031940
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:37:58 -0700
Received: by pwj6 with SMTP id 6so226050pwj.8
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:37:58 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:37:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same
 cpuset
In-Reply-To: <20100606170713.8718.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081135510.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com> <20100606170713.8718.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > @@ -267,6 +259,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >  			continue;
> >  		if (mem && !task_in_mem_cgroup(p, mem))
> >  			continue;
> > +		if (!has_intersects_mems_allowed(p))
> > +			continue;
> >  
> >  		/*
> >  		 * This task already has access to memory reserves and is
> 
> now we have three places of oom filtering
>   (1) select_bad_process

Done.

>   (2) dump_tasks

dump_tasks() has never filtered on this, it's possible for tasks is other 
cpusets to allocate memory on our nodes.

>   (3) oom_kill_task (when oom_kill_allocating_task==1 only)
> 

Why would care about cpuset attachment in oom_kill_task()?  You mean 
oom_kill_process() to filter the children list?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

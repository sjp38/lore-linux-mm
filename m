Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7D66B0087
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 21:26:00 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o2H1LQa9025963
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:21:27 -0700
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by kpbe20.cbf.corp.google.com with ESMTP id o2H1LOPU002869
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:21:25 -0700
Received: by pxi11 with SMTP id 11so389884pxi.16
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:21:24 -0700 (PDT)
Date: Tue, 16 Mar 2010 18:21:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 00/10 -mm v3] oom killer rewrite
In-Reply-To: <20100312164642.2757ec6c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003161813340.14676@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com> <20100312164642.2757ec6c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010, KAMEZAWA Hiroyuki wrote:

> One question. Assume a host A and B. A has 4G memory, B has 8G memory.
> 
> Here, an applicaton which consumes 2G memory.
> 
> Then, this application's oom_score will be 500 on A, 250 on B.
> 

Right.

> How admin detemine the best oom_score_adj value ? Does it depend on envrionment
> even if runnning the same application ?
> 

Yes, because the idea of /proc/pid/oom_score_adj is to allow userspace to 
both set priorities for oom killing and also define when a task has become 
a memory leaker (i.e. using far more memory than expected).  You can't use 
a quantity of memory to either prefer or bias an application because you 
don't know its memory usage in context of the system, memcg, mempolicy, or 
cpuset: a bias of 1G would mean "always kill this task" in a cpuset with a 
512MB node whereas it would mean relatively nothing on a 64GB machine.  
With a proportion, however, you could easily set a oom_score_adj of 250, 
for example, to say this application should be penalized 25% of available 
memory regardless of whether that's the entire system or a "virtual 
system" consisting of a cpuset, memcg, or mempolicy.

It would obviously be trivial to add another /proc/pid knob that would 
calculate the value for you given a quantity based on the memory 
constraints of pid, I'm not against that addition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

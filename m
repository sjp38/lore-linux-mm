Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A2A526B01CC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:54:24 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o5LKsJ1H023625
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:54:19 -0700
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by wpaz1.hot.corp.google.com with ESMTP id o5LKsIRb025532
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:54:18 -0700
Received: by pxi15 with SMTP id 15so452705pxi.16
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:54:17 -0700 (PDT)
Date: Mon, 21 Jun 2010 13:54:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 18/18] oom: deprecate oom_adj tunable
In-Reply-To: <20100621194943.B536.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006211347570.31743@chino.kir.corp.google.com>
References: <20100613201922.619C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162034330.21446@chino.kir.corp.google.com> <20100621194943.B536.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010, KOSAKI Motohiro wrote:

> > Of course it does, it actually has units whereas oom_adj only grows or 
> > shrinks the badness score exponentially.  oom_score_adj's units are well 
> > understood: on a machine with 4G of memory, 250 means we're trying to 
> > prejudice it by 1G of memory so that can be used by other tasks, -250 
> > means other tasks should be prejudiced by 1G in comparison to this task, 
> > etc.  It's actually quite powerful.
> 
> And, no real user want such power.
> 

Google does, and I imagine other users will want to be able to normalize 
each task's memory usage against the others.  It's perfectly legitimate 
for one task to consume 3G while another consumes 1G and want to select 
the 1G task to kill.  Setting the 3G task's oom_score_adj value in this 
case to be -250, for example, depending on the memory capacity of the 
machine, makes much more sense than influencing it as a bitshift on 
top of a vastly unpredictable heuristic with oom_adj.  This seems rather 
trivial to understand.

> When we consider desktop user case, End-users don't use oom_adj by themself.
> their application are using it.  It mean now oom_adj behave as syscall like
> system interface, unlike kernel knob. application developers also don't 
> need oom_score_adj because application developers don't know end-users 
> machine mem size.
> 

I agree, oom_score_adj isn't targeted to the desktop nor is it targeted to 
application developers (unless they are setting it to OOM_SCORE_ADJ_MIN to 
disable oom killing for that task, for example).  It's targeted at 
sysadmins and daemons that partition a machine to run a number of 
concurrent jobs.  It's fine to use memcg, for example, to do such 
partitioning, but memcg can also cause oom conditions with the cgroup.  We 
want to be able to tell the kernel, through an interface such as this, 
that one task shouldn't killed because it's expected to use 3G of memory 
but should be killed when it's using 8G, for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

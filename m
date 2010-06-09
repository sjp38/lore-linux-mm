Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 91F926B01E1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 21:07:10 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o59176QI021326
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 18:07:07 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz21.hot.corp.google.com with ESMTP id o59175U7003550
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 18:07:05 -0700
Received: by pvg7 with SMTP id 7so2244140pvg.39
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 18:07:04 -0700 (PDT)
Date: Tue, 8 Jun 2010 18:07:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same
 cpuset
In-Reply-To: <20100608170630.80753ed1.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081802380.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com> <20100607084024.873B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006081141330.18848@chino.kir.corp.google.com>
 <20100608162513.c633439e.akpm@linux-foundation.org> <alpine.DEB.2.00.1006081654020.19582@chino.kir.corp.google.com> <20100608170630.80753ed1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > Tasks that do not share the same set of allowed nodes with the task that
> > triggered the oom should not be considered as candidates for oom kill.
> > 
> > Tasks in other cpusets with a disjoint set of mems would be unfairly
> > penalized otherwise because of oom conditions elsewhere; an extreme
> > example could unfairly kill all other applications on the system if a
> > single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> > more memory than allowed.
> 
> OK, so Nick's change didn't anticipate things being set to OOM_DISABLE?
> 

I wrote out a more elaborate rebuttal to this in your reply to my latest 
patchset, but not strictly eliminating these tasks from consideration 
unfairly penalizes tasks in other cpusets simply because their big, 
there's no way to understand the scale of other cpusets compared to 
current's with a single divide in the heuristic (in this case, divide by 
8), and there's no guarantee that killing such a task would free any 
memory which would have two results: (i) we need to reinvoke the oom 
killer to kill yet another task, and (ii) we've now unnecessarily killed a 
task simply because it was large and probably lost a substantial amount of 
work.

> OOM_DISABLE seems pretty dangerous really - allows malicious
> unprivileged users to go homicidal?
> 

OOM_DISABLE doesn't get set without CAP_SYS_RESOURCE, you need that 
capability to decrease an oom_adj value.  So my changelog could probably 
benefit from s/user/job/.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B0BFA6B01DF
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:25:35 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o590PXQn026009
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:25:33 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz1.hot.corp.google.com with ESMTP id o590PEoV027716
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:25:32 -0700
Received: by pzk33 with SMTP id 33so5554763pzk.17
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 17:25:31 -0700 (PDT)
Date: Tue, 8 Jun 2010 17:25:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100608132339.54db2317.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081718240.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524310.32225@chino.kir.corp.google.com> <20100608132339.54db2317.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
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
> > 
> > Killing tasks outside of current's cpuset rarely would free memory for
> > current anyway.  To use a sane heuristic, we must ensure that killing a
> > task would likely free memory for current and avoid needlessly killing
> > others at all costs just because their potential memory freeing is
> > unknown.  It is better to kill current than another task needlessly.
> 
> This is all a bit arbitrary, isn't it?  The key word here is "rarely". 

"rarely" certainly is an arbitrary term in this case because it depends 
heavily on the memory usage of other cpuset's on the system.  Consider a 
cpuset with 16G of memory and a single task which consumes most of that 
memory.  Then consider a cpuset with a single 1G node and a task that ooms 
within it; the 16G task in the other cpuset gets killed.

There must either be a complete exclusion or inclusion of a task for 
candidacy if the scale of memory usage amongst our cpusets cannot be 
properly attributed with a single heuristic (such as divide by 4, divide 
by 8, etc).  To me, it never seems approprate to penalize another cpuset's 
tasks by the small chance that it may have allocated atomic memory 
elsewhere or the nodes have been recently changed.  The goal is to be more 
predictable about oom killing decisions without negatively impacting other 
cpusets, and this is a step in that direction.

> If indeed this task had allocated gobs of memory from `current's nodes
> and then sneakily switched nodes, this will be a big regression!
> 

It could be, but that's the fault of userspace for allocating a node that 
is almost full to a new cpuset and expecting it to be completely free.  In 
other words, we can arrange our cpusets with mems however we want but 
we need some guarantee that giving a cpuset completely free memory and 
then killing a task within it because another cpuset went oom doesn't 
happen.

> So..  It's not completely clear to me how we justify this decision. 
> Are we erring too far on the side of keep-tasks-running?  Is failing to
> clear the oom a lot bigger problem than killing an innocent task?  I
> think so.  In which case we should err towards slaughtering the
> innocent?
> 

The one thing we know is that if the victim's mems_allowed is truly 
disjoint from current that there's no guarantee we'll be freeing memory at 
all.  And if we free any, it's the result of the GFP_ATOMIC allocations 
that are allowed anywhere or was previously allocated on one of current's 
mems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

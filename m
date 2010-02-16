Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B3A076B0093
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:47:02 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o1G8kwH1016080
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 08:46:58 GMT
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz29.hot.corp.google.com with ESMTP id o1G8kuwP027073
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:46:57 -0800
Received: by pwj4 with SMTP id 4so645789pwj.8
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:46:56 -0800 (PST)
Date: Tue, 16 Feb 2010 00:46:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100216110859.72C6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002160043530.17122@chino.kir.corp.google.com>
References: <20100215115154.727B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com> <20100216110859.72C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KOSAKI Motohiro wrote:

> > We now determine whether an allocation is constrained by a cpuset by 
> > iterating through the zonelist and checking 
> > cpuset_zone_allowed_softwall().  This checks for the necessary cpuset 
> > restrictions that we need to validate (the GFP_ATOMIC exception is 
> > irrelevant, we don't call into the oom killer for those).  We don't need 
> > to kill outside of its cpuset because we're not guaranteed to find any 
> > memory on those nodes, in fact it allows for needless oom killing if a 
> > task sets all of its threads to have OOM_DISABLE in its own cpuset and 
> > then runs out of memory.  The oom killer would have killed every other 
> > user task on the system even though the offending application can't 
> > allocate there.  That's certainly an undesired result and needs to be 
> > fixed in this manner.
> 
> But this explanation is irrelevant and meaningless. CPUSET can change
> restricted node dynamically. So, the tsk->mempolicy at oom time doesn't
> represent the place of task's usage memory. plus, OOM_DISABLE can 
> always makes undesirable result. it's not special in this case.
> 

It depends whether memory_migrate is set or not when changing a cpuset's 
set of mems.  The point is that we cannot penalize tasks in cpusets with a 
disjoint set of mems because another cpuset is out of memory.  Unless a 
candidate task will definitely free memory on a node that the zonelist 
allows, we should not consider it because it may needlessly kill that 
task, it would be better to kill current.  Otherwise, our badness() 
heuristic cannot possibly determine the optimal task to kill, anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

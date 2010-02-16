Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 581226B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 04:10:54 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o1G9AoMZ020231
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:10:50 GMT
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by spaceape9.eur.corp.google.com with ESMTP id o1G9Am2Z007819
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:10:49 -0800
Received: by pzk17 with SMTP id 17so4845253pzk.4
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:10:48 -0800 (PST)
Date: Tue, 16 Feb 2010 01:10:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100216090408.GL5723@laptop>
Message-ID: <alpine.DEB.2.00.1002160105320.17122@chino.kir.corp.google.com>
References: <20100215115154.727B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com> <20100216110859.72C6.A69D9226@jp.fujitsu.com> <20100216070344.GF5723@laptop> <alpine.DEB.2.00.1002160047340.17122@chino.kir.corp.google.com>
 <20100216090408.GL5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Nick Piggin wrote:

> I don't really agree with your black and white view. We equally
> can't tell a lot of cases about who is pinning memory where. The
> fact is that any task can be pinning memory and the heuristic
> was specifically catering for that.
> 

That's a main source of criticism of the current heuristic: it needlessly 
kills tasks.  There is only one thing we know for certain: current is 
trying to allocate memory on its nodes.  We can either kill a task that 
is allowed that same set or current itself; there's no evidence that 
killing anything else will lead to memory freeing that will allow the 
allocation to succeed.  The heuristic will never perfectly select the task 
that it should kill 100% of the time when playing around with mempolicy 
nodes or cpuset mems, but relying on their current placement is a good 
indicator of what is more likely than not to free memory of interest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

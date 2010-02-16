Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0746B0093
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:49:20 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o1G8nImZ020005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:49:18 -0800
Received: from pxi35 (pxi35.prod.google.com [10.243.27.35])
	by wpaz13.hot.corp.google.com with ESMTP id o1G8nHth016663
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:49:17 -0800
Received: by pxi35 with SMTP id 35so896516pxi.16
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:49:16 -0800 (PST)
Date: Tue, 16 Feb 2010 00:49:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100216070344.GF5723@laptop>
Message-ID: <alpine.DEB.2.00.1002160047340.17122@chino.kir.corp.google.com>
References: <20100215115154.727B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com> <20100216110859.72C6.A69D9226@jp.fujitsu.com> <20100216070344.GF5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Nick Piggin wrote:

> Yes we do need to explain the downside of the patch. It is a
> heuristic and we can't call either approach perfect.
> 
> The fact is that even if 2 tasks are on completely disjoint
> memory policies and never _allocate_ from one another's nodes,
> you can still have one task pinning memory of the other task's
> node.
> 
> Most shared and userspace-pinnable resources (pagecache, vfs
> caches and fds files sockes etc) are allocated by first-touch
> basically.
> 
> I don't see much usage of cpusets and oom killer first hand in
> my experience, so I am happy to defer to others when it comes
> to heuristics. Just so long as we are all aware of the full
> story :)
> 

Unless you can present a heuristic that will determine how much memory 
usage a given task has allocated on nodes in current's zonelist, we must 
exclude tasks from cpusets with a disjoint set of nodes, otherwise we 
cannot determine the optimal task to kill.  There's a strong possibility 
that killing a task on a disjoint set of mems will never free memory for 
current, making it a needless kill.  That's a much more serious 
consequence than not having the patch, in my opinion, than rather simply 
killing current.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

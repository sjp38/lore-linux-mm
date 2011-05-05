Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EEDFD900001
	for <linux-mm@kvack.org>; Thu,  5 May 2011 15:33:17 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Batch locking for rmap fork/exit processing
Date: Thu,  5 May 2011 12:32:48 -0700
Message-Id: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie

012f18004da33ba67 in 2.6.36 caused a significant performance regression in 
fork/exit intensive workloads with a lot of sharing. The problem is that 
fork/exit now contend heavily on the lock of the root anon_vma.

This patchkit attempts to lower this a bit by batching the lock acquisions.
Right now the lock is taken for every shared vma individually. This
patchkit batches this and only reaquires the lock when actually needed.

When multiple processes are doing this in parallel, they will now 
spend much less time bouncing the lock cache line around. In addition
there should be also lower overhead in the uncontended case because
locks are relatively slow (not measured) 

This doesn't completely fix the regression on a 4S system, but cuts 
it down somewhat. One particular workload suffering from this gets
about 5% faster.

This is essentially a micro optimization that just tries to mitigate
the problem a bit.

Better would be to switch back to more local locking like .35 had, but I 
guess then we would be back with the old deadlocks? I was thinking also of 
adding some deadlock avoidance as an alternative.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

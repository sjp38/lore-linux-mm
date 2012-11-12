Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5708B6B0070
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:23:26 -0500 (EST)
Message-Id: <20121112160451.189715188@chello.nl>
Date: Mon, 12 Nov 2012 17:04:51 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/8] Announcement: Enhanced NUMA scheduling with adaptive affinity
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

Hi,

This series implements an improved version of NUMA scheduling, based on
the review and testing feedback we got.

Like the previous version, this code is driven by working set probing
faults (so much of the VM machinery remains) - but the subsequent
utilization of those faults and the scheduler policy has changed
substantially.

The scheduler's affinity logic has been generalized, and this allowed us
to eliminate the 'home node' concept that was needlessly restrictive.

The biggest conceptual addition, beyond the elimination of the home
node, is that the scheduler is now able to recognize 'private' versus
'shared' pages, by carefully analyzing the pattern of how CPUs touch the
working set pages. The scheduler automatically recognizes tasks that
share memory with each other (and make dominant use of that memory) -
versus tasks that allocate and use their working set privately.

This new scheduler code is then able to group tasks that are "memory
related" via their memory access patterns together: in the NUMA context
moving them on the same node if possible, and spreading them amongst
nodes if they use private memory.

Note that this adaptive NUMA affinity mechanism integrated into the
scheduler is essentially free of heuristics - only the access patterns
determine which tasks are related and grouped. As a result this adaptive
affinity code is able to move both threads and processes close(r) to
each other if they are related - and let them spread if they are not. If
a workload changes its characteristics dynamically then its scheduling
will adapt dynamically as well.

You can find the finer details in the individual patches. The series is
based on commit 02743c9c03f1 you can find in linux-next. Reviews and
testing feedback are welcome! (We'll also review some of the other
feedback we got in the last 2 weeks that we might not have reacted to
yet, please be patient.)

Next we plan to pick up bits from Mel's recent series like his page
migration patch.

Thanks,

        Peter, Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

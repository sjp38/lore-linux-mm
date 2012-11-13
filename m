Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 9937C6B0074
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 19:02:32 -0500 (EST)
Date: Tue, 13 Nov 2012 00:02:31 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/8] sched, numa, mm: Add adaptive NUMA affinity
 support
In-Reply-To: <20121112161215.782018877@chello.nl>
Message-ID: <0000013af7130ad7-95edbaf9-d31d-4258-8fc0-013d152246a2-000000@email.amazonses.com>
References: <20121112160451.189715188@chello.nl> <20121112161215.782018877@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>


On Mon, 12 Nov 2012, Peter Zijlstra wrote:

> We define 'shared memory' as all user memory that is frequently
> accessed by multiple tasks and conversely 'private memory' is
> the user memory used predominantly by a single task.

"All"? Should that not be "a memory segment that is frequently..."?

> Using this, we can construct two per-task node-vectors, 'S_i'
> and 'P_i' reflecting the amount of shared and privately used
> pages of this task respectively. Pages for which two consecutive
> 'hits' are of the same cpu are assumed private and the others
> are shared.

The classification is per task? But most tasks have memory areas
that are private and other areas where shared accesses occur. Can that be
per memory area? Private areas need to be kept with the process. Shared
areas may have to be spread across nodes if the memory area is too large.

Guess that is too complicated to determine unless we would be using vmas
which may only roughly correlate to the memory regions for which memory
policies are currently manually setup.

But then this is rather different from my expectations that I had after
reading the intro.

> We also add an extra 'lateral' force to the load balancer that
> perturbs the state when otherwise 'fairly' balanced. This
> ensures we don't get 'stuck' in a state which is fair but
> undesired from a memory location POV (see can_do_numa_run()).

We do useless moves and create additional overhead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

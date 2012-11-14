Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2F1B16B004D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 06:20:27 -0500 (EST)
Date: Wed, 14 Nov 2012 11:20:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 29/31] sched: numa: CPU follows memory
Message-ID: <20121114112022.GJ8218@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
 <1352805180-1607-30-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1352805180-1607-30-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 11:12:58AM +0000, Mel Gorman wrote:
> @@ -864,6 +1106,21 @@ void task_numa_fault(int node, int pages, bool misplaced)
>  		task_numa_placement(p);
>  }
>  
> +static void reset_ptenuma_scan(struct task_struct *p)
> +{
> +	ACCESS_ONCE(p->mm->numa_scan_seq)++;
> +	
> +	if (p->mm && p->mm->mm_balancenuma)
> +		p->mm->mm_balancenuma->mm_numa_fault_tot >>= 1;
> +	if (p->task_balancenuma) {
> +		int nid;
> +		p->task_balancenuma->task_numa_fault_tot >>= 1;
> +		for_each_online_node(nid) {
> +			p->task_balancenuma->task_numa_fault[nid] >>= 1;
> +		}
> +	}
> +}

Overnight tests indicated that cpu-follows is currently broken in this
series but a large part of the problem is a missing

p->mm->numa_scan_offset = 0;

here. means that all tasks are only considered for convergence once without
proper resetting of the scanner. It's effectly becomes the vanilla kernel
with a bunch of system CPU overhead.

Of course it's not the only problem with this patch as the overhead of
finding a proper placement is mnassive and due to the slow scanning rate,
it converges very slowly. While it's based on autonuma, autonuma did the
same job outside the context of a process so it's not exactly equivalent.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 075316B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:07:56 -0400 (EDT)
Date: Fri, 17 Jun 2011 21:07:05 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110617190705.GA26824@elte.hu>
References: <1308097798.17300.142.camel@schen9-DESK>
 <20110615003600.GA9602@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110615003600.GA9602@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>


* Andi Kleen <ak@linux.intel.com> wrote:

> > On 2.6.39, the contention of anon_vma->lock occupies 3.25% of cpu.
> > However, after the switch of the lock to mutex on 3.0-rc2, the mutex
> > acquisition jumps to 18.6% of cpu.  This seems to be the main cause of
> > the 52% throughput regression.
> > 
> This patch makes the mutex in Tim's workload take a bit less CPU time
> (4% down) but it doesn't really fix the regression. When spinning for a 
> value it's always better to read it first before attempting to write it.
> This saves expensive operations on the interconnect.
> 
> So it's not really a fix for this, but may be a slight improvement for 
> other workloads.
> 
> -Andi
> 
> >From 34d4c1e579b3dfbc9a01967185835f5829bd52f0 Mon Sep 17 00:00:00 2001
> From: Andi Kleen <ak@linux.intel.com>
> Date: Tue, 14 Jun 2011 16:27:54 -0700
> Subject: [PATCH] mutex: while spinning read count before attempting cmpxchg
> 
> Under heavy contention it's better to read first before trying to 
> do an atomic operation on the interconnect.
> 
> This gives a few percent improvement for the mutex CPU time under 
> heavy contention and likely saves some power too.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  kernel/mutex.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/mutex.c b/kernel/mutex.c
> index d607ed5..1abffa9 100644
> --- a/kernel/mutex.c
> +++ b/kernel/mutex.c
> @@ -170,7 +170,8 @@ __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
>  		if (owner && !mutex_spin_on_owner(lock, owner))
>  			break;
>  
> -		if (atomic_cmpxchg(&lock->count, 1, 0) == 1) {
> +		if (atomic_read(&lock->count) == 1 && 
> +		    atomic_cmpxchg(&lock->count, 1, 0) == 1) {
>  			lock_acquired(&lock->dep_map, ip);
>  			mutex_set_owner(lock);
>  			preempt_enable();


What is *sorely* missing from your changelog (again) is the 
explanation of *why* it improves performance in the contended case: 
because the cacheline is brought into shared-read MESI state which 
the CMPXCHG might not dirty if the CMPXCHG fails in the contended 
case.

Firstly, this reduces the cost of hard bounces somewhat because the 
owner CPU still has the cacheline in read-shared state, which it can 
invalidate from the other CPU's cache on unlock in a bit cheaper way 
if it were forced to bounce the cacheline back.

Secondly, in the contended case more that 2 CPUs are looping on the 
same cacheline and bringing it in shared and doing the cmpxchg loop 
will not bounce the cacheline around (if CMPXCHG is smart enough to 
not dirty the cacheline even in the failed case - this is CPU model 
dependent) - it will spread to all interested CPUs in read-shared 
state. This is most likely the dominant factor in Tim's tests.

Had you considered and described all that then you'd inevitably have 
been led to consider the much more important issue that is missing 
from your patch: the analysis of what happens to the cacheline under 
*light* contention, which is by far the most important case ...

In the lightly contended case it's ultimately bad to bring in the 
cacheline as read-shared first, because the cmpxchg will have to go 
out to the MESI interconnect *again*: this time to flush the 
cacheline from the previous owner CPU's cache.

So i don't think we want your patch, without some really good 
supporting facts and analysis that show that the lightly contended 
case does not suffer.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

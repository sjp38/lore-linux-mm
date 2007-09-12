Date: Wed, 12 Sep 2007 06:05:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 21 of 24] select process to kill for cpusets
Message-Id: <20070912060558.5822cb56.akpm@linux-foundation.org>
In-Reply-To: <855dc37d74ab151d7a0c.1187786948@v2.random>
References: <patchbomb.1187786927@v2.random>
	<855dc37d74ab151d7a0c.1187786948@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:49:08 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User David Rientjes <rientjes@google.com>
> # Date 1187778125 -7200
> # Node ID 855dc37d74ab151d7a0c640d687b34ee05996235
> # Parent  2c9417ab4c1ff81a77bca4767207338e43b5cd69
> select process to kill for cpusets
> 
> Passes the memory allocation constraint into select_bad_process() so
> that, in the CONSTRAINT_CPUSET case, we can exclude tasks that do not
> overlap nodes with the triggering task's cpuset.
> 
> The OOM killer now invokes select_bad_process() even in the cpuset case
> to select a rogue task to kill instead of simply using current.  Although
> killing current is guaranteed to help alleviate the OOM condition, it is
> by no means guaranteed to be the "best" process to kill.  The
> select_bad_process() heuristics will do a much better job of determining
> that.
> 
> As an added bonus, this also addresses an issue whereas current could be
> set to OOM_DISABLE and is not respected for the CONSTRAINT_CPUSET case.
> Currently we loop back out to __alloc_pages() waiting for another cpuset
> task to trigger the OOM killer that hopefully won't be OOM_DISABLE.  With
> this patch, we're guaranteed to find a task to kill that is not
> OOM_DISABLE if it matches our eligibility requirements the first time.
> 
> If we cannot find any tasks to kill in the cpuset case, we simply make
> the entire OOM killer a no-op since it's better for one cpuset to fail
> memory allocations repeatedly instead of panicing the entire system.
> 
> Cc: Andrea Arcangeli <andrea@suse.de>
> Cc: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |   25 +++++++++++++++++--------
>  1 files changed, 17 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -188,9 +188,13 @@ static inline int constrained_alloc(stru
>   * Simple selection loop. We chose the process with the highest
>   * number of 'points'. We expect the caller will lock the tasklist.
>   *
> + * If constraint is CONSTRAINT_CPUSET, then only choose a task that overlaps
> + * the nodes of the task that triggered the OOM killer.
> + *
>   * (not docbooked, we don't want this one cluttering up the manual)
>   */
> -static struct task_struct *select_bad_process(unsigned long *ppoints)
> +static struct task_struct *select_bad_process(unsigned long *ppoints,
> +					      int constraint)
>  {
>  	struct task_struct *g, *p;
>  	struct task_struct *chosen = NULL;
> @@ -221,6 +225,9 @@ static struct task_struct *select_bad_pr
>  		}
>  
>  		if (p->oomkilladj == OOM_DISABLE)
> +			continue;
> +		if (constraint == CONSTRAINT_CPUSET &&
> +		    !cpuset_excl_nodes_overlap(p))
>  			continue;
>  
>  		points = badness(p, uptime.tv_sec);
> @@ -424,12 +431,6 @@ void out_of_memory(struct zonelist *zone
>  		break;
>  
>  	case CONSTRAINT_CPUSET:
> -		read_lock(&tasklist_lock);
> -		oom_kill_process(current, points,
> -				 "No available memory in cpuset", gfp_mask, order);
> -		read_unlock(&tasklist_lock);
> -		break;
> -
>  	case CONSTRAINT_NONE:
>  		if (down_trylock(&OOM_lock))
>  			break;
> @@ -454,9 +455,17 @@ retry:
>  		 * Rambo mode: Shoot down a process and hope it solves whatever
>  		 * issues we may have.
>  		 */
> -		p = select_bad_process(&points);
> +		p = select_bad_process(&points, constraint);
>  		/* Found nothing?!?! Either we hang forever, or we panic. */
>  		if (unlikely(!p)) {
> +			/*
> +			 * We shouldn't panic the entire system if we can't
> +			 * find any eligible tasks to kill in a
> +			 * cpuset-constrained OOM condition.  Instead, we do
> +			 * nothing and allow other cpusets to continue.
> +			 */
> +			if (constraint == CONSTRAINT_CPUSET)
> +				goto out;
>  			read_unlock(&tasklist_lock);
>  			cpuset_unlock();
>  			panic("Out of memory and no killable processes...\n");

Seems sensible, but it would be nice to get some thought cycles from pj &
Christoph, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

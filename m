Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 85F0E6B005A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 11:47:32 -0400 (EDT)
Date: Thu, 11 Oct 2012 16:47:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 14/33] autonuma: call autonuma_setup_new_exec()
Message-ID: <20121011154728.GZ3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-15-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-15-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:50:56AM +0200, Andrea Arcangeli wrote:
> This resets all per-thread and per-process statistics across exec
> syscalls or after kernel threads detach from the mm. The past
> statistical NUMA information is unlikely to be relevant for the future
> in these cases.
> 

Unlikely is an understatement.

> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/exec.c        |    7 +++++++
>  mm/mmu_context.c |    3 +++
>  2 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 574cf4d..1d55077 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -55,6 +55,7 @@
>  #include <linux/pipe_fs_i.h>
>  #include <linux/oom.h>
>  #include <linux/compat.h>
> +#include <linux/autonuma.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/mmu_context.h>
> @@ -1172,6 +1173,12 @@ void setup_new_exec(struct linux_binprm * bprm)
>  			
>  	flush_signal_handlers(current, 0);
>  	flush_old_files(current->files);
> +
> +	/*
> +	 * Reset autonuma counters, as past NUMA information
> +	 * is unlikely to be relevant for the future.
> +	 */
> +	autonuma_setup_new_exec(current);
>  }
>  EXPORT_SYMBOL(setup_new_exec);
>  
> diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> index 3dcfaf4..e6fff1c 100644
> --- a/mm/mmu_context.c
> +++ b/mm/mmu_context.c
> @@ -7,6 +7,7 @@
>  #include <linux/mmu_context.h>
>  #include <linux/export.h>
>  #include <linux/sched.h>
> +#include <linux/autonuma.h>
>  
>  #include <asm/mmu_context.h>
>  
> @@ -52,6 +53,8 @@ void unuse_mm(struct mm_struct *mm)
>  {
>  	struct task_struct *tsk = current;
>  
> +	autonuma_setup_new_exec(tsk);
> +

Why are the stats discarded in unuse_mm? That does not seem necessary at
all. Why would AIO being completed cause the stats to reset?

>  	task_lock(tsk);
>  	sync_mm_rss(mm);
>  	tsk->mm = NULL;
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

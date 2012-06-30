Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 2FEE56B0072
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 01:04:31 -0400 (EDT)
Received: by qadz32 with SMTP id z32so1164755qad.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 22:04:30 -0700 (PDT)
Date: Sat, 30 Jun 2012 01:04:26 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 18/40] autonuma: call autonuma_setup_new_exec()
Message-ID: <20120630050425.GE3975@localhost.localdomain>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-19-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340888180-15355-19-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Jun 28, 2012 at 02:55:58PM +0200, Andrea Arcangeli wrote:
> This resets all per-thread and per-process statistics across exec
> syscalls or after kernel threads detached from the mm. The past
> statistical NUMA information is unlikely to be relevant for the future
> in these cases.

The previous patch mentioned that it can run in bypass mode. Is
this also able to do so? Meaning that these calls end up doing nops?

Thanks!
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/exec.c        |    3 +++
>  mm/mmu_context.c |    2 ++
>  2 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index da27b91..146ced2 100644
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
> @@ -1172,6 +1173,8 @@ void setup_new_exec(struct linux_binprm * bprm)
>  			
>  	flush_signal_handlers(current, 0);
>  	flush_old_files(current->files);
> +
> +	autonuma_setup_new_exec(current);
>  }
>  EXPORT_SYMBOL(setup_new_exec);
>  
> diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> index 3dcfaf4..40f0f13 100644
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
> @@ -58,5 +59,6 @@ void unuse_mm(struct mm_struct *mm)
>  	/* active_mm is still 'mm' */
>  	enter_lazy_tlb(mm, tsk);
>  	task_unlock(tsk);
> +	autonuma_setup_new_exec(tsk);
>  }
>  EXPORT_SYMBOL_GPL(unuse_mm);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

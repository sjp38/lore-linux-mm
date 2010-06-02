Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 090DC6B01BA
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 11:43:34 -0400 (EDT)
Date: Wed, 2 Jun 2010 17:42:10 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
Message-ID: <20100602154210.GA9622@redhat.com>
References: <20100601093951.2430.A69D9226@jp.fujitsu.com> <20100601201843.GA20732@redhat.com> <20100602221805.F524.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100602221805.F524.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

(add Roland)

On 06/02, KOSAKI Motohiro wrote:
>
> > Otoh, if we make do_coredump() interruptible (and we should do this
> > in any case), then perhaps the TIF_MEMDIE+PF_COREDUMP is not really
> > needed? Afaics we always send SIGKILL along with TIF_MEMDIE.
>
> How is to make per-process oom flag + interruptible coredump?
>
> this per-process oom flag can be used vmscan shortcut exiting too.
> (IOW, It can help DavidR mmap_sem issue)

Firstly, this solution is not complete. We should make it really
interruptible (from user-space too), but we need more changes for
this (in particular we need to distinguish group-exit/exec cases
from the explicit SIGKILL case). Let's not discuss this here, this
is the different story.


But. I agree very much that it makes sense to add the quick fix
right now. Even if this fix will be superseded by the "proper"
fixes later.

> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -2038,6 +2038,11 @@ static int elf_core_dump(struct coredump_params *cprm)
>  				page_cache_release(page);
>  			} else
>  				stop = !dump_seek(cprm->file, PAGE_SIZE);
> +
> +			/* Now, The process received OOM. Exit soon! */
> +			if (current->signal->oom_victim)
> +				stop = 1;

Agreed, most problems with memory allocations should come from this loop.

> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -544,6 +544,9 @@ struct signal_struct {
>  	int			notify_count;
>  	struct task_struct	*group_exit_task;
>
> +	/* true mean the process is OOM-killer victim. */
> +	bool			oom_victim;

Well, the new word in signal_struct is not nice. It is better to
set SIGNAL_OOM_XXX in ->signal->flags (this needs ->siglock).

But. I don't think that signal_struct is the right place for the marker.

The thread which actually dumps the core doesn't necessarily belong
to the same thread group, but it can share ->mm with the selected
oom victim.

IOW, we should mark ->mm instead (perhaps mm->flags) or mm->core_state.
This in turn means we need find_lock_task_mm().

What do you think?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

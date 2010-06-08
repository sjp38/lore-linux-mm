Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EE80B6B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:08:42 -0400 (EDT)
Date: Tue, 8 Jun 2010 13:08:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 05/18] oom: give current access to memory reserves if it
 has been killed
Message-Id: <20100608130804.8794d029.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061524080.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061524080.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:18 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's possible to livelock the page allocator if a thread has mm->mmap_sem

What is the state of this thread?  Trying to allocate memory, I assume.  

> and fails to make forward progress because the oom killer selects another
> thread sharing the same ->mm to kill that cannot exit until the semaphore
> is dropped.
> 
> The oom killer will not kill multiple tasks at the same time; each oom
> killed task must exit before another task may be killed.

This sounds like a quite risky design.  The possibility that we'll
cause other dead/livelocks similar to this one seems pretty high.  It
applies to all sleeping locks in the entire kernel, doesn't it?

If so: it's unfortunate that the kernel doesn't dsitinguish between
D-state-for-locks and D-state-for-disk-io.  Otherwise we could just
skip over D-state-for-locks processes.

Or maybe I'm wrong ;)

>  Thus, if one
> thread is holding mm->mmap_sem and cannot allocate memory, all threads
> sharing the same ->mm are blocked from exiting as well.  In the oom kill
> case, that means the thread holding mm->mmap_sem will never free
> additional memory since it cannot get access to memory reserves and the
> thread that depends on it with access to memory reserves cannot exit
> because it cannot acquire the semaphore.  Thus, the page allocators
> livelocks.
> 
> When the oom killer is called and current happens to have a pending
> SIGKILL, this patch automatically gives it access to memory reserves and
> returns.  Upon returning to the page allocator, its allocation will
> hopefully succeed so it can quickly exit and free its memory.  If not, the
> page allocator will fail the allocation if it is not __GFP_NOFAIL.

You said "hopefully".

Does it actually work?  Any real-world testing results?  If so, they'd
be a useful addition to the changelog.

> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -650,6 +650,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		/* Got some memory back in the last second. */
>  		return;
>  
> +	/*
> +	 * If current has a pending SIGKILL, then automatically select it.  The
> +	 * goal is to allow it to allocate so that it may quickly exit and free
> +	 * its memory.
> +	 */
> +	if (fatal_signal_pending(current)) {
> +		set_thread_flag(TIF_MEMDIE);
> +		return;
> +	}
> +
>  	if (sysctl_panic_on_oom == 2) {
>  		dump_header(NULL, gfp_mask, order, NULL);
>  		panic("out of memory. Compulsory panic_on_oom is selected.\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

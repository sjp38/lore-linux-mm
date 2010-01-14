Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E44766B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:03:03 -0500 (EST)
Date: Fri, 15 Jan 2010 00:02:57 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] oom: OOM-Killed process don't invoke pagefault-oom
Message-ID: <20100114130257.GB8381@laptop>
References: <20100114191940.6749.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114191940.6749.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I don't think this should be required, because the oom killer does not
kill a new task if there is already one in memdie state.

If you have any further tweaks to the heuristic (such as a fatal signal
pending), then it should probably go in select_bad_process() or
somewhere like that.

Thanks,
Nick

On Thu, Jan 14, 2010 at 07:22:34PM +0900, KOSAKI Motohiro wrote:
> 
> Nick, I've found this issue by code review. I'm glad if you review this
> patch.
> 
> Thanks.
> 
> =============================
> commit 1c0fe6e3 (invoke oom-killer from page fault) created
> page fault specific oom handler.
> 
> But If OOM occur, alloc_pages() in page fault might return
> NULL. It mean page fault return VM_FAULT_OOM. But OOM Killer
> itself sholdn't invoke next OOM Kill. it is obviously strange.
> 
> Plus, process exiting itself makes some free memory. we
> don't need kill another process.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Nick Piggin <npiggin@suse.de>
> Cc: Jeff Dike <jdike@addtoit.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/oom_kill.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4f167b8..86cecdf 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -596,6 +596,15 @@ void pagefault_out_of_memory(void)
>  {
>  	unsigned long freed = 0;
>  
> +	/*
> +	 * If the task was received SIGKILL while memory allocation, alloc_pages
> +	 * might return NULL and it cause page fault return VM_FAULT_OOM. But
> +	 * in such case, the task don't need kill any another task, it need
> +	 * just die.
> +	 */
> +	if (fatal_signal_pending(current))
> +		return;
> +
>  	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
>  	if (freed > 0)
>  		/* Got some memory back in the last second. */
> -- 
> 1.6.5.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

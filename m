Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 466AB6B01E3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bfxvb012363
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1554945DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D889845DE4D
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B137E1DB803C
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C8B41DB8043
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/18] oom: give current access to memory reserves if it has been killed
In-Reply-To: <alpine.DEB.2.00.1006061524080.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524080.32225@chino.kir.corp.google.com>
Message-Id: <20100608203216.765D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It's possible to livelock the page allocator if a thread has mm->mmap_sem
> and fails to make forward progress because the oom killer selects another
> thread sharing the same ->mm to kill that cannot exit until the semaphore
> is dropped.
> 
> The oom killer will not kill multiple tasks at the same time; each oom
> killed task must exit before another task may be killed.  Thus, if one
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
> 
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

Sorry, I had found this patch works incorrect. I don't pulled.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

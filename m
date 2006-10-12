Date: Thu, 12 Oct 2006 15:03:50 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/5] oom: less memdie
Message-Id: <20061012150350.00f19d2a.akpm@osdl.org>
In-Reply-To: <20061012120129.29671.3288.sendpatchset@linux.site>
References: <20061012120102.29671.31163.sendpatchset@linux.site>
	<20061012120129.29671.3288.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Oct 2006 16:10:01 +0200 (CEST)
Nick Piggin <npiggin@suse.de> wrote:

> Don't cause all threads in all other thread groups to gain TIF_MEMDIE
> otherwise we'll get a thundering herd eating out memory reserve. This
> may not be the optimal scheme, but it fits our policy of allowing just
> one TIF_MEMDIE in the system at once.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Index: linux-2.6/mm/oom_kill.c
> ===================================================================
> --- linux-2.6.orig/mm/oom_kill.c
> +++ linux-2.6/mm/oom_kill.c
> @@ -322,11 +322,12 @@ static int oom_kill_task(struct task_str
>  
>  	/*
>  	 * kill all processes that share the ->mm (i.e. all threads),
> -	 * but are in a different thread group.
> +	 * but are in a different thread group. Don't let them have access
> +	 * to memory reserves though, otherwise we might deplete all memory.
>  	 */
>  	do_each_thread(g, q) {
>  		if (q->mm == mm && q->tgid != p->tgid)
> -			__oom_kill_task(q, 1);
> +			force_sig(SIGKILL, p);
>  	} while_each_thread(g, q);
>  

Curious.  How much testing did you do of this stuff?  I assume there were
some observed problems.  What were they, and what was the observed effect
of these changes?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

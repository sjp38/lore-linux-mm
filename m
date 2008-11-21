Date: Fri, 21 Nov 2008 14:50:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Make the get_user_pages interruptible
Message-Id: <20081121145043.0e4b2bf9.akpm@linux-foundation.org>
In-Reply-To: <604427e00811201403k26e4bf93tdb2dee9506756a82@mail.gmail.com>
References: <604427e00811201403k26e4bf93tdb2dee9506756a82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, rientjes@google.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Nov 2008 14:03:36 -0800
Ying Han <yinghan@google.com> wrote:

> make get_user_pages interruptible
> The initial implementation of checking TIF_MEMDIE covers the cases of OOM
> killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
> return immediately. This patch includes:
> 
> 1. add the case that the SIGKILL is sent by user processes. The process can
> try to get_user_pages() unlimited memory even if a user process has sent a
> SIGKILL to it(maybe a monitor find the process exceed its memory limit and
> try to kill it). In the old implementation, the SIGKILL won't be handled
> until the get_user_pages() returns.
> 
> 2. change the return value to be ERESTARTSYS. It makes no sense to return
> ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
> Considering the general convention for a system call interrupted by a
> signal is ERESTARTNOSYS, so the current return value is consistant to that.
> 
> Signed-off-by:	Paul Menage <menage@google.com>
> 		Ying Han <yinghan@google.com>
> 
> 

This isn't right?

> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1218,12 +1218,11 @@ int __get_user_pages(struct task_struct *tsk, struct m
>  			struct page *page;
> 
>  			/*
> -			 * If tsk is ooming, cut off its access to large memory
> -			 * allocations. It has a pending SIGKILL, but it can't
> -			 * be processed until returning to user space.
> +			 * If we have a pending SIGKILL, don't keep
> +			 * allocating memory.
>  			 */
> -			if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
> -				return i ? i : -ENOMEM;
> +			if (sigkill_pending(current))
> +				return -ERESTARTSYS;
> 
>  			if (write)
>  				foll_flags |= FOLL_WRITE;

If this function has already put some page*'s into *pages, they will be
leaked.  The function fails to release those pages and it does not
provide sufficient information to callers to allow them to release the
pages.

I thought I already mentioned that last time I saw this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

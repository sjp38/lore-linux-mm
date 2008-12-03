Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB32OlOP021930
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 3 Dec 2008 11:24:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 972BB45DD74
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 11:24:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 692C845DD72
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 11:24:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4289A1DB803C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 11:24:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F2E461DB803A
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 11:24:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][V6]make get_user_pages interruptible
In-Reply-To: <604427e00812021130t1aad58a8j7474258ae33e15a4@mail.gmail.com>
References: <604427e00812021130t1aad58a8j7474258ae33e15a4@mail.gmail.com>
Message-Id: <20081203111440.1D35.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  3 Dec 2008 11:24:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

Hi!

Sorry for too late review.
In general, I like this patch. but ...


> changelog
> [v6] replace the sigkill_pending() with fatal_signal_pending()
>       add the check for cases current != tsk
> 
> From: Ying Han <yinghan@google.com>
> 
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

this description explain why fatal_signal_pending(current) is needed.
but doesn't explain why fatal_signal_pending(tsk) is needed.

more unfortunately, this patch break kernel compatibility.
To read /proc file invoke calling get_user_page().
however, "man 2 read" doesn't describe ERESTARTSYS.

IOW, this patch can break /proc reading user application.

May I ask why fatal_signal_pending(tsk) is needed ?
at least, you need to cc to linux-api@vger.kernel.org IMHO.


Am I talking about pointless?



> Signed-off-by:	Paul Menage <menage@google.com>
> Signed-off-by:	Ying Han <yinghan@google.com>
> 
> mm/memory.c                   |   13 ++-
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 164951c..049a4f1 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1218,12 +1218,15 @@ int __get_user_pages(struct task_struct *tsk, struct m
>  			struct page *page;
> 
>  			/*
> -			 * If tsk is ooming, cut off its access to large memory
> -			 * allocations. It has a pending SIGKILL, but it can't
> -			 * be processed until returning to user space.
> +			 * If we have a pending SIGKILL, don't keep
> +			 * allocating memory. We check both current
> +			 * and tsk to cover the cases where current
> +			 * is allocating pages on behalf of tsk.
>  			 */
> -			if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
> -				return i ? i : -ENOMEM;
> +			if (unlikely(fatal_signal_pending(current) ||
> +				((current != tsk) &&
> +				fatal_signal_pending(tsk))))
> +				return i ? i : -ERESTARTSYS;
> 
>  			if (write)
>  				foll_flags |= FOLL_WRITE;




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

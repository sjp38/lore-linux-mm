Date: Fri, 21 Nov 2008 16:21:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
In-Reply-To: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Nov 2008, Ying Han wrote:

> Signed-off-by:	Paul Menage <menage@google.com>
> 		      Ying Han <yinghan@google.com>
> 

That should be:

Signed-off-by: Paul Menage <menage@google.com>
Signed-off-by: Ying Han <yinghan@google.com>

and the first signed-off line is usually indicative of who wrote the 
original change.  If Paul wrote this code, please add:

From: Paul Menage <menage@google.com>

as the first line of the email so that the proper authorship gets 
attributed in the commit.

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index b483f39..f9c6a8a 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1790,6 +1790,7 @@ extern void sched_dead(struct task_struct *p);
>  extern int in_group_p(gid_t);
>  extern int in_egroup_p(gid_t);
> 
> +extern int sigkill_pending(struct task_struct *tsk);
>  extern void proc_caches_init(void);
>  extern void flush_signals(struct task_struct *);
>  extern void ignore_signals(struct task_struct *);

Interesting way around your email client's line truncation.

> diff --git a/mm/memory.c b/mm/memory.c
> index 164951c..5d3db5e 100644
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
> +				return i ? i : -ERESTARTSYS;
> 
>  			if (write)
>  				foll_flags |= FOLL_WRITE;
> 

We previously tested tsk for TIF_MEMDIE and not current (in fact, nothing 
in __get_user_pages() operates on current).  So why are we introducing 
this check on current and not tsk?

Do we want to avoid branch prediction now because there's data suggesting 
tsk will be SIGKILL'd more frequently in this path other than by the oom 
killer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

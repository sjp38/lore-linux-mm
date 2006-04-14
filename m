Date: Fri, 14 Apr 2006 14:31:09 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/2] mm: fix mm_struct reference counting bugs in
 mm/oom_kill.c
Message-Id: <20060414143109.5d537091.akpm@osdl.org>
In-Reply-To: <200604141349.02047.dsp@llnl.gov>
References: <200604131452.08292.dsp@llnl.gov>
	<200604141214.35806.dsp@llnl.gov>
	<20060414124530.24a36d51.akpm@osdl.org>
	<200604141349.02047.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

Dave Peterson <dsp@llnl.gov> wrote:
>
> Another thing I noticed: oom_kill_task() calls mmput() while holding
> tasklist_lock.

Yes, that'll make my new might_sleep() get upset.

oom_kill_task() doesn't _have_ to run mmput() there - we could propagate
the mm back to the top-level and do the mmput() there.

>  Here the calls to get_task_mm() and mmput() appear to
> be unnecessary.  We shouldn't need to use any kind of locking or
> reference counting since oom_kill_task() doesn't dereference into the
> mm_struct or require the value of p->mm to stay constant.  I believe
> the following (untested) code changes should fix the problem (and
> simplify some other parts of the code).  Does this look correct?

But yes, this looks better.

> 
> diff -urNp -X /home/dsp/dontdiff linux-2.6.17-rc1/mm/oom_kill.c linux-2.6.17-rc1-fix/mm/oom_kill.c
> --- linux-2.6.17-rc1/mm/oom_kill.c	2006-03-19 21:53:29.000000000 -0800
> +++ linux-2.6.17-rc1-fix/mm/oom_kill.c	2006-04-14 13:22:15.000000000 -0700
> @@ -244,17 +244,15 @@ static void __oom_kill_task(task_t *p, c
>  	force_sig(SIGKILL, p);
>  }
>  
> -static struct mm_struct *oom_kill_task(task_t *p, const char *message)
> +static int oom_kill_task(task_t *p, const char *message)
>  {
> -	struct mm_struct *mm = get_task_mm(p);
> +	struct mm_struct *mm;
>  	task_t * g, * q;

Please put a loud comment in here explaining that `mm' may not be dereferenced.

> -	if (!mm)
> -		return NULL;
> -	if (mm == &init_mm) {
> -		mmput(mm);
> -		return NULL;
> -	}
> +	mm = p->mm;
> +
> +	if ((mm == NULL) || (mm == &init_mm))

I think the parenthesisation here is going a bit far ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

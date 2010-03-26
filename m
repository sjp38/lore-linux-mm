Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 728766B01C7
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 18:08:16 -0400 (EDT)
Date: Fri, 26 Mar 2010 15:08:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-Id: <20100326150805.f5853d1c.akpm@linux-foundation.org>
In-Reply-To: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anfei Zhou <anfei.zhou@gmail.com>
Cc: rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Mar 2010 00:25:05 +0800
Anfei Zhou <anfei.zhou@gmail.com> wrote:

> In multi-threading environment, if the current task(A) have got
> the mm->mmap_sem semaphore, and the thread(B) in the same process
> is selected to be oom killed, because they shares the same semaphore,
> thread B can not really be killed.  So __alloc_pages_slowpath turns
> to be a infinite loop.  Here set all the threads in the group to
> TIF_MEMDIE, it gets a chance to break and exit.
> 
> Signed-off-by: Anfei Zhou <anfei.zhou@gmail.com>
> ---
>  mm/oom_kill.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9b223af..aab9892 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -381,6 +381,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>   */
>  static void __oom_kill_task(struct task_struct *p, int verbose)
>  {
> +	struct task_struct *t;
> +
>  	if (is_global_init(p)) {
>  		WARN_ON(1);
>  		printk(KERN_WARNING "tried to kill init!\n");
> @@ -412,6 +414,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
>  	 */
>  	p->rt.time_slice = HZ;
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
> +	for (t = next_thread(p); t != p; t = next_thread(t))
> +		set_tsk_thread_flag(t, TIF_MEMDIE);
>  
>  	force_sig(SIGKILL, p);

Don't we need some sort of locking while walking that ring? 
Unintuitively it appears to be spin_lock_irq(&p->sighand->siglock).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B3ED76B01C7
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 22:51:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2P2pLgc012511
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Mar 2010 11:51:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 616C445DE51
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:51:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 34D9845DE4E
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:51:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 21AC6E38001
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:51:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CB1031DB803A
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:51:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
In-Reply-To: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
Message-Id: <20100325100302.9457.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Mar 2010 11:51:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Anfei Zhou <anfei.zhou@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> In multi-threading environment, if the current task(A) have got
> the mm->mmap_sem semaphore, and the thread(B) in the same process
> is selected to be oom killed, because they shares the same semaphore,
> thread B can not really be killed.  So __alloc_pages_slowpath turns
> to be a infinite loop.  Here set all the threads in the group to
> TIF_MEMDIE, it gets a chance to break and exit.
> 
> Signed-off-by: Anfei Zhou <anfei.zhou@gmail.com>

I like this patch very much.
Thanks, Anfei!
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


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
>  }
> -- 
> 1.6.4.rc1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDED6B01AF
	for <linux-mm@kvack.org>; Sat, 27 Mar 2010 22:46:26 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o2S2kLla017504
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 04:46:22 +0200
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz24.hot.corp.google.com with ESMTP id o2S2kKR7012090
	for <linux-mm@kvack.org>; Sat, 27 Mar 2010 19:46:20 -0700
Received: by pwi9 with SMTP id 9so6811384pwi.4
        for <linux-mm@kvack.org>; Sat, 27 Mar 2010 19:46:20 -0700 (PDT)
Date: Sat, 27 Mar 2010 19:46:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
In-Reply-To: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
Message-ID: <alpine.DEB.2.00.1003271946090.9116@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Anfei Zhou <anfei.zhou@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Mar 2010, Anfei Zhou wrote:

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

I like the concept, but I agree that it would probably be better to write 
it as Oleg suggested.  The oom killer has been rewritten in the -mm tree 
and so this patch doesn't apply cleanly, would it be possible to rebase to 
mmotm with the suggested coding sytle and post this again?

See http://userweb.kernel.org/~akpm/mmotm/mmotm-readme.txt	

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AFF576B01B2
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:15:54 -0400 (EDT)
Received: by pwi7 with SMTP id 7so4334179pwi.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 08:15:53 -0700 (PDT)
Date: Thu, 17 Jun 2010 00:15:47 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 6/9] oom: use same_thread_group instead comparing ->mm
Message-ID: <20100616151547.GF9278@barrios-desktop>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
 <20100616203319.72E6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616203319.72E6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 08:34:02PM +0900, KOSAKI Motohiro wrote:
> Now, oom are using "child->mm != p->mm" check to distinguish subthread.
> But It's incorrect. vfork() child also have the same ->mm.
> 
> This patch change to use same_thread_group() instead.

Hmm. I think we don't use it to distinguish subthread. 
We use it for finding child process which is not vforked. 

I can't understand your point. 


> 
> Cc: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 12204c7..e4b1146 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -161,7 +161,7 @@ unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
>  		list_for_each_entry(c, &t->children, sibling) {
>  			child = find_lock_task_mm(c);
>  			if (child) {
> -				if (child->mm != p->mm)
> +				if (same_thread_group(p, child))
>  					points += child->mm->total_vm/2 + 1;
>  				task_unlock(child);
>  			}
> @@ -486,7 +486,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		list_for_each_entry(child, &t->children, sibling) {
>  			unsigned long child_points;
>  
> -			if (child->mm == p->mm)
> +			if (same_thread_group(p, child))
>  				continue;
>  			if (oom_unkillable_task(child, mem, nodemask))
>  				continue;
> -- 
> 1.6.5.2
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

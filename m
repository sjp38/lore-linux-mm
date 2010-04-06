Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 394166B01F1
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 07:42:44 -0400 (EDT)
Date: Tue, 6 Apr 2010 19:42:35 +0800
From: anfei <anfei.zhou@gmail.com>
Subject: Re: [PATCH -mm 2/4] oom: select_bad_process: PF_EXITING check
 should take ->mm into account
Message-ID: <20100406114235.GA3965@desktop>
References: <20100330154659.GA12416@redhat.com>
 <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com>
 <20100331175836.GA11635@redhat.com>
 <20100331204718.GD11635@redhat.com>
 <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com>
 <20100401135927.GA12460@redhat.com>
 <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com>
 <20100402111406.GA4432@redhat.com>
 <20100402183057.GA31723@redhat.com>
 <20100402183216.GC31723@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402183216.GC31723@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2010 at 08:32:16PM +0200, Oleg Nesterov wrote:
> select_bad_process() checks PF_EXITING to detect the task which
> is going to release its memory, but the logic is very wrong.
> 
> 	- a single process P with the dead group leader disables
> 	  select_bad_process() completely, it will always return
> 	  ERR_PTR() while P can live forever
> 
> 	- if the PF_EXITING task has already released its ->mm
> 	  it doesn't make sense to expect it is goiing to free
> 	  more memory (except task_struct/etc)
> 
> Change the code to ignore the PF_EXITING tasks without ->mm.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
> 
>  mm/oom_kill.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- MM/mm/oom_kill.c~2_FIX_PF_EXITING	2010-04-02 18:51:05.000000000 +0200
> +++ MM/mm/oom_kill.c	2010-04-02 18:58:37.000000000 +0200
> @@ -322,7 +322,7 @@ static struct task_struct *select_bad_pr
>  		 * the process of exiting and releasing its resources.
>  		 * Otherwise we could get an easy OOM deadlock.
>  		 */
> -		if (p->flags & PF_EXITING) {
> +		if ((p->flags & PF_EXITING) && p->mm) {

Even this check is satisfied, it still can't say p is a good victim or
it will release memory automatically if multi threaded, as the exiting
of p doesn't mean the other threads are going to exit, so the ->mm won't
be released.

>  			if (p != current)
>  				return ERR_PTR(-1UL);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

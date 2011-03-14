Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A41C88D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:22:30 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p2EKMQ2g013429
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:22:26 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by hpaq7.eem.corp.google.com with ESMTP id p2EKM6la003578
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:22:24 -0700
Received: by pvg12 with SMTP id 12so1078573pvg.33
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:22:20 -0700 (PDT)
Date: Mon, 14 Mar 2011 13:22:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set TIF_MEMDIE
 if !p->mm
In-Reply-To: <20110314190446.GB21845@redhat.com>
Message-ID: <alpine.DEB.2.00.1103141314190.31514@chino.kir.corp.google.com>
References: <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com>
 <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Mar 2011, Oleg Nesterov wrote:

> oom_kill_process() simply sets TIF_MEMDIE and returns if PF_EXITING.
> This is very wrong by many reasons. In particular, this thread can
> be the dead group leader. Check p->mm != NULL.
> 

This is true only for the oom_kill_allocating_task sysctl where it is 
required in all cases to kill current; current won't be triggering the oom 
killer if it's dead.

oom_kill_process() is called with the thread selected by 
select_bad_process() and that function will not return any thread if any 
eligible task is found to be PF_EXITING and is not current, or any 
eligible task is found to have TIF_MEMDIE.

In other words, for this conditional to be true in oom_kill_process(), 
then p must be current and so it cannot be the dead group leader as 
specified in your changelog unless PF_EXITING gets set between 
select_bad_process() and the oom_kill_process() call: we don't care about 
that since it's in the exit path and we therefore want to give it access 
to memory reserves to quickly exit anyway and the check for PF_EXITING in 
select_bad_process() prevents any infinite loop of that task getting 
constantly reselected if it's dead.

> Note: this is _not_ enough. Just a minimal fix.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
> 
>  mm/oom_kill.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 38/mm/oom_kill.c~1_kill_fix_pf_exiting	2011-03-14 17:53:05.000000000 +0100
> +++ 38/mm/oom_kill.c	2011-03-14 18:51:49.000000000 +0100
> @@ -470,7 +470,7 @@ static int oom_kill_process(struct task_
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
> -	if (p->flags & PF_EXITING) {
> +	if (p->flags & PF_EXITING && p->mm) {
>  		set_tsk_thread_flag(p, TIF_MEMDIE);
>  		boost_dying_task_prio(p, mem);
>  		return 0;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

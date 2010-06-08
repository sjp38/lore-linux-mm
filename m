Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 08C226B01EE
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:04 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg2hP008093
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E9BE45DE56
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C75945DE51
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 23EC0E08002
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D2140E38001
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
In-Reply-To: <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
Message-Id: <20100608203250.7660.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It's unnecessary to SIGKILL a task that is already PF_EXITING and can
> actually cause a NULL pointer dereference of the sighand if it has already
> been detached.  Instead, simply set TIF_MEMDIE so it has access to memory
> reserves and can quickly exit as the comment implies.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -458,7 +458,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
>  	if (p->flags & PF_EXITING) {
> -		__oom_kill_task(p, 0);
> +		set_tsk_thread_flag(p, TIF_MEMDIE);
>  		return 0;
>  	}
>  

I don't pulled PF_EXITING related thing.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

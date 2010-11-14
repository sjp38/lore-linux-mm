Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BDBE38D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:21:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE5LO3c007223
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:21:24 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 45F9245DE55
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:21:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2494A45DE51
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:21:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C447E08003
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:21:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8F531DB803A
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:21:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3]mm/oom-kill: direct hardware access processes should get bonus
In-Reply-To: <1289402666.10699.28.camel@localhost.localdomain>
References: <1289402093.10699.25.camel@localhost.localdomain> <1289402666.10699.28.camel@localhost.localdomain>
Message-Id: <20101114141913.E019.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Sun, 14 Nov 2010 14:21:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <figo1802@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "rientjes@google.com" <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Figo.zhang" <zhangtianfei@leadcoretech.com>
List-ID: <linux-mm.kvack.org>

> the victim should not directly access hardware devices like Xorg server,
> because the hardware could be left in an unpredictable state, although 
> user-application can set /proc/pid/oom_score_adj to protect it. so i think
> those processes should get bonus for protection.
> 
> in v2, fix the incorrect comment.
> in v3, change the divided the badness score by 4, like old heuristic for protection. we just
> want the oom_killer don't select Root/RESOURCE/RAWIO process as possible.
> 
> suppose that if a user process A such as email cleint "evolution" and a process B with
> ditecly hareware access such as "Xorg", they have eat the equal memory (the badness score is 
> the same),so which process are you want to kill? so in new heuristic, it will kill the process B.
> but in reality, we want to kill process A.
> 
> Signed-off-by: Figo.zhang <figo1802@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Sorry for the delay. I've sent completely revert patch to linus. It will
disappear your headache, I believe. I'm sorry that our development
caused your harm. We really don't want it.

Thanks.


> ---
> mm/oom_kill.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4029583..f43d759 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -202,6 +202,15 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  		points -= 30;
>  
>  	/*
> +	 * Root and direct hareware access processes are usually more 
> +	 * important, so they should get bonus for protection. 
> +	 */
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> +	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
> +	    has_capability_noaudit(p, CAP_SYS_RAWIO))
> +		points /= 4;
> +
> +	/*
>  	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
>  	 * either completely disable oom killing or always prefer a certain
>  	 * task.
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A5E576B009A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 23:19:57 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S3JtVl025777
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 12:19:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C4FE245DE51
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:19:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E81F45DE4C
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:19:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7677FE08002
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:19:54 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 12EE3E08003
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:19:54 +0900 (JST)
Date: Wed, 28 Oct 2009 12:17:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091028121722.6e93f3eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091028113713.FD85.A69D9226@jp.fujitsu.com>
References: <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910271843510.11372@sister.anvils>
	<20091028113713.FD85.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com, akpm@linux-foundation.org, rientjes@google.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009 11:47:55 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > 2.  I started out running my mlock test program as root (later
> > switched to use "ulimit -l unlimited" first).  But badness() reckons
> > CAP_SYS_ADMIN or CAP_SYS_RESOURCE is a reason to quarter your points;
> > and CAP_SYS_RAWIO another reason to quarter your points: so running
> > as root makes you sixteen times less likely to be killed.  Quartering
> > is anyway debatable, but sixteenthing seems utterly excessive to me.
> > 
> > I moved the CAP_SYS_RAWIO test in with the others, so it does no
> > more than quartering; but is quartering appropriate anyway?  I did
> > wonder if I was right to be "subverting" the fine-grained CAPs in
> > this way, but have since seen unrelated mail from one who knows
> > better, implying they're something of a fantasy, that su and sudo
> > are indeed what's used in the real world.  Maybe this patch was okay.
> 
> I agree quartering is debatable.
> At least, killing quartering is worth for any user, and it can be push into -stable.
> 
> 
> 
> 
> From 27331555366c908a93c2cdd780b77e421869c5af Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed, 28 Oct 2009 11:28:39 +0900
> Subject: [PATCH] oom: Mitigate suer-user's bonus of oom-score
> 
> Currently, badness calculation code of oom contemplate following bonus.
>  - Super-user have quartering oom-score
>  - CAP_SYS_RAWIO process (e.g. database) also have quartering oom-score
> 
> The problem is, Super-users have CAP_SYS_RAWIO too. Then, they have
> sixteenthing bonus. it's obviously too excessive and meaningless.
> 
> This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I'll pick this up to my series.

Thanks,
-Kame

> ---
>  mm/oom_kill.c |   13 +++++--------
>  1 files changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ea2147d..40d323d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -152,18 +152,15 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	/*
>  	 * Superuser processes are usually more important, so we make it
>  	 * less likely that we kill those.
> -	 */
> -	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> -	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
> -		points /= 4;
> -
> -	/*
> -	 * We don't want to kill a process with direct hardware access.
> +	 *
> +	 * Plus, We don't want to kill a process with direct hardware access.
>  	 * Not only could that mess up the hardware, but usually users
>  	 * tend to only have this flag set on applications they think
>  	 * of as important.
>  	 */
> -	if (has_capability_noaudit(p, CAP_SYS_RAWIO))
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> +	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
> +	    has_capability_noaudit(p, CAP_SYS_RAWIO))
>  		points /= 4;
>  
>  	/*
> -- 
> 1.6.2.5
> 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

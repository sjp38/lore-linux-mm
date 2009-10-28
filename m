Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2C76B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 00:12:46 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n9S4ChDU031354
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 21:12:43 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by spaceape9.eur.corp.google.com with ESMTP id n9S4CBDj028329
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 21:12:40 -0700
Received: by pzk4 with SMTP id 4so334254pzk.32
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 21:12:39 -0700 (PDT)
Date: Tue, 27 Oct 2009 21:12:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091028113713.FD85.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910272111400.8988@chino.kir.corp.google.com>
References: <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <20091028113713.FD85.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, KOSAKI Motohiro wrote:

> I agree quartering is debatable.
> At least, killing quartering is worth for any user, and it can be push into -stable.
> 

Not sure where the -stable reference came from, I don't think this is a 
candidate.

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

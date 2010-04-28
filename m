Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F3CA86B01F2
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 21:00:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S10VxO005280
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 10:00:31 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13B0545DE4D
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:00:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DFEC045DE52
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:00:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B30FC1DB8044
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:00:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 528A21DB8050
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:00:30 +0900 (JST)
Date: Wed, 28 Apr 2010 09:56:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] oom: avoid divide by zero
Message-Id: <20100428095632.137f5eae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004271600220.19364@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004271600220.19364@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 16:01:00 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's evidently possible for a memory controller to have a limit of 0
> bytes, so it's possible for the oom killer to have a divide by zero error
> in such circumstances.
> 
> When this is the case, each candidate task's rss and swap is divided by
> one so they are essentially ranked according to whichever task attached
> to the cgroup has the most resident RAM and swap.
> 
> Reported-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Oh, thank you !

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/oom_kill.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -189,6 +189,14 @@ unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
>  	p = find_lock_task_mm(p);
>  	if (!p)
>  		return 0;
> +
> +	/*
> +	 * The memory controller can have a limit of 0 bytes, so avoid a divide
> +	 * by zero if necessary.
> +	 */
> +	if (!totalpages)
> +		totalpages = 1;
> +
>  	/*
>  	 * The baseline for the badness score is the proportion of RAM that each
>  	 * task's rss and swap space use.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

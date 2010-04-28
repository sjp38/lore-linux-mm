Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 49DF26B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 02:26:35 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch -mm] oom: avoid divide by zero
References: <alpine.DEB.2.00.1004271600220.19364@chino.kir.corp.google.com>
Date: Tue, 27 Apr 2010 23:26:20 -0700
In-Reply-To: <alpine.DEB.2.00.1004271600220.19364@chino.kir.corp.google.com>
	(David Rientjes's message of "Tue, 27 Apr 2010 16:01:00 -0700 (PDT)")
Message-ID: <xr93zl0om6sz.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes <rientjes@google.com> writes:

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

I tested 2.6.34-rc5 + mmotm-2010-04-22-16-38 and the provided patch
fixes the reported problem.

Thanks David.

Tested-by: Greg Thelen <gthelen@google.com>

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

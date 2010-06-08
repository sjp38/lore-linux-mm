Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 05B266B01CF
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:10:40 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o58JAYF1025104
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:10:34 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by hpaq3.eem.corp.google.com with ESMTP id o58J9cwx021749
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:10:33 -0700
Received: by pwj1 with SMTP id 1so2814730pwj.27
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 12:10:32 -0700 (PDT)
Date: Tue, 8 Jun 2010 12:10:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/10] oom: don't try to kill oom_unkillable child
In-Reply-To: <20100608205343.767D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081210180.23776@chino.kir.corp.google.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608205343.767D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> Now, badness() doesn't care neigher CPUSET nor mempolicy. Then
> if the victim child process is oom_unkillable()==1, __out_of_memory()
> can makes kernel hang eventually.
> 
> This patch fixes it.
> 
> 
> [remark: this is needed to fold "oom: sacrifice child with highest
> badness score for parent"]
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index d49d542..0d7397b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -387,9 +387,6 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
>  			      int verbose)
>  {
> -	if (oom_unkillable(p, mem))
> -		return 1;
> -
>  	p = find_lock_task_mm(p);
>  	if (!p)
>  		return 1;
> @@ -440,6 +437,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  
>  			if (c->mm == p->mm)
>  				continue;
> +			if (oom_unkillable(c, mem, nodemask))
> +				continue;
>  
>  			/* badness() returns 0 if the thread is unkillable */
>  			cpoints = badness(c, uptime.tv_sec);

This doesn't apply to anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

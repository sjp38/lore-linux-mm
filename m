Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 705ED6B009B
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:06:32 -0500 (EST)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id oB1I6SRC021011
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 18:06:28 GMT
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB1I6SAb2789500
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 18:06:28 GMT
Received: from d06av11.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB1I6R7A010139
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 11:06:28 -0700
Subject: Re: [thisops uV3 08/18] Taskstats: Use this_cpu_ops
From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Reply-To: holzheu@linux.vnet.ibm.com
In-Reply-To: <20101130190845.819605614@linux.com>
References: <20101130190707.457099608@linux.com>
	 <20101130190845.819605614@linux.com>
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 01 Dec 2010 19:06:26 +0100
Message-ID: <1291226786.2898.22.camel@holzheu-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello Christoph,

On Tue, 2010-11-30 at 13:07 -0600, Christoph Lameter wrote:
> plain text document attachment (this_cpu_taskstats)
> Use this_cpu_inc_return in one place and avoid ugly __raw_get_cpu in another.
> 
> Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  kernel/taskstats.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/kernel/taskstats.c
> ===================================================================
> --- linux-2.6.orig/kernel/taskstats.c	2010-11-30 10:06:35.000000000 -0600
> +++ linux-2.6/kernel/taskstats.c	2010-11-30 10:10:14.000000000 -0600
> @@ -89,8 +89,7 @@ static int prepare_reply(struct genl_inf
>  		return -ENOMEM;
> 
>  	if (!info) {
> -		int seq = get_cpu_var(taskstats_seqnum)++;
> -		put_cpu_var(taskstats_seqnum);
> +		int seq = this_cpu_inc_return(taskstats_seqnum);

Hmmm, wouldn't seq now always be one more than before?

I think that "seq = get_cpu_var(taskstats_seqnum)++" first assigns
taskstats_seqnum to seq and then increases the value in contrast to
this_cpu_inc_return() that returns the already increased value, correct?

Maybe that does not hurt here, Balbir?

>  		reply = genlmsg_put(skb, 0, seq, &family, 0, cmd);
>  	} else
> @@ -581,7 +580,7 @@ void taskstats_exit(struct task_struct *
>  		fill_tgid_exit(tsk);
>  	}
> 
> -	listeners = &__raw_get_cpu_var(listener_array);
> +	listeners = __this_cpu_ptr(listener_array);
>  	if (list_empty(&listeners->list))
>  		return;
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

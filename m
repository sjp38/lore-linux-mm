Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8276B0210
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 19:28:09 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o34NS5Tn014133
	for <linux-mm@kvack.org>; Mon, 5 Apr 2010 01:28:05 +0200
Received: from pzk8 (pzk8.prod.google.com [10.243.19.136])
	by wpaz17.hot.corp.google.com with ESMTP id o34NS3vR013741
	for <linux-mm@kvack.org>; Sun, 4 Apr 2010 16:28:04 -0700
Received: by pzk8 with SMTP id 8so5193pzk.16
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 16:28:03 -0700 (PDT)
Date: Sun, 4 Apr 2010 16:28:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004041627100.7198@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329140633.GA26464@desktop> <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
 <20100330142923.GA10099@desktop> <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com> <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com> <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
 <20100331063007.GN3308@balbir.in.ibm.com> <alpine.DEB.2.00.1003302331001.839@chino.kir.corp.google.com> <alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, David Rientjes wrote:

> It's pointless to try to kill current if select_bad_process() did not
> find an eligible task to kill in mem_cgroup_out_of_memory() since it's
> guaranteed that current is a member of the memcg that is oom and it is,
> by definition, unkillable.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -500,12 +500,9 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  	read_lock(&tasklist_lock);
>  retry:
>  	p = select_bad_process(&points, limit, mem, CONSTRAINT_NONE, NULL);
> -	if (PTR_ERR(p) == -1UL)
> +	if (!p || PTR_ERR(p) == -1UL)
>  		goto out;
>  
> -	if (!p)
> -		p = current;
> -
>  	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
>  				"Memory cgroup out of memory"))
>  		goto retry;
> 

Are there any objections to merging this?  It's pretty straight-forward 
given the fact that oom_kill_process() would fail if select_bad_process() 
returns NULL even if p is set to current since it was not found to be 
eligible during the tasklist scan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

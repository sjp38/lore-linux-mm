Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EC3BE6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 04:04:26 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2V84JUF028667
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 19:04:19 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2V84JKM831542
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 19:04:19 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2V84I4X023011
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 19:04:19 +1100
Date: Wed, 31 Mar 2010 13:34:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
Message-ID: <20100331080414.GO3308@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100329140633.GA26464@desktop>
 <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
 <20100330142923.GA10099@desktop>
 <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com>
 <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com>
 <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
 <20100331063007.GN3308@balbir.in.ibm.com>
 <alpine.DEB.2.00.1003302331001.839@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-03-31 00:08:38]:

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

Should we have a bit fat WAR_ON_ONCE() here?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

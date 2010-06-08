Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFD26B01D1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:51:52 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o58IpkUh026908
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:51:47 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by wpaz29.hot.corp.google.com with ESMTP id o58IpUEC024526
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:51:45 -0700
Received: by pwi6 with SMTP id 6so1833113pwi.28
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:51:45 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:51:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100608203342.7663.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081149320.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524310.32225@chino.kir.corp.google.com> <20100608203342.7663.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -184,14 +184,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  		points /= 4;
> >  
> >  	/*
> > -	 * If p's nodes don't overlap ours, it may still help to kill p
> > -	 * because p may have allocated or otherwise mapped memory on
> > -	 * this node before. However it will be less likely.
> > -	 */
> > -	if (!has_intersects_mems_allowed(p))
> > -		points /= 8;
> > -
> > -	/*
> >  	 * Adjust the score by oom_adj.
> >  	 */
> >  	if (oom_adj) {
> > @@ -277,6 +269,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >  			continue;
> >  		if (mem && !task_in_mem_cgroup(p, mem))
> >  			continue;
> > +		if (!has_intersects_mems_allowed(p))
> > +			continue;
> >  
> >  		/*
> >  		 * This task already has access to memory reserves and is
> 
> pulled. but I'll merge my fix. and append historical remark.
> 

Andrew, are you the maintainer for these fixes or is KOSAKI?

I've been posting this particular patch for at least three months with 
five acks:

Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Nick Piggin <npiggin@suse.de>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

and now he's saying he'll merge his own fix and rewrite the changelog and 
pull it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

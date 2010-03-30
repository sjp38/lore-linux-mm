Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 89CA46B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:29:38 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o2UKTYVQ007619
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:29:34 +0200
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz9.hot.corp.google.com with ESMTP id o2UKTWOr002830
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:29:32 -0700
Received: by pwi5 with SMTP id 5so8132142pwi.19
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:29:32 -0700 (PDT)
Date: Tue, 30 Mar 2010 13:29:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
In-Reply-To: <20100330142923.GA10099@desktop>
Message-ID: <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329140633.GA26464@desktop> <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com> <20100330142923.GA10099@desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: anfei <anfei.zhou@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, anfei wrote:

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index afeab2a..9aae208 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -588,12 +588,8 @@ retry:
> > >  	if (PTR_ERR(p) == -1UL)
> > >  		return;
> > >  
> > > -	/* Found nothing?!?! Either we hang forever, or we panic. */
> > > -	if (!p) {
> > > -		read_unlock(&tasklist_lock);
> > > -		dump_header(NULL, gfp_mask, order, NULL);
> > > -		panic("Out of memory and no killable processes...\n");
> > > -	}
> > > +	if (!p)
> > > +		p = current;
> > >  
> > >  	if (oom_kill_process(p, gfp_mask, order, points, NULL,
> > >  			     "Out of memory"))
> > 
> > The reason p wasn't selected is because it fails to meet the criteria for 
> > candidacy in select_bad_process(), not necessarily because of a race with 
> > the !p->mm check that the -mm patch cited above fixes.  It's quite 
> > possible that current has an oom_adj value of OOM_DISABLE, for example, 
> > where this would be wrong.
> 
> I see.  And what about changing mem_cgroup_out_of_memory() too?
> 

The memory controller is different because it must kill a task even if 
another task is exiting since the imposed limit has been reached.

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0cb1ca4..9e89a29 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -510,8 +510,10 @@ retry:
>  	if (PTR_ERR(p) == -1UL)
>  		goto out;
>  
> -	if (!p)
> -		p = current;
> +	if (!p) {
> +		read_unlock(&tasklist_lock);
> +		panic("Out of memory and no killable processes...\n");
> +	}
>  
>  	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
>  				"Memory cgroup out of memory"))
> 

This actually does appear to be necessary but for a different reason: if 
current is unkillable because it has OOM_DISABLE, for example, then 
oom_kill_process() will repeatedly fail and mem_cgroup_out_of_memory() 
will infinitely loop.

Kame-san?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D61C06B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 21:01:02 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V1103c002886
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 31 Mar 2010 10:01:00 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 27F2945DE52
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 10:01:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AD4845DE51
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 10:01:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E1241E38003
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 10:00:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AC7DE38004
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 10:00:59 +0900 (JST)
Date: Wed, 31 Mar 2010 09:57:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-Id: <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
	<20100326150805.f5853d1c.akpm@linux-foundation.org>
	<20100326223356.GA20833@redhat.com>
	<20100328145528.GA14622@desktop>
	<20100328162821.GA16765@redhat.com>
	<alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com>
	<20100329140633.GA26464@desktop>
	<alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
	<20100330142923.GA10099@desktop>
	<alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: anfei <anfei.zhou@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 13:29:29 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 0cb1ca4..9e89a29 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -510,8 +510,10 @@ retry:
> >  	if (PTR_ERR(p) == -1UL)
> >  		goto out;
> >  
> > -	if (!p)
> > -		p = current;
> > +	if (!p) {
> > +		read_unlock(&tasklist_lock);
> > +		panic("Out of memory and no killable processes...\n");
> > +	}
> >  
> >  	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
> >  				"Memory cgroup out of memory"))
> > 
> 
> This actually does appear to be necessary but for a different reason: if 
> current is unkillable because it has OOM_DISABLE, for example, then 
> oom_kill_process() will repeatedly fail and mem_cgroup_out_of_memory() 
> will infinitely loop.
> 
> Kame-san?
> 

When a memcg goes into OOM and it only has unkillable processes (OOM_DISABLE),
we can do nothing. (we can't panic because container's death != system death.)

Because memcg itself has mutex+waitqueue for mutual execusion of OOM killer, 
I think infinite-loop will not be critical probelm for the whole system.

And, now, memcg has oom-kill-disable + oom-kill-notifier features.
So, If a memcg goes into OOM and there is no killable process, but oom-kill is
not disabled by memcg.....it means system admin's mis-configuraton.

He can stop inifite loop by hand, anyway.
# echo 1 > ..../group_A/memory.oom_control

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

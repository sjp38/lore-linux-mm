Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 72AC76B0047
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 21:40:17 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n092eE1v025081
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Jan 2009 11:40:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E70D245DD72
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:40:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B8A5645DE53
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:40:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 88BB01DB8052
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:40:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 737BB1DB8044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 11:40:12 +0900 (JST)
Date: Fri, 9 Jan 2009 11:39:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/4] memcg: make oom less frequently
Message-Id: <20090109113910.5edcc8ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090109112922.68881c05.nishimura@mxp.nes.nec.co.jp>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191520.df9c1d92.nishimura@mxp.nes.nec.co.jp>
	<44480.10.75.179.62.1231413588.squirrel@webmail-b.css.fujitsu.com>
	<20090109104416.9bf4aab7.nishimura@mxp.nes.nec.co.jp>
	<20090109110358.8a0d991a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090109112922.68881c05.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 11:29:22 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > > @@ -870,8 +870,13 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  		if (!(gfp_mask & __GFP_WAIT))
> > >  			goto nomem;
> > >  
> > > +		if (signal_pending(current))
> > > +			goto oom;
> > > +
> > 
> > I think it's better to avoid to add this check *now*. and "signal is pending" 
> > doesn't mean oom situation.
> > 
> hmm.. charge is assumed to return 0 or -ENOMEM, what should we return on
> signal_pending case ?
> 
> In case of shmem for example, if charge at shmem_getpage fails by -ENOMEM, 
> shmem_fault returns VM_FAULT_OOM, so pagefault_out_of_memory would be called.
> If memcg had not invoked oom-killer, system wide oom would be invoked.
> 
yes, that's problem.

I think generic -EAGAIN support is appreciated. But it will not be for -rc ;)
(... that will make codes other than memcontrol.c more complicated.)

Thanks,
-Kame

> > Hmm..Maybe we can tell "please retry page fault again, it's too long latency in
> > memory reclaim and you received signal." in future.
> > 
> OK.
> 
> > IMHO, only quick path which we can add here now is
> > ==
> > 	if (test_thread_flag(TIG_MEMDIE)) { /* This thread is killed by OOM */
> > 		*memcg = NULL;
> > 		return 0;
> > 	}
> > ==
> > like this.
> > 
> > Anyway, please discuss this "quick exit path" in other patch and just remove 
> > siginal check.
> > 
> > Other part looks ok to me.
> > 
> Thanks :)
> 
> I'll update this one by removing the signal_pendign check.
> 
> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
